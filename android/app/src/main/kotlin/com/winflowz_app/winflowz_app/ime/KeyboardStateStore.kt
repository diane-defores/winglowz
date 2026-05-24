package com.winflowz_app.winflowz_app.ime

import android.app.ActivityManager
import android.content.Context
import android.content.ComponentName
import android.os.Build
import android.os.StatFs
import android.provider.Settings
import android.view.inputmethod.InputMethodInfo
import android.view.inputmethod.InputMethodManager
import android.text.TextUtils
import com.winflowz_app.winflowz_app.WinFlowzNotificationListenerService
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarState
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionLongPressBehavior
import com.winflowz_app.winflowz_app.ime.actions.KeyboardAttachedActionRowState
import java.io.File
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

    var mediaVolumeStepPercent: Int
        get() = preferences.getInt(KEY_MEDIA_VOLUME_STEP_PERCENT, MEDIA_VOLUME_STEP_PERCENT_DEFAULT)
            .coerceIn(MEDIA_STEP_PERCENT_MIN, MEDIA_STEP_PERCENT_MAX)
        set(value) = preferences.edit().putInt(KEY_MEDIA_VOLUME_STEP_PERCENT, value.coerceIn(MEDIA_STEP_PERCENT_MIN, MEDIA_STEP_PERCENT_MAX)).apply()

    var mediaBrightnessStepPercent: Int
        get() = preferences.getInt(KEY_MEDIA_BRIGHTNESS_STEP_PERCENT, MEDIA_BRIGHTNESS_STEP_PERCENT_DEFAULT)
            .coerceIn(MEDIA_STEP_PERCENT_MIN, MEDIA_STEP_PERCENT_MAX)
        set(value) = preferences.edit().putInt(KEY_MEDIA_BRIGHTNESS_STEP_PERCENT, value.coerceIn(MEDIA_STEP_PERCENT_MIN, MEDIA_STEP_PERCENT_MAX)).apply()

    var themeMode: String
        get() = preferences.getString(KEY_THEME_MODE, THEME_SYSTEM) ?: THEME_SYSTEM
        set(value) {
            val normalized =
                if (value in setOf(THEME_SYSTEM, THEME_LIGHT, THEME_DARK)) {
                    value
                } else {
                    THEME_SYSTEM
                }
            preferences.edit().putString(KEY_THEME_MODE, normalized).apply()
        }

    var layoutProfile: KeyboardLayoutProfile
        get() = KeyboardLayoutProfile.fromRaw(preferences.getString(KEY_LAYOUT_PROFILE, DEFAULT_LAYOUT_PROFILE.name))
        set(value) = preferences.edit().putString(KEY_LAYOUT_PROFILE, value.name).apply()

    var cornerModeEnabled: Boolean
        get() = preferences.getBoolean(KEY_CORNER_MODE_ENABLED, DEFAULT_CORNER_MODE_ENABLED)
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

    var keyboardHeightScale: Float
        get() = preferences.getFloat(KEY_KEYBOARD_HEIGHT_SCALE, KEYBOARD_HEIGHT_DEFAULT)
            .coerceIn(KEYBOARD_HEIGHT_MIN, KEYBOARD_HEIGHT_MAX)
        set(value) {
            val normalized = value.coerceIn(KEYBOARD_HEIGHT_MIN, KEYBOARD_HEIGHT_MAX)
            preferences.edit().putFloat(KEY_KEYBOARD_HEIGHT_SCALE, normalized).apply()
        }

    var actionRowHeightScale: Float
        get() = normalizeActionRowHeightScale(
            preferences.getFloat(KEY_ACTION_ROW_HEIGHT_SCALE, ACTION_ROW_HEIGHT_DEFAULT),
        )
        set(value) = preferences.edit().putFloat(KEY_ACTION_ROW_HEIGHT_SCALE, normalizeActionRowHeightScale(value)).apply()

    var compactModeEnabled: Boolean
        get() = preferences.getBoolean(KEY_COMPACT_MODE_ENABLED, false)
        set(value) = preferences.edit().putBoolean(KEY_COMPACT_MODE_ENABLED, value).apply()

    var autoCloseModesEnabled: Boolean
        get() = preferences.getBoolean(KEY_AUTO_CLOSE_MODES_ENABLED, true)
        set(value) = preferences.edit().putBoolean(KEY_AUTO_CLOSE_MODES_ENABLED, value).apply()

    var actionBarLongPressBehavior: KeyboardActionLongPressBehavior
        get() = KeyboardActionLongPressBehavior.fromRaw(
            preferences.getString(KEY_ACTION_BAR_LONG_PRESS_BEHAVIOR, DEFAULT_ACTION_BAR_LONG_PRESS_BEHAVIOR),
        )
        set(value) {
            preferences.edit().putString(KEY_ACTION_BAR_LONG_PRESS_BEHAVIOR, value.wireValue).apply()
        }

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

    var statusBarConfig: KeyboardStatusBarConfig
        get() {
            val rawConfig = preferences.getString(KEY_STATUS_BAR_CONFIG, null)
            if (rawConfig == null || rawConfig.isBlank()) {
                return KeyboardStatusBarConfig.defaults()
            }
            return runCatching {
                val payload = JSONObject(rawConfig)
                KeyboardStatusBarConfig.fromMap(payload.toMap())
            }.getOrElse { KeyboardStatusBarConfig.defaults() }
        }
        set(value) {
            val safeModules = value.sanitizeModuleList()
            val safeConfig =
                KeyboardStatusBarConfig(
                    mode = value.mode,
                    modules = safeModules,
                    accountLabelMode = value.accountLabelMode,
                    tipLevel = value.tipLevel,
                )
            preferences
                .edit()
                .putString(KEY_STATUS_BAR_CONFIG, safeConfig.toJSONObject().toString())
                .apply()
        }

    var accountLabelMode: KeyboardStatusBarAccountLabelMode
        get() =
            KeyboardStatusBarAccountLabelMode.fromRaw(
                preferences.getString(KEY_ACCOUNT_LABEL_MODE, null),
            )
        set(value) =
            preferences
                .edit()
                .putString(KEY_ACCOUNT_LABEL_MODE, value.wireValue)
                .apply()

    var accountLabel: String?
        get() = preferences.getString(KEY_ACCOUNT_LABEL, null)
        set(value) =
            if (value == null) {
                preferences.edit().remove(KEY_ACCOUNT_LABEL).apply()
            } else {
                preferences.edit().putString(KEY_ACCOUNT_LABEL, value.take(48)).apply()
            }

    var tipsLastResetAtMs: Long
        get() = preferences.getLong(KEY_TIPS_LAST_RESET_AT, 0L)
        set(value) = preferences.edit().putLong(KEY_TIPS_LAST_RESET_AT, value).apply()

    val lastKeyboardError: String?
        get() = preferences.getString(KEY_LAST_KEYBOARD_ERROR, null)

    val lastKeyboardErrorAt: String?
        get() = preferences.getString(KEY_LAST_KEYBOARD_ERROR_AT, null)

    val keyboardRecoveryCount: Int
        get() = preferences.getInt(KEY_KEYBOARD_RECOVERY_COUNT, 0)

    var voiceRuntimeMode: String
        get() = preferences.getString(KEY_VOICE_RUNTIME_MODE, VOICE_RUNTIME_UNAVAILABLE) ?: VOICE_RUNTIME_UNAVAILABLE
        set(value) {
            val normalized =
                if (value in setOf(VOICE_RUNTIME_LOCAL, VOICE_RUNTIME_ANDROID_FALLBACK, VOICE_RUNTIME_CLOUD_FALLBACK, VOICE_RUNTIME_UNAVAILABLE)) {
                    value
                } else {
                    VOICE_RUNTIME_UNAVAILABLE
                }
            preferences.edit().putString(KEY_VOICE_RUNTIME_MODE, normalized).apply()
        }

    var voiceLanguageTag: String
        get() = preferences.getString(KEY_VOICE_LANGUAGE_TAG, Locale.getDefault().toLanguageTag()) ?: Locale.getDefault().toLanguageTag()
        set(value) = preferences.edit().putString(KEY_VOICE_LANGUAGE_TAG, value.take(32)).apply()

    var voicePackId: String
        get() = preferences.getString(KEY_VOICE_PACK_ID, "none") ?: "none"
        set(value) = preferences.edit().putString(KEY_VOICE_PACK_ID, value.take(96)).apply()

    var voiceEngine: String
        get() = preferences.getString(KEY_VOICE_ENGINE, "android_speech_recognizer") ?: "android_speech_recognizer"
        set(value) = preferences.edit().putString(KEY_VOICE_ENGINE, value.take(48)).apply()

    var voiceFallbackReason: String
        get() = preferences.getString(KEY_VOICE_FALLBACK_REASON, "missing_pack") ?: "missing_pack"
        set(value) = preferences.edit().putString(KEY_VOICE_FALLBACK_REASON, value.take(48)).apply()

    var voiceLastErrorCode: String
        get() = preferences.getString(KEY_VOICE_LAST_ERROR_CODE, "none") ?: "none"
        set(value) = preferences.edit().putString(KEY_VOICE_LAST_ERROR_CODE, value.take(64)).apply()

    var voiceModelArtifactPath: String
        get() = preferences.getString(KEY_VOICE_MODEL_ARTIFACT_PATH, "none") ?: "none"
        set(value) {
            val normalized = value.trim().ifBlank { "none" }.take(512)
            preferences.edit().putString(KEY_VOICE_MODEL_ARTIFACT_PATH, normalized).apply()
        }

    fun updateVoiceRuntimeStatus(
        runtimeMode: String,
        languageTag: String,
        packId: String,
        engine: String,
        fallbackReason: String,
        lastErrorCode: String,
    ) {
        val status =
            KeyboardVoiceRuntimeStatus.normalized(
                runtimeMode = runtimeMode,
                languageTag = languageTag,
                packId = packId,
                engine = engine,
                fallbackReason = fallbackReason,
                lastErrorCode = lastErrorCode,
            )
        voiceRuntimeMode = status.runtimeMode
        voiceLanguageTag = status.languageTag
        voicePackId = status.packId
        voiceEngine = status.engine
        voiceFallbackReason = status.fallbackReason
        voiceLastErrorCode = status.lastErrorCode
        KeyboardVoiceRuntimeEventQueue.enqueue(status)
    }

    fun setVoiceRuntimeConfig(
        languageTag: String,
        packId: String,
        engine: String,
        modelArtifactPath: String? = null,
    ) {
        voiceLanguageTag = languageTag
        voicePackId = packId
        voiceEngine = engine
        if (modelArtifactPath != null) {
            voiceModelArtifactPath = modelArtifactPath
        }
    }

    fun clearKeyboardDiagnostics() {
        preferences
            .edit()
            .remove(KEY_LAST_KEYBOARD_ERROR)
            .remove(KEY_LAST_KEYBOARD_ERROR_AT)
            .putInt(KEY_KEYBOARD_RECOVERY_COUNT, 0)
            .apply()
    }

    fun buildStatusMap(): Map<String, Any> {
        val theme = themeConfig()
        val rawThemeConfig = preferences.getString(KEY_THEME_CONFIG, null)
        val themeConfigSize = rawThemeConfig?.length ?: 0
        val backgroundSource =
            when {
                theme.useImage && !theme.backgroundImagePath.isNullOrBlank() -> "image"
                theme.useGradient && theme.gradientStyle == "radial" -> "gradient_radial"
                theme.useGradient -> "gradient_linear"
                else -> "solid"
            }
        val fallbackStatus =
            when {
                theme.useImage && !theme.backgroundImagePath.isNullOrBlank() &&
                    !File(theme.backgroundImagePath).exists()
                -> "image_missing_fallback"
                rawThemeConfig == null && themeMode != THEME_SYSTEM -> "theme_mode_migrated"
                rawThemeConfig == null -> "default_preset"
                else -> "none"
            }
        return mapOf(
            "supported" to true,
            "enabled" to isInputMethodEnabled(),
            "active" to isInputMethodActive(),
            "voiceEnabled" to voiceEnabled,
            "clipboardSyncDesired" to clipboardSyncDesired,
            "mediaControlsEnabled" to mediaControlsEnabled,
            "mediaVolumeStepPercent" to mediaVolumeStepPercent,
            "mediaBrightnessStepPercent" to mediaBrightnessStepPercent,
            "mediaSessionAccessGranted" to isMediaSessionAccessGranted(),
            "systemSettingsWriteGranted" to canWriteSystemSettings(),
            "themeMode" to themeMode,
            "themePresetId" to theme.presetId,
            "themePressEffect" to theme.pressEffect,
            "themeBackgroundSource" to backgroundSource,
            "themeConfigSize" to themeConfigSize,
            "themeFallbackStatus" to fallbackStatus,
            "layoutProfile" to layoutProfile.name,
            "cornerModeEnabled" to cornerModeEnabled,
            "cornerPresetId" to cornerConfig().presetId,
            "debugTouchOverlayEnabled" to debugTouchOverlayEnabled,
            "keyVibrationEnabled" to keyVibrationEnabled,
            "keySoundEnabled" to keySoundEnabled,
            "spellingSuggestionsEnabled" to spellingSuggestionsEnabled,
            "specialKeyCornersEnabled" to specialKeyCornersEnabled,
            "frenchLanguageEnabled" to frenchLanguageEnabled,
            "englishLanguageEnabled" to englishLanguageEnabled,
            "doubleSpacePeriodEnabled" to doubleSpacePeriodEnabled,
            "punctuationAutoSpacingEnabled" to punctuationAutoSpacingEnabled,
            "keyboardHeightScale" to keyboardHeightScale,
            "actionRowHeightScale" to actionRowHeightScale,
            "compactModeEnabled" to compactModeEnabled,
            "autoCloseModesEnabled" to autoCloseModesEnabled,
            "actionBarLongPressBehavior" to actionBarLongPressBehavior.wireValue,
            "privacyMode" to privacyMode,
            "statusBarConfig" to statusBarConfig.toMap(),
            "accountLabel" to (accountLabel ?: ""),
            "accountLabelMode" to accountLabelMode.wireValue,
            "tipsLastResetAtMs" to tipsLastResetAtMs,
            "lastKeyboardError" to (lastKeyboardError ?: ""),
            "lastKeyboardErrorAt" to (lastKeyboardErrorAt ?: ""),
            "keyboardRecoveryCount" to keyboardRecoveryCount,
            "voiceRuntimeMode" to voiceRuntimeMode,
            "voiceLanguageTag" to voiceLanguageTag,
            "voicePackId" to voicePackId,
            "voiceEngine" to voiceEngine,
            "voiceModelArtifactPath" to voiceModelArtifactPath,
            "voiceFallbackReason" to voiceFallbackReason,
            "voiceLastErrorCode" to voiceLastErrorCode,
            "deviceAndroidSdk" to Build.VERSION.SDK_INT,
            "devicePrimaryAbi" to (Build.SUPPORTED_ABIS.firstOrNull() ?: "unknown"),
            "deviceTotalCapacityMb" to deviceTotalCapacityMb(),
            "deviceFreeSpaceMb" to deviceFreeSpaceMb(),
            "deviceRamMb" to deviceRamMb(),
        )
    }

    private fun deviceTotalCapacityMb(): Int {
        return runCatching {
            val stats = StatFs(context.filesDir.absolutePath)
            val totalBytes = stats.totalBytes.coerceAtLeast(0L)
            (totalBytes / BYTES_PER_MB).toInt()
        }.getOrDefault(0)
    }

    private fun deviceFreeSpaceMb(): Int {
        return runCatching {
            val stats = StatFs(context.filesDir.absolutePath)
            val freeBytes = stats.availableBytes.coerceAtLeast(0L)
            (freeBytes / BYTES_PER_MB).toInt()
        }.getOrDefault(0)
    }

    private fun deviceRamMb(): Int {
        return runCatching {
            val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
            val info = ActivityManager.MemoryInfo()
            manager?.getMemoryInfo(info)
            val totalRamBytes = info.totalMem.coerceAtLeast(0L)
            (totalRamBytes / BYTES_PER_MB).toInt()
        }.getOrDefault(0)
    }

    fun setStatusBarConfig(config: KeyboardStatusBarConfig): KeyboardStatusBarConfig {
        statusBarConfig = config
        return statusBarConfig
    }

    fun resetStatusBarConfig(): KeyboardStatusBarConfig {
        val reset = KeyboardStatusBarConfig.defaults()
        statusBarConfig = reset
        return reset
    }

    fun setKeyboardUserContext(
        rawAccountLabel: String?,
        rawAccountLabelMode: String?,
        rawTipsLastResetAtMs: Long?,
    ) {
        accountLabel = rawAccountLabel?.trim()?.take(64)
        accountLabelMode = KeyboardStatusBarAccountLabelMode.fromRaw(rawAccountLabelMode)
        if (rawTipsLastResetAtMs != null && rawTipsLastResetAtMs > 0) {
            tipsLastResetAtMs = rawTipsLastResetAtMs
        }
    }

    fun emojiRecents(limit: Int = 16): List<String> {
        return preferences
            .getString(KEY_EMOJI_RECENTS, "")
            .orEmpty()
            .split(EMOJI_RECENT_SEPARATOR)
            .map { it.trim() }
            .filter { isEmojiRecentCandidate(it) }
            .take(limit)
    }

    fun pushEmojiRecent(emoji: String, privateMode: Boolean) {
        if (privateMode) {
            return
        }
        val normalized = emoji.trim()
        if (!isEmojiRecentCandidate(normalized)) {
            return
        }
        val next =
            (listOf(normalized) + emojiRecents())
                .distinct()
                .take(16)
                .joinToString(separator = EMOJI_RECENT_SEPARATOR)
        preferences.edit().putString(KEY_EMOJI_RECENTS, next).apply()
    }

    fun symbolRecents(limit: Int = 32): List<String> {
        return preferences
            .getString(KEY_SYMBOL_RECENTS, "")
            .orEmpty()
            .split(SYMBOL_RECENT_SEPARATOR)
            .map { it.trim() }
            .filter { isSymbolRecentCandidate(it) }
            .take(limit)
    }

    fun pushSymbolRecent(symbol: String, privateMode: Boolean) {
        if (privateMode) {
            return
        }
        val normalized = symbol.trim()
        if (!isSymbolRecentCandidate(normalized)) {
            return
        }
        val next =
            (listOf(normalized) + symbolRecents())
                .distinct()
                .take(32)
                .joinToString(separator = SYMBOL_RECENT_SEPARATOR)
        preferences.edit().putString(KEY_SYMBOL_RECENTS, next).apply()
    }

    private fun isEmojiRecentCandidate(value: String): Boolean {
        if (value.isBlank()) {
            return false
        }
        val codePoints = value.codePoints().toArray()
        return codePoints.any { codePoint ->
            codePoint == 0x200D ||
                codePoint == 0xFE0F ||
                codePoint in 0x1F000..0x1FAFF ||
                codePoint in 0x2600..0x27BF
        }
    }

    private fun isSymbolRecentCandidate(value: String): Boolean {
        return value.isNotBlank() && value.codePointCount(0, value.length) <= 2
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

    fun actionBarState(): KeyboardActionBarState {
        val raw = preferences.getString(KEY_ACTION_BAR_STATE, null).orEmpty()
        if (raw.isBlank()) {
            return KeyboardActionBarState(longPressBehavior = actionBarLongPressBehavior)
        }
        return runCatching {
            val objectValue = JSONObject(raw)
            val order = parseStringArray(objectValue.optJSONArray("orderedActionIds"))
            val pinned = parseStringArray(objectValue.optJSONArray("pinnedActionIds")).toSet()
            val attached =
                objectValue.optJSONArray("attachedRows")
                    ?.let { array ->
                        buildList {
                            for (index in 0 until array.length()) {
                                val item = array.optJSONObject(index) ?: continue
                                val providerActionId = item.optString("providerActionId").trim()
                                val rowId = item.optString("rowId").trim()
                                val dedupeKey = item.optString("dedupeKey").trim()
                                if (providerActionId.isNotEmpty() && rowId.isNotEmpty() && dedupeKey.isNotEmpty()) {
                                    add(
                                        KeyboardAttachedActionRowState(
                                            providerActionId = providerActionId,
                                            rowId = rowId,
                                            dedupeKey = dedupeKey,
                                        ),
                                    )
                                }
                            }
                        }
                    }.orEmpty()
            val rowPageById =
                objectValue.optJSONObject("rowPageById")
                    ?.let { value ->
                        buildMap {
                            val iterator = value.keys()
                            while (iterator.hasNext()) {
                                val key = iterator.next()
                                val page = value.optInt(key, 0)
                                put(key, page.coerceAtLeast(0))
                            }
                        }
                    }.orEmpty()
            val usage =
                objectValue.optJSONObject("adaptiveUsageScoreById")
                    ?.let { value ->
                        buildMap {
                            val iterator = value.keys()
                            while (iterator.hasNext()) {
                                val key = iterator.next()
                                put(key, value.optLong(key, 0L))
                            }
                        }
                    }.orEmpty()
            KeyboardActionBarState(
                orderedActionIds = order,
                pinnedActionIds = pinned,
                attachedRows = attached,
                rowPageById = rowPageById,
                adaptiveUsageScoreById = usage,
                longPressBehavior = actionBarLongPressBehavior,
            )
        }.getOrDefault(KeyboardActionBarState(longPressBehavior = actionBarLongPressBehavior))
    }

    fun replaceActionBarState(state: KeyboardActionBarState) {
        val encoded =
            JSONObject()
                .put("orderedActionIds", JSONArray(state.orderedActionIds))
                .put("pinnedActionIds", JSONArray(state.pinnedActionIds.toList()))
                .put(
                    "attachedRows",
                    JSONArray().apply {
                        state.attachedRows.forEach { row ->
                            put(
                                JSONObject()
                                    .put("providerActionId", row.providerActionId)
                                    .put("rowId", row.rowId)
                                    .put("dedupeKey", row.dedupeKey),
                            )
                        }
                    },
                )
                .put(
                    "rowPageById",
                    JSONObject().apply {
                        state.rowPageById.forEach { (rowId, page) ->
                            put(rowId, page.coerceAtLeast(0))
                        }
                    },
                )
                .put(
                    "adaptiveUsageScoreById",
                    JSONObject().apply {
                        state.adaptiveUsageScoreById.forEach { (actionId, score) ->
                            put(actionId, score)
                        }
                    },
                )
                .toString()
        preferences.edit().putString(KEY_ACTION_BAR_STATE, encoded).apply()
    }

    fun cornerConfig(): KeyboardCornerConfig {
        return KeyboardCornerConfig.fromJson(preferences.getString(KEY_CORNER_CONFIG, null))
    }

    fun themeConfig(): KeyboardThemeConfig {
        val raw = preferences.getString(KEY_THEME_CONFIG, null)
        val parsed = KeyboardThemeConfig.fromJson(raw)
        if (preferences.contains(KEY_THEME_CONFIG)) {
            return parsed
        }
        return when (themeMode) {
            THEME_LIGHT -> parsed.copy(presetId = "winflowz_light")
            THEME_DARK -> parsed.copy(
                presetId = "winflowz_dark",
                backgroundStartColor = android.graphics.Color.parseColor("#121815"),
                backgroundEndColor = android.graphics.Color.parseColor("#121815"),
                keyColor = android.graphics.Color.parseColor("#232B27"),
                specialKeyColor = android.graphics.Color.parseColor("#2E3833"),
                activeKeyColor = android.graphics.Color.parseColor("#36B384"),
                pressedKeyColor = android.graphics.Color.parseColor("#43524B"),
                textColor = android.graphics.Color.parseColor("#EBF2EE"),
                statusTextColor = android.graphics.Color.parseColor("#CCD9D2"),
            )
            else -> parsed.copy(presetId = "system")
        }
    }

    fun replaceThemeConfig(config: KeyboardThemeConfig): KeyboardThemeConfig {
        val previous = themeConfig()
        val validated = config.validated()
        val encoded = validated.toJson()
        if (encoded.length > MAX_THEME_CONFIG_JSON_LENGTH) {
            throw IllegalArgumentException("Theme config is too large")
        }
        cleanupReplacedThemeImage(previous.backgroundImagePath, validated.backgroundImagePath)
        preferences.edit().putString(KEY_THEME_CONFIG, encoded).apply()
        return validated
    }

    fun setThemePreset(presetId: String): KeyboardThemeConfig {
        return replaceThemeConfig(KeyboardThemePresets.configFor(presetId))
    }

    fun resetThemeConfig(): KeyboardThemeConfig {
        val previous = themeConfig()
        preferences.edit().remove(KEY_THEME_CONFIG).apply()
        cleanupReplacedThemeImage(previous.backgroundImagePath, null)
        return themeConfig()
    }

    private fun cleanupReplacedThemeImage(previousPath: String?, nextPath: String?) {
        val before = previousPath?.trim().orEmpty()
        if (before.isEmpty()) {
            return
        }
        val after = nextPath?.trim().orEmpty()
        if (before == after) {
            return
        }
        val baseDirectory = File(context.filesDir, "keyboard_themes")
        val previousFile = File(before)
        if (!baseDirectory.exists() || !previousFile.exists()) {
            return
        }
        val managedPath = runCatching { previousFile.canonicalPath }.getOrNull() ?: return
        val basePath = runCatching { baseDirectory.canonicalPath }.getOrNull() ?: return
        if (!managedPath.startsWith(basePath + File.separator)) {
            return
        }
        runCatching { previousFile.delete() }
    }

    fun replaceCornerConfig(config: KeyboardCornerConfig): KeyboardCornerConfig {
        val validated = config.validated()
        val encoded = validated.toJson().toString()
        if (encoded.length > MAX_CORNER_CONFIG_JSON_LENGTH) {
            throw KeyboardCornerConfigException("Corner shortcut config is too large")
        }
        preferences.edit().putString(KEY_CORNER_CONFIG, encoded).apply()
        return validated
    }

    fun setCornerPreset(presetId: String): KeyboardCornerConfig {
        val next = cornerConfig().withPreset(presetId)
        return replaceCornerConfig(next)
    }

    fun resetCornerConfig(): KeyboardCornerConfig {
        preferences.edit().remove(KEY_CORNER_CONFIG).apply()
        return KeyboardCornerConfig()
    }

    fun pushClipboardEntry(
        content: String,
        pinned: Boolean = false,
    ) {
        val normalized = content.replace(Regex("\\s+"), " ").trim()
        if (normalized.isEmpty()) {
            return
        }
        val existing = clipboardEntries()
        val dedupeKey = clipboardDedupeKey(normalized)
        val existingPinned = existing.firstOrNull { clipboardDedupeKey(it.content) == dedupeKey }?.pinned == true
        val next =
            (listOf(KeyboardClipboardEntry(normalized, pinned || existingPinned)) + existing)
                .dedupeClipboardEntries()
                .take(MAX_CLIPBOARD_ENTRIES)
        preferences.edit().putString(KEY_CLIPBOARD_ENTRIES, encodeClipboardEntries(next)).apply()
    }

    private fun isInputMethodEnabled(): Boolean {
        val manager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        return manager.enabledInputMethodList.any(::isWinFlowzIme)
    }

    private fun isInputMethodActive(): Boolean {
        val current =
            Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.DEFAULT_INPUT_METHOD,
            )
                ?: return false
        return current.contains(context.packageName) &&
            current.contains(WinFlowzInputMethodService::class.java.simpleName)
    }

    fun isMediaSessionAccessGranted(): Boolean {
        val expected = ComponentName(context, WinFlowzNotificationListenerService::class.java).flattenToString()
        val enabled =
            Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners",
            ) ?: return false
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabled)
        while (splitter.hasNext()) {
            if (splitter.next().equals(expected, ignoreCase = true)) {
                return true
            }
        }
        return false
    }

    fun canWriteSystemSettings(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.System.canWrite(context)
    }

    private fun isWinFlowzIme(info: InputMethodInfo): Boolean {
        val serviceName = info.serviceName ?: return false
        return info.packageName == context.packageName &&
            serviceName.endsWith(WinFlowzInputMethodService::class.java.simpleName)
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

    private fun parseStringArray(array: JSONArray?): List<String> {
        if (array == null) {
            return emptyList()
        }
        return buildList {
            for (index in 0 until array.length()) {
                val value = array.optString(index).trim()
                if (value.isNotEmpty()) {
                    add(value)
                }
            }
        }
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
                    val content = item.optString("content").replace(Regex("\\s+"), " ").trim()
                    if (content.isNotEmpty()) {
                        add(
                            KeyboardClipboardEntry(
                                content = content,
                                pinned = item.optBoolean("pinned", false),
                            ),
                        )
                    }
                }
            }.dedupeClipboardEntries()
        }.getOrDefault(emptyList())
    }

    private fun encodeClipboardEntries(entries: List<KeyboardClipboardEntry>): String {
        val array = JSONArray()
        entries
            .filter { it.content.isNotBlank() }
            .dedupeClipboardEntries()
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

    private fun List<KeyboardClipboardEntry>.dedupeClipboardEntries(): List<KeyboardClipboardEntry> {
        val byKey = linkedMapOf<String, KeyboardClipboardEntry>()
        forEach { entry ->
            val normalized = entry.content.replace(Regex("\\s+"), " ").trim()
            if (normalized.isBlank()) {
                return@forEach
            }
            val key = clipboardDedupeKey(normalized)
            val existing = byKey[key]
            byKey[key] = KeyboardClipboardEntry(
                content = existing?.content ?: normalized,
                pinned = entry.pinned || existing?.pinned == true,
            )
        }
        return byKey.values.toList()
    }

    private fun clipboardDedupeKey(content: String): String = content.replace(Regex("\\s+"), " ").trim().lowercase()

    private fun JSONObject.toMap(): Map<String, Any> {
        return mutableMapOf<String, Any>().also { map ->
            val keys = keys()
            while (keys.hasNext()) {
                val key = keys.next()
                val value = this.opt(key)
                if (value == null || value == JSONObject.NULL) {
                    map[key] = ""
                    continue
                }
                when (value) {
                    is JSONObject -> map[key] = value.toMap()
                    is JSONArray -> {
                        val values = mutableListOf<Any>()
                        for (index in 0 until value.length()) {
                            val entry = value.opt(index)
                            values.add(
                                when (entry) {
                                    is JSONObject -> entry.toMap()
                                    is JSONArray -> entry.toList()
                                    else -> entry
                                },
                            )
                        }
                        map[key] = values
                    }
                    else -> map[key] = value
                }
            }
        }
    }

    private fun JSONArray.toList(): List<Any> {
        return List(length()) { index ->
            val entry = this.opt(index)
            when (entry) {
                is JSONObject -> entry.toMap()
                is JSONArray -> entry.toList()
                else -> entry
            }
        }
    }

    companion object {
        const val PREFERENCES_NAME = "winflowz_app_keyboard_prefs"
        const val KEY_VOICE_ENABLED = "voice_enabled"
        const val KEY_CLIPBOARD_SYNC_DESIRED = "clipboard_sync_desired"
        const val KEY_MEDIA_CONTROLS_ENABLED = "media_controls_enabled"
        const val KEY_MEDIA_VOLUME_STEP_PERCENT = "media_volume_step_percent"
        const val KEY_MEDIA_BRIGHTNESS_STEP_PERCENT = "media_brightness_step_percent"
        const val KEY_THEME_MODE = "theme_mode"
        const val KEY_LAYOUT_PROFILE = "layout_profile"
        const val KEY_CORNER_MODE_ENABLED = "corner_mode_enabled"
        val DEFAULT_LAYOUT_PROFILE = KeyboardLayoutProfile.AZERTY
        const val DEFAULT_CORNER_MODE_ENABLED = true
        const val KEY_DEBUG_TOUCH_OVERLAY_ENABLED = "debug_touch_overlay_enabled"
        const val KEY_KEY_VIBRATION_ENABLED = "key_vibration_enabled"
        const val KEY_KEY_SOUND_ENABLED = "key_sound_enabled"
        const val KEY_SPELLING_SUGGESTIONS_ENABLED = "spelling_suggestions_enabled"
        const val KEY_SPECIAL_KEY_CORNERS_ENABLED = "special_key_corners_enabled"
        const val KEY_FRENCH_LANGUAGE_ENABLED = "french_language_enabled"
        const val KEY_ENGLISH_LANGUAGE_ENABLED = "english_language_enabled"
        const val KEY_DOUBLE_SPACE_PERIOD_ENABLED = "double_space_period_enabled"
        const val KEY_PUNCTUATION_AUTO_SPACING_ENABLED = "punctuation_auto_spacing_enabled"
        const val KEY_KEYBOARD_HEIGHT_SCALE = "keyboard_height_scale"
        const val KEY_ACTION_ROW_HEIGHT_SCALE = "action_row_height_scale"
        const val KEY_COMPACT_MODE_ENABLED = "compact_mode_enabled"
        const val KEY_AUTO_CLOSE_MODES_ENABLED = "auto_close_modes_enabled"
        const val KEY_ACTION_BAR_STATE = "action_bar_state"
        const val KEY_ACTION_BAR_LONG_PRESS_BEHAVIOR = "action_bar_long_press_behavior"
        const val KEY_EMOJI_RECENTS = "emoji_recents"
        const val KEY_SYMBOL_RECENTS = "symbol_recents"
        const val KEY_PRIVACY_MODE = "privacy_mode"
        const val KEY_TEXT_EXPANSION_SNIPPETS = "text_expansion_snippets"
        const val KEY_TEXT_EXPANSION_DICTIONARY = "text_expansion_dictionary"
        const val KEY_CLIPBOARD_ENTRIES = "clipboard_entries"
        const val KEY_CORNER_CONFIG = "corner_config"
        const val KEY_THEME_CONFIG = "theme_config"
        const val KEY_STATUS_BAR_CONFIG = "status_bar_config"
        const val KEY_ACCOUNT_LABEL = "keyboard_statusbar_account_label"
        const val KEY_ACCOUNT_LABEL_MODE = "keyboard_statusbar_account_label_mode"
        const val KEY_TIPS_LAST_RESET_AT = "keyboard_statusbar_tips_last_reset_at_ms"
        const val KEY_LAST_KEYBOARD_ERROR = "last_keyboard_error"
        const val KEY_LAST_KEYBOARD_ERROR_AT = "last_keyboard_error_at"
        const val KEY_KEYBOARD_RECOVERY_COUNT = "keyboard_recovery_count"
        const val KEY_VOICE_RUNTIME_MODE = "voice_runtime_mode"
        const val KEY_VOICE_LANGUAGE_TAG = "voice_language_tag"
        const val KEY_VOICE_PACK_ID = "voice_pack_id"
        const val KEY_VOICE_ENGINE = "voice_engine"
        const val KEY_VOICE_MODEL_ARTIFACT_PATH = "voice_model_artifact_path"
        const val KEY_VOICE_FALLBACK_REASON = "voice_fallback_reason"
        const val KEY_VOICE_LAST_ERROR_CODE = "voice_last_error_code"
        const val VOICE_RUNTIME_LOCAL = "local"
        const val VOICE_RUNTIME_ANDROID_FALLBACK = "android_fallback"
        const val VOICE_RUNTIME_CLOUD_FALLBACK = "cloud_fallback"
        const val VOICE_RUNTIME_UNAVAILABLE = "unavailable"
        const val EMOJI_RECENT_SEPARATOR = "|"
        const val SYMBOL_RECENT_SEPARATOR = "\u001E"
        const val MAX_TEXT_RULES = 300
        const val MAX_CLIPBOARD_ENTRIES = 60
        const val MAX_CORNER_CONFIG_JSON_LENGTH = 24000
        const val MAX_THEME_CONFIG_JSON_LENGTH = 48000
        const val PRIVACY_AUTO = "auto"
        const val PRIVACY_STRICT = "strict"
        const val PRIVACY_STANDARD = "standard"
        const val THEME_SYSTEM = "system"
        const val THEME_LIGHT = "light"
        const val THEME_DARK = "dark"
        const val KEYBOARD_HEIGHT_MIN = 0.85f
        const val KEYBOARD_HEIGHT_MAX = 1.20f
        const val KEYBOARD_HEIGHT_DEFAULT = 1.0f
        const val ACTION_ROW_HEIGHT_MIN = 0.33333334f
        const val ACTION_ROW_HEIGHT_MAX = 1.0f
        const val ACTION_ROW_HEIGHT_DEFAULT = 1.0f
        const val MEDIA_STEP_PERCENT_MIN = 1
        const val MEDIA_STEP_PERCENT_MAX = 20
        const val MEDIA_VOLUME_STEP_PERCENT_DEFAULT = 5
        const val MEDIA_BRIGHTNESS_STEP_PERCENT_DEFAULT = 10
        const val DEFAULT_ACTION_BAR_LONG_PRESS_BEHAVIOR = "attach_context_row"
        const val BYTES_PER_MB = 1024L * 1024L

        fun normalizeActionRowHeightScale(value: Float): Float {
            return when {
                value < 0.50f -> ACTION_ROW_HEIGHT_MIN
                value < 0.84f -> 0.6666667f
                else -> 1.0f
            }
        }
    }
}
