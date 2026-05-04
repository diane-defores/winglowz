package com.voiceflowz.voiceflowz.ime

import android.content.Context
import android.provider.Settings
import android.view.inputmethod.InputMethodInfo
import android.view.inputmethod.InputMethodManager

class KeyboardStateStore(private val context: Context) {
    private val preferences =
        context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)

    var voiceEnabled: Boolean
        get() = preferences.getBoolean(KEY_VOICE_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_VOICE_ENABLED, value).apply()

    var clipboardSyncDesired: Boolean
        get() = preferences.getBoolean(KEY_CLIPBOARD_SYNC_DESIRED, false)
        set(value) = preferences.edit().putBoolean(KEY_CLIPBOARD_SYNC_DESIRED, value).apply()

    var mediaControlsEnabled: Boolean
        get() = preferences.getBoolean(KEY_MEDIA_CONTROLS_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_MEDIA_CONTROLS_ENABLED, value).apply()

    var privacyMode: String
        get() = preferences.getString(KEY_PRIVACY_MODE, PRIVACY_AUTO) ?: PRIVACY_AUTO
        set(value) {
            val normalized =
                if (value in setOf(PRIVACY_AUTO, PRIVACY_STRICT, PRIVACY_STANDARD)) {
                    value
                } else {
                    PRIVACY_AUTO
                }
            preferences.edit().putString(KEY_PRIVACY_MODE, normalized).apply()
        }

    fun buildStatusMap(): Map<String, Any> {
        return mapOf(
            "supported" to true,
            "enabled" to isInputMethodEnabled(),
            "active" to isInputMethodActive(),
            "voiceEnabled" to voiceEnabled,
            "clipboardSyncDesired" to clipboardSyncDesired,
            "mediaControlsEnabled" to mediaControlsEnabled,
            "privacyMode" to privacyMode,
        )
    }

    private fun isInputMethodEnabled(): Boolean {
        val manager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return manager.enabledInputMethodList.any(::isVoiceFlowzIme)
    }

    private fun isInputMethodActive(): Boolean {
        val current =
            Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.DEFAULT_INPUT_METHOD,
            )
                ?: return false
        return current.contains(context.packageName) &&
            current.contains(VoiceFlowzInputMethodService::class.java.simpleName)
    }

    private fun isVoiceFlowzIme(info: InputMethodInfo): Boolean {
        val serviceName = info.serviceName ?: return false
        return info.packageName == context.packageName &&
            serviceName.endsWith(VoiceFlowzInputMethodService::class.java.simpleName)
    }

    companion object {
        const val PREFERENCES_NAME = "voiceflowz_keyboard_prefs"
        const val KEY_VOICE_ENABLED = "voice_enabled"
        const val KEY_CLIPBOARD_SYNC_DESIRED = "clipboard_sync_desired"
        const val KEY_MEDIA_CONTROLS_ENABLED = "media_controls_enabled"
        const val KEY_PRIVACY_MODE = "privacy_mode"
        const val PRIVACY_AUTO = "auto"
        const val PRIVACY_STRICT = "strict"
        const val PRIVACY_STANDARD = "standard"
    }
}
