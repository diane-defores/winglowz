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
    Emoji,
    Clipboard,
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
    ToggleEmojiPanel,
    ToggleClipboardPanel,
    ToggleMediaPanel,
    ToggleSnippetsPanel,
    ToggleSettingsPanel,
    CopySelection,
    PasteClipboard,
    ShowClipboardPins,
    MediaPrevious,
    MediaPlayPause,
    MediaNext,
    InsertSnippetOne,
    OpenWinFlowzAppSettings,
    ToggleCornerMode,
    ToggleLayoutProfile,
    ToggleDebugTouchOverlay,
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

data class KeyboardKeySpec(
    val id: String,
    val label: String,
    val action: KeyboardKeyAction,
    val glyph: KeyboardKeyGlyph? = null,
    val weight: Float = 1f,
    val enabled: Boolean = true,
    val active: Boolean = false,
    val suggestion: String? = null,
)

data class KeyboardRowSpec(
    val keys: List<KeyboardKeySpec>,
    val leadingWeight: Float = 0f,
    val trailingWeight: Float = leadingWeight,
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
    val doubleSpacePeriodEnabled: Boolean,
    val punctuationAutoSpacingEnabled: Boolean,
    val emojiCategory: KeyboardEmojiCategory,
    val recentEmojis: List<String>,
    val enterLabel: String,
    val clipboardAllowed: Boolean,
    val voiceAllowed: Boolean,
    val snippetsAllowed: Boolean,
    val suggestions: List<String>,
)

