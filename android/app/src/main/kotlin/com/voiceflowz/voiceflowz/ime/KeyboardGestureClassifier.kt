package com.voiceflowz.voiceflowz.ime

import kotlin.math.hypot

data class GestureSample(
    val startX: Float,
    val startY: Float,
    val endX: Float,
    val endY: Float,
    val maxDistanceFromStart: Float,
)

data class GestureThresholds(
    val tapSlopPx: Float,
    val cornerThresholdPx: Float,
    val returnCenterRadiusPx: Float,
)

enum class GestureSelection {
    PrimaryTap,
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
    Canceled,
}

object KeyboardGestureClassifier {
    fun classify(sample: GestureSample, thresholds: GestureThresholds): GestureSelection {
        val dx = sample.endX - sample.startX
        val dy = sample.endY - sample.startY
        val distance = hypot(dx.toDouble(), dy.toDouble()).toFloat()

        if (distance <= thresholds.tapSlopPx) {
            return GestureSelection.PrimaryTap
        }

        if (sample.maxDistanceFromStart > thresholds.cornerThresholdPx &&
            distance <= thresholds.returnCenterRadiusPx
        ) {
            return GestureSelection.Canceled
        }

        if (dx <= -thresholds.cornerThresholdPx && dy <= -thresholds.cornerThresholdPx) {
            return GestureSelection.TopLeft
        }
        if (dx >= thresholds.cornerThresholdPx && dy <= -thresholds.cornerThresholdPx) {
            return GestureSelection.TopRight
        }
        if (dx <= -thresholds.cornerThresholdPx && dy >= thresholds.cornerThresholdPx) {
            return GestureSelection.BottomLeft
        }
        if (dx >= thresholds.cornerThresholdPx && dy >= thresholds.cornerThresholdPx) {
            return GestureSelection.BottomRight
        }

        return GestureSelection.PrimaryTap
    }
}
