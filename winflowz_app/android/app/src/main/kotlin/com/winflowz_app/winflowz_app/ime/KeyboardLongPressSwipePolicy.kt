package com.winflowz_app.winflowz_app.ime

import kotlin.math.abs

internal object KeyboardLongPressSwipePolicy {
    private val targetSelections =
        listOf(
            GestureSelection.Up,
            GestureSelection.Right,
            GestureSelection.Down,
            GestureSelection.Left,
        )

    fun canActivateFromKeyExit(
        consumedByProtectedInteraction: Boolean,
        longPressTriggered: Boolean,
        keyEnabled: Boolean,
        pointerInsideStartKey: Boolean,
    ): Boolean {
        return !consumedByProtectedInteraction &&
            !longPressTriggered &&
            keyEnabled &&
            !pointerInsideStartKey
    }

    fun canLaunchCtrlSwipeFromRow(
        startRowIndex: Int?,
        ctrlRowIndex: Int?,
        rowScrollable: Boolean,
        panelScrollable: Boolean,
    ): Boolean {
        return startRowIndex != null &&
            ctrlRowIndex != null &&
            startRowIndex == ctrlRowIndex &&
            !rowScrollable &&
            !panelScrollable
    }

    fun shouldPreserveSpaceSliderGesture(
        startKeyIsSpace: Boolean,
        dx: Float,
        dy: Float,
        spaceSlideStartPx: Float,
    ): Boolean {
        return startKeyIsSpace &&
            abs(dx) >= spaceSlideStartPx &&
            abs(dx) >= abs(dy) * 1.25f
    }

    fun chooseTargetSelection(
        candidates: Collection<GestureSelection>,
        targetX: Float,
        targetY: Float,
        centerX: Float,
        centerY: Float,
    ): GestureSelection? {
        return targetSelections.firstOrNull { it in candidates }
    }

    fun shouldRepeatGestureSelection(
        selection: GestureSelection,
        value: KeyboardKeyValue,
        repeatingActions: Set<KeyboardKeyAction>,
    ): Boolean {
        if (selection == GestureSelection.PrimaryTap || selection == GestureSelection.Canceled) {
            return false
        }
        return value.kind == KeyboardKeyValueKind.Action && value.action in repeatingActions
    }
}
