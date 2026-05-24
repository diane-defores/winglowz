package com.winflowz_app.winflowz_app.ime

import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarState
import com.winflowz_app.winflowz_app.ime.actions.KeyboardAttachedActionRowState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class KeyboardLayoutBuilderTest {
    @Test
    fun `uses azerty profile for letters`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.AZERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val firstLetterRow = snapshot.rows[1]
        val rowLabels = firstLetterRow.keys.map { it.label }.joinToString(separator = "")
        assertEquals("azertyuiop", rowLabels)
        assertEquals(KeyboardKeyValueKind.Text, firstLetterRow.keys.first().keyValue?.kind)
        assertEquals("a", firstLetterRow.keys.first().keyValue?.text)
    }

    @Test
    fun `qwerty home row uses ten equal letter grid slots`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val topLetterRow = snapshot.rows[1]
        val homeLetterRow = snapshot.rows[2]

        assertEquals("qwertyuiop", topLetterRow.keys.map { it.label }.joinToString(separator = ""))
        assertEquals("asdfghjkl;", homeLetterRow.keys.map { it.label }.joinToString(separator = ""))
        assertEquals(topLetterRow.keys.size, homeLetterRow.keys.size)
        assertTrue(homeLetterRow.keys.all { it.weight == 1f })
        assertEquals(0f, homeLetterRow.leadingWeight)
        assertEquals(0f, homeLetterRow.trailingWeight)
    }

    @Test
    fun `places shift and backspace above bottom controls in letter mode`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val bottomLetterRow = snapshot.rows[3]
        val controlRow = snapshot.rows.last()

        assertEquals("Maj", bottomLetterRow.keys.first().label)
        assertEquals(KeyboardKeyAction.Shift, bottomLetterRow.keys.first().action)
        assertEquals("Del", bottomLetterRow.keys.last().label)
        assertEquals(KeyboardKeyAction.Backspace, bottomLetterRow.keys.last().action)
        assertEquals("Ctrl", controlRow.keys.first().label)
        assertTrue(controlRow.keys.zipWithNext().any { (left, right) ->
            left.label == "Tab" &&
                left.action == KeyboardKeyAction.InsertTab &&
                right.label == "Échap" &&
                right.action == KeyboardKeyAction.Escape
        })
        assertTrue(controlRow.keys.any { it.label == "Échap" && it.action == KeyboardKeyAction.Escape })
        assertTrue(controlRow.keys.any { it.action == KeyboardKeyAction.Enter })
        assertTrue(controlRow.keys.none { it.action == KeyboardKeyAction.Shift || it.action == KeyboardKeyAction.Backspace })
    }

    @Test
    fun `compact letter bottom row keeps shift at normal key width`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    compactModeEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val compactBottomRow = snapshot.rows[3]
        val shift = compactBottomRow.keys.first()

        assertEquals("Maj", shift.label)
        assertEquals(KeyboardKeyAction.Shift, shift.action)
        assertEquals(1, shift.span)
        assertTrue(compactBottomRow.keys.all { it.span == null || it.span == 1 })
    }

    @Test
    fun `forces number mode on phone fields`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Phone,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Done",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        assertEquals(KeyboardLayoutMode.Numbers, snapshot.mode)
        val controlRow = snapshot.rows.last()
        assertTrue(controlRow.keys.any { it.label == "+" })
        assertTrue(controlRow.keys.any { it.label == "#" })
    }

    @Test
    fun `forces number mode on numeric fields`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Number,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Done",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        assertEquals(KeyboardLayoutMode.Numbers, snapshot.mode)
        val controlRow = snapshot.rows.last()
        assertTrue(controlRow.keys.any { it.label == "+" })
        assertTrue(controlRow.keys.any { it.label == "-" })
    }

    @Test
    fun `number mode uses a centered three by three keypad with side special keys`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Numbers,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val numericRows = snapshot.rows.drop(1).take(3).map { row -> row.keys.map { it.label } }

        assertEquals(listOf("@", "+", "1", "2", "3", "-", "#"), numericRows[0])
        assertEquals(listOf("?", "*", "4", "5", "6", "/", "!"), numericRows[1])
        assertEquals(listOf(":", ".", "7", "8", "9", "0", ";"), numericRows[2])
    }

    @Test
    fun `navigation panel is dedicated to navigation and editing controls`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Navigation,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val panelRows = snapshot.rows.drop(1).take(snapshot.panelRowCount)
        val panelActions = panelRows.flatMap { row -> row.keys.map { it.action } }
        val labels = panelRows.flatMap { row -> row.keys.map { it.label } }

        assertEquals(3, snapshot.panelRowCount)
        assertEquals(listOf("All", "Copy", "DelW←", "DelW→", "⏫", "↑"), panelRows[0].keys.map { it.label })
        assertEquals(listOf("Cut", "Paste", "Word←", "Word→", "⏬", "↓"), panelRows[1].keys.map { it.label })
        assertEquals(listOf("Undo", "Redo", "Del←", "Del→", "⬅", "➡"), panelRows[2].keys.map { it.label })
        assertTrue(labels.containsAll(listOf("Del←", "Del→", "DelW←", "DelW→")))
        assertTrue(labels.containsAll(listOf("⏫", "↑", "⏬", "↓")))
        assertFalse(labels.contains("Clip"))
        assertFalse(labels.contains("Back"))
        assertTrue(panelActions.contains(KeyboardKeyAction.SelectAll))
        assertTrue(panelActions.contains(KeyboardKeyAction.CopySelection))
        assertTrue(panelActions.contains(KeyboardKeyAction.CutSelection))
        assertTrue(panelActions.contains(KeyboardKeyAction.PasteClipboard))
        assertTrue(panelActions.contains(KeyboardKeyAction.Undo))
        assertTrue(panelActions.contains(KeyboardKeyAction.Redo))
        assertTrue(panelActions.contains(KeyboardKeyAction.NavigateLineUp))
        assertTrue(panelActions.contains(KeyboardKeyAction.NavigateLineDown))
        assertTrue(panelActions.contains(KeyboardKeyAction.NavigateParagraphUp))
        assertTrue(panelActions.contains(KeyboardKeyAction.NavigateParagraphDown))
        assertTrue(panelActions.contains(KeyboardKeyAction.NavigateWordLeft))
        assertTrue(panelActions.contains(KeyboardKeyAction.NavigateWordRight))
        assertTrue(panelActions.contains(KeyboardKeyAction.ForwardDelete))
        assertTrue(panelActions.contains(KeyboardKeyAction.DeleteWordAfter))
        assertTrue(panelActions.none { it == KeyboardKeyAction.Text || it == KeyboardKeyAction.KeyValue })
        assertTrue(snapshot.rows.drop(1 + snapshot.panelRowCount).any { row ->
            row.keys.any { it.action == KeyboardKeyAction.Text || it.action == KeyboardKeyAction.KeyValue }
        })
    }

    @Test
    fun `navigation and settings panels are real modes not action surfaces`() {
        val navigation =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Navigation,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )
        val settings =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Settings,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val navigationPanelKeys = navigation.rows.drop(1).take(navigation.panelRowCount).flatMap { it.keys }
        val settingsPanelKeys = settings.rows.drop(1).take(settings.panelRowCount).flatMap { it.keys }

        assertTrue(navigationPanelKeys.isNotEmpty())
        assertTrue(settingsPanelKeys.isNotEmpty())
        assertTrue(navigationPanelKeys.none { it.actionSurface })
        assertTrue(settingsPanelKeys.none { it.actionSurface })
    }

    @Test
    fun `special tool panels use action surfaces for compact action sizing`() {
        val panels =
            listOf(
                KeyboardPanelMode.Accents,
                KeyboardPanelMode.Emoji,
                KeyboardPanelMode.Clipboard,
                KeyboardPanelMode.ClipboardFull,
                KeyboardPanelMode.Snippets,
            )

        panels.forEach { panel ->
            val snapshot =
                KeyboardLayoutBuilder.build(
                    KeyboardLayoutRequest(
                        mode = KeyboardLayoutMode.Letters,
                        panel = panel,
                        shifted = false,
                        fieldContext = KeyboardFieldContextMode.Text,
                        layoutProfile = KeyboardLayoutProfile.QWERTY,
                        cornerModeEnabled = false,
                        debugTouchOverlayEnabled = false,
                        doubleSpacePeriodEnabled = true,
                        punctuationAutoSpacingEnabled = true,
                        emojiCategory = KeyboardEmojiCategory.Recents,
                        recentEmojis = emptyList(),
                        enterLabel = "Enter",
                        clipboardAllowed = true,
                        clipboardEntries = listOf(KeyboardClipboardEntry("Pinned clip", pinned = true)),
                        voiceAllowed = true,
                        snippetsAllowed = true,
                        snippets = listOf(KeyboardTextRule("ja", "j'arrive", caseSensitive = false)),
                        suggestions = emptyList(),
                    ),
                )
            val panelKeys = snapshot.rows.drop(1).take(snapshot.panelRowCount).flatMap { it.keys }

            assertTrue(panel.name, panelKeys.isNotEmpty())
            assertTrue(panel.name, panelKeys.all { it.actionSurface })
        }
    }

    @Test
    fun `symbol mode puts delete on symbol row instead of control row`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Symbols,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val symbolRows = snapshot.rows.drop(1).take(3)
        val modifierValues = snapshot.rows.last().keys.mapNotNull { it.keyValue?.modifier }.toSet()

        assertEquals(listOf("[", "]", "{", "}", "#", "%", "^", "*", "+", "="), symbolRows[0].keys.map { it.label })
        assertEquals(listOf("_", "\\", "|", "~", "<", ">", "$", "€", "£", "¥"), symbolRows[1].keys.map { it.label })
        assertEquals(listOf("Esc", ".", ",", "?", "!", "'", "`", "•", "Del"), symbolRows[2].keys.map { it.label })
        assertTrue(symbolRows[2].keys.last().action == KeyboardKeyAction.Backspace)
        assertFalse(snapshot.rows.last().keys.any { it.label == "Del" && it.action == KeyboardKeyAction.Backspace })
        assertTrue(modifierValues.contains(KeyboardSystemModifier.Ctrl))
        assertTrue(modifierValues.contains(KeyboardSystemModifier.Fn))
        assertFalse(modifierValues.contains(KeyboardSystemModifier.Alt))
    }

    @Test
    fun `symbol mode exposes escape key`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Symbols,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        assertTrue(snapshot.rows.any { row ->
            row.keys.any { it.label == "Esc" && it.action == KeyboardKeyAction.Escape }
        })
    }

    @Test
    fun `symbol mode supports additional shifted character pages`() {
        val secondPage =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Symbols,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    symbolPage = 1,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )
        val thirdPage =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Symbols,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    symbolPage = 2,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val secondPageLabels = secondPage.rows.drop(1).take(3).flatMap { row -> row.keys.map { it.label } }
        val thirdPageLabels = thirdPage.rows.drop(1).take(3).flatMap { row -> row.keys.map { it.label } }

        assertTrue(secondPageLabels.containsAll(listOf("(", ")", "©", "®", "™", "…", "¿", "‰")))
        assertTrue(thirdPageLabels.containsAll(listOf("←", "→", "✓", "✕", "≤", "≥", "π", "Ω")))
    }

    @Test
    fun `accent panel exposes french accents without replacing typing rows`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Accents,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = true,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val panelRows = snapshot.rows.drop(1).take(snapshot.panelRowCount)
        val labels = panelRows.flatMap { row -> row.keys.map { it.label } }

        assertEquals(2, snapshot.panelRowCount)
        assertTrue(labels.containsAll(listOf("é", "è", "ê", "ë", "à", "â", "ç")))
        assertTrue(labels.containsAll(listOf("ù", "û", "ü", "î", "ï", "ô", "œ", "æ")))
        assertTrue(snapshot.rows.drop(1 + snapshot.panelRowCount).any { row ->
            row.keys.any { it.label == "q" }
        })
    }

    @Test
    fun `emoji panel keeps dense categories and fills sparse recents`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Emoji,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = listOf("🔥"),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val categoryLabels = snapshot.rows[1].keys.map { it.label }
        val emojiLabels = snapshot.rows[2].keys.map { it.label }
        assertTrue(categoryLabels.containsAll(listOf("🕘", "😀", "👏", "✨", "🌿", "🍔", "💡", "⚽")))
        assertFalse(categoryLabels.contains("×"))
        assertEquals(8, emojiLabels.size)
        assertEquals("🔥", emojiLabels.first())
        assertTrue(emojiLabels.contains("😀"))
    }

    @Test
    fun `emoji recents ignore polluted plain text entries`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Emoji,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = listOf("🔥", "E", "P", "S", "T", "M", "L"),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val emojiLabels = snapshot.rows[2].keys.map { it.label }

        assertEquals("🔥", emojiLabels.first())
        assertFalse(emojiLabels.any { it in listOf("E", "P", "S", "T", "M", "L") })
        assertTrue(emojiLabels.contains("😀"))
    }

    @Test
    fun `clipboard panel exposes select all beside cut and recent entries`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Clipboard,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    clipboardEntries =
                        listOf(
                            KeyboardClipboardEntry("Latest copied text"),
                            KeyboardClipboardEntry("  latest   copied text  ", pinned = true),
                            KeyboardClipboardEntry("Pinned account id", pinned = true),
                        ),
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val actionRow = snapshot.rows[1]
        val historyRows = snapshot.rows.drop(2).take(snapshot.panelRowCount - 1)
        val labels = historyRows.flatMap { row -> row.keys.map { it.label } }
        val actions = actionRow.keys.map { it.action }

        assertEquals(3, snapshot.panelRowCount)
        assertFalse(actionRow.horizontalScrollable)
        assertTrue(actions.containsAll(listOf(KeyboardKeyAction.SelectAll, KeyboardKeyAction.CutSelection, KeyboardKeyAction.CopySelection, KeyboardKeyAction.PasteClipboard, KeyboardKeyAction.PastePlainClipboard)))
        assertFalse(actions.contains(KeyboardKeyAction.ToggleClipboardPanel))
        assertEquals("All", actionRow.keys[0].label)
        assertEquals(KeyboardKeyAction.SelectAll, actionRow.keys[0].action)
        assertEquals("Cut", actionRow.keys[1].label)
        assertEquals(KeyboardKeyAction.CutSelection, actionRow.keys[1].action)
        assertFalse(actionRow.keys.any { it.label == "History" })
        assertTrue(labels.contains("Pin Latest copied text"))
        assertTrue(labels.contains("Pin Pinned account id"))
        assertEquals(1, labels.count { it.contains("Latest copied text") })
        assertTrue(historyRows.flatMap { row -> row.keys }.all { it.action == KeyboardKeyAction.InsertClipboardEntry })
        assertTrue(snapshot.rows.drop(1 + snapshot.panelRowCount).any { row ->
            row.keys.any { it.action == KeyboardKeyAction.Text || it.action == KeyboardKeyAction.KeyValue }
        })
    }

    @Test
    fun `full clipboard panel replaces typing rows with history entries`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.ClipboardFull,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    clipboardEntries =
                        listOf(
                            KeyboardClipboardEntry("Pinned clip", pinned = true),
                            KeyboardClipboardEntry("Normal clip"),
                        ),
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val labels = snapshot.rows.drop(1).take(snapshot.panelRowCount).flatMap { row -> row.keys.map { it.label } }

        assertTrue(labels.contains("Pin Pinned clip"))
        assertTrue(labels.contains("Normal clip"))
        assertTrue(snapshot.rows.drop(1 + snapshot.panelRowCount).none { row ->
            row.keys.any { it.action == KeyboardKeyAction.Text || it.action == KeyboardKeyAction.KeyValue }
        })
    }

    @Test
    fun `snippets panel exposes current snippets in a horizontal row`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Snippets,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    snippets =
                        listOf(
                            KeyboardTextRule("ja", "j'arrive", caseSensitive = false),
                            KeyboardTextRule("addr", "Mon adresse est", caseSensitive = false),
                        ),
                    suggestions = emptyList(),
                ),
            )

        val panelRow = snapshot.rows[1]

        assertTrue(panelRow.horizontalScrollable)
        assertTrue(panelRow.keys.any { it.label == "j'arrive" && it.suggestion == "j'arrive" })
        assertTrue(panelRow.keys.any { it.label == "Mon adresse est" && it.suggestion == "Mon adresse est" })
        assertTrue(panelRow.keys.any { it.label == "App" && it.action == KeyboardKeyAction.OpenWinFlowzSnippets })
        assertTrue(panelRow.keys.any { it.label == "Close" })
    }

    @Test
    fun `media panel exposes controls and now playing line`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Media,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                    mediaNowPlayingLabel = "Daft Punk - Digital Love",
                ),
            )

        val panelRows = snapshot.rows.drop(1).take(snapshot.panelRowCount)
        val actions = panelRows.flatMap { row -> row.keys.map { it.action } }

        assertEquals(2, snapshot.panelRowCount)
        assertEquals("media-panel-primary", panelRows[0].rowId)
        assertTrue(panelRows[0].pagedHorizontalScrollable)
        assertEquals(10, panelRows[0].visiblePageKeyCount)
        assertTrue(actions.contains(KeyboardKeyAction.MediaPrevious))
        assertTrue(actions.contains(KeyboardKeyAction.MediaPlayPause))
        assertTrue(actions.contains(KeyboardKeyAction.MediaNext))
        assertTrue(actions.contains(KeyboardKeyAction.MediaNowPlaying))
        assertTrue(actions.contains(KeyboardKeyAction.OpenMediaApp))
        assertTrue(actions.contains(KeyboardKeyAction.MediaLoop))
        assertTrue(actions.contains(KeyboardKeyAction.MediaShuffle))
        assertTrue(actions.contains(KeyboardKeyAction.VolumeDown))
        assertTrue(actions.contains(KeyboardKeyAction.VolumeUp))
        assertTrue(actions.contains(KeyboardKeyAction.BrightnessDown))
        assertTrue(actions.contains(KeyboardKeyAction.BrightnessUp))
        assertEquals("Daft Punk - Digital Love", panelRows[1].keys.single().label)
    }

    @Test
    fun `settings panel exposes app keyboard theme and core toggles`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Settings,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = true,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val panelRows = snapshot.rows.drop(1).take(snapshot.panelRowCount)
        val actions = panelRows.flatMap { row -> row.keys.map { it.action } }
        val labels = panelRows.flatMap { row -> row.keys.map { it.label } }

        assertEquals(4, snapshot.panelRowCount)
        assertTrue(actions.contains(KeyboardKeyAction.ShowKeyboardPicker))
        assertTrue(actions.contains(KeyboardKeyAction.OpenWinFlowzSettings))
        assertTrue(actions.contains(KeyboardKeyAction.OpenThemeSettings))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleLayoutProfile))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleKeyVibration))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleKeySound))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleSpellingSuggestions))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleSpecialKeyCorners))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleFrenchLanguage))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleEnglishLanguage))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleCornerMode))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleDoubleSpacePeriod))
        assertTrue(actions.contains(KeyboardKeyAction.TogglePunctuationAutoSpacing))
        assertTrue(actions.contains(KeyboardKeyAction.ToggleDebugTouchOverlay))
        assertTrue(labels.containsAll(listOf("Keyboard", "App", "Theme", "QWERTY", "Vibe on", "Sound off", "Suggest on", "FR on", "EN on", "Special off", "Corners on", "2sp on", "Punc on", "Debug off")))
        assertTrue(snapshot.rows.drop(1 + snapshot.panelRowCount).none { row ->
            row.keys.any { it.action == KeyboardKeyAction.Text || it.action == KeyboardKeyAction.KeyValue }
        })
    }

    @Test
    fun `theme panel previews expose the theme pin badge for each preset`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.ThemeSettings,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = true,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                    themePresetId = KeyboardThemePresets.GLASS_MINT,
                ),
            )

        val themeKeys =
            snapshot.rows
                .drop(1)
                .take(snapshot.panelRowCount)
                .flatMap { row -> row.keys }
                .filter { it.action == KeyboardKeyAction.SelectThemePreset }

        assertEquals(KeyboardThemePresets.all.size, themeKeys.size)
        assertTrue(themeKeys.all { it.pinned })
        assertTrue(themeKeys.all { it.themePreviewConfig?.presetId == it.suggestion })
        assertTrue(themeKeys.single { it.suggestion == KeyboardThemePresets.GLASS_MINT }.active)
    }

    @Test
    fun `adds suggestion row above typing rows`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = listOf("bonjour", "bonsoir"),
                ),
            )

        assertEquals(1, snapshot.suggestionRowCount)
        assertEquals(KeyboardKeyAction.InsertSuggestion, snapshot.rows[1].keys.first().action)
        assertEquals("bonjour", snapshot.rows[1].keys.first().suggestion)
    }

    @Test
    fun `attached number row appears above typing rows with paged digits then symbols`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                    actionBarState =
                        KeyboardActionBarState(
                            attachedRows =
                                listOf(
                                    KeyboardAttachedActionRowState(
                                        providerActionId = "numbers",
                                        rowId = "action-row-numbers",
                                        dedupeKey = "numbers",
                                    ),
                                ),
                        ),
                ),
            )

        assertEquals(1, snapshot.suggestionRowCount)
        assertEquals("1234567890", snapshot.rows[1].keys.take(10).joinToString(separator = "") { it.label })
        assertTrue(snapshot.rows[1].keys.drop(10).map { it.label }.containsAll(listOf("+", "-", "=", "$")))
        assertTrue(snapshot.rows[1].pagedHorizontalScrollable)
        assertEquals(10, snapshot.rows[1].visiblePageKeyCount)
        assertTrue(snapshot.rows[0].keys.any { it.label == "123" && it.active })
    }

    @Test
    fun `pinned action remains visually distinct from active action`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Numbers,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                    actionBarState = KeyboardActionBarState(pinnedActionIds = setOf("numbers")),
                ),
            )

        val numbersKey = snapshot.rows.first().keys.first { it.actionDescriptorId == "numbers" }
        assertTrue(numbersKey.active)
        assertTrue(numbersKey.pinned)
    }

    @Test
    fun `main action bar keeps all actions distributed without horizontal scrolling`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                    actionBarState = KeyboardActionBarState(),
                ),
            )

        val mainActionRow = snapshot.rows.first()
        assertEquals("action-row-main", mainActionRow.rowId)
        assertFalse(mainActionRow.horizontalScrollable)
        assertFalse(mainActionRow.pagedHorizontalScrollable)
        assertTrue(mainActionRow.keys.map { it.label }.containsAll(listOf("123", "Acc", "#+=", "Nav", "Prefs")))
        assertFalse(mainActionRow.keys.any { it.label == "ABC" && it.actionDescriptorPrimary })
        assertEquals(listOf("123", "#+=", "Acc"), mainActionRow.keys.take(3).map { it.label })
        assertTrue(mainActionRow.keys.any { it.label == "Snip" && it.action == KeyboardKeyAction.ToggleSnippetsPanel })
    }

    @Test
    fun `clipboard attached row is hidden in private mode`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = false,
                    voiceAllowed = false,
                    snippetsAllowed = false,
                    suggestions = emptyList(),
                    fieldPolicy =
                        KeyboardFieldPolicy(
                            privateMode = true,
                            reason = "password",
                            inputAllowed = true,
                            voiceAllowed = false,
                            clipboardAllowed = false,
                            snippetsAllowed = false,
                            learningAllowed = false,
                        ),
                    actionBarState =
                        KeyboardActionBarState(
                            attachedRows =
                                listOf(
                                    KeyboardAttachedActionRowState(
                                        providerActionId = "clipboard",
                                        rowId = "action-row-clipboard",
                                        dedupeKey = "clipboard",
                                    ),
                                ),
                        ),
                ),
            )

        assertTrue(snapshot.rows[0].keys.none { it.label == "Clip" })
        assertTrue(snapshot.rows.drop(1).none { row -> row.rowId == "action-row-clipboard" })
    }

    @Test
    fun `navigation panel exposes clipboard actions directly`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.Navigation,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val navActions = snapshot.rows.drop(1).flatMap { row -> row.keys.map { it.action } }
        assertTrue(KeyboardKeyAction.CopySelection in navActions)
        assertTrue(KeyboardKeyAction.CutSelection in navActions)
        assertTrue(KeyboardKeyAction.PasteClipboard in navActions)
        assertTrue(KeyboardKeyAction.ToggleClipboardPanel !in navActions)
        assertTrue(KeyboardKeyAction.ClosePanel !in navActions)
    }

    @Test
    fun `letter control row exposes ctrl and escape without alt`() {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = false,
                    debugTouchOverlayEnabled = false,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = true,
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val modifierValues = snapshot.rows.last().keys.mapNotNull { it.keyValue?.modifier }.toSet()
        assertTrue(modifierValues.contains(KeyboardSystemModifier.Ctrl))
        assertFalse(modifierValues.contains(KeyboardSystemModifier.Alt))
        assertFalse(modifierValues.contains(KeyboardSystemModifier.Fn))
        assertTrue(snapshot.rows.last().keys.any { it.label == "Échap" && it.action == KeyboardKeyAction.Escape })
    }
}
