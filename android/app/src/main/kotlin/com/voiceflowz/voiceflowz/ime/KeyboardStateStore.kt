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

    var layoutProfile: KeyboardLayoutProfile
        get() = KeyboardLayoutProfile.fromRaw(preferences.getString(KEY_LAYOUT_PROFILE, KeyboardLayoutProfile.QWERTY.name))
        set(value) = preferences.edit().putString(KEY_LAYOUT_PROFILE, value.name).apply()

    var cornerModeEnabled: Boolean
        get() = preferences.getBoolean(KEY_CORNER_MODE_ENABLED, false)
        set(value) = preferences.edit().putBoolean(KEY_CORNER_MODE_ENABLED, value).apply()

    var debugTouchOverlayEnabled: Boolean
        get() = preferences.getBoolean(KEY_DEBUG_TOUCH_OVERLAY_ENABLED, false)
        set(value) = preferences.edit().putBoolean(KEY_DEBUG_TOUCH_OVERLAY_ENABLED, value).apply()

    var doubleSpacePeriodEnabled: Boolean
        get() = preferences.getBoolean(KEY_DOUBLE_SPACE_PERIOD_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_DOUBLE_SPACE_PERIOD_ENABLED, value).apply()

    var punctuationAutoSpacingEnabled: Boolean
        get() = preferences.getBoolean(KEY_PUNCTUATION_AUTO_SPACING_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_PUNCTUATION_AUTO_SPACING_ENABLED, value).apply()

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
            "layoutProfile" to layoutProfile.name,
            "cornerModeEnabled" to cornerModeEnabled,
            "debugTouchOverlayEnabled" to debugTouchOverlayEnabled,
            "doubleSpacePeriodEnabled" to doubleSpacePeriodEnabled,
            "punctuationAutoSpacingEnabled" to punctuationAutoSpacingEnabled,
            "privacyMode" to privacyMode,
        )
    }

    fun emojiRecents(limit: Int = 16): List<String> {
        return preferences
            .getString(KEY_EMOJI_RECENTS, "")
            .orEmpty()
            .split(EMOJI_RECENT_SEPARATOR)
            .map { it.trim() }
            .filter { it.isNotBlank() }
            .take(limit)
    }

    fun pushEmojiRecent(emoji: String, privateMode: Boolean) {
        if (privateMode) {
            return
        }
        val normalized = emoji.trim()
        if (normalized.isEmpty()) {
            return
        }
        val next =
            (listOf(normalized) + emojiRecents())
                .distinct()
                .take(16)
                .joinToString(separator = EMOJI_RECENT_SEPARATOR)
        preferences.edit().putString(KEY_EMOJI_RECENTS, next).apply()
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
        const val KEY_LAYOUT_PROFILE = "layout_profile"
        const val KEY_CORNER_MODE_ENABLED = "corner_mode_enabled"
        const val KEY_DEBUG_TOUCH_OVERLAY_ENABLED = "debug_touch_overlay_enabled"
        const val KEY_DOUBLE_SPACE_PERIOD_ENABLED = "double_space_period_enabled"
        const val KEY_PUNCTUATION_AUTO_SPACING_ENABLED = "punctuation_auto_spacing_enabled"
        const val KEY_EMOJI_RECENTS = "emoji_recents"
        const val KEY_PRIVACY_MODE = "privacy_mode"
        const val EMOJI_RECENT_SEPARATOR = "|"
        const val PRIVACY_AUTO = "auto"
        const val PRIVACY_STRICT = "strict"
        const val PRIVACY_STANDARD = "standard"
    }
}
