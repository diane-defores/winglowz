package com.winflowz_app.winflowz_app.ime

enum class KeyboardLayoutProfile {
    QWERTY,
    AZERTY,
    ;

    companion object {
        fun fromRaw(raw: String?): KeyboardLayoutProfile {
            return values().firstOrNull { it.name.equals(raw, ignoreCase = true) } ?: QWERTY
        }
    }
}

enum class KeyboardLayoutMode {
    Letters,
    Numbers,
    Accents,
    Symbols,
}

enum class KeyboardPanelMode {
    None,
    Navigation,
    Accents,
    Emoji,
    Clipboard,
    ClipboardFull,
    Media,
    Snippets,
    Settings,
}

enum class KeyboardEmojiCategory {
    Recents,
    Smileys,
    Hands,
    Symbols,
}

enum class KeyboardFieldContextMode {
    Text,
    Email,
    Url,
    Phone,
    Number,
    Search,
}

enum class KeyboardKeyAction {
    KeyValue,
    Text,
    Backspace,
    ForwardDelete,
    DeleteWordBefore,
    DeleteWordAfter,
    Enter,
    Shift,
    ModeLetters,
    ModeNumbers,
    ModeAccents,
    ModeSymbols,
    ToggleNavigationPanel,
    ToggleAccentPanel,
    ToggleEmojiPanel,
    ToggleClipboardPanel,
    ToggleMediaPanel,
    ToggleSnippetsPanel,
    ToggleSettingsPanel,
    CopySelection,
    PasteClipboard,
    InsertClipboardEntry,
    ShowClipboardPins,
    MediaPrevious,
    MediaPlayPause,
    MediaNext,
    MediaNowPlaying,
    InsertSnippetOne,
    OpenWinFlowzAppSettings,
    OpenThemeSettings,
    ShowKeyboardPicker,
    ToggleCornerMode,
    ToggleLayoutProfile,
    ToggleDebugTouchOverlay,
    ToggleKeyVibration,
    ToggleKeySound,
    ToggleSpellingSuggestions,
    ToggleSpecialKeyCorners,
    ToggleFrenchLanguage,
    ToggleEnglishLanguage,
    ToggleDoubleSpacePeriod,
    TogglePunctuationAutoSpacing,
    SelectEmojiRecents,
    SelectEmojiSmileys,
    SelectEmojiHands,
    SelectEmojiSymbols,
    NavigateCharLeft,
    NavigateCharRight,
    NavigateWordLeft,
    NavigateWordRight,
    NavigateLineUp,
    NavigateLineDown,
    NavigateParagraphUp,
    NavigateParagraphDown,
    NavigateLineStart,
    NavigateLineEnd,
    ClosePanel,
    Voice,
    CutSelection,
    SelectAll,
    PastePlainClipboard,
    Undo,
    Redo,
    CancelSelection,
    InsertSuggestion,
}

data class KeyboardKeyGlyph(
    val primary: String,
    val topLeft: String? = null,
    val topRight: String? = null,
    val bottomLeft: String? = null,
    val bottomRight: String? = null,
) {
    fun outputFor(selection: GestureSelection): String? {
        return when (selection) {
            GestureSelection.PrimaryTap -> primary
            GestureSelection.TopLeft -> topLeft ?: primary
            GestureSelection.TopRight -> topRight ?: primary
            GestureSelection.BottomLeft -> bottomLeft ?: primary
            GestureSelection.BottomRight -> bottomRight ?: primary
            GestureSelection.Canceled -> null
        }
    }
}

data class KeyboardClipboardEntry(
    val content: String,
    val pinned: Boolean = false,
)

data class KeyboardKeySpec(
    val id: String,
    val label: String,
    val action: KeyboardKeyAction,
    val glyph: KeyboardKeyGlyph? = null,
    val keyValue: KeyboardKeyValue? = null,
    val weight: Float = 1f,
    val enabled: Boolean = true,
    val active: Boolean = false,
    val suggestion: String? = null,
)

data class KeyboardRowSpec(
    val keys: List<KeyboardKeySpec>,
    val leadingWeight: Float = 0f,
    val trailingWeight: Float = leadingWeight,
    val horizontalScrollable: Boolean = false,
)

