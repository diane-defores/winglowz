package com.winflowz_app.winflowz_app.ime

import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarController
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarState
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionEnvironment
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class KeyboardActionBarControllerTest {
    private val controller = KeyboardActionBarController()

    @Test
    fun `long press toggles pinned action row on and off`() {
        val pinned =
            controller.onLongPress(
                actionId = "numbers",
                state = KeyboardActionBarState(),
                environment = environment(),
            )

        assertEquals("Action pinned", pinned.status)
        assertTrue("numbers" in pinned.nextState.pinnedActionIds)
        assertTrue(pinned.nextState.attachedRows.any { it.providerActionId == "numbers" })

        val unpinned =
            controller.onLongPress(
                actionId = "numbers",
                state = pinned.nextState,
                environment = environment(),
            )

        assertEquals("Action unpinned", unpinned.status)
        assertFalse("numbers" in unpinned.nextState.pinnedActionIds)
        assertFalse(unpinned.nextState.attachedRows.any { it.providerActionId == "numbers" })
    }

    @Test
    fun `symbols accents emoji clipboard snippets and media expose pinnable rows`() {
        val actionIds = listOf("symbols", "accents", "emoji", "clipboard", "snippets", "media")

        actionIds.forEach { actionId ->
            val result =
                controller.onLongPress(
                    actionId = actionId,
                    state = KeyboardActionBarState(),
                    environment = environment(),
                )

            assertEquals("Action pinned", result.status)
            assertTrue(actionId in result.nextState.pinnedActionIds)
            assertTrue(result.nextState.attachedRows.any { it.providerActionId == actionId })
        }
    }

    @Test
    fun `pinned action ids render attached rows after state restore`() {
        val snapshot =
            controller.buildRenderSnapshot(
                state = KeyboardActionBarState(pinnedActionIds = setOf("symbols", "emoji")),
                environment = environment(),
            )

        assertTrue(snapshot.attachedRows.any { it.dedupeKey == "symbols" })
        assertTrue(snapshot.attachedRows.any { it.dedupeKey == "emoji" })
    }

    @Test
    fun `media pinned row keeps controls after stop`() {
        val snapshot =
            controller.buildRenderSnapshot(
                state = KeyboardActionBarState(pinnedActionIds = setOf("media")),
                environment = environment(),
            )

        val mediaRow = snapshot.attachedRows.single { it.dedupeKey == "media" }
        val labels = mediaRow.items.map { it.label }

        assertEquals(10, mediaRow.visiblePageKeyCount)
        assertTrue(labels.indexOf("Vol-") > labels.indexOf("Stop"))
        assertTrue(labels.indexOf("Vol+") > labels.indexOf("Stop"))
        assertTrue(labels.indexOf("Bri-") > labels.indexOf("Stop"))
        assertTrue(labels.indexOf("Bri+") > labels.indexOf("Stop"))
        assertTrue(labels.indexOf("Loop") > labels.indexOf("Stop"))
    }

    @Test
    fun `pinned action rows only scroll when they exceed alphabet slots`() {
        val overflowingActionIds = listOf("numbers", "symbols", "accents", "navigation", "emoji", "media")

        overflowingActionIds.forEach { actionId ->
            val snapshot =
                controller.buildRenderSnapshot(
                    state = KeyboardActionBarState(pinnedActionIds = setOf(actionId)),
                    environment = environment(),
                )

            val row = snapshot.attachedRows.single { it.dedupeKey == actionId }
            assertEquals(10, row.visiblePageKeyCount)
        }

        val shortRowsSnapshot =
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
                            pinnedActionIds = setOf("clipboard", "snippets"),
                            attachedRows =
                                listOf(
                                    KeyboardAttachedActionRowState("clipboard", "action-row-clipboard", "clipboard"),
                                    KeyboardAttachedActionRowState("snippets", "action-row-snippets", "snippets"),
                                ),
                        ),
                ),
            )

        val clipboardRow = shortRowsSnapshot.rows.single { it.rowId == "action-row-clipboard" }
        val snippetsRow = shortRowsSnapshot.rows.single { it.rowId == "action-row-snippets" }
        assertFalse(clipboardRow.horizontalScrollable)
        assertFalse(snippetsRow.horizontalScrollable)
        assertEquals(null, clipboardRow.visiblePageKeyCount)
        assertEquals(null, snippetsRow.visiblePageKeyCount)
    }

    private fun environment(): KeyboardActionEnvironment {
        return KeyboardActionEnvironment(
            fieldPolicy =
                KeyboardFieldPolicy(
                    privateMode = false,
                    reason = "standard",
                    inputAllowed = true,
                    voiceAllowed = true,
                    clipboardAllowed = true,
                    snippetsAllowed = true,
                    learningAllowed = true,
                ),
            layoutMode = KeyboardLayoutMode.Letters,
            panelMode = KeyboardPanelMode.None,
            clipboardAllowed = true,
            voiceAllowed = true,
            snippetsAllowed = true,
            mediaControlsEnabled = true,
        )
    }
}
