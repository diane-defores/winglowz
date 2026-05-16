package com.winflowz_app.winflowz_app.ime

import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarController
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarState
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionCatalog
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionEnvironment
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionRenderer

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
    Nature,
    Food,
    Objects,
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
    InsertTab,
    Escape,
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
    OpenMediaApp,
    MediaStop,
    MediaShuffle,
    MediaLoop,
    VolumeDown,
    VolumeUp,
    BrightnessDown,
    BrightnessUp,
    InsertSnippetOne,
    OpenWinFlowzSnippets,
    OpenWinFlowzSettings,
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
    DecreaseKeyboardHeight,
    IncreaseKeyboardHeight,
    ToggleCompactMode,
    SelectEmojiRecents,
    SelectEmojiSmileys,
    SelectEmojiHands,
    SelectEmojiSymbols,
    SelectEmojiNature,
    SelectEmojiFood,
    SelectEmojiObjects,
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
)

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
    val pinned: Boolean = false,
    val actionSurface: Boolean = false,
    val actionDescriptorId: String? = null,
    val actionDescriptorPrimary: Boolean = false,
    val suggestion: String? = null,
    val cornerAssignments: KeyboardCornerAssignments = KeyboardCornerAssignments.Empty,
)

data class KeyboardRowSpec(
    val keys: List<KeyboardKeySpec>,
    val leadingWeight: Float = 0f,
    val trailingWeight: Float = leadingWeight,
    val horizontalScrollable: Boolean = false,
    val pagedHorizontalScrollable: Boolean = false,
    val visiblePageKeyCount: Int? = null,
    val rowId: String? = null,
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
    val keyboardHeightScale: Float = KeyboardStateStore.KEYBOARD_HEIGHT_DEFAULT,
    val compactModeEnabled: Boolean = false,
    val emojiCategory: KeyboardEmojiCategory,
    val recentEmojis: List<String>,
    val enterLabel: String,
    val clipboardAllowed: Boolean,
    val clipboardEntries: List<KeyboardClipboardEntry> = emptyList(),
    val voiceAllowed: Boolean,
    val snippetsAllowed: Boolean,
    val mediaControlsEnabled: Boolean = true,
    val snippets: List<KeyboardTextRule> = emptyList(),
    val suggestions: List<String>,
    val actionBarState: KeyboardActionBarState = KeyboardActionBarState(),
    val mediaNowPlayingLabel: String? = null,
    val cornerConfig: KeyboardCornerConfig = KeyboardCornerConfig(),
    val fieldPolicy: KeyboardFieldPolicy = KeyboardSecurityPolicy.evaluate(null, KeyboardStateStore.PRIVACY_AUTO),
)

