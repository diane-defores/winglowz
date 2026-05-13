package com.winflowz_app.winflowz_app.ime

import android.content.Context
import android.provider.Settings
import android.view.inputmethod.InputMethodInfo
import android.view.inputmethod.InputMethodManager
import java.util.Locale
import org.json.JSONArray
import org.json.JSONObject

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

    var keyVibrationEnabled: Boolean
        get() = preferences.getBoolean(KEY_KEY_VIBRATION_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_KEY_VIBRATION_ENABLED, value).apply()

    var keySoundEnabled: Boolean
        get() = preferences.getBoolean(KEY_KEY_SOUND_ENABLED, false)
        set(value) = preferences.edit().putBoolean(KEY_KEY_SOUND_ENABLED, value).apply()

    var spellingSuggestionsEnabled: Boolean
        get() = preferences.getBoolean(KEY_SPELLING_SUGGESTIONS_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_SPELLING_SUGGESTIONS_ENABLED, value).apply()

    var specialKeyCornersEnabled: Boolean
        get() = preferences.getBoolean(KEY_SPECIAL_KEY_CORNERS_ENABLED, false)
        set(value) = preferences.edit().putBoolean(KEY_SPECIAL_KEY_CORNERS_ENABLED, value).apply()

    var frenchLanguageEnabled: Boolean
        get() = preferences.getBoolean(KEY_FRENCH_LANGUAGE_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_FRENCH_LANGUAGE_ENABLED, value).apply()

    var englishLanguageEnabled: Boolean
        get() = preferences.getBoolean(KEY_ENGLISH_LANGUAGE_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_ENGLISH_LANGUAGE_ENABLED, value).apply()

    var doubleSpacePeriodEnabled: Boolean
        get() = preferences.getBoolean(KEY_DOUBLE_SPACE_PERIOD_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_DOUBLE_SPACE_PERIOD_ENABLED, value).apply()

    var punctuationAutoSpacingEnabled: Boolean
        get() {
            // Spec-compatible default: French enabled by default, other locales disabled by default.
            if (preferences.contains(KEY_PUNCTUATION_AUTO_SPACING_ENABLED)) {
                return preferences.getBoolean(KEY_PUNCTUATION_AUTO_SPACING_ENABLED, false)
            }
            return defaultPunctuationAutoSpacingForLocale()
        }
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
            "keyVibrationEnabled" to keyVibrationEnabled,
            "keySoundEnabled" to keySoundEnabled,
            "spellingSuggestionsEnabled" to spellingSuggestionsEnabled,
            "specialKeyCornersEnabled" to specialKeyCornersEnabled,
            "frenchLanguageEnabled" to frenchLanguageEnabled,
            "englishLanguageEnabled" to englishLanguageEnabled,
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

    fun textRules(): List<KeyboardTextRule> {
        return snippetRules() + dictionaryRules()
    }

    fun snippetRules(): List<KeyboardTextRule> = readRules(KEY_TEXT_EXPANSION_SNIPPETS)

    fun dictionaryRules(): List<KeyboardTextRule> = readRules(KEY_TEXT_EXPANSION_DICTIONARY)

    fun replaceSnippetRules(rules: List<KeyboardTextRule>) {
        preferences.edit().putString(KEY_TEXT_EXPANSION_SNIPPETS, encodeRules(rules)).apply()
    }

    fun replaceDictionaryRules(rules: List<KeyboardTextRule>) {
        preferences.edit().putString(KEY_TEXT_EXPANSION_DICTIONARY, encodeRules(rules)).apply()
    }

    fun clipboardEntries(): List<KeyboardClipboardEntry> = readClipboardEntries()

    fun pushClipboardEntry(
        content: String,
        pinned: Boolean = false,
    ) {
        val normalized = content.trim()
        if (normalized.isEmpty()) {
            return
        }
        val existing = clipboardEntries()
        val existingPinned = existing.firstOrNull { it.content == normalized }?.pinned == true
        val next =
            (listOf(KeyboardClipboardEntry(normalized, pinned || existingPinned)) + existing)
                .distinctBy { it.content }
                .take(MAX_CLIPBOARD_ENTRIES)
        preferences.edit().putString(KEY_CLIPBOARD_ENTRIES, encodeClipboardEntries(next)).apply()
    }

    private fun isInputMethodEnabled(): Boolean {
        val manager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return manager.enabledInputMethodList.any(::isWinFlowzAppIme)
    }

    private fun isInputMethodActive(): Boolean {
        val current =
            Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.DEFAULT_INPUT_METHOD,
            )
                ?: return false
        return current.contains(context.packageName) &&
            current.contains(WinFlowzAppInputMethodService::class.java.simpleName)
    }

    private fun isWinFlowzAppIme(info: InputMethodInfo): Boolean {
        val serviceName = info.serviceName ?: return false
        return info.packageName == context.packageName &&
            serviceName.endsWith(WinFlowzAppInputMethodService::class.java.simpleName)
    }

    private fun defaultPunctuationAutoSpacingForLocale(): Boolean {
        return Locale.getDefault().language.equals("fr", ignoreCase = true)
    }

    private fun readRules(key: String): List<KeyboardTextRule> {
        val raw = preferences.getString(key, "[]").orEmpty()
        return runCatching {
            val array = JSONArray(raw)
            buildList {
                for (index in 0 until array.length()) {
                    val item = array.optJSONObject(index) ?: continue
                    val trigger = item.optString("trigger").trim()
                    val replacement = item.optString("replacement")
                    if (trigger.isNotEmpty() && replacement.isNotBlank()) {
                        add(
                            KeyboardTextRule(
                                trigger = trigger,
                                replacement = replacement,
                                caseSensitive = item.optBoolean("caseSensitive", false),
                            ),
                        )
                    }
                }
            }
        }.getOrDefault(emptyList())
    }

    private fun encodeRules(rules: List<KeyboardTextRule>): String {
        val array = JSONArray()
        rules
            .filter { it.trigger.isNotBlank() && it.replacement.isNotBlank() }
            .take(MAX_TEXT_RULES)
            .forEach { rule ->
                array.put(
                    JSONObject()
                        .put("trigger", rule.trigger.trim())
                        .put("replacement", rule.replacement)
                        .put("caseSensitive", rule.caseSensitive),
                )
            }
        return array.toString()
    }

    private fun readClipboardEntries(): List<KeyboardClipboardEntry> {
        val raw = preferences.getString(KEY_CLIPBOARD_ENTRIES, "[]").orEmpty()
        return runCatching {
            val array = JSONArray(raw)
            buildList {
                for (index in 0 until array.length()) {
                    val item = array.optJSONObject(index) ?: continue
                    val content = item.optString("content").trim()
                    if (content.isNotEmpty()) {
                        add(
                            KeyboardClipboardEntry(
                                content = content,
                                pinned = item.optBoolean("pinned", false),
                            ),
                        )
                    }
                }
            }
        }.getOrDefault(emptyList())
    }

    private fun encodeClipboardEntries(entries: List<KeyboardClipboardEntry>): String {
        val array = JSONArray()
        entries
            .filter { it.content.isNotBlank() }
            .take(MAX_CLIPBOARD_ENTRIES)
            .forEach { entry ->
                array.put(
                    JSONObject()
                        .put("content", entry.content)
                        .put("pinned", entry.pinned),
                )
            }
        return array.toString()
    }

    companion object {
        const val PREFERENCES_NAME = "winflowz_app_keyboard_prefs"
        const val KEY_VOICE_ENABLED = "voice_enabled"
        const val KEY_CLIPBOARD_SYNC_DESIRED = "clipboard_sync_desired"
        const val KEY_MEDIA_CONTROLS_ENABLED = "media_controls_enabled"
        const val KEY_LAYOUT_PROFILE = "layout_profile"
        const val KEY_CORNER_MODE_ENABLED = "corner_mode_enabled"
        const val KEY_DEBUG_TOUCH_OVERLAY_ENABLED = "debug_touch_overlay_enabled"
        const val KEY_KEY_VIBRATION_ENABLED = "key_vibration_enabled"
        const val KEY_KEY_SOUND_ENABLED = "key_sound_enabled"
        const val KEY_SPELLING_SUGGESTIONS_ENABLED = "spelling_suggestions_enabled"
        const val KEY_SPECIAL_KEY_CORNERS_ENABLED = "special_key_corners_enabled"
        const val KEY_FRENCH_LANGUAGE_ENABLED = "french_language_enabled"
        const val KEY_ENGLISH_LANGUAGE_ENABLED = "english_language_enabled"
        const val KEY_DOUBLE_SPACE_PERIOD_ENABLED = "double_space_period_enabled"
        const val KEY_PUNCTUATION_AUTO_SPACING_ENABLED = "punctuation_auto_spacing_enabled"
        const val KEY_EMOJI_RECENTS = "emoji_recents"
        const val KEY_PRIVACY_MODE = "privacy_mode"
        const val KEY_TEXT_EXPANSION_SNIPPETS = "text_expansion_snippets"
        const val KEY_TEXT_EXPANSION_DICTIONARY = "text_expansion_dictionary"
        const val KEY_CLIPBOARD_ENTRIES = "clipboard_entries"
        const val EMOJI_RECENT_SEPARATOR = "|"
        const val MAX_TEXT_RULES = 300
        const val MAX_CLIPBOARD_ENTRIES = 60
        const val PRIVACY_AUTO = "auto"
        const val PRIVACY_STRICT = "strict"
        const val PRIVACY_STANDARD = "standard"
    }
}