data class KeyboardLayoutSnapshot(
    val rows: List<KeyboardRowSpec>,
    val mode: KeyboardLayoutMode,
    val panel: KeyboardPanelMode,
    val panelRowCount: Int,
    val suggestionRowCount: Int,
)

data class KeyboardLayoutRequest(
    val mode: KeyboardLayoutMode,
    val panel: KeyboardPanelMode,
    val shifted: Boolean,
    val fieldContext: KeyboardFieldContextMode,
    val layoutProfile: KeyboardLayoutProfile,
    val cornerModeEnabled: Boolean,
    val debugTouchOverlayEnabled: Boolean,
    val keyVibrationEnabled: Boolean = true,
    val keySoundEnabled: Boolean = false,
    val spellingSuggestionsEnabled: Boolean = true,
    val specialKeyCornersEnabled: Boolean = false,
    val frenchLanguageEnabled: Boolean = true,
    val englishLanguageEnabled: Boolean = true,
    val doubleSpacePeriodEnabled: Boolean,
    val punctuationAutoSpacingEnabled: Boolean,
    val emojiCategory: KeyboardEmojiCategory,
    val recentEmojis: List<String>,
    val enterLabel: String,
    val clipboardAllowed: Boolean,
    val clipboardEntries: List<KeyboardClipboardEntry> = emptyList(),
    val voiceAllowed: Boolean,
    val snippetsAllowed: Boolean,
    val snippets: List<KeyboardTextRule> = emptyList(),
    val suggestions: List<String>,
    val mediaNowPlayingLabel: String? = null,
)