object KeyboardLayoutBuilder {
    fun build(request: KeyboardLayoutRequest): KeyboardLayoutSnapshot {
        val effectiveMode =
            if (request.fieldContext.isNumericEntry()) {
                KeyboardLayoutMode.Numbers
            } else {
                request.mode
            }

        val rows = mutableListOf<KeyboardRowSpec>()
        rows.add(actionRow(request, effectiveMode))
        val suggestionRows = suggestionRows(request)
        rows.addAll(suggestionRows)
        val panelRows = panelRows(request)
        rows.addAll(panelRows)
        rows.addAll(letterRows(request, effectiveMode))
        rows.add(controlRow(request, effectiveMode))
        return KeyboardLayoutSnapshot(
            rows = rows,
            mode = effectiveMode,
            panel = request.panel,
            panelRowCount = panelRows.size,
            suggestionRowCount = suggestionRows.size,
        )
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
                    modeKey("Acc", KeyboardKeyAction.ModeAccents, mode == KeyboardLayoutMode.Accents),
                    modeKey("#+=", KeyboardKeyAction.ModeSymbols, mode == KeyboardLayoutMode.Symbols),
                    panelKey("Nav", KeyboardKeyAction.ToggleNavigationPanel, request.panel == KeyboardPanelMode.Navigation),
                    panelKey("Emoji", KeyboardKeyAction.ToggleEmojiPanel, request.panel == KeyboardPanelMode.Emoji),
                    panelKey("Clip", KeyboardKeyAction.ToggleClipboardPanel, request.panel == KeyboardPanelMode.Clipboard, request.clipboardAllowed),
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
            KeyboardPanelMode.Emoji -> emojiPanelRows(request)
            KeyboardPanelMode.Clipboard -> listOf(clipboardPanelRow(request))
            KeyboardPanelMode.Media -> listOf(mediaPanelRow())
            KeyboardPanelMode.Snippets -> listOf(snippetsPanelRow(request))
            KeyboardPanelMode.Settings -> listOf(settingsPanelRow(request))
        }
    }

    private fun navigationPanelRows(): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-start", "Start", KeyboardKeyAction.NavigateLineStart),
                        KeyboardKeySpec("nav-word-left", "Word←", KeyboardKeyAction.NavigateWordLeft),
                        KeyboardKeySpec("nav-left", "←", KeyboardKeyAction.NavigateCharLeft),
                        KeyboardKeySpec("nav-right", "→", KeyboardKeyAction.NavigateCharRight),
                        KeyboardKeySpec("nav-word-right", "Word→", KeyboardKeyAction.NavigateWordRight),
                        KeyboardKeySpec("nav-end", "End", KeyboardKeyAction.NavigateLineEnd),
                    ),
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-del-before", "Del", KeyboardKeyAction.Backspace),
                        KeyboardKeySpec("nav-del-word-before", "DelW←", KeyboardKeyAction.DeleteWordBefore),
                        KeyboardKeySpec("nav-del-after", "FDel", KeyboardKeyAction.ForwardDelete),
                        KeyboardKeySpec("nav-del-word-after", "DelW→", KeyboardKeyAction.DeleteWordAfter),
                        KeyboardKeySpec("nav-cancel", "Esc", KeyboardKeyAction.CancelSelection),
                        KeyboardKeySpec("nav-close", "Back", KeyboardKeyAction.ClosePanel, weight = 1.2f),
                    ),
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
            keys =
                listOf(
                    KeyboardKeySpec(
                        id = "clip-copy",
                        label = "Copy",
                        action = KeyboardKeyAction.CopySelection,
                        enabled = request.clipboardAllowed,
                        weight = 1.2f,
                    ),
                    KeyboardKeySpec(
                        id = "clip-cut",
                        label = "Cut",
                        action = KeyboardKeyAction.CutSelection,
                        enabled = request.clipboardAllowed,
                    ),
                    KeyboardKeySpec(
                        id = "clip-paste",
                        label = "Paste",
                        action = KeyboardKeyAction.PasteClipboard,
                        enabled = request.clipboardAllowed,
                        weight = 1.2f,
                    ),
                    KeyboardKeySpec(
                        id = "clip-paste-plain",
                        label = "Plain",
                        action = KeyboardKeyAction.PastePlainClipboard,
                        enabled = request.clipboardAllowed,
                    ),
                    KeyboardKeySpec(
                        id = "clip-select-all",
                        label = "All",
                        action = KeyboardKeyAction.SelectAll,
                    ),
                    KeyboardKeySpec(
                        id = "clip-undo",
                        label = "Undo",
                        action = KeyboardKeyAction.Undo,
                    ),
                    KeyboardKeySpec(
                        id = "clip-redo",
                        label = "Redo",
                        action = KeyboardKeyAction.Redo,
                    ),
                    KeyboardKeySpec(
                        id = "clip-pins",
                        label = "Pins app",
                        action = KeyboardKeyAction.ShowClipboardPins,
                        enabled = request.clipboardAllowed,
                    ),
                    KeyboardKeySpec(
                        id = "clip-close",
                        label = "Close",
                        action = KeyboardKeyAction.ClosePanel,
                    ),
                ),
        )
    }

    private fun mediaPanelRow(): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys =
                listOf(
                    KeyboardKeySpec("media-prev", "Prev", KeyboardKeyAction.MediaPrevious),
                    KeyboardKeySpec("media-play", ">||", KeyboardKeyAction.MediaPlayPause, weight = 1.2f),
                    KeyboardKeySpec("media-next", "Next", KeyboardKeyAction.MediaNext),
                    KeyboardKeySpec("media-close", "Close", KeyboardKeyAction.ClosePanel),
                ),
        )
    }

    private fun snippetsPanelRow(request: KeyboardLayoutRequest): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys =
                listOf(
                    KeyboardKeySpec(
                        id = "snippet-one",
                        label = "Snippet",
                        action = KeyboardKeyAction.InsertSnippetOne,
                        enabled = request.snippetsAllowed,
                        weight = 1.8f,
                    ),
                    KeyboardKeySpec(
                        id = "snippet-open",
                        label = "App",
                        action = KeyboardKeyAction.OpenWinFlowzAppSettings,
                        weight = 1.2f,
                    ),
                    KeyboardKeySpec("snippet-close", "Close", KeyboardKeyAction.ClosePanel),
                ),
        )
    }

    private fun settingsPanelRow(request: KeyboardLayoutRequest): KeyboardRowSpec {
        return KeyboardRowSpec(
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
                        id = "setting-layout",
                        label = request.layoutProfile.name,
                        action = KeyboardKeyAction.ToggleLayoutProfile,
                        weight = 1.1f,
                    ),
                    KeyboardKeySpec(
                        id = "setting-debug",
                        label = if (request.debugTouchOverlayEnabled) "Debug on" else "Debug off",
                        action = KeyboardKeyAction.ToggleDebugTouchOverlay,
                        active = request.debugTouchOverlayEnabled,
                        weight = 1.1f,
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
                        id = "setting-app",
                        label = "App",
                        action = KeyboardKeyAction.OpenWinFlowzAppSettings,
                    ),
                    KeyboardKeySpec(
                        id = "setting-close",
                        label = "Close",
                        action = KeyboardKeyAction.ClosePanel,
                    ),
                ),
        )
    }

    private fun letterRows(
        request: KeyboardLayoutRequest,
        mode: KeyboardLayoutMode,
    ): List<KeyboardRowSpec> {
        return when (mode) {
            KeyboardLayoutMode.Letters -> letterRowsForProfile(request.layoutProfile)
            KeyboardLayoutMode.Numbers -> numberRows()
            KeyboardLayoutMode.Accents -> accentRows()
            KeyboardLayoutMode.Symbols -> symbolRows()
        }
    }

    private fun letterRowsForProfile(profile: KeyboardLayoutProfile): List<KeyboardRowSpec> {
        return when (profile) {
            KeyboardLayoutProfile.QWERTY ->
                listOf(
                    rowFromChars("qwertyuiop"),
                    rowFromChars("asdfghjkl", leading = 0.45f),
                    rowFromChars("zxcvbnm", leading = 1.25f),
                )
            KeyboardLayoutProfile.AZERTY ->
                listOf(
                    rowFromChars("azertyuiop"),
                    rowFromChars("qsdfghjklm", leading = 0.25f),
                    rowFromChars("wxcvbn", leading = 1.7f),
                )
        }
    }

    private fun rowFromChars(chars: String, leading: Float = 0f): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys = chars.map { letterKey(it) },
            leadingWeight = leading,
        )
    }

    private fun numberRows(): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec("1234567890".map { textKey(it.toString()) }),
            KeyboardRowSpec(listOf("-", "/", ":", ";", "(", ")", "$", "&", "@", "\"").map { textKey(it) }),
            KeyboardRowSpec(listOf(".", ",", "?", "!", "'", "+", "=").map { textKey(it) }, leadingWeight = 1.2f),
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
        return KeyboardRowSpec(
            keys =
                listOf(
                    KeyboardKeySpec(
                        id = "shift",
                        label = shiftLabel,
                        action = KeyboardKeyAction.Shift,
                        weight = 1.2f,
                        active = request.shifted && mode == KeyboardLayoutMode.Letters,
                    ),
                    textKey(leftSymbol),
                    textKey("Espace", " ", weight = 4f),
                    textKey(rightSymbol),
                    KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter, weight = 1.3f),
                    KeyboardKeySpec("del", "Del", KeyboardKeyAction.Backspace, weight = 1.2f),
                ),
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
        return KeyboardKeySpec(
            id = "letter-$lower",
            label = lower,
            action = KeyboardKeyAction.Text,
            glyph = glyphFor(lower[0]),
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
        return KeyboardKeySpec(
            id = "text-$label-$output",
            label = label,
            action = KeyboardKeyAction.Text,
            glyph = KeyboardKeyGlyph(primary = output),
            weight = weight,
        )
    }

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
