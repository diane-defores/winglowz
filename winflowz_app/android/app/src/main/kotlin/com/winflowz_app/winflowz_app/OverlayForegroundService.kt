package com.winflowz_app.winflowz_app

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
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import kotlin.math.abs

class OverlayForegroundService : Service() {
    companion object {
        const val ACTION_START = "com.winflowz_app.winflowz_app.overlay.START"
        const val ACTION_STOP = "com.winflowz_app.winflowz_app.overlay.STOP"
        const val ACTION_CANCEL = "com.winflowz_app.winflowz_app.overlay.CANCEL"
        const val ACTION_PAUSE = "com.winflowz_app.winflowz_app.overlay.PAUSE"
        const val ACTION_RESUME = "com.winflowz_app.winflowz_app.overlay.RESUME"
        const val ACTION_SET_STATE = "com.winflowz_app.winflowz_app.overlay.SET_STATE"
        const val ACTION_UPDATE_METER = "com.winflowz_app.winflowz_app.overlay.UPDATE_METER"
        const val ACTION_SET_RESULT_TEXT = "com.winflowz_app.winflowz_app.overlay.SET_RESULT_TEXT"
        const val ACTION_DELIVER_TEXT = "com.winflowz_app.winflowz_app.overlay.DELIVER_TEXT"
        const val ACTION_SET_APPEARANCE = "com.winflowz_app.winflowz_app.overlay.SET_APPEARANCE"
        const val EXTRA_STATE = "state"
        const val EXTRA_LEVEL = "level"
        const val EXTRA_TEXT = "text"
        const val EXTRA_SIZE_SCALE = "sizeScale"
        const val EXTRA_OPACITY = "opacity"

        private const val NOTIFICATION_ID = 71011
        private const val notificationChannelId = "winflowz_app_overlay_recording"
        private const val notificationChannelName = "WinFlowz Overlay Recording"
        private const val TAG = "WinFlowzOverlay"

        private const val defaultCollapsedWidth = 50
        private const val initialRightInset = 72
        private const val preferencesName = "winflowz_app_overlay_prefs"
        private const val keyOverlaySizeScale = "overlay_size_scale"
        private const val keyOverlayOpacity = "overlay_opacity"
        private const val keyOverlayX = "overlay_x"
        private const val keyOverlayY = "overlay_y"
        private const val dragLongPressDelayMs = 320L

        @Volatile
        private var running = false
        private var lastState = "not_created"

        @Synchronized
        fun isRunning(): Boolean = running

        @Synchronized
        fun serviceState(): String = lastState

        @Synchronized
        private fun updateServiceState(state: String) {
            lastState = state
        }
    }

