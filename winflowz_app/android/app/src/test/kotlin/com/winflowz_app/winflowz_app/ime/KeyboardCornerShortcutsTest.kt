package com.winflowz_app.winflowz_app.ime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class KeyboardCornerShortcutsTest {
    @Test
    fun `smart french corners are the default preset`() {
        val aKey = keyById("letter-a")
        val eKey = keyById("letter-e")
        val rKey = keyById("letter-r")
        val cKey = keyById("letter-c")
        val hKey = keyById("letter-h")
        val wKey = keyById("letter-w")
        val sKey = keyById("letter-s")
        val bKey = keyById("letter-b")
        val nKey = keyById("letter-n")
        val jKey = keyById("letter-j")
        val lKey = keyById("letter-l")
        val uKey = keyById("letter-u")
        val zKey = keyById("letter-z")

        assertNull(aKey.cornerAssignments.topLeft)
        assertNull(aKey.cornerAssignments.topRight)
        assertNull(aKey.cornerAssignments.bottomLeft)
        assertNull(eKey.cornerAssignments.topLeft)
        assertNull(eKey.cornerAssignments.topRight)
        assertEquals("1", rKey.cornerAssignments.up?.label)
        assertEquals("8", cKey.cornerAssignments.up?.label)
        assertEquals("6", hKey.cornerAssignments.up?.label)
        assertEquals("0", bKey.cornerAssignments.up?.label)
        assertNull(uKey.cornerAssignments.topLeft)
        assertNull(uKey.cornerAssignments.topRight)
        assertNull(uKey.cornerAssignments.bottomLeft)
        assertEquals("-", nKey.cornerAssignments.topLeft?.label)
        assertEquals("_", nKey.cornerAssignments.topRight?.label)
        assertEquals("?", jKey.cornerAssignments.bottomLeft?.label)
        assertEquals("!", jKey.cornerAssignments.bottomRight?.label)
        assertEquals(":", lKey.cornerAssignments.topLeft?.label)
        assertEquals(";", lKey.cornerAssignments.topRight?.label)
        assertEquals("\$", lKey.cornerAssignments.bottomLeft?.label)
        assertEquals("€", lKey.cornerAssignments.bottomRight?.label)
        assertNull(hKey.cornerAssignments.topLeft)
        assertNull(hKey.cornerAssignments.topRight)
        assertNull(hKey.cornerAssignments.bottomLeft)
        assertNull(hKey.cornerAssignments.bottomRight)
        assertEquals("↑", wKey.cornerAssignments.up?.label)
        assertEquals("↓", wKey.cornerAssignments.down?.label)
        assertEquals("←", sKey.cornerAssignments.left?.label)
        assertEquals("→", sKey.cornerAssignments.right?.label)
        assertEquals("W←", zKey.cornerAssignments.bottomLeft?.label)
        assertEquals("W→", zKey.cornerAssignments.bottomRight?.label)
        assertEquals(KeyboardKeyAction.NavigateLineUp, wKey.cornerAssignments.up?.value?.action)
        assertEquals(KeyboardKeyAction.NavigateWordLeft, zKey.cornerAssignments.bottomLeft?.value?.action)
        assertEquals(KeyboardKeyAction.NavigateWordRight, zKey.cornerAssignments.bottomRight?.value?.action)
        assertEquals(KeyboardKeyAction.NavigateCharLeft, sKey.cornerAssignments.left?.value?.action)
        assertEquals(KeyboardKeyAction.NavigateCharRight, sKey.cornerAssignments.right?.value?.action)
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
        assertNull(key.cornerAssignments.topRight?.label)
    }

    @Test
    fun `smart french corners also resolve on azerty layout`() {
        val aKey = keyById("letter-a", layoutProfile = KeyboardLayoutProfile.AZERTY)
        val zKey = keyById("letter-z", layoutProfile = KeyboardLayoutProfile.AZERTY)
        val wKey = keyById("letter-w", layoutProfile = KeyboardLayoutProfile.AZERTY)
        val sKey = keyById("letter-s", layoutProfile = KeyboardLayoutProfile.AZERTY)
        val eKey = keyById("letter-e", layoutProfile = KeyboardLayoutProfile.AZERTY)
        val uKey = keyById("letter-u", layoutProfile = KeyboardLayoutProfile.AZERTY)
        val cKey = keyById("letter-c", layoutProfile = KeyboardLayoutProfile.AZERTY)

        assertNull(aKey.cornerAssignments.topLeft)
        assertNull(aKey.cornerAssignments.topRight)
        assertEquals("é", eKey.cornerAssignments.topLeft?.label)
        assertEquals("è", eKey.cornerAssignments.topRight?.label)
        assertEquals("ù", uKey.cornerAssignments.topLeft?.label)
        assertNull(uKey.cornerAssignments.topRight)
        assertEquals("ç", cKey.cornerAssignments.topLeft?.label)
        assertNull(cKey.cornerAssignments.topRight)
        assertNull(wKey.cornerAssignments.down)
        assertEquals("↑", zKey.cornerAssignments.up?.label)
        assertEquals("↓", zKey.cornerAssignments.down?.label)
        assertEquals("←", sKey.cornerAssignments.left?.label)
        assertEquals("→", sKey.cornerAssignments.right?.label)
        assertEquals("W←", zKey.cornerAssignments.bottomLeft?.label)
        assertEquals("W→", zKey.cornerAssignments.bottomRight?.label)
        assertEquals(KeyboardKeyAction.NavigateWordLeft, zKey.cornerAssignments.bottomLeft?.value?.action)
        assertEquals(KeyboardKeyAction.NavigateWordRight, zKey.cornerAssignments.bottomRight?.value?.action)
    }

    @Test
    fun `azerty s and z directional gestures ignore special-key toggle`() {
        val zKey = keyById("letter-z", layoutProfile = KeyboardLayoutProfile.AZERTY, specialKeyCorners = false)
        val sKey = keyById("letter-s", layoutProfile = KeyboardLayoutProfile.AZERTY, specialKeyCorners = false)

        assertEquals("↑", zKey.cornerAssignments.up?.label)
        assertEquals("↓", zKey.cornerAssignments.down?.label)
        assertEquals("←", sKey.cornerAssignments.left?.label)
        assertEquals("→", sKey.cornerAssignments.right?.label)
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
        val accent = keyById(
            "letter-e",
            config = config,
            fieldPolicy = privatePolicy(),
            layoutProfile = KeyboardLayoutProfile.AZERTY,
        )

        assertNull(sensitive.cornerAssignments.topLeft)
        assertEquals("é", accent.cornerAssignments.topLeft?.label)
    }

    @Test
    fun `corrupt stored json falls back to default config`() {
        val config = KeyboardCornerConfig.fromJson("{not-json")

        assertEquals(KeyboardCornerPresets.FRENCH_ACCENTS, config.presetId)
        assertTrue(config.overrides.isEmpty())
    }

    @Test
    fun `new directional slots parse from json map`() {
        val config =
            KeyboardCornerConfig.fromMap(
                mapOf(
                    "presetId" to KeyboardCornerPresets.NONE,
                    "overrides" to
                        listOf(
                            mapOf(
                                "keyId" to "letter-h",
                                "slot" to "up",
                                "expression" to "action:NavigateLineUp",
                                "label" to "↑",
                            ),
                        ),
                ),
            )

        val resolved = keyById("letter-h", config = config)
        assertEquals("↑", resolved.cornerAssignments.up?.label)
        assertEquals(KeyboardKeyAction.NavigateLineUp, resolved.cornerAssignments.up?.value?.action)
    }

    private fun keyById(
        keyId: String,
        config: KeyboardCornerConfig = KeyboardCornerConfig(),
        specialKeyCorners: Boolean = false,
        fieldPolicy: KeyboardFieldPolicy = publicPolicy(),
        layoutProfile: KeyboardLayoutProfile = KeyboardLayoutProfile.QWERTY,
    ): KeyboardKeySpec {
        val snapshot =
            KeyboardLayoutBuilder.build(
                KeyboardLayoutRequest(
                    mode = KeyboardLayoutMode.Letters,
                    panel = KeyboardPanelMode.None,
                    shifted = false,
                    fieldContext = KeyboardFieldContextMode.Text,
                    layoutProfile = layoutProfile,
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
