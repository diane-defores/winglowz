package com.winflowz_app.winflowz_app.ime

internal enum class KeyboardCtrlSurfaceTapAction {
    ToggleModifier,
    LockSurface,
    UnlockSurface,
}

internal object KeyboardCtrlSurfaceModePolicy {
    fun actionForPrimaryTap(
        locked: Boolean,
        lastTapAtMs: Long,
        nowAtMs: Long,
        doubleTapTimeoutMs: Long,
    ): KeyboardCtrlSurfaceTapAction {
        if (locked) {
            return KeyboardCtrlSurfaceTapAction.UnlockSurface
        }
        return if (
            lastTapAtMs > 0L &&
            nowAtMs >= lastTapAtMs &&
            nowAtMs - lastTapAtMs <= doubleTapTimeoutMs
        ) {
            KeyboardCtrlSurfaceTapAction.LockSurface
        } else {
            KeyboardCtrlSurfaceTapAction.ToggleModifier
        }
    }

    fun shouldUnlockOnLongPress(locked: Boolean): Boolean = locked
}