object KeyboardLayoutBuilder {
    private val builtInModMap =
        KeyboardModMap().apply {
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("h"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_LEFT, "Left"))
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("j"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_DOWN, "Down"))
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("k"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_UP, "Up"))
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("l"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_RIGHT, "Right"))
        }

    fun build(request: KeyboardLayoutRequest): KeyboardLayoutSnapshot {
        val effectiveMode =
            if (request.fieldContext.isNumericEntry()) {
                KeyboardLayoutMode.Numbers
            } else {
                request.mode
            }

        val rows = mutableListOf<KeyboardRowSpec>()
        rows.add(actionRow(request, effectiveMode))
        val suggestionRows = if (request.panel.suppressesTypingRows()) emptyList() else suggestionRows(request)
        rows.addAll(suggestionRows)
        val panelRows = panelRows(request)
        rows.addAll(panelRows)
        if (!request.panel.suppressesTypingRows()) {
            rows.addAll(letterRows(request, effectiveMode))
            rows.add(controlRow(request, effectiveMode))
        }
        return KeyboardLayoutSnapshot(
            rows = rows,
            mode = effectiveMode,
            panel = request.panel,
            panelRowCount = panelRows.size,
            suggestionRowCount = suggestionRows.size,
        )
    }

    private fun KeyboardPanelMode.suppressesTypingRows(): Boolean {
        return this == KeyboardPanelMode.Settings || this == KeyboardPanelMode.ClipboardFull
    }

    private fun actionRow(
        request: KeyboardLayoutRequest,
        mode: KeyboardLayoutMode,
    ): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys =
                listOf(
                    modeKey("ABC", KeyboardKeyAction.ModeLetters, mode == KeyboardLayoutMode.Letters),
                    modeKey("123", KeyboardKeyAction.ModeNumbers, mode == KeyboardLayoutMode.Numbers),
                    panelKey("Acc", KeyboardKeyAction.ToggleAccentPanel, request.panel == KeyboardPanelMode.Accents),
                    modeKey("#+=", KeyboardKeyAction.ModeSymbols, mode == KeyboardLayoutMode.Symbols),
                    panelKey("Nav", KeyboardKeyAction.ToggleNavigationPanel, request.panel == KeyboardPanelMode.Navigation),
                    panelKey("Emoji", KeyboardKeyAction.ToggleEmojiPanel, request.panel == KeyboardPanelMode.Emoji),
                    panelKey(
                        "Clip",
                        KeyboardKeyAction.ToggleClipboardPanel,
                        request.panel == KeyboardPanelMode.Clipboard || request.panel == KeyboardPanelMode.ClipboardFull,
                        request.clipboardAllowed,
                    ),
                    panelKey("Snip", KeyboardKeyAction.ToggleSnippetsPanel, request.panel == KeyboardPanelMode.Snippets, request.snippetsAllowed),
                    panelKey("Media", KeyboardKeyAction.ToggleMediaPanel, request.panel == KeyboardPanelMode.Media),
                    panelKey("Prefs", KeyboardKeyAction.ToggleSettingsPanel, request.panel == KeyboardPanelMode.Settings),
                    KeyboardKeySpec("voice", "Mic", KeyboardKeyAction.Voice, enabled = request.voiceAllowed),
                ),
        )
    }

    private fun suggestionRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        val suggestions = request.suggestions.map { it.trim() }.filter { it.isNotEmpty() }.take(3)
        if (suggestions.isEmpty()) {
            return emptyList()
        }
        return listOf(
            KeyboardRowSpec(
                keys =
                    suggestions.mapIndexed { index, suggestion ->
                        KeyboardKeySpec(
                            id = "suggestion-$index",
                            label = suggestion,
                            action = KeyboardKeyAction.InsertSuggestion,
                            suggestion = suggestion,
                            weight = 1.4f,
                        )
                    },
            ),
        )
    }

    private fun panelRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return when (request.panel) {
            KeyboardPanelMode.None -> emptyList()
            KeyboardPanelMode.Navigation -> navigationPanelRows()
            KeyboardPanelMode.Accents -> accentPanelRows()
            KeyboardPanelMode.Emoji -> emojiPanelRows(request)
            KeyboardPanelMode.Clipboard -> listOf(clipboardPanelRow(request))
            KeyboardPanelMode.ClipboardFull -> clipboardFullPanelRows(request)
            KeyboardPanelMode.Media -> mediaPanelRows(request)
            KeyboardPanelMode.Snippets -> listOf(snippetsPanelRow(request))
            KeyboardPanelMode.Settings -> settingsPanelRows(request)
        }
    }

    private fun navigationPanelRows(): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-select-all", "All", KeyboardKeyAction.SelectAll),
                        KeyboardKeySpec("nav-copy", "Copy", KeyboardKeyAction.CopySelection),
                        KeyboardKeySpec("nav-cut", "Cut", KeyboardKeyAction.CutSelection),
                        KeyboardKeySpec("nav-paste", "Paste", KeyboardKeyAction.PasteClipboard),
                        KeyboardKeySpec("nav-undo", "Undo", KeyboardKeyAction.Undo),
                        KeyboardKeySpec("nav-redo", "Redo", KeyboardKeyAction.Redo),
                        KeyboardKeySpec("nav-close", "Back", KeyboardKeyAction.ClosePanel, weight = 1.2f),
                    ),
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-paragraph-up", "Para↑", KeyboardKeyAction.NavigateParagraphUp, weight = 1.3f),
                        KeyboardKeySpec("nav-line-up", "Line↑", KeyboardKeyAction.NavigateLineUp, weight = 1.3f),
                    ),
                leadingWeight = 1.5f,
                trailingWeight = 1.5f,
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-word-left", "Word←", KeyboardKeyAction.NavigateWordLeft, weight = 1.3f),
                        KeyboardKeySpec("nav-left", "←", KeyboardKeyAction.NavigateCharLeft, weight = 1.1f),
                        KeyboardKeySpec("nav-right", "→", KeyboardKeyAction.NavigateCharRight, weight = 1.1f),
                        KeyboardKeySpec("nav-word-right", "Word→", KeyboardKeyAction.NavigateWordRight, weight = 1.3f),
                    ),
                leadingWeight = 0.6f,
                trailingWeight = 0.6f,
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-line-down", "Line↓", KeyboardKeyAction.NavigateLineDown, weight = 1.3f),
                        KeyboardKeySpec("nav-paragraph-down", "Para↓", KeyboardKeyAction.NavigateParagraphDown, weight = 1.3f),
                    ),
                leadingWeight = 1.5f,
                trailingWeight = 1.5f,
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-del-before", "Del←", KeyboardKeyAction.Backspace),
                        KeyboardKeySpec("nav-del-word-before", "DelW←", KeyboardKeyAction.DeleteWordBefore, weight = 1.2f),
                        KeyboardKeySpec("nav-del-after", "Del→", KeyboardKeyAction.ForwardDelete, weight = 1.1f),
                        KeyboardKeySpec("nav-del-word-after", "DelW→", KeyboardKeyAction.DeleteWordAfter, weight = 1.2f),
                    ),
            ),
        )
    }

    private fun accentPanelRows(): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(
                listOf("é", "è", "ê", "ë", "à", "â", "ç").map { textKey(it) },
                leadingWeight = 0.35f,
                trailingWeight = 0.35f,
            ),
            KeyboardRowSpec(
                listOf("ù", "û", "ü", "î", "ï", "ô", "œ", "æ").map { textKey(it) },
                leadingWeight = 0.2f,
                trailingWeight = 0.2f,
            ),
        )
    }

    private fun emojiPanelRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        val categoryRow =
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("emoji-recents", "Rec", KeyboardKeyAction.SelectEmojiRecents, active = request.emojiCategory == KeyboardEmojiCategory.Recents),
                        KeyboardKeySpec("emoji-smileys", ":-)", KeyboardKeyAction.SelectEmojiSmileys, active = request.emojiCategory == KeyboardEmojiCategory.Smileys),
                        KeyboardKeySpec("emoji-hands", "Hands", KeyboardKeyAction.SelectEmojiHands, active = request.emojiCategory == KeyboardEmojiCategory.Hands),
                        KeyboardKeySpec("emoji-symbols", "Sym", KeyboardKeyAction.SelectEmojiSymbols, active = request.emojiCategory == KeyboardEmojiCategory.Symbols),
                        KeyboardKeySpec("emoji-close", "Close", KeyboardKeyAction.ClosePanel),
                    ),
            )

        val recents = request.recentEmojis.filter { it.isNotBlank() }.take(8)
        val smileys = listOf("😀", "😂", "😊", "😍", "🤔", "😅", "😭", "😎")
        val hands = listOf("👍", "👎", "👏", "🙏", "👌", "🤝", "✌️", "🤞")
        val symbols = listOf("❤️", "🔥", "✨", "✅", "❌", "⚠️", "🎯", "💡")
        val selected =
            when (request.emojiCategory) {
                KeyboardEmojiCategory.Recents -> if (recents.isEmpty()) smileys else recents
                KeyboardEmojiCategory.Smileys -> smileys
                KeyboardEmojiCategory.Hands -> hands
                KeyboardEmojiCategory.Symbols -> symbols
            }

        val emojiRows =
            selected.chunked(4).mapIndexed { index, chunk ->
                KeyboardRowSpec(
                    keys = chunk.map { textKey(label = it, output = it, weight = 1f) },
                    leadingWeight = if (index == 1 && chunk.size < 4) 0.6f else 0f,
                )
            }

        return listOf(categoryRow) + emojiRows
    }

    private fun clipboardPanelRow(request: KeyboardLayoutRequest): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys = clipboardEntryKeys(request.clipboardEntries.take(12), request.clipboardAllowed),
            horizontalScrollable = true,
        )
    }

    private fun clipboardFullPanelRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        val pinned = request.clipboardEntries.filter { it.pinned }
        val normal = request.clipboardEntries.filterNot { it.pinned }
        val entries = (pinned + normal).take(12)
        if (entries.isEmpty()) {
            return listOf(KeyboardRowSpec(keys = clipboardEntryKeys(emptyList(), request.clipboardAllowed)))
        }
        return entries.chunked(3).map { chunk ->
            KeyboardRowSpec(keys = clipboardEntryKeys(chunk, request.clipboardAllowed))
        }
    }

    private fun clipboardEntryKeys(
        entries: List<KeyboardClipboardEntry>,
        clipboardAllowed: Boolean,
    ): List<KeyboardKeySpec> {
        if (entries.isEmpty()) {
            return listOf(
                KeyboardKeySpec(
                    id = "clip-empty",
                    label = "Clipboard empty",
                    action = KeyboardKeyAction.InsertClipboardEntry,
                    enabled = false,
                    weight = 1.8f,
                ),
            )
        }
        return entries.mapIndexed { index, entry ->
            KeyboardKeySpec(
                id = "clip-entry-$index",
                label = clipboardLabel(entry),
                action = KeyboardKeyAction.InsertClipboardEntry,
                enabled = clipboardAllowed,
                active = entry.pinned,
                suggestion = entry.content,
                weight = 1.8f,
            )
        }
    }

    private fun clipboardLabel(entry: KeyboardClipboardEntry): String {
        val normalized = entry.content.replace(Regex("\\s+"), " ").trim()
        val label = if (normalized.length <= 24) normalized else normalized.take(23) + "..."
        return if (entry.pinned) "Pin $label" else label
    }

    private fun mediaPanelRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        val rows =
            mutableListOf(
                KeyboardRowSpec(
                    keys =
                        listOf(
                            KeyboardKeySpec("media-prev", "Prev", KeyboardKeyAction.MediaPrevious),
                            KeyboardKeySpec("media-play", ">||", KeyboardKeyAction.MediaPlayPause, weight = 1.2f),
                            KeyboardKeySpec("media-next", "Next", KeyboardKeyAction.MediaNext),
                            KeyboardKeySpec("media-now", "Now", KeyboardKeyAction.MediaNowPlaying),
                            KeyboardKeySpec("media-close", "Close", KeyboardKeyAction.ClosePanel),
                        ),
                ),
            )
        request.mediaNowPlayingLabel?.let { label ->
            rows.add(
                KeyboardRowSpec(
                    keys =
                        listOf(
                            KeyboardKeySpec(
                                "media-now-playing-label",
                                label,
                                KeyboardKeyAction.MediaNowPlaying,
                                weight = 5f,
                            ),
                        ),
                ),
            )
        }
        return rows
    }

    private fun snippetsPanelRow(request: KeyboardLayoutRequest): KeyboardRowSpec {
        val snippetKeys =
            request.snippets
                .take(12)
                .mapIndexed { index, rule ->
                    KeyboardKeySpec(
                        id = "snippet-$index",
                        label = snippetLabel(rule),
                        action = KeyboardKeyAction.InsertSnippetOne,
                        enabled = request.snippetsAllowed,
                        weight = 1.7f,
                        suggestion = rule.replacement,
                    )
                }
        val contentKeys =
            if (snippetKeys.isEmpty()) {
                listOf(
                    KeyboardKeySpec(
                        id = "snippet-empty",
                        label = "No snippets",
                        action = KeyboardKeyAction.InsertSnippetOne,
                        enabled = false,
                        weight = 1.8f,
                    ),
                )
            } else {
                snippetKeys
            }
        return KeyboardRowSpec(
            keys =
                contentKeys +
                    listOf(
                        KeyboardKeySpec(
                            id = "snippet-open",
                            label = "App",
                            action = KeyboardKeyAction.OpenWinFlowzAppSettings,
                            weight = 1.2f,
                        ),
                        KeyboardKeySpec("snippet-close", "Close", KeyboardKeyAction.ClosePanel),
                    ),
            horizontalScrollable = true,
        )
    }

    private fun snippetLabel(rule: KeyboardTextRule): String {
        val replacement = rule.replacement.trim()
        val label = replacement.ifBlank { rule.trigger.trim() }
        return if (label.length <= 18) label else label.take(17) + "..."
    }

    private fun settingsPanelRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("setting-keyboard-picker", "Keyboard", KeyboardKeyAction.ShowKeyboardPicker, weight = 1.3f),
                        KeyboardKeySpec("setting-app", "App", KeyboardKeyAction.OpenWinFlowzAppSettings),
                        KeyboardKeySpec("setting-theme", "Theme", KeyboardKeyAction.OpenThemeSettings),
                        KeyboardKeySpec("setting-layout", request.layoutProfile.name, KeyboardKeyAction.ToggleLayoutProfile, weight = 1.1f),
                        KeyboardKeySpec("setting-close", "Close", KeyboardKeyAction.ClosePanel),
                    ),
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec(
                            id = "setting-vibration",
                            label = if (request.keyVibrationEnabled) "Vibe on" else "Vibe off",
                            action = KeyboardKeyAction.ToggleKeyVibration,
                            active = request.keyVibrationEnabled,
                        ),
                        KeyboardKeySpec(
                            id = "setting-sound",
                            label = if (request.keySoundEnabled) "Sound on" else "Sound off",
                            action = KeyboardKeyAction.ToggleKeySound,
                            active = request.keySoundEnabled,
                        ),
                        KeyboardKeySpec(
                            id = "setting-debug",
                            label = if (request.debugTouchOverlayEnabled) "Debug on" else "Debug off",
                            action = KeyboardKeyAction.ToggleDebugTouchOverlay,
                            active = request.debugTouchOverlayEnabled,
                        ),
                        KeyboardKeySpec(
                            id = "setting-suggestions",
                            label = if (request.spellingSuggestionsEnabled) "Suggest on" else "Suggest off",
                            action = KeyboardKeyAction.ToggleSpellingSuggestions,
                            active = request.spellingSuggestionsEnabled,
                            weight = 1.2f,
                        ),
                    ),
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec(
                            id = "setting-language-fr",
                            label = if (request.frenchLanguageEnabled) "FR on" else "FR off",
                            action = KeyboardKeyAction.ToggleFrenchLanguage,
                            active = request.frenchLanguageEnabled,
                        ),
                        KeyboardKeySpec(
                            id = "setting-language-en",
                            label = if (request.englishLanguageEnabled) "EN on" else "EN off",
                            action = KeyboardKeyAction.ToggleEnglishLanguage,
                            active = request.englishLanguageEnabled,
                        ),
                    ),
                leadingWeight = 1f,
                trailingWeight = 1f,
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec(
                            id = "setting-corners",
                            label = if (request.cornerModeEnabled) "Corners on" else "Corners off",
                            action = KeyboardKeyAction.ToggleCornerMode,
                            active = request.cornerModeEnabled,
                            weight = 1.2f,
                        ),
                        KeyboardKeySpec(
                            id = "setting-double-space",
                            label = if (request.doubleSpacePeriodEnabled) "2sp on" else "2sp off",
                            action = KeyboardKeyAction.ToggleDoubleSpacePeriod,
                            active = request.doubleSpacePeriodEnabled,
                        ),
                        KeyboardKeySpec(
                            id = "setting-punct",
                            label = if (request.punctuationAutoSpacingEnabled) "Punc on" else "Punc off",
                            action = KeyboardKeyAction.TogglePunctuationAutoSpacing,
                            active = request.punctuationAutoSpacingEnabled,
                        ),
                        KeyboardKeySpec(
                            id = "setting-special-corners",
                            label = if (request.specialKeyCornersEnabled) "Special on" else "Special off",
                            action = KeyboardKeyAction.ToggleSpecialKeyCorners,
                            active = request.specialKeyCornersEnabled,
                            weight = 1.2f,
                        ),
                    ),
            ),
        )
    }

    private fun letterRows(
        request: KeyboardLayoutRequest,
        mode: KeyboardLayoutMode,
    ): List<KeyboardRowSpec> {
        return when (mode) {
            KeyboardLayoutMode.Letters -> letterRowsForProfile(request)
            KeyboardLayoutMode.Numbers -> numberRows()
            KeyboardLayoutMode.Accents -> accentRows()
            KeyboardLayoutMode.Symbols -> symbolRows()
        }
    }

    private fun letterRowsForProfile(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return when (request.layoutProfile) {
            KeyboardLayoutProfile.QWERTY ->
                listOf(
                    rowFromChars("qwertyuiop"),
                    rowFromChars("asdfghjkl", leading = 0.45f),
                    bottomLetterRowWithControls("zxcvbnm", request.shifted),
                )
            KeyboardLayoutProfile.AZERTY ->
                listOf(
                    rowFromChars("azertyuiop"),
                    rowFromChars("qsdfghjklm", leading = 0.25f),
                    bottomLetterRowWithControls("wxcvbn", request.shifted),
                )
        }
    }

    private fun bottomLetterRowWithControls(
        chars: String,
        shifted: Boolean,
    ): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys =
                listOf(shiftKey("Maj", shifted)) +
                    chars.map { letterKey(it) } +
                    KeyboardKeySpec("del-letter-row", "Del", KeyboardKeyAction.Backspace, weight = 1.2f),
        )
    }

    private fun rowFromChars(chars: String, leading: Float = 0f): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys = chars.map { letterKey(it) },
            leadingWeight = leading,
        )
    }

    private fun numberRows(): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(
                listOf(
                    textKey("@", weight = 0.9f),
                    textKey("+", weight = 0.9f),
                    textKey("1", weight = 1.1f),
                    textKey("2", weight = 1.1f),
                    textKey("3", weight = 1.1f),
                    textKey("-", weight = 0.9f),
                    textKey("#", weight = 0.9f),
                ),
            ),
            KeyboardRowSpec(
                listOf(
                    textKey("?", weight = 0.9f),
                    textKey("*", weight = 0.9f),
                    textKey("4", weight = 1.1f),
                    textKey("5", weight = 1.1f),
                    textKey("6", weight = 1.1f),
                    textKey("/", weight = 0.9f),
                    textKey("!", weight = 0.9f),
                ),
            ),
            KeyboardRowSpec(
                listOf(
                    textKey(":", weight = 0.9f),
                    textKey(".", weight = 0.9f),
                    textKey("7", weight = 1.1f),
                    textKey("8", weight = 1.1f),
                    textKey("9", weight = 1.1f),
                    textKey(",", weight = 0.9f),
                    textKey(";", weight = 0.9f),
                ),
            ),
        )
    }

    private fun accentRows(): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(listOf("à", "â", "ä", "ç", "é", "è", "ê", "ë").map { textKey(it) }, leadingWeight = 0.4f),
            KeyboardRowSpec(listOf("î", "ï", "ô", "ö", "ù", "û", "ü", "ÿ").map { textKey(it) }, leadingWeight = 0.4f),
            KeyboardRowSpec(listOf("œ", "æ", "ñ", "’", "—").map { textKey(it, weight = 1.2f) }, leadingWeight = 1.6f),
        )
    }

    private fun symbolRows(): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(listOf("[", "]", "{", "}", "#", "%", "^", "*", "+", "=").map { textKey(it) }),
            KeyboardRowSpec(listOf("_", "\\", "|", "~", "<", ">", "€", "£", "¥").map { textKey(it) }, leadingWeight = 0.45f),
            KeyboardRowSpec(listOf(".", ",", "?", "!", "'", "`", "•").map { textKey(it) }, leadingWeight = 1.2f),
        )
    }

    private fun controlRow(
        request: KeyboardLayoutRequest,
        mode: KeyboardLayoutMode,
    ): KeyboardRowSpec {
        val leftSymbol =
            when (request.fieldContext) {
                KeyboardFieldContextMode.Email -> "@"
                KeyboardFieldContextMode.Url -> "/"
                KeyboardFieldContextMode.Phone,
                KeyboardFieldContextMode.Number,
                -> "+"
                KeyboardFieldContextMode.Text,
                KeyboardFieldContextMode.Search,
                -> ","
            }
        val rightSymbol =
            when (request.fieldContext) {
                KeyboardFieldContextMode.Email -> ".com"
                KeyboardFieldContextMode.Url -> ".com"
                KeyboardFieldContextMode.Phone -> "#"
                KeyboardFieldContextMode.Number -> "-"
                KeyboardFieldContextMode.Text,
                KeyboardFieldContextMode.Search,
                -> "."
            }
        val shiftLabel = if (mode == KeyboardLayoutMode.Letters) "Maj" else "Shift"
        if (mode == KeyboardLayoutMode.Letters) {
            return KeyboardRowSpec(
                keys =
                    listOf(
                        modifierKey("Ctrl", KeyboardSystemModifier.Ctrl),
                        modifierKey("Alt", KeyboardSystemModifier.Alt),
                        modifierKey("Fn", KeyboardSystemModifier.Fn),
                        textKey(leftSymbol),
                        textKey("Espace", " ", weight = 3f),
                        textKey(rightSymbol),
                        KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter, weight = 1.3f),
                    ),
            )
        }
        return KeyboardRowSpec(
            keys =
                listOf(
                    shiftKey(shiftLabel, active = false),
                    modifierKey("Ctrl", KeyboardSystemModifier.Ctrl),
                    modifierKey("Alt", KeyboardSystemModifier.Alt),
                    modifierKey("Fn", KeyboardSystemModifier.Fn),
                    textKey(leftSymbol),
                    textKey("Espace", " ", weight = 3f),
                    textKey(rightSymbol),
                    KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter, weight = 1.3f),
                    KeyboardKeySpec("del", "Del", KeyboardKeyAction.Backspace, weight = 1.2f),
            ),
        )
    }

    private fun shiftKey(
        label: String,
        active: Boolean,
    ): KeyboardKeySpec {
        return KeyboardKeySpec(
            id = "shift",
            label = label,
            action = KeyboardKeyAction.Shift,
            keyValue = KeyboardKeyValue.modifier(KeyboardSystemModifier.Shift, label),
            weight = 1.2f,
            active = active,
        )
    }

    private fun modeKey(
        label: String,
        action: KeyboardKeyAction,
        active: Boolean,
    ): KeyboardKeySpec {
        return KeyboardKeySpec(
            id = "mode-$label",
            label = label,
            action = action,
            active = active,
        )
    }

    private fun panelKey(
        label: String,
        action: KeyboardKeyAction,
        active: Boolean,
        enabled: Boolean = true,
    ): KeyboardKeySpec {
        return KeyboardKeySpec(
            id = "panel-$label",
            label = label,
            action = action,
            active = active,
            enabled = enabled,
        )
    }

    private fun letterKey(char: Char): KeyboardKeySpec {
        val lower = char.lowercase()
        val parsed = KeyboardKeyValueParser.parse(lower)
        return KeyboardKeySpec(
            id = "letter-$lower",
            label = parsed.renderLabel(),
            action = KeyboardKeyAction.Text,
            glyph = glyphFor(lower[0]),
            keyValue = parsed,
        )
    }

    private fun KeyboardFieldContextMode.isNumericEntry(): Boolean {
        return this == KeyboardFieldContextMode.Phone || this == KeyboardFieldContextMode.Number
    }

    private fun textKey(
        label: String,
        output: String = label,
        weight: Float = 1f,
    ): KeyboardKeySpec {
        val parsed = KeyboardKeyValueParser.parse(if (label == output) output else "$label:'${escapeKeyValue(output)}'")
        return KeyboardKeySpec(
            id = "text-$label-$output",
            label = parsed.renderLabel(),
            action = KeyboardKeyAction.Text,
            glyph = KeyboardKeyGlyph(primary = output),
            keyValue = parsed,
            weight = weight,
        )
    }

    private fun modifierKey(
        label: String,
        modifier: KeyboardSystemModifier,
    ): KeyboardKeySpec {
        val parsed = KeyboardKeyValueParser.parse("$label:modifier:${modifier.name}")
        return KeyboardKeySpec(
            id = "modifier-${modifier.name.lowercase()}",
            label = parsed.renderLabel(),
            action = KeyboardKeyAction.KeyValue,
            keyValue = parsed,
            weight = 0.9f,
        )
    }

    fun defaultModMap(): KeyboardModMap = builtInModMap

    private fun escapeKeyValue(value: String): String = value.replace("\\", "\\\\").replace("'", "\\'")

    private fun glyphFor(char: Char): KeyboardKeyGlyph {
        return when (char) {
            'a' -> KeyboardKeyGlyph("a", topLeft = "à", topRight = "â", bottomLeft = "ä", bottomRight = "æ")
            'e' -> KeyboardKeyGlyph("e", topLeft = "é", topRight = "è", bottomLeft = "ê", bottomRight = "ë")
            'i' -> KeyboardKeyGlyph("i", topLeft = "î", topRight = "ï")
            'o' -> KeyboardKeyGlyph("o", topLeft = "ô", topRight = "ö")
            'u' -> KeyboardKeyGlyph("u", topLeft = "ù", topRight = "û", bottomLeft = "ü")
            'c' -> KeyboardKeyGlyph("c", topLeft = "ç")
            'n' -> KeyboardKeyGlyph("n", topLeft = "ñ")
            's' -> KeyboardKeyGlyph("s", topRight = "ß")
            else -> KeyboardKeyGlyph(primary = char.toString())
        }
    }
}
