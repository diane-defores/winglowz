package com.voiceflowz.voiceflowz.ime

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.view.View.MeasureSpec
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.max

class VoiceFlowzKeyboardView(
    context: Context,
    private val callbacks: Callbacks,
) : View(context) {
    interface Callbacks {
        fun onText(text: String)
        fun onEmojiInserted(emoji: String)
        fun onBackspace()
        fun onDeleteWordBefore(): Boolean
        fun onEnter()
        fun onVoice()
        fun onCopySelection()
        fun onPasteClipboard(): Boolean
        fun onSnippets()
        fun onSettings()
        fun onMediaPlayPause()
        fun onMediaPrevious()
        fun onMediaNext()
        fun onNavigateCharLeft(): Boolean
        fun onNavigateCharRight(): Boolean
        fun onNavigateWordLeft(): Boolean
        fun onNavigateWordRight(): Boolean
        fun onNavigateLineStart(): Boolean
        fun onNavigateLineEnd(): Boolean
        fun onLayoutProfileChanged(profile: KeyboardLayoutProfile)
        fun onCornerModeChanged(enabled: Boolean)
        fun onDebugTouchOverlayChanged(enabled: Boolean)
        fun onDoubleSpacePeriodChanged(enabled: Boolean)
        fun onPunctuationAutoSpacingChanged(enabled: Boolean)
    }

    private data class KeyFrame(
        val key: KeyboardKeySpec,
        val rect: RectF,
    )

    private var shifted = false
    private var layoutMode = KeyboardLayoutMode.Letters
    private var panelMode = KeyboardPanelMode.None
    private var layoutProfile = KeyboardLayoutProfile.QWERTY
    private var cornerModeEnabled = false
    private var debugTouchOverlayEnabled = false
    private var doubleSpacePeriodEnabled = true
    private var punctuationAutoSpacingEnabled = true
    private var emojiCategory = KeyboardEmojiCategory.Recents
    private var recentEmojis = emptyList<String>()
    private var fieldPolicy = KeyboardSecurityPolicy.evaluate(null, KeyboardStateStore.PRIVACY_AUTO)
    private var fieldContext = KeyboardFieldContextMode.Text
    private var enterLabel = "Enter"
    private var statusText = "VoiceFlowz"

    private var gestureStartFrame: KeyFrame? = null
    private var gestureStartX = 0f
    private var gestureStartY = 0f
    private var gestureLatestX = 0f
    private var gestureLatestY = 0f
    private var gestureMaxDistance = 0f
    private var activeKeyId: String? = null
    private var debugGestureText = "idle"

    private val keyFrames = mutableListOf<KeyFrame>()
    private var layoutSnapshot = buildSnapshot()

    private val density = resources.displayMetrics.density
    private val outerPadding = dp(8f)
    private val keyGap = dp(5f)
    private val keyRadius = dp(8f)
    private val statusHeight = dp(30f)
    private val actionRowHeight = dp(40f)
    private val textRowHeight = dp(46f)
    private val controlRowHeight = dp(48f)
    private val panelRowHeight = dp(42f)

    private val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(238, 241, 238)
    }
    private val privateBackgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(246, 232, 226)
    }
    private val keyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
    }
    private val specialKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(224, 230, 227)
    }
    private val activeKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(23, 121, 93)
    }
    private val pressedKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(202, 218, 211)
    }
    private val disabledKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(214, 217, 215)
    }
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(29, 35, 32)
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }
    private val secondaryTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(92, 103, 98)
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }
    private val statusPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(51, 61, 56)
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }
    private val debugStrokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(216, 32, 32)
        style = Paint.Style.STROKE
        strokeWidth = dp(1f)
    }
    private val debugTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(160, 24, 24)
        textAlign = Paint.Align.LEFT
        typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
    }

    private val gestureThresholds =
        GestureThresholds(
            tapSlopPx = dp(10f),
            cornerThresholdPx = dp(16f),
            returnCenterRadiusPx = dp(12f),
        )

    init {
        isClickable = true
        isFocusable = true
        setBackgroundColor(Color.TRANSPARENT)
    }

    fun applyPolicy(policy: KeyboardFieldPolicy) {
        fieldPolicy = policy
        statusText =
            if (policy.privateMode) {
                "VoiceFlowz - private input (${policy.reason})"
            } else {
                "VoiceFlowz"
            }
        refreshLayout()
    }

    fun applyRuntimePreferences(
        profile: KeyboardLayoutProfile,
        cornersEnabled: Boolean,
        debugTouchOverlay: Boolean,
        doubleSpacePeriod: Boolean,
        punctuationAutoSpacing: Boolean,
        recents: List<String>,
    ) {
        layoutProfile = profile
        cornerModeEnabled = cornersEnabled
        debugTouchOverlayEnabled = debugTouchOverlay
        doubleSpacePeriodEnabled = doubleSpacePeriod
        punctuationAutoSpacingEnabled = punctuationAutoSpacing
        recentEmojis = recents
        refreshLayout()
    }

    fun applyInputContext(
        contextMode: KeyboardFieldContextMode,
        enterActionLabel: String,
    ) {
        fieldContext = contextMode
        enterLabel = enterActionLabel
        if (fieldContext == KeyboardFieldContextMode.Phone) {
            layoutMode = KeyboardLayoutMode.Numbers
        }
        refreshLayout()
    }

    fun setStatus(message: String) {
        statusText = message
        invalidate()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val desiredHeight = desiredKeyboardHeight()
        setMeasuredDimension(width, resolveSize(desiredHeight, heightMeasureSpec))
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        keyFrames.clear()
        canvas.drawRect(
            0f,
            0f,
            width.toFloat(),
            height.toFloat(),
            if (fieldPolicy.privateMode) privateBackgroundPaint else backgroundPaint,
        )

        val left = outerPadding
        val right = width - outerPadding
        var y = outerPadding

        drawStatus(canvas, y, right - left)
        y += statusHeight + keyGap

        layoutSnapshot.rows.forEachIndexed { index, row ->
            val rowHeight = rowHeightFor(index)
            drawRow(canvas, row, left, y, right - left, rowHeight)
            y += rowHeight + keyGap
        }

        if (debugTouchOverlayEnabled) {
            drawDebugOverlay(canvas)
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                val hit = hitTest(event.x, event.y)
                if (hit == null || !hit.key.enabled) {
                    return false
                }
                gestureStartFrame = hit
                gestureStartX = event.x
                gestureStartY = event.y
                gestureLatestX = event.x
                gestureLatestY = event.y
                gestureMaxDistance = 0f
                activeKeyId = hit.key.id
                debugGestureText = "start key=${hit.key.id}"
                invalidate()
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                if (gestureStartFrame == null) {
                    return false
                }
                gestureLatestX = event.x
                gestureLatestY = event.y
                val dx = gestureLatestX - gestureStartX
                val dy = gestureLatestY - gestureStartY
                val distance = hypot(dx.toDouble(), dy.toDouble()).toFloat()
                gestureMaxDistance = max(gestureMaxDistance, distance)
                activeKeyId = gestureStartFrame?.key?.id
                debugGestureText =
                    "move dir=${directionFrom(dx, dy)} dist=${distance.toInt()} max=${gestureMaxDistance.toInt()}"
                invalidate()
                return true
            }
            MotionEvent.ACTION_UP -> {
                val startFrame = gestureStartFrame
                val key = startFrame?.key
                if (key == null || !key.enabled) {
                    resetGesture()
                    invalidate()
                    return true
                }
                val selection =
                    effectiveGestureSelection(
                        key = key,
                        sample =
                            GestureSample(
                                startX = gestureStartX,
                                startY = gestureStartY,
                                endX = event.x,
                                endY = event.y,
                                maxDistanceFromStart = gestureMaxDistance,
                            ),
                    )
                debugGestureText =
                    "up key=${key.id} sel=${selection.name} tap=${gestureThresholds.tapSlopPx.toInt()} corner=${gestureThresholds.cornerThresholdPx.toInt()}"
                dispatch(key, selection)
                resetGesture()
                invalidate()
                return true
            }
            MotionEvent.ACTION_CANCEL -> {
                resetGesture()
                debugGestureText = "cancel"
                invalidate()
                return true
            }
        }
        return super.onTouchEvent(event)
    }

    private fun resetGesture() {
        gestureStartFrame = null
        activeKeyId = null
        gestureMaxDistance = 0f
    }

    private fun drawStatus(canvas: Canvas, top: Float, contentWidth: Float) {
        statusPaint.textSize = sp(13f)
        val baseline = top + statusHeight / 2f - (statusPaint.descent() + statusPaint.ascent()) / 2f
        canvas.drawText(statusText, outerPadding + contentWidth / 2f, baseline, statusPaint)
    }

    private fun drawRow(
        canvas: Canvas,
        row: KeyboardRowSpec,
        left: Float,
        top: Float,
        width: Float,
        height: Float,
    ) {
        val totalWeight =
            row.keys.sumOf { it.weight.toDouble() }.toFloat() + row.leadingWeight + row.trailingWeight
        val usableWidth = width - keyGap * max(0, row.keys.size - 1)
        val unit = usableWidth / totalWeight
        var x = left + unit * row.leadingWeight

        row.keys.forEach { key ->
            val keyWidth = unit * key.weight
            val rect = RectF(x, top, x + keyWidth, top + height)
            keyFrames.add(KeyFrame(key, rect))
            drawKey(canvas, key, rect)
            x += keyWidth + keyGap
        }
    }

    private fun drawKey(
        canvas: Canvas,
        key: KeyboardKeySpec,
        rect: RectF,
    ) {
        val paint = when {
            !key.enabled -> disabledKeyPaint
            key.id == activeKeyId -> pressedKeyPaint
            key.active -> activeKeyPaint
            key.action == KeyboardKeyAction.Text -> keyPaint
            else -> specialKeyPaint
        }
        canvas.drawRoundRect(rect, keyRadius, keyRadius, paint)

        textPaint.color =
            if (key.active) {
                Color.WHITE
            } else if (key.enabled) {
                Color.rgb(29, 35, 32)
            } else {
                Color.rgb(123, 130, 126)
            }
        textPaint.textSize = keyTextSize(key)
        val baseline = rect.centerY() - (textPaint.descent() + textPaint.ascent()) / 2f
        canvas.drawText(displayLabel(key), rect.centerX(), baseline, textPaint)

        if (shouldRenderCorners(key)) {
            renderCornerGlyphs(canvas, rect, key.glyph)
        }
    }

    private fun shouldRenderCorners(key: KeyboardKeySpec): Boolean {
        if (!cornerModeEnabled || key.action != KeyboardKeyAction.Text) {
            return false
        }
        val glyph = key.glyph ?: return false
        return glyph.topLeft != null ||
            glyph.topRight != null ||
            glyph.bottomLeft != null ||
            glyph.bottomRight != null
    }

    private fun renderCornerGlyphs(
        canvas: Canvas,
        rect: RectF,
        glyph: KeyboardKeyGlyph?,
    ) {
        if (glyph == null) {
            return
        }
        secondaryTextPaint.textSize = sp(9f)
        secondaryTextPaint.color = Color.rgb(92, 103, 98)
        glyph.topLeft?.let {
            canvas.drawText(it, rect.left + dp(10f), rect.top + dp(12f), secondaryTextPaint)
        }
        glyph.topRight?.let {
            canvas.drawText(it, rect.right - dp(10f), rect.top + dp(12f), secondaryTextPaint)
        }
        glyph.bottomLeft?.let {
            canvas.drawText(it, rect.left + dp(10f), rect.bottom - dp(8f), secondaryTextPaint)
        }
        glyph.bottomRight?.let {
            canvas.drawText(it, rect.right - dp(10f), rect.bottom - dp(8f), secondaryTextPaint)
        }
    }

    private fun effectiveGestureSelection(
        key: KeyboardKeySpec,
        sample: GestureSample,
    ): GestureSelection {
        if (!cornerModeEnabled || key.action != KeyboardKeyAction.Text || key.glyph == null) {
            return GestureSelection.PrimaryTap
        }
        return KeyboardGestureClassifier.classify(sample, gestureThresholds)
    }

    private fun dispatch(
        key: KeyboardKeySpec,
        selection: GestureSelection,
    ) {
        if (selection == GestureSelection.Canceled) {
            setStatus("Gesture canceled")
            performHapticFeedback(HapticFeedbackConstants.REJECT)
            return
        }
        performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
        when (key.action) {
            KeyboardKeyAction.Text -> {
                val output = outputFor(key, selection) ?: return
                callbacks.onText(output)
                if (panelMode == KeyboardPanelMode.Emoji) {
                    callbacks.onEmojiInserted(output)
                }
                if (shifted && layoutMode == KeyboardLayoutMode.Letters) {
                    shifted = false
                }
            }
            KeyboardKeyAction.Backspace -> callbacks.onBackspace()
            KeyboardKeyAction.DeleteWordBefore -> {
                if (!callbacks.onDeleteWordBefore()) {
                    setStatus("Word deletion unavailable")
                }
            }
            KeyboardKeyAction.Enter -> callbacks.onEnter()
            KeyboardKeyAction.Shift -> shifted = !shifted
            KeyboardKeyAction.ModeLetters -> {
                layoutMode = KeyboardLayoutMode.Letters
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.ModeNumbers -> {
                layoutMode = KeyboardLayoutMode.Numbers
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.ModeAccents -> {
                layoutMode = KeyboardLayoutMode.Accents
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.ModeSymbols -> {
                layoutMode = KeyboardLayoutMode.Symbols
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.ToggleNavigationPanel -> togglePanel(KeyboardPanelMode.Navigation)
            KeyboardKeyAction.ToggleEmojiPanel -> togglePanel(KeyboardPanelMode.Emoji)
            KeyboardKeyAction.ToggleClipboardPanel -> togglePanel(KeyboardPanelMode.Clipboard)
            KeyboardKeyAction.ToggleMediaPanel -> togglePanel(KeyboardPanelMode.Media)
            KeyboardKeyAction.ToggleSnippetsPanel -> togglePanel(KeyboardPanelMode.Snippets)
            KeyboardKeyAction.ToggleSettingsPanel -> togglePanel(KeyboardPanelMode.Settings)
            KeyboardKeyAction.CopySelection -> callbacks.onCopySelection()
            KeyboardKeyAction.PasteClipboard -> {
                val pasted = callbacks.onPasteClipboard()
                if (pasted) {
                    panelMode = KeyboardPanelMode.None
                } else {
                    setStatus("Clipboard unavailable")
                }
            }
            KeyboardKeyAction.ShowClipboardPins -> {
                setStatus("Pinned clipboard list opens from app")
            }
            KeyboardKeyAction.MediaPrevious -> callbacks.onMediaPrevious()
            KeyboardKeyAction.MediaPlayPause -> callbacks.onMediaPlayPause()
            KeyboardKeyAction.MediaNext -> callbacks.onMediaNext()
            KeyboardKeyAction.InsertSnippetOne -> {
                callbacks.onText("Merci - envoye depuis VoiceFlowz")
                callbacks.onSnippets()
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.OpenVoiceFlowzSettings -> callbacks.onSettings()
            KeyboardKeyAction.ToggleCornerMode -> {
                cornerModeEnabled = !cornerModeEnabled
                callbacks.onCornerModeChanged(cornerModeEnabled)
                setStatus(if (cornerModeEnabled) "Corner swipe enabled" else "Corner swipe disabled")
            }
            KeyboardKeyAction.ToggleLayoutProfile -> {
                layoutProfile =
                    if (layoutProfile == KeyboardLayoutProfile.QWERTY) {
                        KeyboardLayoutProfile.AZERTY
                    } else {
                        KeyboardLayoutProfile.QWERTY
                    }
                callbacks.onLayoutProfileChanged(layoutProfile)
                setStatus("Layout ${layoutProfile.name}")
            }
            KeyboardKeyAction.ToggleDebugTouchOverlay -> {
                debugTouchOverlayEnabled = !debugTouchOverlayEnabled
                callbacks.onDebugTouchOverlayChanged(debugTouchOverlayEnabled)
                setStatus(if (debugTouchOverlayEnabled) "Touch debug enabled" else "Touch debug disabled")
            }
            KeyboardKeyAction.ToggleDoubleSpacePeriod -> {
                doubleSpacePeriodEnabled = !doubleSpacePeriodEnabled
                callbacks.onDoubleSpacePeriodChanged(doubleSpacePeriodEnabled)
                setStatus(if (doubleSpacePeriodEnabled) "Double-space period on" else "Double-space period off")
            }
            KeyboardKeyAction.TogglePunctuationAutoSpacing -> {
                punctuationAutoSpacingEnabled = !punctuationAutoSpacingEnabled
                callbacks.onPunctuationAutoSpacingChanged(punctuationAutoSpacingEnabled)
                setStatus(if (punctuationAutoSpacingEnabled) "Punctuation spacing on" else "Punctuation spacing off")
            }
            KeyboardKeyAction.SelectEmojiRecents -> emojiCategory = KeyboardEmojiCategory.Recents
            KeyboardKeyAction.SelectEmojiSmileys -> emojiCategory = KeyboardEmojiCategory.Smileys
            KeyboardKeyAction.SelectEmojiHands -> emojiCategory = KeyboardEmojiCategory.Hands
            KeyboardKeyAction.SelectEmojiSymbols -> emojiCategory = KeyboardEmojiCategory.Symbols
            KeyboardKeyAction.NavigateCharLeft -> {
                if (!callbacks.onNavigateCharLeft()) {
                    setStatus("Left unavailable")
                }
            }
            KeyboardKeyAction.NavigateCharRight -> {
                if (!callbacks.onNavigateCharRight()) {
                    setStatus("Right unavailable")
                }
            }
            KeyboardKeyAction.NavigateWordLeft -> {
                if (!callbacks.onNavigateWordLeft()) {
                    setStatus("Word-left unavailable")
                }
            }
            KeyboardKeyAction.NavigateWordRight -> {
                if (!callbacks.onNavigateWordRight()) {
                    setStatus("Word-right unavailable")
                }
            }
            KeyboardKeyAction.NavigateLineStart -> {
                if (!callbacks.onNavigateLineStart()) {
                    setStatus("Start unavailable")
                }
            }
            KeyboardKeyAction.NavigateLineEnd -> {
                if (!callbacks.onNavigateLineEnd()) {
                    setStatus("End unavailable")
                }
            }
            KeyboardKeyAction.ClosePanel -> panelMode = KeyboardPanelMode.None
            KeyboardKeyAction.Voice -> callbacks.onVoice()
        }
        refreshLayout()
    }

    private fun togglePanel(target: KeyboardPanelMode) {
        panelMode = if (panelMode == target) KeyboardPanelMode.None else target
    }

    private fun buildSnapshot(): KeyboardLayoutSnapshot {
        return KeyboardLayoutBuilder.build(
            KeyboardLayoutRequest(
                mode = layoutMode,
                panel = panelMode,
                shifted = shifted,
                fieldContext = fieldContext,
                layoutProfile = layoutProfile,
                cornerModeEnabled = cornerModeEnabled,
                debugTouchOverlayEnabled = debugTouchOverlayEnabled,
                doubleSpacePeriodEnabled = doubleSpacePeriodEnabled,
                punctuationAutoSpacingEnabled = punctuationAutoSpacingEnabled,
                emojiCategory = emojiCategory,
                recentEmojis = recentEmojis,
                enterLabel = enterLabel,
                clipboardAllowed = fieldPolicy.clipboardAllowed,
                voiceAllowed = fieldPolicy.voiceAllowed,
                snippetsAllowed = fieldPolicy.snippetsAllowed,
            ),
        )
    }

    private fun outputFor(
        key: KeyboardKeySpec,
        selection: GestureSelection,
    ): String? {
        val raw = key.glyph?.outputFor(selection) ?: key.label
        if (!shifted || layoutSnapshot.mode != KeyboardLayoutMode.Letters) {
            return raw
        }
        return if (raw.length == 1 && raw[0].isLetter()) {
            raw.uppercase()
        } else {
            raw
        }
    }

    private fun displayLabel(key: KeyboardKeySpec): String {
        if (key.action != KeyboardKeyAction.Text) {
            return key.label
        }
        val primary = key.glyph?.primary ?: key.label
        if (primary == " ") {
            return key.label
        }
        if (!shifted || layoutSnapshot.mode != KeyboardLayoutMode.Letters) {
            return primary
        }
        return if (primary.length == 1 && primary[0].isLetter()) {
            primary.uppercase()
        } else {
            primary
        }
    }

    private fun keyTextSize(key: KeyboardKeySpec): Float {
        return when {
            key.label.length <= 1 -> sp(19f)
            key.weight >= 3f -> sp(15f)
            key.label.length >= 5 -> sp(11f)
            else -> sp(12.5f)
        }
    }

    private fun hitTest(x: Float, y: Float): KeyFrame? {
        return keyFrames.firstOrNull { it.rect.contains(x, y) }
    }

    private fun rowHeightFor(index: Int): Float {
        return when {
            index == 0 -> actionRowHeight
            layoutSnapshot.panelRowCount > 0 && index in 1..layoutSnapshot.panelRowCount -> panelRowHeight
            index == layoutSnapshot.rows.lastIndex -> controlRowHeight
            else -> textRowHeight
        }
    }

    private fun desiredKeyboardHeight(): Int {
        val rowCount = layoutSnapshot.rows.size
        val rowsHeight =
            layoutSnapshot.rows.indices.sumOf { index ->
                rowHeightFor(index).toDouble()
            }.toFloat()
        return (outerPadding * 2 + statusHeight + rowsHeight + keyGap * rowCount).toInt()
    }

    private fun drawDebugOverlay(canvas: Canvas) {
        keyFrames.forEach { frame ->
            canvas.drawRoundRect(frame.rect, keyRadius, keyRadius, debugStrokePaint)
        }
        val dx = gestureLatestX - gestureStartX
        val dy = gestureLatestY - gestureStartY
        val direction = directionFrom(dx, dy)
        debugTextPaint.textSize = sp(10f)
        val debugLine =
            "debug key=${activeKeyId ?: "-"} dir=$direction sel=${debugGestureText}"
        canvas.drawText(debugLine, outerPadding, height - dp(6f), debugTextPaint)
    }

    private fun directionFrom(dx: Float, dy: Float): String {
        if (abs(dx) < 1f && abs(dy) < 1f) {
            return "center"
        }
        val horizontal = if (dx >= 0f) "R" else "L"
        val vertical = if (dy >= 0f) "D" else "U"
        return "$horizontal$vertical"
    }

    private fun refreshLayout() {
        layoutSnapshot = buildSnapshot()
        requestLayout()
        invalidate()
    }

    private fun dp(value: Float): Float = value * density

    private fun sp(value: Float): Float = value * resources.displayMetrics.scaledDensity
}
