package com.winflowz_app.winflowz_app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.Manifest
import android.provider.Settings
import android.text.TextUtils
import android.view.inputmethod.InputMethodManager
import com.winflowz_app.winflowz_app.ime.KeyboardClipboardEventQueue
import com.winflowz_app.winflowz_app.ime.KeyboardLayoutProfile
import com.winflowz_app.winflowz_app.ime.KeyboardStateStore
import com.winflowz_app.winflowz_app.ime.KeyboardTextRule
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "winflowz_app/overlay"
    private val keyboardChannelName = "winflowz_app/keyboard"
    private val preferencesName = "winflowz_app_overlay_prefs"
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
                    "openAppSettings" -> {
                        openApplicationSettings()
                        result.success(true)
                    }
                    "drainOverlayEvents" -> {
                        result.success(OverlayEventQueue.drain())
                    }
                    "setOverlayEnabled" -> {
                        val requestedEnabled =
                            call.argument<Boolean>("enabled") ?: false
                        OverlayEventQueue.enqueue(
                            "bridgeCall",
                            mapOf(
                                "method" to "setOverlayEnabled",
                                "enabled" to requestedEnabled,
                            ),
                        )
                        if (requestedEnabled && !isOverlayPermissionGranted()) {
                            OverlayEventQueue.enqueue(
                                "bridgeError",
                                mapOf("code" to "OVERLAY_PERMISSION_DENIED"),
                            )
                            result.error(
                                "OVERLAY_PERMISSION_DENIED",
                                "Overlay permission is required before enabling overlay.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        try {
                            setOverlayEnabled(requestedEnabled)
                            result.success(buildStatusMap())
                        } catch (error: Exception) {
                            OverlayEventQueue.enqueue(
                                "bridgeError",
                                mapOf(
                                    "code" to "OVERLAY_TOGGLE_FAILED",
                                    "detail" to (error.message ?: error.javaClass.simpleName),
                                ),
                            )
                            result.error(
                                "OVERLAY_TOGGLE_FAILED",
                                "Unable to toggle overlay service.",
                                error.message,
                            )
                        }
                    }
                    "setOverlayAppearance" -> {
                        val sizeScale =
                            call.argument<Number>("sizeScale")?.toFloat()
                                ?: overlaySizeScale()
                        val opacity =
                            call.argument<Number>("opacity")?.toFloat()
                                ?: overlayOpacity()
                        OverlayEventQueue.enqueue(
                            "bridgeCall",
                            mapOf(
                                "method" to "setOverlayAppearance",
                                "sizeScale" to sizeScale,
                                "opacity" to opacity,
                            ),
                        )
                        setOverlayAppearance(sizeScale, opacity)
                        result.success(buildStatusMap())
                    }
                    "getOverlayStatus" -> {
                        result.success(buildStatusMap())
                    }
                    "startOverlayRecording" -> {
                        OverlayEventQueue.enqueue(
                            "bridgeCall",
                            mapOf("method" to "startOverlayRecording"),
                        )
                        if (!isOverlayPermissionGranted()) {
                            OverlayEventQueue.enqueue(
                                "bridgeError",
                                mapOf("code" to "OVERLAY_PERMISSION_DENIED"),
                            )
                            result.error(
                                "OVERLAY_PERMISSION_DENIED",
                                "Overlay permission is required to start overlay recording.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        if (!isOverlayEnabled()) {
                            overlayPreferences()
                                .edit()
                                .putBoolean(keyOverlayEnabled, true)
                                .apply()
                            OverlayEventQueue.enqueue(
                                "overlayPreference",
                                mapOf(
                                    "enabled" to true,
                                    "source" to "startOverlayRecording",
                                ),
                            )
                        }
                        try {
                            sendOverlayCommand(OverlayForegroundService.ACTION_START)
                            result.success(buildStatusMap())
                        } catch (error: Exception) {
                            OverlayEventQueue.enqueue(
                                "bridgeError",
                                mapOf(
                                    "code" to "OVERLAY_START_FAILED",
                                    "detail" to (error.message ?: error.javaClass.simpleName),
                                ),
                            )
                            result.error(
                                "OVERLAY_START_FAILED",
                                "Unable to start overlay service.",
                                error.message,
                            )
                        }
                    }
                    "stopOverlayRecording" -> {
                        OverlayEventQueue.enqueue(
                            "bridgeCall",
                            mapOf("method" to "stopOverlayRecording"),
                        )
                        sendOverlayCommand(OverlayForegroundService.ACTION_STOP)
                        result.success(buildStatusMap())
                    }
                    "cancelOverlayRecording" -> {
                        OverlayEventQueue.enqueue(
                            "bridgeCall",
                            mapOf("method" to "cancelOverlayRecording"),
                        )
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
                        call.argument<String>("layoutProfile")?.let {
                            keyboardState.layoutProfile = KeyboardLayoutProfile.fromRaw(it)
                        }
                        call.argument<Boolean>("cornerModeEnabled")?.let {
                            keyboardState.cornerModeEnabled = it
                        }
                        call.argument<Boolean>("debugTouchOverlayEnabled")?.let {
                            keyboardState.debugTouchOverlayEnabled = it
                        }
                        call.argument<Boolean>("keyVibrationEnabled")?.let {
                            keyboardState.keyVibrationEnabled = it
                        }
                        call.argument<Boolean>("keySoundEnabled")?.let {
                            keyboardState.keySoundEnabled = it
                        }
                        call.argument<Boolean>("spellingSuggestionsEnabled")?.let {
                            keyboardState.spellingSuggestionsEnabled = it
                        }
                        call.argument<Boolean>("specialKeyCornersEnabled")?.let {
                            keyboardState.specialKeyCornersEnabled = it
                        }
                        call.argument<Boolean>("frenchLanguageEnabled")?.let {
                            keyboardState.frenchLanguageEnabled = it
                        }
                        call.argument<Boolean>("englishLanguageEnabled")?.let {
                            keyboardState.englishLanguageEnabled = it
                        }
                        call.argument<Boolean>("doubleSpacePeriodEnabled")?.let {
                            keyboardState.doubleSpacePeriodEnabled = it
                        }
                        call.argument<Boolean>("punctuationAutoSpacingEnabled")?.let {
                            keyboardState.punctuationAutoSpacingEnabled = it
                        }
                        call.argument<String>("privacyMode")?.let {
                            keyboardState.privacyMode = it
                        }
                        result.success(keyboardState.buildStatusMap())
                    }
                    "setKeyboardSnippetRules" -> {
                        keyboardState.replaceSnippetRules(keyboardTextRulesFromArgument(call.arguments))
                        result.success(true)
                    }
                    "setKeyboardDictionaryRules" -> {
                        keyboardState.replaceDictionaryRules(keyboardTextRulesFromArgument(call.arguments))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun keyboardTextRulesFromArgument(argument: Any?): List<KeyboardTextRule> {
        return (argument as? List<*>)
            .orEmpty()
            .mapNotNull { item ->
                val row = item as? Map<*, *> ?: return@mapNotNull null
                val trigger = (row["trigger"] as? String).orEmpty().trim()
                val replacement = (row["replacement"] as? String).orEmpty()
                if (trigger.isEmpty() || replacement.isBlank()) {
                    return@mapNotNull null
                }
                KeyboardTextRule(
                    trigger = trigger,
                    replacement = replacement,
                    caseSensitive = row["caseSensitive"] as? Boolean ?: false,
                )
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
        OverlayEventQueue.enqueue(
            "overlayPreference",
            mapOf("enabled" to enabled),
        )
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
            "recordAudioGranted" to isRecordAudioPermissionGranted(),
            "sizeScale" to overlaySizeScale(),
            "opacity" to overlayOpacity(),
            "eventQueueSize" to OverlayEventQueue.size(),
            "serviceState" to OverlayForegroundService.serviceState(),
            "lastNativeEvent" to (OverlayEventQueue.lastEventSummary() ?: "none"),
        )
    }

    private fun openApplicationSettings() {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            Uri.parse("package:$packageName"),
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun isRecordAudioPermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }
}
