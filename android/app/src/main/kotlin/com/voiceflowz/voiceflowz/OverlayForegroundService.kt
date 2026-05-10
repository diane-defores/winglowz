package com.voiceflowz.voiceflowz

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager

class OverlayForegroundService : Service() {
    companion object {
        const val ACTION_START = "com.voiceflowz.voiceflowz.overlay.START"
        const val ACTION_STOP = "com.voiceflowz.voiceflowz.overlay.STOP"
        const val ACTION_CANCEL = "com.voiceflowz.voiceflowz.overlay.CANCEL"
        const val ACTION_SET_STATE = "com.voiceflowz.voiceflowz.overlay.SET_STATE"
        const val ACTION_UPDATE_METER = "com.voiceflowz.voiceflowz.overlay.UPDATE_METER"
        const val ACTION_SET_RESULT_TEXT = "com.voiceflowz.voiceflowz.overlay.SET_RESULT_TEXT"
        const val ACTION_DELIVER_TEXT = "com.voiceflowz.voiceflowz.overlay.DELIVER_TEXT"
        const val ACTION_SET_APPEARANCE = "com.voiceflowz.voiceflowz.overlay.SET_APPEARANCE"
        const val EXTRA_STATE = "state"
        const val EXTRA_LEVEL = "level"
        const val EXTRA_TEXT = "text"
        const val EXTRA_SIZE_SCALE = "sizeScale"
        const val EXTRA_OPACITY = "opacity"

        private const val NOTIFICATION_ID = 71011
        private const val notificationChannelId = "voiceflowz_overlay_recording"
        private const val notificationChannelName = "VoiceFlowz Overlay Recording"
        private const val HOLD_TO_RECORD_DELAY_MS = 220L
        private const val TAG = "VoiceFlowzOverlay"

        private const val maxXOffset = 16
        private const val defaultCollapsedWidth = 44
        private const val preferencesName = "voiceflowz_overlay_prefs"
        private const val keyOverlaySizeScale = "overlay_size_scale"
        private const val keyOverlayOpacity = "overlay_opacity"

        @Volatile
        private var running = false

        @Synchronized
        fun isRunning(): Boolean = running
    }

    private var windowManager: WindowManager? = null
    private var overlayView: OverlayView? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private var isShowing = false
    private var isDragging = false
    private var isHoldRecording = false
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var longPressRunnable: Runnable? = null
    private var pendingState = "collapsed"
    private var sizeScale = 1f
    private var overlayOpacity = 0.8f

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        loadAppearancePreferences()
        createNotificationChannelIfNeeded()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (isRunning() && !Settings.canDrawOverlays(this)) {
            OverlayEventQueue.enqueue("serviceError", mapOf("code" to "OVERLAY_PERMISSION_REVOKED"))
            handleStop()
            return START_NOT_STICKY
        }