object KeyboardLayoutBuilder {
    private val builtInModMap =
        KeyboardModMap().apply {
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("h"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_LEFT, "Left"))
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("j"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_DOWN, "Down"))
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("k"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_UP, "Up"))
            add(KeyboardSystemModifier.Fn, KeyboardKeyValue.text("l"), KeyboardKeyValue.keyEvent(android.view.KeyEvent.KEYCODE_DPAD_RIGHT, "Right"))
        }

    private val actionBarController = KeyboardActionBarController(KeyboardActionCatalog.default())
    private val actionRenderer = KeyboardActionRenderer()

    fun build(request: KeyboardLayoutRequest): KeyboardLayoutSnapshot {
        val effectiveMode =
            if (request.fieldContext.isNumericEntry()) {
                KeyboardLayoutMode.Numbers
            } else {
                request.mode
            }

        val actionEnvironment =
            KeyboardActionEnvironment(
                fieldPolicy = request.fieldPolicy,
                layoutMode = effectiveMode,
                panelMode = request.panel,
                clipboardAllowed = request.clipboardAllowed,
                voiceAllowed = request.voiceAllowed,
                snippetsAllowed = request.snippetsAllowed,
                mediaControlsEnabled = request.mediaControlsEnabled,
            )
        val renderedActionRows =
            actionRenderer.renderRows(
                actionBarController.buildRenderSnapshot(
                    state = request.actionBarState,
                    environment = actionEnvironment,
                ),
            )

        val rows = mutableListOf<KeyboardRowSpec>()
        rows.add(renderedActionRows.first())
        val suggestionRows =
            if (request.panel.suppressesTypingRows(request.compactModeEnabled)) {
                emptyList()
            } else {
                renderedActionRows.drop(1) + suggestionRows(request)
            }
        rows.addAll(suggestionRows)
        val panelRows = panelRows(request)
        rows.addAll(panelRows)
        if (!request.panel.suppressesTypingRows(request.compactModeEnabled)) {
            rows.addAll(letterRows(request, effectiveMode))
            if (!request.compactModeEnabled) {
                rows.add(controlRow(request, effectiveMode))
            }
        }
        val resolvedRows = rows.map { row -> attachCornerAssignments(row, request) }
        return KeyboardLayoutSnapshot(
            rows = resolvedRows,
            mode = effectiveMode,
            panel = request.panel,
            panelRowCount = panelRows.size,
            suggestionRowCount = suggestionRows.size,
        )
    }

    fun safeFallback(): KeyboardLayoutSnapshot {
        return KeyboardLayoutSnapshot(
            rows =
                listOf(
                    KeyboardRowSpec(
                        keys =
                            listOf(
                                KeyboardKeySpec("fallback-status", "Recovered", KeyboardKeyAction.ClosePanel, enabled = false, weight = 2f),
                                KeyboardKeySpec("fallback-abc", "ABC", KeyboardKeyAction.ModeLetters),
                                KeyboardKeySpec("fallback-del", "Del", KeyboardKeyAction.Backspace),
                            ),
                    ),
                    KeyboardRowSpec(
                        keys = "asdfghjkl".map { char -> safeTextKey(char.toString()) },
                    ),
                    KeyboardRowSpec(
                        keys =
                            listOf(
                                safeTextKey("z"),
                                safeTextKey("x"),
                                safeTextKey("c"),
                                safeTextKey("v"),
                                safeTextKey("b"),
                                safeTextKey("n"),
                                safeTextKey("m"),
                                safeTextKey(" ", label = "Space", weight = 2.2f),
                                KeyboardKeySpec("fallback-enter", "Enter", KeyboardKeyAction.Enter, weight = 1.2f),
                            ),
                    ),
                ),
            mode = KeyboardLayoutMode.Letters,
            panel = KeyboardPanelMode.None,
            panelRowCount = 0,
            suggestionRowCount = 0,
        )
    }

    private fun safeTextKey(
        output: String,
        label: String = output,
        weight: Float = 1f,
    ): KeyboardKeySpec {
        return KeyboardKeySpec(
            id = if (output == " ") "fallback-space" else "fallback-text-${output.codePoints().toArray().joinToString("-")}",
            label = label,
            action = KeyboardKeyAction.Text,
            glyph = KeyboardKeyGlyph(primary = output),
            keyValue = KeyboardKeyValue.text(output, label),
            weight = weight,
        )
    }

    private fun attachCornerAssignments(
        row: KeyboardRowSpec,
        request: KeyboardLayoutRequest,
    ): KeyboardRowSpec {
        return row.copy(
            keys =
                row.keys.map { key ->
                    key.copy(
                        cornerAssignments =
                            KeyboardCornerShortcutResolver.resolve(
                                key = key,
                                config = request.cornerConfig,
                                cornerModeEnabled = request.cornerModeEnabled,
                                specialKeyCornersEnabled = request.specialKeyCornersEnabled,
                                fieldPolicy = request.fieldPolicy,
                            ),
                    )
                },
        )
    }

    private fun KeyboardPanelMode.suppressesTypingRows(compactModeEnabled: Boolean): Boolean {
        return this == KeyboardPanelMode.Settings ||
            this == KeyboardPanelMode.ClipboardFull ||
            (compactModeEnabled && this != KeyboardPanelMode.None)
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
            KeyboardPanelMode.Navigation -> navigationPanelRows(request.compactModeEnabled).asActionSurfaceRows()
            KeyboardPanelMode.Accents -> accentPanelRows(request.compactModeEnabled).asActionSurfaceRows()
            KeyboardPanelMode.Emoji -> emojiPanelRows(request).asActionSurfaceRows()
            KeyboardPanelMode.Clipboard -> listOf(clipboardPanelRow(request)).asActionSurfaceRows()
            KeyboardPanelMode.ClipboardFull -> clipboardFullPanelRows(request).asActionSurfaceRows()
            KeyboardPanelMode.Media -> mediaPanelRows(request).asActionSurfaceRows()
            KeyboardPanelMode.Snippets -> listOf(snippetsPanelRow(request)).asActionSurfaceRows()
            KeyboardPanelMode.Settings -> settingsPanelRows(request).asActionSurfaceRows()
        }
    }

    private fun navigationPanelRows(compactModeEnabled: Boolean): List<KeyboardRowSpec> {
        if (compactModeEnabled) {
            return listOf(
                KeyboardRowSpec(
                    keys =
                        listOf(
                            KeyboardKeySpec("nav-select-all", "All", KeyboardKeyAction.SelectAll),
                            KeyboardKeySpec("nav-copy", "Copy", KeyboardKeyAction.CopySelection),
                            KeyboardKeySpec("nav-del-word-before", "DelW←", KeyboardKeyAction.DeleteWordBefore),
                            KeyboardKeySpec("nav-del-word-after", "DelW→", KeyboardKeyAction.DeleteWordAfter),
                            KeyboardKeySpec("nav-paragraph-up", "⏫", KeyboardKeyAction.NavigateParagraphUp),
                            KeyboardKeySpec("nav-line-up", "↑", KeyboardKeyAction.NavigateLineUp),
                        ),
                ),
                KeyboardRowSpec(
                    keys =
                        listOf(
                            KeyboardKeySpec("nav-cut", "Cut", KeyboardKeyAction.CutSelection),
                            KeyboardKeySpec("nav-paste", "Paste", KeyboardKeyAction.PasteClipboard),
                            KeyboardKeySpec("nav-word-left", "Word←", KeyboardKeyAction.NavigateWordLeft),
                            KeyboardKeySpec("nav-word-right", "Word→", KeyboardKeyAction.NavigateWordRight),
                            KeyboardKeySpec("nav-paragraph-down", "⏬", KeyboardKeyAction.NavigateParagraphDown),
                            KeyboardKeySpec("nav-line-down", "↓", KeyboardKeyAction.NavigateLineDown),
                        ),
                ),
                KeyboardRowSpec(
                    keys =
                        listOf(
                            KeyboardKeySpec("nav-undo", "Undo", KeyboardKeyAction.Undo),
                            KeyboardKeySpec("nav-redo", "Redo", KeyboardKeyAction.Redo),
                            KeyboardKeySpec("nav-del-before", "Del←", KeyboardKeyAction.Backspace),
                            KeyboardKeySpec("nav-del-after", "Del→", KeyboardKeyAction.ForwardDelete),
                            KeyboardKeySpec("nav-left", "←", KeyboardKeyAction.NavigateCharLeft),
                            KeyboardKeySpec("nav-right", "→", KeyboardKeyAction.NavigateCharRight),
                        ),
                ),
            )
        }
        return listOf(
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-select-all", "All", KeyboardKeyAction.SelectAll),
                        KeyboardKeySpec("nav-copy", "Copy", KeyboardKeyAction.CopySelection),
                        KeyboardKeySpec("nav-del-word-before", "DelW←", KeyboardKeyAction.DeleteWordBefore),
                        KeyboardKeySpec("nav-del-word-after", "DelW→", KeyboardKeyAction.DeleteWordAfter),
                        KeyboardKeySpec("nav-paragraph-up", "⏫", KeyboardKeyAction.NavigateParagraphUp),
                        KeyboardKeySpec("nav-line-up", "↑", KeyboardKeyAction.NavigateLineUp),
                    ),
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-cut", "Cut", KeyboardKeyAction.CutSelection),
                        KeyboardKeySpec("nav-paste", "Paste", KeyboardKeyAction.PasteClipboard),
                        KeyboardKeySpec("nav-word-left", "Word←", KeyboardKeyAction.NavigateWordLeft),
                        KeyboardKeySpec("nav-word-right", "Word→", KeyboardKeyAction.NavigateWordRight),
                        KeyboardKeySpec("nav-paragraph-down", "⏬", KeyboardKeyAction.NavigateParagraphDown),
                        KeyboardKeySpec("nav-line-down", "↓", KeyboardKeyAction.NavigateLineDown),
                    ),
            ),
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("nav-undo", "Undo", KeyboardKeyAction.Undo),
                        KeyboardKeySpec("nav-redo", "Redo", KeyboardKeyAction.Redo),
                        KeyboardKeySpec("nav-del-before", "Del←", KeyboardKeyAction.Backspace),
                        KeyboardKeySpec("nav-del-after", "Del→", KeyboardKeyAction.ForwardDelete),
                        KeyboardKeySpec("nav-left", "←", KeyboardKeyAction.NavigateCharLeft),
                        KeyboardKeySpec("nav-right", "→", KeyboardKeyAction.NavigateCharRight),
                    ),
            ),
        )
    }

    private fun accentPanelRows(compactModeEnabled: Boolean): List<KeyboardRowSpec> {
        val rows = listOf(
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
        if (!compactModeEnabled) {
            return rows
        }
        return rows +
            KeyboardRowSpec(
                listOf("É", "È", "Ê", "À", "Â", "Ç", "Œ", "Æ").map { textKey(it) } +
                    KeyboardKeySpec("accent-close", "Back", KeyboardKeyAction.ClosePanel),
                leadingWeight = 0.1f,
                trailingWeight = 0.1f,
            )
    }

    private fun emojiPanelRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        val categoryRow =
            KeyboardRowSpec(
                keys =
                    listOf(
                        KeyboardKeySpec("emoji-recents", "🕘", KeyboardKeyAction.SelectEmojiRecents, active = request.emojiCategory == KeyboardEmojiCategory.Recents),
                        KeyboardKeySpec("emoji-smileys", ":-)", KeyboardKeyAction.SelectEmojiSmileys, active = request.emojiCategory == KeyboardEmojiCategory.Smileys),
                        KeyboardKeySpec("emoji-hands", "👏", KeyboardKeyAction.SelectEmojiHands, active = request.emojiCategory == KeyboardEmojiCategory.Hands),
                        KeyboardKeySpec("emoji-symbols", "✨", KeyboardKeyAction.SelectEmojiSymbols, active = request.emojiCategory == KeyboardEmojiCategory.Symbols),
                        KeyboardKeySpec("emoji-nature", "🌿", KeyboardKeyAction.SelectEmojiNature, active = request.emojiCategory == KeyboardEmojiCategory.Nature),
                        KeyboardKeySpec("emoji-food", "🍔", KeyboardKeyAction.SelectEmojiFood, active = request.emojiCategory == KeyboardEmojiCategory.Food),
                        KeyboardKeySpec("emoji-objects", "💡", KeyboardKeyAction.SelectEmojiObjects, active = request.emojiCategory == KeyboardEmojiCategory.Objects),
                        KeyboardKeySpec("emoji-close", "×", KeyboardKeyAction.ClosePanel),
                    ),
            )

        val smileys = listOf("😀", "😃", "😄", "😁", "😂", "🤣", "😊", "😍", "🥰", "😘", "😎", "🤔", "😅", "😭", "😤", "😴")
        val hands = listOf("👍", "👎", "👏", "🙏", "👌", "🤝", "✌️", "🤞", "🤟", "👋", "🙌", "🫶", "💪", "☝️", "👀", "🫡")
        val symbols = listOf("❤️", "🔥", "✨", "✅", "❌", "⚠️", "🎯", "💡", "⭐", "💥", "💯", "🔔", "📌", "🔒", "🔁", "➕")
        val nature = listOf("🌿", "🌱", "🌴", "🌵", "🌸", "🌻", "🌙", "☀️", "⭐", "🌈", "⚡", "💧", "🔥", "🌊", "🍀", "🌍")
        val food = listOf("🍔", "🍕", "🍟", "🌮", "🍣", "🍜", "🍩", "🍪", "🍫", "☕", "🍺", "🍎", "🍌", "🍓", "🥑", "🥐")
        val objects = listOf("💡", "📌", "📎", "✏️", "📱", "💻", "⌚", "🎧", "📷", "🔑", "🔒", "🧲", "🧰", "⚙️", "🛠️", "🧪")
        val recents = (request.recentEmojis.filter { it.isNotBlank() } + smileys).distinct().take(16)
        val selected =
            when (request.emojiCategory) {
                KeyboardEmojiCategory.Recents -> recents
                KeyboardEmojiCategory.Smileys -> smileys
                KeyboardEmojiCategory.Hands -> hands
                KeyboardEmojiCategory.Symbols -> symbols
                KeyboardEmojiCategory.Nature -> nature
                KeyboardEmojiCategory.Food -> food
                KeyboardEmojiCategory.Objects -> objects
            }

        val emojiChunkSize = 8
        val emojiRows =
            selected.chunked(emojiChunkSize).take(if (request.compactModeEnabled) 2 else Int.MAX_VALUE).mapIndexed { index, chunk ->
                KeyboardRowSpec(
                    keys = chunk.map { textKey(label = it, output = it, weight = 1f) },
                    leadingWeight = if (index == 1 && chunk.size < emojiChunkSize) 0.6f else 0f,
                )
            }

        return listOf(categoryRow) + emojiRows
    }

    private fun clipboardPanelRow(request: KeyboardLayoutRequest): KeyboardRowSpec {
        return KeyboardRowSpec(
            rowId = "panel-clipboard",
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
                            KeyboardKeySpec("media-open-app", "App", KeyboardKeyAction.OpenMediaApp),
                            KeyboardKeySpec("media-stop", "Stop", KeyboardKeyAction.MediaStop),
                        ),
                    horizontalScrollable = !request.compactModeEnabled,
                ),
            )
        if (request.compactModeEnabled) {
            rows.add(
                KeyboardRowSpec(
                    keys =
                        listOf(
                            KeyboardKeySpec("media-volume-down", "Vol-", KeyboardKeyAction.VolumeDown),
                            KeyboardKeySpec("media-volume-up", "Vol+", KeyboardKeyAction.VolumeUp),
                            KeyboardKeySpec("media-brightness-down", "Bri-", KeyboardKeyAction.BrightnessDown),
                            KeyboardKeySpec("media-brightness-up", "Bri+", KeyboardKeyAction.BrightnessUp),
                            KeyboardKeySpec("media-close", "Back", KeyboardKeyAction.ClosePanel),
                        ),
                ),
            )
            rows.add(
                KeyboardRowSpec(
                    keys =
                        listOf(
                            KeyboardKeySpec("media-shuffle", "Shuffle", KeyboardKeyAction.MediaShuffle, weight = 1.2f),
                            KeyboardKeySpec("media-loop", "Loop", KeyboardKeyAction.MediaLoop),
                            KeyboardKeySpec("media-open-settings", "App", KeyboardKeyAction.OpenWinFlowzSettings),
                            KeyboardKeySpec("media-status", "Media controls", KeyboardKeyAction.MediaNowPlaying, weight = 1.6f),
                        ),
                ),
            )
        }
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
            rowId = "panel-snippets",
            keys =
                contentKeys +
                    listOf(
                        KeyboardKeySpec(
                            id = "snippet-open",
                            label = "App",
                            action = KeyboardKeyAction.OpenWinFlowzSnippets,
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
                        KeyboardKeySpec("setting-app", "App", KeyboardKeyAction.OpenWinFlowzSettings),
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
                            id = "setting-height-down",
                            label = "H-",
                            action = KeyboardKeyAction.DecreaseKeyboardHeight,
                        ),
                        KeyboardKeySpec(
                            id = "setting-compact",
                            label = if (request.compactModeEnabled) "Compact on" else "Compact",
                            action = KeyboardKeyAction.ToggleCompactMode,
                            active = request.compactModeEnabled,
                            weight = 1.8f,
                        ),
                        KeyboardKeySpec(
                            id = "setting-height-up",
                            label = "H+",
                            action = KeyboardKeyAction.IncreaseKeyboardHeight,
                        ),
                    ),
                leadingWeight = 0.6f,
                trailingWeight = 0.6f,
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
        if (request.compactModeEnabled) {
            return compactRows(request, mode)
        }
        return when (mode) {
            KeyboardLayoutMode.Letters -> letterRowsForProfile(request)
            KeyboardLayoutMode.Numbers -> numberRows()
            KeyboardLayoutMode.Accents -> accentRows()
            KeyboardLayoutMode.Symbols -> symbolRows()
        }
    }

    private fun compactRows(
        request: KeyboardLayoutRequest,
        mode: KeyboardLayoutMode,
    ): List<KeyboardRowSpec> {
        return when (mode) {
            KeyboardLayoutMode.Letters -> compactLetterRows(request)
            KeyboardLayoutMode.Numbers -> compactNumberRows(request)
            KeyboardLayoutMode.Accents -> compactAccentRows(request)
            KeyboardLayoutMode.Symbols -> compactSymbolRows(request)
        }
    }

    private fun compactLetterRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return when (request.layoutProfile) {
            KeyboardLayoutProfile.QWERTY ->
                listOf(
                    KeyboardRowSpec(rowFromChars("qwertyuiop").keys + KeyboardKeySpec("del-letter-row", "Del", KeyboardKeyAction.Backspace)),
                    KeyboardRowSpec(
                        rowFromChars("asdfghjkl").keys + KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter),
                        leadingWeight = 0.5f,
                        trailingWeight = 0.5f,
                    ),
                    compactControlLetterRow("zxcvbnm", request),
                )
            KeyboardLayoutProfile.AZERTY ->
                listOf(
                    KeyboardRowSpec(rowFromChars("azertyuiop").keys + KeyboardKeySpec("del-letter-row", "Del", KeyboardKeyAction.Backspace)),
                    KeyboardRowSpec(rowFromChars("qsdfghjklm").keys + KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter)),
                    compactControlLetterRow("wxcvbn", request),
                )
        }
    }

    private fun compactControlLetterRow(
        chars: String,
        request: KeyboardLayoutRequest,
    ): KeyboardRowSpec {
        return KeyboardRowSpec(
            keys =
                listOf(
                    shiftKey("Maj", request.shifted),
                    modifierKey("Ctrl", KeyboardSystemModifier.Ctrl),
                    modifierKey("Alt", KeyboardSystemModifier.Alt),
                    KeyboardKeySpec("tab-letter-compact", "Tab", KeyboardKeyAction.InsertTab),
                    KeyboardKeySpec("esc-letter-compact", "Échap", KeyboardKeyAction.Escape),
                ) +
                    chars.map { letterKey(it) } +
                    listOf(
                        textKey("Espace", " "),
                    ),
        )
    }

    private fun compactNumberRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(listOf(textKey("@"), textKey("+"), textKey("1"), textKey("2"), textKey("3"), textKey("-"), textKey("#"), KeyboardKeySpec("del", "Del", KeyboardKeyAction.Backspace))),
            KeyboardRowSpec(listOf(textKey("?"), textKey("*"), textKey("4"), textKey("5"), textKey("6"), textKey("/"), textKey("!"), KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter))),
            KeyboardRowSpec(listOf(modeKey("ABC", KeyboardKeyAction.ModeLetters, false), modifierKey("Ctrl", KeyboardSystemModifier.Ctrl), textKey("7"), textKey("8"), textKey("9"), textKey("."), textKey(","), textKey("Espace", " "))),
        )
    }

    private fun compactAccentRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(listOf("à", "â", "ä", "ç", "é", "è", "ê", "ë").map { textKey(it) } + KeyboardKeySpec("del", "Del", KeyboardKeyAction.Backspace)),
            KeyboardRowSpec(listOf("î", "ï", "ô", "ö", "ù", "û", "ü", "ÿ").map { textKey(it) } + KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter)),
            KeyboardRowSpec(listOf(modeKey("ABC", KeyboardKeyAction.ModeLetters, false), modifierKey("Ctrl", KeyboardSystemModifier.Ctrl), textKey("œ"), textKey("æ"), textKey("ñ"), textKey("’"), textKey("Espace", " "))),
        )
    }

    private fun compactSymbolRows(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return listOf(
            KeyboardRowSpec(listOf("[", "]", "{", "}", "#", "%", "^", "*", "+").map { textKey(it) } + KeyboardKeySpec("del", "Del", KeyboardKeyAction.Backspace)),
            KeyboardRowSpec(listOf("_", "\\", "|", "~", "<", ">", "$", "€", "£").map { textKey(it) } + KeyboardKeySpec("enter", request.enterLabel, KeyboardKeyAction.Enter)),
            KeyboardRowSpec(
                listOf(
                    modeKey("ABC", KeyboardKeyAction.ModeLetters, false),
                    KeyboardKeySpec("esc-symbols", "Esc", KeyboardKeyAction.Escape),
                    modifierKey("Ctrl", KeyboardSystemModifier.Ctrl),
                    modifierKey("Alt", KeyboardSystemModifier.Alt),
                    modifierKey("Fn", KeyboardSystemModifier.Fn),
                    textKey("."),
                    textKey(","),
                    textKey("?"),
                    textKey("!"),
                    textKey("Espace", " "),
                ),
            ),
        )
    }

    private fun letterRowsForProfile(request: KeyboardLayoutRequest): List<KeyboardRowSpec> {
        return when (request.layoutProfile) {
            KeyboardLayoutProfile.QWERTY ->
                listOf(
                    rowFromChars("qwertyuiop"),
                    rowFromChars("asdfghjkl", leading = 0.5f),
                    bottomLetterRowWithControls("zxcvbnm", request.shifted),
                )
            KeyboardLayoutProfile.AZERTY ->
                listOf(
                    rowFromChars("azertyuiop"),
                    rowFromChars("qsdfghjklm"),
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
            KeyboardRowSpec(listOf("_", "\\", "|", "~", "<", ">", "$", "€", "£", "¥").map { textKey(it) }, leadingWeight = 0.3f),
            KeyboardRowSpec(
                listOf(KeyboardKeySpec("esc-symbols", "Esc", KeyboardKeyAction.Escape)) +
                    listOf(".", ",", "?", "!", "'", "`", "•").map { textKey(it) },
                leadingWeight = 0.7f,
            ),
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
                        KeyboardKeySpec("tab-letter-control", "Tab", KeyboardKeyAction.InsertTab),
                        KeyboardKeySpec("esc-letter-control", "Échap", KeyboardKeyAction.Escape),
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
        val value = KeyboardKeyValue.text(output, label)
        return KeyboardKeySpec(
            id = stableTextKeyId(output),
            label = value.renderLabel(),
            action = KeyboardKeyAction.Text,
            glyph = KeyboardKeyGlyph(primary = output),
            keyValue = value,
            weight = weight,
        )
    }

    private fun KeyboardKeySpec.asActionSurface(): KeyboardKeySpec = copy(actionSurface = true)

    private fun KeyboardRowSpec.asActionSurfaceRow(): KeyboardRowSpec {
        return copy(keys = keys.map { it.asActionSurface() })
    }

    private fun List<KeyboardRowSpec>.asActionSurfaceRows(): List<KeyboardRowSpec> {
        return map { it.asActionSurfaceRow() }
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

    private fun stableTextKeyId(output: String): String {
        if (output == " ") {
            return "space"
        }
        if (output.length == 1 && output[0].isDigit()) {
            return "digit-$output"
        }
        val mapped =
            mapOf(
                "," to "comma",
                "." to "period",
                ";" to "semicolon",
                ":" to "colon",
                "!" to "exclamation",
                "?" to "question",
                "/" to "slash",
                "\\" to "backslash",
                "+" to "plus",
                "-" to "hyphen",
                "*" to "asterisk",
                "@" to "at",
                "#" to "hash",
                "'" to "apostrophe",
                "\"" to "quote",
                "_" to "underscore",
                "|" to "pipe",
                "~" to "tilde",
                "<" to "less",
                ">" to "greater",
                "€" to "euro",
                "£" to "pound",
                "¥" to "yen",
                "[" to "left-bracket",
                "]" to "right-bracket",
                "{" to "left-brace",
                "}" to "right-brace",
                "%" to "percent",
                "^" to "caret",
                "=" to "equals",
                "`" to "backtick",
                "•" to "bullet",
                "—" to "em-dash",
                "…" to "ellipsis",
                ".com" to "dotcom",
            )[output]
        if (mapped != null) {
            return "text-$mapped"
        }
        val codePoints =
            output.codePoints()
                .toArray()
                .joinToString(separator = "-") { codePoint -> codePoint.toString(16) }
        return "text-u$codePoints"
    }

    private fun glyphFor(char: Char): KeyboardKeyGlyph {
        return KeyboardKeyGlyph(primary = char.toString())
    }
}
