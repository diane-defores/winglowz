package com.voiceflowz.voiceflowz

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import android.view.inputmethod.InputMethodManager
import com.voiceflowz.voiceflowz.ime.KeyboardClipboardEventQueue
import com.voiceflowz.voiceflowz.ime.KeyboardStateStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "voiceflowz/overlay"
    private val keyboardChannelName = "voiceflowz/keyboard"
    private val preferencesName = "voiceflowz_overlay_prefs"
    private val keyOverlayEnabled = "overlay_enabled"
    private val keyOverlaySizeScale = "overlay_size_scale"
    private val keyOverlayOpacity = "overlay_opacity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isOverlayPermissionGranted" -> {
                        result.success(isOverlayPermissionGranted())
                    }
                    "isAccessibilityPermissionGranted" -> {
                        result.success(isAccessibilityPermissionGranted())
                    }
                    "openOverlayPermissionSettings" -> {
                        openOverlayPermissionSettings()
                        result.success(true)
                    }
                    "openAccessibilitySettings" -> {
                        openAccessibilitySettings()
                        result.success(true)
                    }
                    "drainOverlayEvents" -> {
                        result.success(OverlayEventQueue.drain())
                    }
                    "setOverlayEnabled" -> {
                        val requestedEnabled =
                            call.argument<Boolean>("enabled") ?: false
                        if (requestedEnabled && !isOverlayPermissionGranted()) {
                            result.error(
                                "OVERLAY_PERMISSION_DENIED",
                                "Overlay permission is required before enabling overlay.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        setOverlayEnabled(requestedEnabled)
                        result.success(buildStatusMap())
                    }
                    "setOverlayAppearance" -> {
                        val sizeScale =
                            call.argument<Number>("sizeScale")?.toFloat()
                                ?: overlaySizeScale()
                        val opacity =
                            call.argument<Number>("opacity")?.toFloat()
                                ?: overlayOpacity()
                        setOverlayAppearance(sizeScale, opacity)
                        result.success(buildStatusMap())
                    }
                    "getOverlayStatus" -> {
                        result.success(buildStatusMap())
                    }
                    "startOverlayRecording" -> {
                        if (!isOverlayPermissionGranted()) {
                            result.error(
                                "OVERLAY_PERMISSION_DENIED",
                                "Overlay permission is required to start overlay recording.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        if (!isOverlayEnabled()) {
                            result.error(
                                "OVERLAY_DISABLED",
                                "Overlay must be enabled before starting overlay recording.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        try {
                            sendOverlayCommand(OverlayForegroundService.ACTION_START)
                            result.success(buildStatusMap())
                        } catch (error: Exception) {
                            result.error(
                                "OVERLAY_START_FAILED",
                                "Unable to start overlay service.",
                                error.message,
                            )
                        }
                    }
                    "stopOverlayRecording" -> {
                        sendOverlayCommand(OverlayForegroundService.ACTION_STOP)
                        result.success(buildStatusMap())
                    }
                    "cancelOverlayRecording" -> {
                        sendOverlayCommand(OverlayForegroundService.ACTION_CANCEL)
                        result.success(buildStatusMap())
                    }
                    "setOverlayState" -> {
                        val state = call.argument<String>("state") ?: "collapsed"
                        sendOverlayCommand(
                            OverlayForegroundService.ACTION_SET_STATE,
                        ) { intent ->
                            intent.putExtra(OverlayForegroundService.EXTRA_STATE, state)
                        }
                        result.success(true)
                    }
                    "updateMeterLevel" -> {
                        val level =
                            call.argument<Number>("level")?.toFloat() ?: 0f
                        sendOverlayCommand(
                            OverlayForegroundService.ACTION_UPDATE_METER,
                        ) { intent ->
                            intent.putExtra(
                                OverlayForegroundService.EXTRA_LEVEL,
                                level,
                            )
                        }
                        result.success(true)
                    }
                    "setResultText" -> {
                        val text = call.argument<String>("text") ?: ""
                        sendOverlayCommand(
                            OverlayForegroundService.ACTION_SET_RESULT_TEXT,
                        ) { intent ->
                            intent.putExtra(OverlayForegroundService.EXTRA_TEXT, text)
                        }
                        result.success(true)
                    }
                    "deliverText" -> {
                        val text = call.argument<String>("text") ?: ""
                        if (text.isBlank()) {
                            result.success(
                                mapOf(
                                    "injected" to false,
                                    "clipboardCopied" to false,
                                    "sensitiveField" to false,
                                ),
                            )
                        } else {
                            result.success(OverlayTextInjectionHelper.deliverText(this, text))
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, keyboardChannelName)
            .setMethodCallHandler { call, result ->
                val keyboardState = KeyboardStateStore(this)
                when (call.method) {
                    "getKeyboardStatus" -> {
                        result.success(keyboardState.buildStatusMap())
                    }
                    "drainKeyboardClipboardEvents" -> {
                        result.success(KeyboardClipboardEventQueue.drain())
                    }
                    "openInputMethodSettings" -> {
                        openInputMethodSettings()
                        result.success(true)
                    }
                    "showInputMethodPicker" -> {
                        showInputMethodPicker()
                        result.success(true)
                    }
                    "setKeyboardPreferences" -> {
                        call.argument<Boolean>("voiceEnabled")?.let {
                            keyboardState.voiceEnabled = it
                        }
                        call.argument<Boolean>("clipboardSyncDesired")?.let {
                            keyboardState.clipboardSyncDesired = it
                        }
                        call.argument<Boolean>("mediaControlsEnabled")?.let {
                            keyboardState.mediaControlsEnabled = it
                        }
                        call.argument<String>("privacyMode")?.let {
                            keyboardState.privacyMode = it
                        }
                        result.success(keyboardState.buildStatusMap())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun sendOverlayCommand(
        action: String,
        fillIntent: ((Intent) -> Unit)? = null,
    ) {
        val intent = Intent(this, OverlayForegroundService::class.java).apply {
            this.action = action
            fillIntent?.invoke(this)
        }
        if (action == OverlayForegroundService.ACTION_START &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
        ) {
            startForegroundService(intent)
            return
        }
        startService(intent)
    }

    private fun isOverlayPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun openOverlayPermissionSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return
        }
        val intent =
            Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName"),
            )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun openInputMethodSettings() {
        val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun showInputMethodPicker() {
        val manager = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        manager.showInputMethodPicker()
    }

    private fun isAccessibilityPermissionGranted(): Boolean {
        val expectedComponent = ComponentName(this, OverlayAccessibilityService::class.java)
        val expected = expectedComponent.flattenToString()
        val enabledServices =
            Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
            ) ?: return false
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        while (splitter.hasNext()) {
            val enabledService = splitter.next()
            if (enabledService.equals(expected, ignoreCase = true)) {
                return true
            }
        }
        return false
    }

    private fun overlayPreferences() = getSharedPreferences(preferencesName, MODE_PRIVATE)

    private fun isOverlayEnabled(): Boolean =
        overlayPreferences().getBoolean(keyOverlayEnabled, false)

    private fun overlaySizeScale(): Float =
        overlayPreferences().getFloat(keyOverlaySizeScale, 1f)

    private fun overlayOpacity(): Float =
        overlayPreferences().getFloat(keyOverlayOpacity, 0.8f)

    private fun setOverlayEnabled(enabled: Boolean) {
        overlayPreferences().edit().putBoolean(keyOverlayEnabled, enabled).apply()
        if (enabled) {
            sendOverlayCommand(OverlayForegroundService.ACTION_START)
        } else {
            stopOverlayForegroundService(cancel = false)
        }
    }

    private fun setOverlayAppearance(sizeScale: Float, opacity: Float) {
        val normalizedSizeScale = sizeScale.coerceIn(0.8f, 1.4f)
        val normalizedOpacity = opacity.coerceIn(0.5f, 1f)
        overlayPreferences()
            .edit()
            .putFloat(keyOverlaySizeScale, normalizedSizeScale)
            .putFloat(keyOverlayOpacity, normalizedOpacity)
            .apply()
        sendOverlayCommand(OverlayForegroundService.ACTION_SET_APPEARANCE) { intent ->
            intent.putExtra(OverlayForegroundService.EXTRA_SIZE_SCALE, normalizedSizeScale)
            intent.putExtra(OverlayForegroundService.EXTRA_OPACITY, normalizedOpacity)
        }
    }

    private fun stopOverlayForegroundService(cancel: Boolean) {
        sendOverlayCommand(
            if (cancel) {
                OverlayForegroundService.ACTION_CANCEL
            } else {
                OverlayForegroundService.ACTION_STOP
            },
        )
    }

    private fun buildStatusMap(): Map<String, Any> {
        val overlayPermissionGranted = isOverlayPermissionGranted()
        val accessibilityPermissionGranted = isAccessibilityPermissionGranted()
        val requestedEnabled = isOverlayEnabled()
        var running = OverlayForegroundService.isRunning()
        val enabled = requestedEnabled && overlayPermissionGranted
        if (!enabled && running) {
            stopOverlayForegroundService(cancel = false)
            running = false
        }
        val mode =
            if (accessibilityPermissionGranted) {
                "injection_and_clipboard"
            } else {
                "clipboard_only"
            }
        return mapOf(
            "enabled" to enabled,
            "requestedEnabled" to requestedEnabled,
            "running" to running,
            "overlayPermissionGranted" to overlayPermissionGranted,
            "accessibilityPermissionGranted" to accessibilityPermissionGranted,
            "deliveryMode" to mode,
            "sizeScale" to overlaySizeScale(),
            "opacity" to overlayOpacity(),
        )
    }
}
