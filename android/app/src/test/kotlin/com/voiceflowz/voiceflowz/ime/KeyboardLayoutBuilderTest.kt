package com.voiceflowz.voiceflowz.ime

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
                ),
            )

        val firstLetterRow = snapshot.rows[1]
        val rowLabels = firstLetterRow.keys.map { it.label }.joinToString(separator = "")
        assertEquals("azertyuiop", rowLabels)
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
                ),
            )

        assertEquals(KeyboardLayoutMode.Numbers, snapshot.mode)
        val controlRow = snapshot.rows.last()
        assertTrue(controlRow.keys.any { it.label == "+" })
        assertTrue(controlRow.keys.any { it.label == "#" })
    }
}
