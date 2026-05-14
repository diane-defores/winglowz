package com.winflowz_app.winflowz_app.ime

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.SoundEffectConstants
import android.view.View
import android.view.View.MeasureSpec
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.max

class WinFlowzAppKeyboardView(
    context: Context,
    private val callbacks: Callbacks,
) : View(context) {
    interface Callbacks {
        fun onText(text: String): Boolean
        fun onEmojiInserted(emoji: String)
        fun onBackspace(): Boolean
        fun onForwardDelete(): Boolean
        fun onDeleteWordBefore(): Boolean
        fun onDeleteWordAfter(): Boolean
        fun onEnter(): Boolean
        fun onVoice()
        fun onCopySelection()
        fun onCutSelection(): Boolean
        fun onPasteClipboard(): Boolean
        fun onPastePlainClipboard(): Boolean
        fun onSelectAll(): Boolean
        fun onUndo(): Boolean
        fun onRedo(): Boolean
        fun onCancelSelection(): Boolean
        fun onSuggestionSelected(suggestion: String): Boolean
        fun onSnippets()
        fun onSettings()
        fun onThemeSettings()
        fun onKeyboardPicker()
        fun onMediaPlayPause()
        fun onMediaPrevious()
        fun onMediaNext()
        fun onMediaNowPlaying(): String
        fun onNavigateCharLeft(): Boolean
        fun onNavigateCharRight(): Boolean
        fun onNavigateWordLeft(): Boolean
        fun onNavigateWordRight(): Boolean
        fun onNavigateLineUp(): Boolean
        fun onNavigateLineDown(): Boolean
        fun onNavigateParagraphUp(): Boolean
        fun onNavigateParagraphDown(): Boolean
        fun onNavigateLineStart(): Boolean
        fun onNavigateLineEnd(): Boolean
        fun onKeyEvent(keyCode: Int, metaState: Int): Boolean
        fun onLayoutProfileChanged(profile: KeyboardLayoutProfile)
        fun onCornerModeChanged(enabled: Boolean)
        fun onDebugTouchOverlayChanged(enabled: Boolean)
        fun onKeyVibrationChanged(enabled: Boolean)
        fun onKeySoundChanged(enabled: Boolean)
        fun onSpellingSuggestionsChanged(enabled: Boolean)
        fun onSpecialKeyCornersChanged(enabled: Boolean)
        fun onFrenchLanguageChanged(enabled: Boolean)
        fun onEnglishLanguageChanged(enabled: Boolean)
        fun onDoubleSpacePeriodChanged(enabled: Boolean)
        fun onPunctuationAutoSpacingChanged(enabled: Boolean)
    }

    private data class KeyFrame(
        val key: KeyboardKeySpec,
        val rect: RectF,
        val rowScrollable: Boolean = false,
    )

    private var shifted = false
    private var layoutMode = KeyboardLayoutMode.Letters
    private var panelMode = KeyboardPanelMode.None
    private var layoutProfile = KeyboardLayoutProfile.QWERTY
    private var cornerModeEnabled = false
    private var debugTouchOverlayEnabled = false
    private var keyVibrationEnabled = true
    private var keySoundEnabled = false
    private var spellingSuggestionsEnabled = true
    private var specialKeyCornersEnabled = false
    private var frenchLanguageEnabled = true
    private var englishLanguageEnabled = true
    private var doubleSpacePeriodEnabled = true
    private var punctuationAutoSpacingEnabled = true
    private var emojiCategory = KeyboardEmojiCategory.Recents
    private var recentEmojis = emptyList<String>()
    private var fieldPolicy = KeyboardSecurityPolicy.evaluate(null, KeyboardStateStore.PRIVACY_AUTO)
    private var fieldContext = KeyboardFieldContextMode.Text
    private var enterLabel = "Enter"
    private var statusText = "WinFlowzApp"
    private var suggestions = emptyList<String>()
    private var clipboardEntries = emptyList<KeyboardClipboardEntry>()
    private var snippets = emptyList<KeyboardTextRule>()
    private var mediaNowPlayingLabel: String? = null
    private var cornerConfig = KeyboardCornerConfig()
    private val activeSystemModifiers = linkedSetOf<KeyboardSystemModifier>()

    private var gestureStartFrame: KeyFrame? = null
    private var gestureStartX = 0f
    private var gestureStartY = 0f
    private var gestureLatestX = 0f
    private var gestureLatestY = 0f
    private var gestureMaxDistance = 0f
    private var activePointerId = MotionEvent.INVALID_POINTER_ID
    private var activeKeyId: String? = null
    private var debugGestureText = "idle"
    private var longPressTriggered = false
    private var repeatActionKey: KeyboardKeySpec? = null
    private var slidingSpace = false
    private var lastSlideStep = 0
    private var scrollingHorizontalRow = false
    private var lastHorizontalScrollX = 0f
    private var horizontalRowScrollOffset = 0f
    private var horizontalRowMaxScrollOffset = 0f

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
    private val longPressDelayMs = 420L
    private val repeatDelayMs = 72L
    private val spaceSlideStartPx = dp(18f)
    private val spaceSlideStepPx = dp(34f)

    private val longPressRunnable =
        Runnable {
            handleLongPress()
        }

    private val repeatRunnable =
        object : Runnable {
            override fun run() {
                val key = repeatActionKey ?: return
                dispatch(key, GestureSelection.PrimaryTap)
                postDelayed(this, repeatDelayMs)
            }
        }

    private val repeatingActions =
        setOf(
            KeyboardKeyAction.Backspace,
            KeyboardKeyAction.ForwardDelete,
            KeyboardKeyAction.DeleteWordBefore,
            KeyboardKeyAction.DeleteWordAfter,
            KeyboardKeyAction.NavigateCharLeft,
            KeyboardKeyAction.NavigateCharRight,
            KeyboardKeyAction.NavigateWordLeft,
            KeyboardKeyAction.NavigateWordRight,
            KeyboardKeyAction.NavigateLineUp,
            KeyboardKeyAction.NavigateLineDown,
            KeyboardKeyAction.NavigateParagraphUp,
            KeyboardKeyAction.NavigateParagraphDown,
        )

    init {
        isClickable = true
        isFocusable = true
        setBackgroundColor(Color.TRANSPARENT)
    }

    fun applyPolicy(policy: KeyboardFieldPolicy) {
        fieldPolicy = policy
        if (policy.privateMode) {
            recentEmojis = emptyList()
            if (emojiCategory == KeyboardEmojiCategory.Recents) {
                emojiCategory = KeyboardEmojiCategory.Smileys
            }
        }
        statusText =
            if (policy.privateMode) {
                "WinFlowzApp - private input (${policy.reason})"
            } else {
                "WinFlowzApp"
            }
        refreshLayout()
    }

    fun applyRuntimePreferences(
        profile: KeyboardLayoutProfile,
        cornersEnabled: Boolean,
        debugTouchOverlay: Boolean,
        keyVibration: Boolean,
        keySound: Boolean,
        spellingSuggestions: Boolean,
        specialKeyCorners: Boolean,
        frenchLanguage: Boolean,
        englishLanguage: Boolean,
        doubleSpacePeriod: Boolean,
        punctuationAutoSpacing: Boolean,
        recents: List<String>,
        clipboardEntries: List<KeyboardClipboardEntry>,
        snippets: List<KeyboardTextRule>,
        cornerConfig: KeyboardCornerConfig,
    ) {
        layoutProfile = profile
        cornerModeEnabled = cornersEnabled
        debugTouchOverlayEnabled = debugTouchOverlay
        keyVibrationEnabled = keyVibration
        keySoundEnabled = keySound
        spellingSuggestionsEnabled = spellingSuggestions
        specialKeyCornersEnabled = specialKeyCorners
        frenchLanguageEnabled = frenchLanguage
        englishLanguageEnabled = englishLanguage
        doubleSpacePeriodEnabled = doubleSpacePeriod
        punctuationAutoSpacingEnabled = punctuationAutoSpacing
        this.clipboardEntries = clipboardEntries
        this.snippets = snippets
        this.cornerConfig = cornerConfig
        recentEmojis = if (fieldPolicy.privateMode) emptyList() else recents
        if (fieldPolicy.privateMode && emojiCategory == KeyboardEmojiCategory.Recents) {
            emojiCategory = KeyboardEmojiCategory.Smileys
        }
        refreshLayout()
    }

    fun applyInputContext(
        contextMode: KeyboardFieldContextMode,
        enterActionLabel: String,
    ) {
        fieldContext = contextMode
        enterLabel = enterActionLabel
        refreshLayout()
    }

    fun applyTypingAssistant(
        autoCapitalized: Boolean,
        candidates: List<String>,
    ) {
        if (layoutMode == KeyboardLayoutMode.Letters && shifted != autoCapitalized) {
            shifted = autoCapitalized
        }
        suggestions = candidates.take(3)
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
                return startGesture(event.getPointerId(event.actionIndex), event.x, event.y)
            }
            MotionEvent.ACTION_POINTER_DOWN -> {
                if (activePointerId != MotionEvent.INVALID_POINTER_ID) {
                    debugGestureText = "multi-touch ignored active=$activePointerId"
                    invalidate()
                    return true
                }
                val index = event.actionIndex
                return startGesture(event.getPointerId(index), event.getX(index), event.getY(index))
            }
            MotionEvent.ACTION_MOVE -> {
                if (gestureStartFrame == null) {
                    return false
                }
                val pointerIndex = event.findPointerIndex(activePointerId)
                if (pointerIndex < 0) {
                    cancelGesture("missing active pointer")
                    return true
                }
                gestureLatestX = event.getX(pointerIndex)
                gestureLatestY = event.getY(pointerIndex)
                val dx = gestureLatestX - gestureStartX
                val dy = gestureLatestY - gestureStartY
                val distance = hypot(dx.toDouble(), dy.toDouble()).toFloat()
                gestureMaxDistance = max(gestureMaxDistance, distance)
                activeKeyId = gestureStartFrame?.key?.id
                handleSpaceSlider(dx, dy)
                handleHorizontalRowScroll(dx, gestureLatestX)
                debugGestureText =
                    "move dir=${directionFrom(dx, dy)} dist=${distance.toInt()} max=${gestureMaxDistance.toInt()} slide=$slidingSpace scroll=$scrollingHorizontalRow"
                invalidate()
                return true
            }
            MotionEvent.ACTION_UP -> {
                return finishGesture(event.getPointerId(event.actionIndex), event.x, event.y)
            }
            MotionEvent.ACTION_POINTER_UP -> {
                val index = event.actionIndex
                return finishGesture(event.getPointerId(index), event.getX(index), event.getY(index))
            }
            MotionEvent.ACTION_CANCEL -> {
                cancelGesture("cancel")
                return true
            }
        }
        return super.onTouchEvent(event)
    }

    private fun startGesture(
        pointerId: Int,
        x: Float,
        y: Float,
    ): Boolean {
        val hit = hitTest(x, y)
        if (hit == null || !hit.key.enabled) {
            return false
        }
        gestureStartFrame = hit
        gestureStartX = x
        gestureStartY = y
        gestureLatestX = x
        gestureLatestY = y
        gestureMaxDistance = 0f
        activePointerId = pointerId
        activeKeyId = hit.key.id
        longPressTriggered = false
        slidingSpace = false
        lastSlideStep = 0
        debugGestureText = "start pointer=$pointerId key=${hit.key.id}"
        removeCallbacks(longPressRunnable)
        postDelayed(longPressRunnable, longPressDelayMs)
        invalidate()
        return true
    }

    private fun finishGesture(
        pointerId: Int,
        x: Float,
        y: Float,
    ): Boolean {
        if (pointerId != activePointerId) {
            debugGestureText = "ignored pointer-up pointer=$pointerId active=$activePointerId"
            invalidate()
            return true
        }
        removeCallbacks(longPressRunnable)
        stopRepeat()
        val key = gestureStartFrame?.key
        if (key == null || !key.enabled) {
            resetGesture()
            invalidate()
            return true
        }
        if (slidingSpace || scrollingHorizontalRow || longPressTriggered) {
            debugGestureText = "up key=${key.id} consumed slide=$slidingSpace scroll=$scrollingHorizontalRow long=$longPressTriggered"
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
                        endX = x,
                        endY = y,
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

    private fun cancelGesture(reason: String) {
        removeCallbacks(longPressRunnable)
        stopRepeat()
        resetGesture()
        debugGestureText = reason
        invalidate()
    }

    private fun resetGesture() {
        gestureStartFrame = null
        activePointerId = MotionEvent.INVALID_POINTER_ID
        activeKeyId = null
        gestureMaxDistance = 0f
        longPressTriggered = false
        slidingSpace = false
        lastSlideStep = 0
        scrollingHorizontalRow = false
        lastHorizontalScrollX = 0f
    }

    private fun handleLongPress() {
        val key = gestureStartFrame?.key ?: return
        if (!key.enabled || slidingSpace || scrollingHorizontalRow) {
            return
        }
        debugGestureText = "long key=${key.id}"
        if (key.action in repeatingActions) {
            longPressTriggered = true
            repeatActionKey = key
            dispatch(key, GestureSelection.PrimaryTap)
            removeCallbacks(repeatRunnable)
            postDelayed(repeatRunnable, repeatDelayMs)
        } else if (key.action == KeyboardKeyAction.Shift) {
            longPressTriggered = true
            shifted = true
            setStatus("Shift held")
            refreshLayout()
        } else if (key.action == KeyboardKeyAction.ToggleClipboardPanel) {
            longPressTriggered = true
            horizontalRowScrollOffset = 0f
            panelMode = KeyboardPanelMode.ClipboardFull
            setStatus("Clipboard history")
            refreshLayout()
        } else {
            invalidate()
            return
        }
        performKeyboardHaptic(HapticFeedbackConstants.LONG_PRESS)
        invalidate()
    }

    private fun stopRepeat() {
        removeCallbacks(repeatRunnable)
        repeatActionKey = null
    }

    private fun handleSpaceSlider(
        dx: Float,
        dy: Float,
    ) {
        val key = gestureStartFrame?.key ?: return
        if (!isSpaceKey(key) || abs(dx) < spaceSlideStartPx || abs(dx) < abs(dy) * 1.25f) {
            return
        }
        removeCallbacks(longPressRunnable)
        slidingSpace = true
        val step = (dx / spaceSlideStepPx).toInt()
        val delta = step - lastSlideStep
        if (delta == 0) {
            return
        }
        repeat(abs(delta)) {
            val moved =
                if (delta > 0) {
                    callbacks.onNavigateCharRight()
                } else {
                    callbacks.onNavigateCharLeft()
                }
            if (!moved) {
                setStatus("Cursor slide unavailable")
                return@repeat
            }
        }
        lastSlideStep = step
    }

    private fun handleHorizontalRowScroll(
        dxFromStart: Float,
        x: Float,
    ) {
        if (!gestureStartFrame.isScrollableRowFrame() || abs(dxFromStart) < dp(8f)) {
            return
        }
        if (abs(dxFromStart) < abs(gestureLatestY - gestureStartY) * 1.2f) {
            return
        }
        removeCallbacks(longPressRunnable)
        if (!scrollingHorizontalRow) {
            scrollingHorizontalRow = true
            lastHorizontalScrollX = x
        }
        val delta = lastHorizontalScrollX - x
        val next = (horizontalRowScrollOffset + delta).coerceIn(0f, horizontalRowMaxScrollOffset)
        if (next != horizontalRowScrollOffset) {
            horizontalRowScrollOffset = next
            invalidate()
        }
        lastHorizontalScrollX = x
    }

    private fun KeyFrame?.isScrollableRowFrame(): Boolean {
        return this?.rowScrollable == true
    }

    private fun isSpaceKey(key: KeyboardKeySpec): Boolean {
        return key.action == KeyboardKeyAction.Text &&
            (key.glyph?.primary == " " || key.keyValue?.text == " ")
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
        if (row.horizontalScrollable) {
            drawScrollableRow(canvas, row, left, top, width, height)
            return
        }

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

    private fun drawScrollableRow(
        canvas: Canvas,
        row: KeyboardRowSpec,
        left: Float,
        top: Float,
        width: Float,
        height: Float,
    ) {
        val baseKeyWidth = dp(76f)
        val keyWidths = row.keys.map { key -> max(dp(72f), baseKeyWidth * key.weight) }
        val contentWidth = keyWidths.sum() + keyGap * max(0, row.keys.size - 1)
        horizontalRowMaxScrollOffset = max(0f, contentWidth - width)
        horizontalRowScrollOffset = horizontalRowScrollOffset.coerceIn(0f, horizontalRowMaxScrollOffset)

        val clipSave = canvas.save()
        canvas.clipRect(left, top, left + width, top + height)
        var x = left - horizontalRowScrollOffset
        row.keys.forEachIndexed { index, key ->
            val keyWidth = keyWidths[index]
            val rect = RectF(x, top, x + keyWidth, top + height)
            if (rect.right >= left && rect.left <= left + width) {
                keyFrames.add(KeyFrame(key, rect, rowScrollable = true))
                drawKey(canvas, key, rect)
            }
            x += keyWidth + keyGap
        }
        canvas.restoreToCount(clipSave)
    }

    private fun drawKey(
        canvas: Canvas,
        key: KeyboardKeySpec,
        rect: RectF,
    ) {
        val paint = when {
            !key.enabled -> disabledKeyPaint
            key.id == activeKeyId -> pressedKeyPaint
            key.active || isActiveModifierKey(key) -> activeKeyPaint
            key.action == KeyboardKeyAction.Text -> keyPaint
            else -> specialKeyPaint
        }
        canvas.drawRoundRect(rect, keyRadius, keyRadius, paint)

        textPaint.color =
            if (key.active || isActiveModifierKey(key)) {
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
            renderCornerGlyphs(canvas, rect, key.cornerAssignments)
        }
    }

    private fun shouldRenderCorners(key: KeyboardKeySpec): Boolean {
        return cornerModeEnabled &&
            allowsCornerGesture(key) &&
            !key.cornerAssignments.isEmpty()
    }

    private fun renderCornerGlyphs(
        canvas: Canvas,
        rect: RectF,
        assignments: KeyboardCornerAssignments,
    ) {
        secondaryTextPaint.textSize = sp(9f)
        secondaryTextPaint.color = Color.rgb(92, 103, 98)
        assignments.topLeft?.let {
            canvas.drawText(it.label, rect.left + dp(10f), rect.top + dp(12f), secondaryTextPaint)
        }
        assignments.topRight?.let {
            canvas.drawText(it.label, rect.right - dp(10f), rect.top + dp(12f), secondaryTextPaint)
        }
        assignments.bottomLeft?.let {
            canvas.drawText(it.label, rect.left + dp(10f), rect.bottom - dp(8f), secondaryTextPaint)
        }
        assignments.bottomRight?.let {
            canvas.drawText(it.label, rect.right - dp(10f), rect.bottom - dp(8f), secondaryTextPaint)
        }
    }

    private fun effectiveGestureSelection(
        key: KeyboardKeySpec,
        sample: GestureSample,
    ): GestureSelection {
        if (!cornerModeEnabled || !allowsCornerGesture(key) || key.cornerAssignments.isEmpty()) {
            return GestureSelection.PrimaryTap
        }
        return KeyboardGestureClassifier.classify(sample, gestureThresholds)
    }

    private fun allowsCornerGesture(key: KeyboardKeySpec): Boolean {
        return (key.action == KeyboardKeyAction.Text && key.id != "space") || specialKeyCornersEnabled
    }

    private fun dispatch(
        key: KeyboardKeySpec,
        selection: GestureSelection,
    ) {
        if (selection == GestureSelection.Canceled) {
            setStatus("Gesture canceled")
            performKeyboardHaptic(HapticFeedbackConstants.REJECT)
            return
        }
        performKeyboardHaptic(HapticFeedbackConstants.KEYBOARD_TAP)
        performKeySound()
        if (selection != GestureSelection.PrimaryTap) {
            val cornerValue = keyValueForSelection(key, selection)
            if (cornerValue == null || !dispatchKeyValue(cornerValue, selection, clearModifiersAfter = true)) {
                setStatus("Corner shortcut unavailable")
            }
            return
        }
        when (key.action) {
            KeyboardKeyAction.KeyValue -> {
                val keyValue = key.keyValue ?: return
                if (!dispatchKeyValue(keyValue, selection, clearModifiersAfter = true)) {
                    setStatus("Key unavailable")
                }
            }
            KeyboardKeyAction.Text -> {
                val keyValue = keyValueForSelection(key, selection) ?: return
                val committed = dispatchKeyValue(keyValue, selection, clearModifiersAfter = true)
                if (!committed) {
                    setStatus("Text input unavailable")
                    return
                }
                if (panelMode == KeyboardPanelMode.Emoji) {
                    val output = keyValue.text ?: return
                    callbacks.onEmojiInserted(output)
                }
            }
            KeyboardKeyAction.Backspace -> {
                if (!callbacks.onBackspace()) {
                    setStatus("Delete unavailable")
                }
            }
            KeyboardKeyAction.ForwardDelete -> {
                if (!callbacks.onForwardDelete()) {
                    setStatus("Forward delete unavailable")
                }
            }
            KeyboardKeyAction.DeleteWordBefore -> {
                if (!callbacks.onDeleteWordBefore()) {
                    setStatus("Word deletion unavailable")
                }
            }
            KeyboardKeyAction.DeleteWordAfter -> {
                if (!callbacks.onDeleteWordAfter()) {
                    setStatus("Forward word deletion unavailable")
                }
            }
            KeyboardKeyAction.Enter -> {
                if (!callbacks.onEnter()) {
                    setStatus("Enter action unavailable")
                }
            }
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
            KeyboardKeyAction.ToggleAccentPanel -> togglePanel(KeyboardPanelMode.Accents)
            KeyboardKeyAction.ToggleEmojiPanel -> togglePanel(KeyboardPanelMode.Emoji)
            KeyboardKeyAction.ToggleClipboardPanel -> toggleClipboardPanel()
            KeyboardKeyAction.ToggleMediaPanel -> togglePanel(KeyboardPanelMode.Media)
            KeyboardKeyAction.ToggleSnippetsPanel -> togglePanel(KeyboardPanelMode.Snippets)
            KeyboardKeyAction.ToggleSettingsPanel -> togglePanel(KeyboardPanelMode.Settings)
            KeyboardKeyAction.CopySelection -> callbacks.onCopySelection()
            KeyboardKeyAction.CutSelection -> {
                if (!callbacks.onCutSelection()) {
                    setStatus("Cut unavailable")
                }
            }
            KeyboardKeyAction.PasteClipboard -> {
                val pasted = callbacks.onPasteClipboard()
                if (pasted) {
                    panelMode = KeyboardPanelMode.None
                } else {
                    setStatus("Clipboard unavailable")
                }
            }
            KeyboardKeyAction.PastePlainClipboard -> {
                val pasted = callbacks.onPastePlainClipboard()
                if (pasted) {
                    panelMode = KeyboardPanelMode.None
                } else {
                    setStatus("Plain paste unavailable")
                }
            }
            KeyboardKeyAction.InsertClipboardEntry -> {
                val content = key.suggestion
                if (content.isNullOrBlank()) {
                    setStatus("Clipboard empty")
                } else if (callbacks.onText(content)) {
                    panelMode = KeyboardPanelMode.None
                } else {
                    setStatus("Clipboard entry rejected by field")
                }
            }
            KeyboardKeyAction.SelectAll -> {
                if (!callbacks.onSelectAll()) {
                    setStatus("Select all unavailable")
                }
            }
            KeyboardKeyAction.Undo -> {
                if (!callbacks.onUndo()) {
                    setStatus("Undo unavailable")
                }
            }
            KeyboardKeyAction.Redo -> {
                if (!callbacks.onRedo()) {
                    setStatus("Redo unavailable")
                }
            }
            KeyboardKeyAction.CancelSelection -> {
                if (!callbacks.onCancelSelection()) {
                    setStatus("Selection cancel unavailable")
                }
            }
            KeyboardKeyAction.InsertSuggestion -> {
                val suggestion = key.suggestion ?: return
                if (!callbacks.onSuggestionSelected(suggestion)) {
                    setStatus("Suggestion unavailable")
                }
            }
            KeyboardKeyAction.ShowClipboardPins -> {
                setStatus("Pinned clipboard list is in WinFlowzApp app")
            }
            KeyboardKeyAction.MediaPrevious -> callbacks.onMediaPrevious()
            KeyboardKeyAction.MediaPlayPause -> callbacks.onMediaPlayPause()
            KeyboardKeyAction.MediaNext -> callbacks.onMediaNext()
            KeyboardKeyAction.MediaNowPlaying -> {
                if (mediaNowPlayingLabel == null) {
                    mediaNowPlayingLabel = callbacks.onMediaNowPlaying()
                    setStatus(mediaNowPlayingLabel ?: "Now playing unavailable")
                } else {
                    mediaNowPlayingLabel = null
                    setStatus("Now playing hidden")
                }
                refreshLayout()
            }
            KeyboardKeyAction.InsertSnippetOne -> {
                val snippet = key.suggestion
                if (snippet.isNullOrBlank()) {
                    callbacks.onSnippets()
                } else if (callbacks.onText(snippet)) {
                    panelMode = KeyboardPanelMode.None
                } else {
                    setStatus("Snippet rejected by field")
                }
            }
            KeyboardKeyAction.OpenWinFlowzAppSettings -> callbacks.onSettings()
            KeyboardKeyAction.OpenThemeSettings -> callbacks.onThemeSettings()
            KeyboardKeyAction.ShowKeyboardPicker -> callbacks.onKeyboardPicker()
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
            KeyboardKeyAction.ToggleKeyVibration -> {
                keyVibrationEnabled = !keyVibrationEnabled
                callbacks.onKeyVibrationChanged(keyVibrationEnabled)
                setStatus(if (keyVibrationEnabled) "Key vibration on" else "Key vibration off")
            }
            KeyboardKeyAction.ToggleKeySound -> {
                keySoundEnabled = !keySoundEnabled
                callbacks.onKeySoundChanged(keySoundEnabled)
                setStatus(if (keySoundEnabled) "Key sound on" else "Key sound off")
            }
            KeyboardKeyAction.ToggleSpellingSuggestions -> {
                spellingSuggestionsEnabled = !spellingSuggestionsEnabled
                callbacks.onSpellingSuggestionsChanged(spellingSuggestionsEnabled)
                setStatus(if (spellingSuggestionsEnabled) "Suggestions on" else "Suggestions off")
            }
            KeyboardKeyAction.ToggleSpecialKeyCorners -> {
                specialKeyCornersEnabled = !specialKeyCornersEnabled
                callbacks.onSpecialKeyCornersChanged(specialKeyCornersEnabled)
                setStatus(if (specialKeyCornersEnabled) "Special key corners on" else "Special key corners off")
            }
            KeyboardKeyAction.ToggleFrenchLanguage -> {
                frenchLanguageEnabled = !frenchLanguageEnabled
                callbacks.onFrenchLanguageChanged(frenchLanguageEnabled)
                setStatus(if (frenchLanguageEnabled) "French enabled" else "French disabled")
            }
            KeyboardKeyAction.ToggleEnglishLanguage -> {
                englishLanguageEnabled = !englishLanguageEnabled
                callbacks.onEnglishLanguageChanged(englishLanguageEnabled)
                setStatus(if (englishLanguageEnabled) "English enabled" else "English disabled")
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
            KeyboardKeyAction.NavigateLineUp -> {
                if (!callbacks.onNavigateLineUp()) {
                    setStatus("Line-up unavailable")
                }
            }
            KeyboardKeyAction.NavigateLineDown -> {
                if (!callbacks.onNavigateLineDown()) {
                    setStatus("Line-down unavailable")
                }
            }
            KeyboardKeyAction.NavigateParagraphUp -> {
                if (!callbacks.onNavigateParagraphUp()) {
                    setStatus("Paragraph-up unavailable")
                }
            }
            KeyboardKeyAction.NavigateParagraphDown -> {
                if (!callbacks.onNavigateParagraphDown()) {
                    setStatus("Paragraph-down unavailable")
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

    private fun performKeyboardHaptic(feedbackConstant: Int) {
        if (keyVibrationEnabled) {
            performHapticFeedback(feedbackConstant)
        }
    }

    private fun performKeySound() {
        if (keySoundEnabled) {
            playSoundEffect(SoundEffectConstants.CLICK)
        }
    }

    private fun dispatchKeyValue(
        value: KeyboardKeyValue,
        selection: GestureSelection,
        clearModifiersAfter: Boolean,
    ): Boolean {
        val effectiveValue =
            if (value.kind == KeyboardKeyValueKind.Modifier) {
                value
            } else {
                KeyboardKeyModifier.apply(value, currentSystemModifiers(), KeyboardLayoutBuilder.defaultModMap())
            }
        val result =
            when (effectiveValue.kind) {
                KeyboardKeyValueKind.Text -> {
                    val text = effectiveValue.text ?: return false
                    callbacks.onText(text)
                }
                KeyboardKeyValueKind.KeyEvent -> {
                    val keyCode = effectiveValue.keyCode ?: return false
                    callbacks.onKeyEvent(keyCode, metaStateFor(currentSystemModifiers()))
                }
                KeyboardKeyValueKind.Action -> {
                    val action = effectiveValue.action ?: return false
                    dispatch(
                        KeyboardKeySpec(
                            id = "keyvalue-action-${action.name}",
                            label = action.name,
                            action = action,
                        ),
                        selection,
                    )
                    true
                }
                KeyboardKeyValueKind.Modifier -> {
                    toggleSystemModifier(effectiveValue.modifier ?: return false)
                    true
                }
                KeyboardKeyValueKind.Macro -> {
                    effectiveValue.macro.all { macroValue ->
                        dispatchKeyValue(macroValue, GestureSelection.PrimaryTap, clearModifiersAfter = false)
                    }
                }
            }
        if (result && clearModifiersAfter && effectiveValue.kind != KeyboardKeyValueKind.Modifier) {
            clearTransientModifiers()
        }
        return result
    }

    private fun toggleSystemModifier(modifier: KeyboardSystemModifier) {
        when (modifier) {
            KeyboardSystemModifier.Shift -> shifted = !shifted
            KeyboardSystemModifier.Ctrl,
            KeyboardSystemModifier.Alt,
            KeyboardSystemModifier.Fn,
            -> {
                if (activeSystemModifiers.contains(modifier)) {
                    activeSystemModifiers.remove(modifier)
                } else {
                    activeSystemModifiers.add(modifier)
                }
                val state = if (activeSystemModifiers.contains(modifier)) "on" else "off"
                setStatus("${modifier.name} $state")
            }
        }
    }

    private fun clearTransientModifiers() {
        activeSystemModifiers.clear()
        if (shifted && layoutSnapshot.mode == KeyboardLayoutMode.Letters) {
            shifted = false
        }
    }

    private fun currentSystemModifiers(): Set<KeyboardSystemModifier> {
        val modifiers = linkedSetOf<KeyboardSystemModifier>()
        if (shifted && layoutSnapshot.mode == KeyboardLayoutMode.Letters) {
            modifiers.add(KeyboardSystemModifier.Shift)
        }
        modifiers.addAll(activeSystemModifiers)
        return modifiers
    }

    private fun metaStateFor(modifiers: Set<KeyboardSystemModifier>): Int {
        var metaState = 0
        if (KeyboardSystemModifier.Shift in modifiers) {
            metaState = metaState or android.view.KeyEvent.META_SHIFT_ON or android.view.KeyEvent.META_SHIFT_LEFT_ON
        }
        if (KeyboardSystemModifier.Ctrl in modifiers) {
            metaState = metaState or android.view.KeyEvent.META_CTRL_ON or android.view.KeyEvent.META_CTRL_LEFT_ON
        }
        if (KeyboardSystemModifier.Alt in modifiers) {
            metaState = metaState or android.view.KeyEvent.META_ALT_ON or android.view.KeyEvent.META_ALT_LEFT_ON
        }
        return metaState
    }

    private fun isActiveModifierKey(key: KeyboardKeySpec): Boolean {
        val modifier = key.keyValue?.modifier ?: return false
        return (modifier == KeyboardSystemModifier.Shift && shifted) ||
            activeSystemModifiers.contains(modifier)
    }

    private fun togglePanel(target: KeyboardPanelMode) {
        horizontalRowScrollOffset = 0f
        panelMode = if (panelMode == target) KeyboardPanelMode.None else target
    }

    private fun toggleClipboardPanel() {
        horizontalRowScrollOffset = 0f
        panelMode =
            if (panelMode == KeyboardPanelMode.Clipboard || panelMode == KeyboardPanelMode.ClipboardFull) {
                KeyboardPanelMode.None
            } else {
                KeyboardPanelMode.Clipboard
            }
    }

    private fun buildSnapshot(): KeyboardLayoutSnapshot {
        val effectiveMode =
            if (fieldContext == KeyboardFieldContextMode.Phone ||
                fieldContext == KeyboardFieldContextMode.Number
            ) {
                KeyboardLayoutMode.Numbers
            } else {
                layoutMode
            }
        return KeyboardLayoutBuilder.build(
            KeyboardLayoutRequest(
                mode = effectiveMode,
                panel = panelMode,
                shifted = shifted,
                fieldContext = fieldContext,
                layoutProfile = layoutProfile,
                cornerModeEnabled = cornerModeEnabled,
                debugTouchOverlayEnabled = debugTouchOverlayEnabled,
                keyVibrationEnabled = keyVibrationEnabled,
                keySoundEnabled = keySoundEnabled,
                spellingSuggestionsEnabled = spellingSuggestionsEnabled,
                specialKeyCornersEnabled = specialKeyCornersEnabled,
                frenchLanguageEnabled = frenchLanguageEnabled,
                englishLanguageEnabled = englishLanguageEnabled,
                doubleSpacePeriodEnabled = doubleSpacePeriodEnabled,
                punctuationAutoSpacingEnabled = punctuationAutoSpacingEnabled,
                emojiCategory = emojiCategory,
                recentEmojis = recentEmojis,
                enterLabel = enterLabel,
                clipboardAllowed = fieldPolicy.clipboardAllowed,
                clipboardEntries = clipboardEntries,
                voiceAllowed = fieldPolicy.voiceAllowed,
                snippetsAllowed = fieldPolicy.snippetsAllowed,
                snippets = snippets,
                suggestions = suggestions,
                mediaNowPlayingLabel = mediaNowPlayingLabel,
                cornerConfig = cornerConfig,
                fieldPolicy = fieldPolicy,
            ),
        )
    }

    private fun keyValueForSelection(
        key: KeyboardKeySpec,
        selection: GestureSelection,
    ): KeyboardKeyValue? {
        return if (selection == GestureSelection.PrimaryTap) {
            val raw = key.glyph?.primary ?: key.label
            key.keyValue ?: KeyboardKeyValue.text(raw, key.label)
        } else {
            key.cornerAssignments.forSelection(selection)?.value
        }
    }

    private fun displayLabel(key: KeyboardKeySpec): String {
        if (key.id == "media-now-playing-label" && key.label.length > 52) {
            return key.label.take(49) + "..."
        }
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
            key.id == "media-now-playing-label" -> sp(10f)
            key.weight >= 3f -> sp(15f)
            key.label.length >= 5 -> sp(11f)
            else -> sp(12.5f)
        }
    }

    private fun hitTest(x: Float, y: Float): KeyFrame? {
        return keyFrames.firstOrNull { it.rect.contains(x, y) }
    }

    private fun rowHeightFor(index: Int): Float {
        val firstPanelIndex = 1 + layoutSnapshot.suggestionRowCount
        return when {
            index == 0 -> actionRowHeight
            layoutSnapshot.suggestionRowCount > 0 && index in 1..layoutSnapshot.suggestionRowCount -> panelRowHeight
            layoutSnapshot.panelRowCount > 0 && index in firstPanelIndex until firstPanelIndex + layoutSnapshot.panelRowCount -> panelRowHeight
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