        when (intent?.action) {
            ACTION_START -> handleStart()
            ACTION_STOP -> handleStop()
            ACTION_CANCEL -> handleStop()
            ACTION_SET_STATE -> handleSetState(intent.getStringExtra(EXTRA_STATE))
            ACTION_UPDATE_METER -> handleUpdateMeter(
                intent.getFloatExtra(EXTRA_LEVEL, 0f),
            )
            ACTION_SET_RESULT_TEXT -> handleSetResultText(
                intent.getStringExtra(EXTRA_TEXT) ?: "",
            )
            ACTION_DELIVER_TEXT -> {
                val text = intent.getStringExtra(EXTRA_TEXT).orEmpty()
                handleDeliverText(text)
            }
            ACTION_SET_APPEARANCE -> handleSetAppearance(
                intent.getFloatExtra(EXTRA_SIZE_SCALE, sizeScale),
                intent.getFloatExtra(EXTRA_OPACITY, overlayOpacity),
            )
            else -> Log.w(TAG, "Overlay service action ignored: ${intent?.action ?: "null"}")
        }
        return START_STICKY
    }

    override fun onDestroy() {
        Log.i(TAG, "Overlay service destroyed.")
        hideOverlay()
        synchronized(this) {
            running = false
        }
        super.onDestroy()
    }

    private fun handleStart() {
        synchronized(this) {
            if (running) {
                ensureOverlay()
                return
            }
            if (!Settings.canDrawOverlays(this)) {
                OverlayEventQueue.enqueue(
                    "serviceError",
                    mapOf("code" to "OVERLAY_PERMISSION_MISSING"),
                )
                return
            }
            if (!ensureForegroundNotification()) {
                return
            }
            if (!ensureOverlay()) {
                return
            }
            running = true
        }
    }

    private fun handleStop() {
        synchronized(this) {
            if (!running) {
                return
            }
            hideOverlay()
            setOverlayStateInternal("collapsed")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                stopForeground(STOP_FOREGROUND_REMOVE)
            } else {
                @Suppress("DEPRECATION")
                stopForeground(true)
            }
            stopSelf()
            running = false
        }
    }

    private fun handleUpdateMeter(level: Float) {
        overlayView?.post {
            overlayView?.updateMeter(level)
        }
    }

    private fun handleSetResultText(text: String) {
        if (text.isBlank()) {
            return
        }
        overlayView?.post { overlayView?.showResult() }
    }

    private fun handleDeliverText(text: String) {
        OverlayTextInjectionHelper.deliverText(this, text)
    }

    private fun ensureForegroundNotification(): Boolean {
        return try {
            startForegroundCompat(buildNotification("Tap the floating button to dictate"))
            true
        } catch (_: Exception) {
            OverlayEventQueue.enqueue(
                "serviceError",
                mapOf("code" to "OVERLAY_FOREGROUND_START_FAILED"),
            )
            false
        }
    }

    private fun ensureOverlay(): Boolean {
        if (isShowing) {
            return true
        }
        if (!Settings.canDrawOverlays(this)) {
            OverlayEventQueue.enqueue("serviceError", mapOf("code" to "OVERLAY_PERMISSION_MISSING"))
            return false
        }

        overlayView = OverlayView(this).apply {
            onBubbleTap = {
                OverlayEventQueue.enqueue("bubbleTap")
                setOverlayStateInternal("recording")
            }
            onRecordStop = {
                OverlayEventQueue.enqueue("recordStop")
                setOverlayStateInternal("processing")
            }
            onRecordCancel = {
                OverlayEventQueue.enqueue("recordCancel")
                setOverlayStateInternal("collapsed")
            }
            onBubbleLongPress = {
                OverlayEventQueue.enqueue("longPress")
                setOverlayStateInternal("recording")
            }
        }

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = resources.displayMetrics.widthPixels - (maxXOffset + defaultCollapsedWidth)
            y = (resources.displayMetrics.heightPixels * 0.6).toInt()
            alpha = 0.8f
        }

        overlayView?.setState(pendingState)
        overlayView?.setSizeScale(sizeScale)
        setWindowStateForOverlay(pendingState)
        attachTouchListener()
        try {
            windowManager?.addView(overlayView, layoutParams)
            isShowing = true
            return true
        } catch (_: Exception) {
            OverlayEventQueue.enqueue("serviceError", mapOf("code" to "OVERLAY_VIEW_ADD_FAILED"))
            overlayView = null
            layoutParams = null
            return false
        }
    }

    private fun hideOverlay() {
        if (!isShowing) {
            return
        }
        longPressRunnable?.let { runnable ->
            overlayView?.removeCallbacks(runnable)
            longPressRunnable = null
        }
        try {
            windowManager?.removeView(overlayView)
        } catch (_: Exception) {
            // best effort cleanup
        }
        overlayView?.post {
            overlayView?.setOnTouchListener(null)
        }
        overlayView = null
        layoutParams = null
        isShowing = false
    }

    private fun attachTouchListener() {
        overlayView?.setOnTouchListener { _, event ->
            val state = overlayView?.getCurrentState() ?: "collapsed"
            if (state != "collapsed") {
                return@setOnTouchListener false
            }
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    layoutParams?.let { params ->
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isDragging = false
                        isHoldRecording = false

                        longPressRunnable?.let { view ->
                            overlayView?.removeCallbacks(view)
                        }
                        longPressRunnable = Runnable {
                            if (!isDragging) {
                                isHoldRecording = true
                                overlayView?.emitLongPress()
                            }
                        }
                        overlayView?.postDelayed(longPressRunnable, HOLD_TO_RECORD_DELAY_MS)
                        true
                    } ?: false
                }
                MotionEvent.ACTION_MOVE -> {
                    val params = layoutParams ?: return@setOnTouchListener false
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY
                    if (!isDragging && (kotlin.math.abs(dx) > 10 || kotlin.math.abs(dy) > 10)) {
                        isDragging = true
                        isHoldRecording = false
                        longPressRunnable?.let { overlayView?.removeCallbacks(it) }
                    }
                    if (isDragging) {
                        params.x = initialX + dx.toInt()
                        params.y = initialY + dy.toInt()
                        try {
                            windowManager?.updateViewLayout(overlayView, params)
                        } catch (_: Exception) {
                            // keep touch handling stable if this fails once
                        }
                    }
                    true
                }
                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL -> {
                    longPressRunnable?.let { overlayView?.removeCallbacks(it) }

                    if (isDragging) {
                        snapToEdge()
                    } else if (isHoldRecording) {
                        overlayView?.onRecordStop?.let { onRecordStop ->
                            onRecordStop()
                        }
                    } else {
                        overlayView?.performClick()
                    }
                    isDragging = false
                    isHoldRecording = false
                    true
                }
                else -> false
            }
        }
    }

    private fun setWindowStateForOverlay(state: String) {
        val params = layoutParams ?: return
        params.flags =
            if (state == "collapsed") {
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            } else {
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            }
        params.alpha = overlayOpacity
        try {
            windowManager?.updateViewLayout(overlayView, params)
        } catch (_: Exception) {
            // ignore
        }
    }

    private fun setOverlayStateInternal(state: String?) {
        val normalized = normalizeState(state ?: "collapsed")
        pendingState = normalized
        overlayView?.post {
            overlayView?.setState(normalized)
            setWindowStateForOverlay(normalized)
        }
    }

    private fun handleSetState(state: String?) {
        setOverlayStateInternal(state)
    }

    private fun handleSetAppearance(nextSizeScale: Float, nextOpacity: Float) {
        sizeScale = nextSizeScale.coerceIn(0.8f, 1.4f)
        overlayOpacity = nextOpacity.coerceIn(0.5f, 1f)
        overlayView?.post {
            overlayView?.setSizeScale(sizeScale)
            setWindowStateForOverlay(pendingState)
        }
    }

    private fun loadAppearancePreferences() {
        val preferences = getSharedPreferences(preferencesName, MODE_PRIVATE)
        sizeScale = preferences.getFloat(keyOverlaySizeScale, 1f).coerceIn(0.8f, 1.4f)
        overlayOpacity = preferences.getFloat(keyOverlayOpacity, 0.8f).coerceIn(0.5f, 1f)
    }

    private fun normalizeState(state: String): String {
        return when (state) {
            "collapsed", "recording", "processing", "result" -> state
            else -> "collapsed"
        }
    }

    private fun snapToEdge() {
        val params = layoutParams ?: return
        val viewWidth = overlayView?.width ?: defaultCollapsedWidth
        val screenWidth = resources.displayMetrics.widthPixels
        params.x = if (params.x + viewWidth / 2 < screenWidth / 2) {
            maxXOffset
        } else {
            screenWidth - viewWidth - maxXOffset
        }
        try {
            windowManager?.updateViewLayout(overlayView, params)
        } catch (_: Exception) {
            // ignore
        }
    }

    private fun startForegroundCompat(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createNotificationChannelIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager = getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(notificationChannelId) != null) {
            return
        }
        val channel = NotificationChannel(
            notificationChannelId,
            notificationChannelName,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Foreground notification while overlay is active."
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(contentText: String): Notification {
        val launchIntent =
            packageManager.getLaunchIntentForPackage(packageName)
                ?: Intent(this, MainActivity::class.java)
        val pendingIntent =
            PendingIntent.getActivity(
                this,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        val builder =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, notificationChannelId)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
            }
        return builder
            .setContentTitle("VoiceFlowz overlay")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
}
