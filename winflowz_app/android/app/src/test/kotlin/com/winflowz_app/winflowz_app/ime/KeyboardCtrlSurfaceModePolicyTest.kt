package com.winflowz_app.winflowz_app.ime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class KeyboardCtrlSurfaceModePolicyTest {
    @Test
    fun `simple tap keeps ctrl as modifier`() {
        assertEquals(
            KeyboardCtrlSurfaceTapAction.ToggleModifier,
            KeyboardCtrlSurfaceModePolicy.actionForPrimaryTap(
                locked = false,
                lastTapAtMs = 0L,
                nowAtMs = 1000L,
                doubleTapTimeoutMs = 300L,
            ),
        )
    }

    @Test
    fun `fast second tap locks ctrl action surface`() {
        assertEquals(
            KeyboardCtrlSurfaceTapAction.LockSurface,
            KeyboardCtrlSurfaceModePolicy.actionForPrimaryTap(
                locked = false,
                lastTapAtMs = 1000L,
                nowAtMs = 1200L,
                doubleTapTimeoutMs = 300L,
            ),
        )
    }

    @Test
    fun `tap while locked unlocks ctrl action surface`() {
        assertEquals(
            KeyboardCtrlSurfaceTapAction.UnlockSurface,
            KeyboardCtrlSurfaceModePolicy.actionForPrimaryTap(
                locked = true,
                lastTapAtMs = 1000L,
                nowAtMs = 1200L,
                doubleTapTimeoutMs = 300L,
            ),
        )
    }

    @Test
    fun `long press only unlocks when the surface is locked`() {
        assertTrue(KeyboardCtrlSurfaceModePolicy.shouldUnlockOnLongPress(locked = true))
        assertFalse(KeyboardCtrlSurfaceModePolicy.shouldUnlockOnLongPress(locked = false))
    }
}