    private var windowManager: WindowManager? = null
    private var overlayView: OverlayView? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private var isShowing = false
    private var isDragging = false
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var latestTouchX = 0f
    private var latestTouchY = 0f
    private var isDragArmed = false
    private var hasMovedPastTapSlop = false
    private var longPressRunnable: Runnable? = null
    private var pendingState = "collapsed"
    private var sizeScale = 1f
    private var overlayOpacity = 0.9f

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        updateServiceState("created")
        OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "created"))
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        loadAppearancePreferences()
        createNotificationChannelIfNeeded()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (isRunning() && !Settings.canDrawOverlays(this)) {
            OverlayEventQueue.enqueue("serviceError", mapOf("code" to "OVERLAY_PERMISSION_REVOKED"))
            updateServiceState("permission_revoked")
            handleStop()
            return START_NOT_STICKY
        }

        OverlayEventQueue.enqueue(
            "serviceCommand",
            mapOf("action" to (intent?.action ?: "null")),
        )
        when (intent?.action) {
            ACTION_START -> handleStart()
            ACTION_STOP -> handleStop()
            ACTION_CANCEL -> handleStop()
            ACTION_PAUSE -> handlePause()
            ACTION_RESUME -> handleResume()
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
        OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "destroyed"))
        updateServiceState("destroyed")
        hideOverlay()
        synchronized(this) {
            running = false
        }
        super.onDestroy()
    }

    private fun handleStart() {
        synchronized(this) {
            updateServiceState("start_requested")
            if (running) {
                OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "already_running"))
                ensureOverlay()
                setOverlayStateInternal("recording")
                return
            }
            if (!Settings.canDrawOverlays(this)) {
                OverlayEventQueue.enqueue(
                    "serviceError",
                    mapOf("code" to "OVERLAY_PERMISSION_MISSING"),
                )
                updateServiceState("permission_missing")
                return
            }
            if (!ensureForegroundNotification()) {
                updateServiceState("foreground_failed")
                return
            }
            if (!ensureOverlay()) {
                updateServiceState("overlay_add_failed")
                return
            }
            running = true
            setOverlayStateInternal("recording")
            OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "running"))
        }
    }

    private fun handleStop() {
        synchronized(this) {
            if (!running) {
                OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "stop_ignored_not_running"))
                updateServiceState("stopped")
                return
            }
            updateServiceState("stopping")
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
            updateServiceState("stopped")
            OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "stopped"))
        }
    }

    private fun handlePause() {
        synchronized(this) {
            if (!running) {
                OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "pause_ignored_not_running"))
                return
            }
            OverlayEventQueue.enqueue("recordPause")
            setOverlayStateInternal("paused")
        }
    }

    private fun handleResume() {
        synchronized(this) {
            if (!running) {
                OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "resume_ignored_not_running"))
                return
            }
            OverlayEventQueue.enqueue("recordResume")
            setOverlayStateInternal("recording")
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
            OverlayEventQueue.enqueue("serviceLifecycle", mapOf("state" to "foreground_started"))
            true
        } catch (error: Exception) {
            OverlayEventQueue.enqueue(
                "serviceError",
                mapOf(
                    "code" to "OVERLAY_FOREGROUND_START_FAILED",
                    "detail" to (error.message ?: error.javaClass.simpleName),
                ),
            )
            false
        }
    }

    private fun ensureOverlay(): Boolean {
        if (isShowing) {
            OverlayEventQueue.enqueue("overlayView", mapOf("state" to "already_showing"))
            return true
        }
        if (!Settings.canDrawOverlays(this)) {
            OverlayEventQueue.enqueue("serviceError", mapOf("code" to "OVERLAY_PERMISSION_MISSING"))
            return false
        }

        overlayView = OverlayView(this).apply {
            onBubbleTap = {
                OverlayEventQueue.enqueue("bubbleTap")
                toggleRecordingState()
            }
            onRecordStop = {
                OverlayEventQueue.enqueue("recordStop")
                setOverlayStateInternal("processing")
            }
            onRecordCancel = {
                OverlayEventQueue.enqueue("recordCancel")
                setOverlayStateInternal("collapsed")
            }
            onRecordPause = {
                OverlayEventQueue.enqueue("recordPause")
                setOverlayStateInternal("paused")
            }
            onRecordResume = {
                OverlayEventQueue.enqueue("recordResume")
                setOverlayStateInternal("recording")
            }
            onBubbleLongPress = {
                OverlayEventQueue.enqueue("longPress")
                toggleRecordingState()
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
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            val savedPosition = loadPositionPreference()
            x = savedPosition?.first
                ?: resources.displayMetrics.widthPixels - (initialRightInset + defaultCollapsedWidth)
            y = savedPosition?.second
                ?: (resources.displayMetrics.heightPixels * 0.6).toInt()
            alpha = overlayOpacity
        }
        clampToScreen()

        overlayView?.setState(pendingState)
        overlayView?.setSizeScale(sizeScale)
        setWindowStateForOverlay(pendingState)
        attachTouchListener()
        try {
            windowManager?.addView(overlayView, layoutParams)
            isShowing = true
            OverlayEventQueue.enqueue(
                "overlayView",
                mapOf(
                    "state" to "shown",
                    "x" to (layoutParams?.x ?: -1),
                    "y" to (layoutParams?.y ?: -1),
                ),
            )
            return true
        } catch (error: Exception) {
            OverlayEventQueue.enqueue(
                "serviceError",
                mapOf(
                    "code" to "OVERLAY_VIEW_ADD_FAILED",
                    "detail" to (error.message ?: error.javaClass.simpleName),
                ),
            )
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
        overlayView?.setDragHandleTouchListener(null)
        overlayView?.setOnTouchListener(null)
        try {
            windowManager?.removeView(overlayView)
        } catch (error: Exception) {
            OverlayEventQueue.enqueue(
                "serviceError",
                mapOf(
                    "code" to "OVERLAY_VIEW_REMOVE_FAILED",
                    "detail" to (error.message ?: error.javaClass.simpleName),
                ),
            )
        }
        overlayView = null
        layoutParams = null
        isShowing = false
    }

    private fun attachTouchListener() {
        val dragHandleTouchListener = View.OnTouchListener { _, event ->
            handleDragTouch(
                event,
                triggerTapOnRelease = false,
                requireLongPressToDrag = false,
            )
        }
        overlayView?.setOnTouchListener { _, event ->
            val state = overlayView?.getCurrentState() ?: "collapsed"
            if (state != "collapsed") {
                return@setOnTouchListener false
            }
            handleDragTouch(
                event,
                triggerTapOnRelease = true,
                requireLongPressToDrag = true,
            )
        }
        overlayView?.setDragHandleTouchListener(dragHandleTouchListener)
    }

    private fun handleDragTouch(
        event: MotionEvent,
        triggerTapOnRelease: Boolean,
        requireLongPressToDrag: Boolean,
    ): Boolean {
        return when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                layoutParams?.let { params ->
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    latestTouchX = event.rawX
                    latestTouchY = event.rawY
                    isDragging = false
                    isDragArmed = !requireLongPressToDrag
                    hasMovedPastTapSlop = false
                    if (requireLongPressToDrag) {
                        longPressRunnable?.let { overlayView?.removeCallbacks(it) }
                        longPressRunnable = Runnable {
                            val currentParams = layoutParams ?: return@Runnable
                            initialX = currentParams.x
                            initialY = currentParams.y
                            initialTouchX = latestTouchX
                            initialTouchY = latestTouchY
                            isDragArmed = true
                            overlayView?.performHapticFeedback(HapticFeedbackConstants.LONG_PRESS)
                            OverlayEventQueue.enqueue("overlayDragMode", mapOf("state" to "armed"))
                        }
                        overlayView?.postDelayed(longPressRunnable, dragLongPressDelayMs)
                    } else {
                        longPressRunnable = null
                    }
                    overlayView?.parent?.requestDisallowInterceptTouchEvent(true)
                    true
                } ?: false
            }
            MotionEvent.ACTION_MOVE -> {
                val params = layoutParams ?: return false
                latestTouchX = event.rawX
                latestTouchY = event.rawY
                val dragSlop = resources.displayMetrics.density * 8f
                val totalDx = event.rawX - initialTouchX
                val totalDy = event.rawY - initialTouchY
                if (!hasMovedPastTapSlop && (abs(totalDx) > dragSlop || abs(totalDy) > dragSlop)) {
                    hasMovedPastTapSlop = true
                }
                if (requireLongPressToDrag && !isDragArmed) {
                    return true
                }
                val dx = event.rawX - initialTouchX
                val dy = event.rawY - initialTouchY
                if (!isDragging && (abs(dx) > dragSlop || abs(dy) > dragSlop)) {
                    isDragging = true
                    longPressRunnable?.let { overlayView?.removeCallbacks(it) }
                }
                if (isDragging) {
                    params.x = initialX + dx.toInt()
                    params.y = initialY + dy.toInt()
                    try {
                        windowManager?.updateViewLayout(overlayView, params)
                    } catch (_: Exception) {
                        // Keep touch handling stable if this transiently fails.
                    }
                }
                true
            }
            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_CANCEL -> {
                longPressRunnable?.let { overlayView?.removeCallbacks(it) }

                if (isDragging) {
                    clampToScreen()
                    savePositionPreference()
                } else if (
                    triggerTapOnRelease &&
                    event.actionMasked == MotionEvent.ACTION_UP &&
                    !isDragArmed &&
                    !hasMovedPastTapSlop
                ) {
                    overlayView?.performClick()
                }
                isDragging = false
                isDragArmed = false
                hasMovedPastTapSlop = false
                longPressRunnable = null
                overlayView?.parent?.requestDisallowInterceptTouchEvent(false)
                true
            }
            else -> false
        }
    }

    private fun setWindowStateForOverlay(state: String) {
        val params = layoutParams ?: return
        params.flags =
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        params.alpha = overlayOpacity
        try {
            windowManager?.updateViewLayout(overlayView, params)
        } catch (_: Exception) {
            // ignore
        }
    }

    private fun toggleRecordingState() {
        val current = overlayView?.getCurrentState() ?: pendingState
        if (current == "recording") {
            OverlayEventQueue.enqueue("recordStop")
            setOverlayStateInternal("processing")
        } else {
            setOverlayStateInternal("recording")
        }
    }

    private fun setOverlayStateInternal(state: String?) {
        val normalized = normalizeState(state ?: "collapsed")
        pendingState = normalized
        updateServiceState(normalized)
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
        overlayOpacity = preferences.getFloat(keyOverlayOpacity, 0.9f).coerceIn(0.5f, 1f)
    }

    private fun loadPositionPreference(): Pair<Int, Int>? {
        val preferences = getSharedPreferences(preferencesName, MODE_PRIVATE)
        if (!preferences.contains(keyOverlayX) || !preferences.contains(keyOverlayY)) {
            return null
        }
        val x = preferences.getInt(keyOverlayX, 0)
        val y = preferences.getInt(keyOverlayY, 0)
        return Pair(x, y)
    }

    private fun savePositionPreference() {
        val params = layoutParams ?: return
        getSharedPreferences(preferencesName, MODE_PRIVATE)
            .edit()
            .putInt(keyOverlayX, params.x)
            .putInt(keyOverlayY, params.y)
            .apply()
        OverlayEventQueue.enqueue(
            "overlayPosition",
            mapOf("x" to params.x, "y" to params.y),
        )
    }

    private fun normalizeState(state: String): String {
        return when (state) {
            "collapsed", "recording", "paused", "processing", "result" -> state
            else -> "collapsed"
        }
    }

    private fun clampToScreen() {
        val params = layoutParams ?: return
        val viewWidth = overlayView?.width ?: defaultCollapsedWidth
        val viewHeight = overlayView?.height ?: defaultCollapsedWidth
        val screenWidth = resources.displayMetrics.widthPixels
        val screenHeight = resources.displayMetrics.heightPixels
        params.x = params.x.coerceIn(0, (screenWidth - viewWidth).coerceAtLeast(0))
        params.y = params.y.coerceIn(0, (screenHeight - viewHeight).coerceAtLeast(0))
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
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
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
            .setContentTitle("WinFlowz overlay")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
}
