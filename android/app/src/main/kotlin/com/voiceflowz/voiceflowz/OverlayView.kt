package com.voiceflowz.voiceflowz

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.util.TypedValue
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.roundToInt

class OverlayView(context: Context) : FrameLayout(context) {

    var onBubbleTap: (() -> Unit)? = null
    var onRecordStop: (() -> Unit)? = null
    var onRecordCancel: (() -> Unit)? = null
    var onBubbleLongPress: (() -> Unit)? = null

    private var currentState = "collapsed"
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())

    private val fabSize = dpToPx(44f)
    private val expandedWidth = dpToPx(216f)
    private val expandedHeight = dpToPx(54f)
    private val buttonSize = dpToPx(28f)
    private val cornerRadius = dpToPx(24f)

    private val primaryColor = Color.parseColor("#6366f1")
    private val dangerColor = Color.parseColor("#ef4444")
    private val successColor = Color.parseColor("#22c55e")
    private val accentColor = Color.parseColor("#22d3ee")
    private val surfaceColor = Color.parseColor("#1e293b")

    private val fabView: TextView
    private val expandedContainer: LinearLayout
    private val cancelButton: TextView
    private val waveformView: WaveformView
    private val doneButton: TextView

    init {
        fabView = TextView(context).apply {
            layoutParams = LayoutParams(fabSize, fabSize)
            text = "REC"
            textSize = 14f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            visibility = VISIBLE
            setPadding(0, 0, 0, 0)
        }
        fabView.background = CircleDrawable(primaryColor)
        addView(fabView)

        expandedContainer = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LayoutParams(expandedWidth, expandedHeight)
            setPadding(
                dpToPx(8f),
                dpToPx(8f),
                dpToPx(8f),
                dpToPx(8f),
            )
            visibility = GONE
        }
        expandedContainer.background = RoundRectDrawable(surfaceColor, cornerRadius.toFloat())

        cancelButton = TextView(context).apply {
            layoutParams = LinearLayout.LayoutParams(buttonSize, buttonSize).apply {
                setMargins(0, 0, dpToPx(8f), 0)
            }
            text = "X"
            textSize = 14f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            background = CircleDrawable(dangerColor)
            setOnClickListener {
                onRecordCancel?.invoke()
            }
        }
        expandedContainer.addView(cancelButton)

        waveformView = WaveformView(context).apply {
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f)
        }
        expandedContainer.addView(waveformView)

        doneButton = TextView(context).apply {
            layoutParams = LinearLayout.LayoutParams(buttonSize, buttonSize).apply {
                setMargins(dpToPx(8f), 0, 0, 0)
            }
            text = "OK"
            textSize = 12f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            background = CircleDrawable(successColor)
            setOnClickListener {
                onRecordStop?.invoke()
            }
        }
        expandedContainer.addView(doneButton)
        addView(expandedContainer)

        fabView.setOnClickListener { onBubbleTap?.invoke() }
    }

    fun getCurrentState(): String = currentState

    fun setSizeScale(scale: Float) {
        val normalized = scale.coerceIn(0.8f, 1.4f)
        scaleX = normalized
        scaleY = normalized
        pivotX = 0f
        pivotY = 0f
    }

    fun setState(state: String) {
        currentState = normalizeState(state)
        when (currentState) {
            "collapsed" -> {
                fabView.visibility = VISIBLE
                fabView.background = CircleDrawable(primaryColor)
                expandedContainer.visibility = GONE
                layoutParams?.width = fabSize
                layoutParams?.height = fabSize
            }
            "recording" -> {
                fabView.visibility = GONE
                expandedContainer.visibility = VISIBLE
                cancelButton.isEnabled = true
                doneButton.isEnabled = true
                cancelButton.alpha = 1f
                doneButton.alpha = 1f
                waveformView.setProcessing(false)
                layoutParams?.width = expandedWidth
                layoutParams?.height = expandedHeight
            }
            "processing" -> {
                fabView.visibility = GONE
                expandedContainer.visibility = VISIBLE
                cancelButton.isEnabled = false
                doneButton.isEnabled = false
                cancelButton.alpha = 0.35f
                doneButton.alpha = 0.35f
                waveformView.setProcessing(true)
                layoutParams?.width = expandedWidth
                layoutParams?.height = expandedHeight
            }
            "result" -> {
                fabView.visibility = VISIBLE
                fabView.background = CircleDrawable(successColor)
                expandedContainer.visibility = GONE
                layoutParams?.width = fabSize
                layoutParams?.height = fabSize
                handler.removeCallbacksAndMessages(null)
                handler.postDelayed({ setState("collapsed") }, 1400)
            }
        }
        requestLayout()
    }

    fun showResult() {
        setState("result")
    }

    fun updateMeter(level: Float) {
        waveformView.setLevel(level)
    }

    override fun performClick(): Boolean {
        super.performClick()
        if (currentState == "collapsed") {
            onBubbleTap?.invoke()
        }
        return true
    }

    fun emitLongPress() {
        onBubbleLongPress?.invoke()
    }

    private fun normalizeState(state: String): String {
        return if (state in setOf("collapsed", "recording", "processing", "result")) {
            state
        } else {
            "collapsed"
        }
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            resources.displayMetrics,
        ).roundToInt()
    }

    private class CircleDrawable(private val color: Int) : android.graphics.drawable.Drawable() {
        private val paint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                this.color = color
                style = Paint.Style.FILL
            }

        override fun draw(canvas: Canvas) {
            val cx = bounds.exactCenterX()
            val cy = bounds.exactCenterY()
            val radius = minOf(cx, cy)
            canvas.drawCircle(cx, cy, radius, paint)
        }

        override fun setAlpha(alpha: Int) {
            paint.alpha = alpha
        }

        override fun setColorFilter(cf: android.graphics.ColorFilter?) {
            paint.colorFilter = cf
        }

        @Deprecated("Deprecated in Java")
        override fun getOpacity(): Int = android.graphics.PixelFormat.TRANSLUCENT
    }

    private class RoundRectDrawable(
        private val color: Int,
        private val radius: Float,
    ) : android.graphics.drawable.Drawable() {
        private val paint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                this.color = color
                style = Paint.Style.FILL
            }
        private val rect = RectF()

        override fun draw(canvas: Canvas) {
            rect.set(bounds)
            canvas.drawRoundRect(rect, radius, radius, paint)
        }

        override fun setAlpha(alpha: Int) {
            paint.alpha = alpha
        }

        override fun setColorFilter(cf: android.graphics.ColorFilter?) {
            paint.colorFilter = cf
        }

        @Deprecated("Deprecated in Java")
        override fun getOpacity(): Int = android.graphics.PixelFormat.TRANSLUCENT
    }
}
