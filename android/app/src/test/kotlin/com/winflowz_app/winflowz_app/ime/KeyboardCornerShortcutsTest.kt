package com.winflowz_app.winflowz_app.ime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class KeyboardCornerShortcutsTest {
    @Test
    fun `french accents remain the default preset`() {
        val key = keyById("letter-a")

        assertEquals("à", key.cornerAssignments.topLeft?.label)
        assertEquals("â", key.cornerAssignments.topRight?.label)
        assertEquals("ä", key.cornerAssignments.bottomLeft?.label)
        assertEquals("æ", key.cornerAssignments.bottomRight?.label)
        assertEquals("à", key.cornerAssignments.topLeft?.value?.text)
    }

    @Test
    fun `user override wins over the active preset for one slot only`() {
        val config =
            KeyboardCornerConfig(
                overrides =
                    listOf(
                        KeyboardCornerShortcut(
                            keyId = "letter-a",
                            slot = KeyboardCornerSlot.TopLeft,
                            expression = "A+: 'aa'",
                            label = "A+",
                        ),
                    ),
            )
        val key = keyById("letter-a", config = config)

        assertEquals("A+", key.cornerAssignments.topLeft?.label)
        assertEquals("aa", key.cornerAssignments.topLeft?.value?.text)
        assertEquals("â", key.cornerAssignments.topRight?.label)
    }

    @Test
    fun `special key corner assignments are bounded by special key toggle`() {
        val config =
            KeyboardCornerConfig(
                overrides =
                    listOf(
                        KeyboardCornerShortcut(
                            keyId = "modifier-ctrl",
                            slot = KeyboardCornerSlot.TopLeft,
                            expression = "Tab:keyevent:61",
                        ),
                    ),
            )

        val disabled = keyById("modifier-ctrl", config = config, specialKeyCorners = false)
        val enabled = keyById("modifier-ctrl", config = config, specialKeyCorners = true)

        assertTrue(disabled.cornerAssignments.isEmpty())
        assertEquals("Tab", enabled.cornerAssignments.topLeft?.label)
    }

    @Test
    fun `private fields suppress sensitive corner actions without hiding text accents`() {
        val config =
            KeyboardCornerConfig(
                overrides =
                    listOf(
                        KeyboardCornerShortcut(
                            keyId = "letter-j",
                            slot = KeyboardCornerSlot.TopLeft,
                            expression = "JA:'j\\'arrive'",
                            label = "JA",
                            sensitive = true,
                        ),
                    ),
            )

        val sensitive = keyById("letter-j", config = config, fieldPolicy = privatePolicy())
        val accent = keyById("letter-a", config = config, fieldPolicy = privatePolicy())

        assertNull(sensitive.cornerAssignments.topLeft)
        assertEquals("à", accent.cornerAssignments.topLeft?.label)
    }

    @Test
    fun `corrupt stored json falls back to default config`() {
        val config = KeyboardCornerConfig.fromJson("{not-json")

        assertEquals(KeyboardCornerPresets.FRENCH_ACCENTS, config.presetId)
        assertTrue(config.overrides.isEmpty())
    }

    private fun keyById(
        keyId: String,
        config: KeyboardCornerConfig = KeyboardCornerConfig(),
        specialKeyCorners: Boolean = false,
        fieldPolicy: KeyboardFieldPolicy = publicPolicy(),
    ): KeyboardKeySpec {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = KeyboardLayoutProfile.QWERTY,
                    cornerModeEnabled = true,
                    debugTouchOverlayEnabled = false,
                    specialKeyCornersEnabled = specialKeyCorners,
                    doubleSpacePeriodEnabled = true,
                    punctuationAutoSpacingEnabled = true,
                    emojiCategory = KeyboardEmojiCategory.Recents,
                    recentEmojis = emptyList(),
                    enterLabel = "Enter",
                    clipboardAllowed = fieldPolicy.clipboardAllowed,
                    voiceAllowed = fieldPolicy.voiceAllowed,
                    snippetsAllowed = fieldPolicy.snippetsAllowed,
                    suggestions = emptyList(),
                    cornerConfig = config,
                    fieldPolicy = fieldPolicy,
                ),
            )
        return snapshot.rows.flatMap { it.keys }.first { it.id == keyId }
    }

    private fun publicPolicy(): KeyboardFieldPolicy {
        return KeyboardFieldPolicy(
            privateMode = false,
            reason = "Test field",
            inputAllowed = true,
            voiceAllowed = true,
            clipboardAllowed = true,
            snippetsAllowed = true,
            learningAllowed = true,
        )
    }

    private fun privatePolicy(): KeyboardFieldPolicy {
        return KeyboardFieldPolicy(
            privateMode = true,
            reason = "Private test field",
            inputAllowed = true,
            voiceAllowed = false,
            clipboardAllowed = false,
            snippetsAllowed = false,
            learningAllowed = false,
        )
    }
}
