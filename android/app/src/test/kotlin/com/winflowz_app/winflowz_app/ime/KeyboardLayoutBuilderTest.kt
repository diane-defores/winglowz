package com.winflowz_app.winflowz_app.ime

import org.junit.Assert.assertEquals
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
    fun `navigation panel exposes forward deletion and selection cancel`() {
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

        val panelActions = snapshot.rows.take(3).flatMap { row -> row.keys.map { it.action } }
        assertTrue(panelActions.contains(KeyboardKeyAction.ForwardDelete))
        assertTrue(panelActions.contains(KeyboardKeyAction.DeleteWordAfter))
        assertTrue(panelActions.contains(KeyboardKeyAction.CancelSelection))
    }

    @Test
    fun `clipboard panel exposes reference editing actions`() {
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
                    voiceAllowed = true,
                    snippetsAllowed = true,
                    suggestions = emptyList(),
                ),
            )

        val panelActions = snapshot.rows[1].keys.map { it.action }
        assertTrue(panelActions.contains(KeyboardKeyAction.CutSelection))
        assertTrue(panelActions.contains(KeyboardKeyAction.PastePlainClipboard))
        assertTrue(panelActions.contains(KeyboardKeyAction.SelectAll))
        assertTrue(panelActions.contains(KeyboardKeyAction.Undo))
        assertTrue(panelActions.contains(KeyboardKeyAction.Redo))
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
    fun `control row exposes parsed modifier key values`() {
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
        assertTrue(modifierValues.contains(KeyboardSystemModifier.Shift))
        assertTrue(modifierValues.contains(KeyboardSystemModifier.Ctrl))
        assertTrue(modifierValues.contains(KeyboardSystemModifier.Alt))
        assertTrue(modifierValues.contains(KeyboardSystemModifier.Fn))
    }
}
