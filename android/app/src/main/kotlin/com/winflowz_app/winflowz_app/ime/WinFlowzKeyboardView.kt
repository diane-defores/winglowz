package com.winflowz_app.winflowz_app.ime

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.content.Context
import android.content.res.Configuration
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.LinearGradient
import android.graphics.Shader
import android.graphics.Typeface
import android.os.SystemClock
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.SoundEffectConstants
import android.view.View
import android.view.View.MeasureSpec
import android.view.animation.OvershootInterpolator
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarController
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarState
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionCatalog
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionEnvironment
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionLongPressBehavior
import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

private data class NativeKeyboardColors(
    val background: Int,
    val privateBackground: Int,
    val key: Int,
    val specialKey: Int,
    val activeKey: Int,
    val pressedKey: Int,
    val disabledKey: Int,
    val text: Int,
    val activeText: Int,
    val disabledText: Int,
    val secondaryText: Int,
    val statusText: Int,
) {
    companion object {
        val Light =
            NativeKeyboardColors(
                background = Color.rgb(238, 241, 238),
                privateBackground = Color.rgb(246, 232, 226),
                key = Color.WHITE,
                specialKey = Color.rgb(224, 230, 227),
                activeKey = Color.rgb(23, 121, 93),
                pressedKey = Color.rgb(202, 218, 211),
                disabledKey = Color.rgb(214, 217, 215),
                text = Color.rgb(29, 35, 32),
                activeText = Color.WHITE,
                disabledText = Color.rgb(123, 130, 126),
                secondaryText = Color.rgb(92, 103, 98),
                statusText = Color.rgb(51, 61, 56),
            )

        val Dark =
            NativeKeyboardColors(
                background = Color.rgb(18, 24, 21),
                privateBackground = Color.rgb(42, 28, 27),
                key = Color.rgb(35, 43, 39),
                specialKey = Color.rgb(46, 56, 51),
                activeKey = Color.rgb(54, 179, 132),
                pressedKey = Color.rgb(67, 82, 75),
                disabledKey = Color.rgb(30, 36, 33),
                text = Color.rgb(235, 242, 238),
                activeText = Color.rgb(8, 20, 15),
                disabledText = Color.rgb(108, 119, 113),
                secondaryText = Color.rgb(168, 181, 174),
                statusText = Color.rgb(204, 217, 210),
            )
    }
}

class WinFlowzKeyboardView(
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
        fun onOpenMediaApp()
        fun onMediaStop()
        fun onMediaShuffle()
        fun onMediaLoop()
        fun onVolumeDown()
        fun onVolumeUp()
        fun onBrightnessDown()
        fun onBrightnessUp()
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
        fun onKeyboardHeightScaleChanged(scale: Float)
        fun onCompactModeChanged(enabled: Boolean)
        fun onActionBarStateChanged(state: KeyboardActionBarState)
    }

    private data class KeyFrame(
        val key: KeyboardKeySpec,
        val rect: RectF,
        val rowId: String? = null,
        val rowScrollable: Boolean = false,
        val rowPagedScrollable: Boolean = false,
        val rowVisibleWidth: Float = 0f,
        val panelScrollable: Boolean = false,
    )

    private var shifted = false
    private var shiftLocked = false
    private var actionBarState = KeyboardActionBarState()
    private var themeMode = KeyboardStateStore.THEME_SYSTEM
    private var themeConfig = KeyboardThemeConfig()
    private var themeImagePath: String? = null
    private var themeBitmap: Bitmap? = null
    private var nativeColors = NativeKeyboardColors.Light
    private var resolvedTextColor = NativeKeyboardColors.Light.text
    private var resolvedCornerTextColor = NativeKeyboardColors.Light.secondaryText
    private var resolvedStatusTextColor = NativeKeyboardColors.Light.statusText
    private var resolvedKeyRadius = resources.displayMetrics.density * 8f
    private var layoutMode = KeyboardLayoutMode.Letters
    private var panelMode = KeyboardPanelMode.None
    private var layoutProfile = KeyboardLayoutProfile.QWERTY
    private var cornerModeEnabled = false
    private var debugTouchOverlayEnabled = false
    private var keyVibrationEnabled = true
    private var keySoundEnabled = false
    private var spellingSuggestionsEnabled = true
    private var mediaControlsEnabled = true
    private var specialKeyCornersEnabled = false
    private var frenchLanguageEnabled = true
    private var englishLanguageEnabled = true
    private var doubleSpacePeriodEnabled = true
    private var punctuationAutoSpacingEnabled = true
    private var keyboardHeightScale = KeyboardStateStore.KEYBOARD_HEIGHT_DEFAULT
    private var compactModeEnabled = false
    private var emojiCategory = KeyboardEmojiCategory.Recents
    private var recentEmojis = emptyList<String>()
    private var fieldPolicy = KeyboardSecurityPolicy.evaluate(null, KeyboardStateStore.PRIVACY_AUTO)
    private var fieldContext = KeyboardFieldContextMode.Text
    private var enterLabel = "Enter"
    private var statusText = "WinFlowz"
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
    private var activeHorizontalRowId: String? = null
    private var horizontalGestureStartOffset = 0f
    private var horizontalGestureDragDx = 0f
    private val horizontalRowScrollOffsetById = mutableMapOf<String, Float>()
    private val horizontalRowMaxOffsetById = mutableMapOf<String, Float>()
    private val horizontalRowPageWidthById = mutableMapOf<String, Float>()
    private val horizontalRowPageById = mutableMapOf<String, Int>()
    private val horizontalRowAnimatorById = mutableMapOf<String, ValueAnimator>()
    private var scrollingVerticalPanel = false
    private var lastVerticalScrollY = 0f
    private var verticalPanelScrollOffset = 0f
    private var verticalPanelMaxScrollOffset = 0f
    private var recoveringFromKeyboardError = false

    private val keyFrames = mutableListOf<KeyFrame>()
    private var layoutSnapshot = KeyboardLayoutBuilder.safeFallback()

    private val density = resources.displayMetrics.density
    private val pressEffects = KeyboardPressEffects(density) { SystemClock.uptimeMillis() }
    private val outerPadding = dp(8f)
    private val keyRadius = dp(8f)
    private val statusHeight = dp(30f)
    private val actionRowHeight = dp(40f)
    private val textRowHeight = dp(46f)
    private val controlRowHeight = dp(48f)
    private val panelRowHeight = dp(42f)
    private val keyboardHeightStep = 0.03f

    private fun keyGap(): Float = dp(themeConfig.keyHorizontalGap)

    private fun rowGap(): Float = dp(themeConfig.rowVerticalGap)

    private fun keyWidthScale(): Float = themeConfig.keyWidthScale.coerceIn(0.75f, 1f)

    private val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.background
    }
    private val privateBackgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.privateBackground
    }
    private val keyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.key
    }
    private val specialKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.specialKey
    }
    private val activeKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.activeKey
    }
    private val pressedKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.pressedKey
    }
    private val keyBorderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.TRANSPARENT
        style = Paint.Style.STROKE
        strokeWidth = 0f
    }
    private val keyShadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.TRANSPARENT
        style = Paint.Style.FILL
    }
    private val pinnedBadgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(255, 255, 255)
        style = Paint.Style.FILL
    }
    private val pinnedBadgeAccentPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.rgb(23, 121, 93)
        style = Paint.Style.FILL
    }
    private val disabledKeyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.disabledKey
    }
    private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.text
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }
    private val secondaryTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.secondaryText
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }
    private val statusPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = NativeKeyboardColors.Light.statusText
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
    private val horizontalSnapDurationMs = 340L
    private val horizontalSnapInterpolator = OvershootInterpolator(0.85f)

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

    private val actionBarController = KeyboardActionBarController(KeyboardActionCatalog.default())

    init {
        isClickable = true
        isFocusable = true
        setBackgroundColor(Color.TRANSPARENT)
        applyThemeMode(themeMode)
        refreshLayout()
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
                "WinFlowz - private input (${policy.reason})"
            } else {
                "WinFlowz"
            }
        reconcileActionBarState()
        refreshLayout()
    }

    fun applyRuntimePreferences(
        profile: KeyboardLayoutProfile,
        cornersEnabled: Boolean,
        debugTouchOverlay: Boolean,
        keyVibration: Boolean,
        keySound: Boolean,
        spellingSuggestions: Boolean,
        mediaControlsEnabled: Boolean,
        specialKeyCorners: Boolean,
        frenchLanguage: Boolean,
        englishLanguage: Boolean,
        doubleSpacePeriod: Boolean,
        punctuationAutoSpacing: Boolean,
        keyboardHeightScale: Float,
        compactMode: Boolean,
        themeMode: String,
        themeConfig: KeyboardThemeConfig,
        recents: List<String>,
        clipboardEntries: List<KeyboardClipboardEntry>,
        snippets: List<KeyboardTextRule>,
        cornerConfig: KeyboardCornerConfig,
        actionBarState: KeyboardActionBarState,
        actionBarLongPressBehavior: KeyboardActionLongPressBehavior,
    ) {
        layoutProfile = profile
        cornerModeEnabled = cornersEnabled
        debugTouchOverlayEnabled = debugTouchOverlay
        keyVibrationEnabled = keyVibration
        keySoundEnabled = keySound
        spellingSuggestionsEnabled = spellingSuggestions
        this.mediaControlsEnabled = mediaControlsEnabled
        specialKeyCornersEnabled = specialKeyCorners
        frenchLanguageEnabled = frenchLanguage
        englishLanguageEnabled = englishLanguage
        doubleSpacePeriodEnabled = doubleSpacePeriod
        punctuationAutoSpacingEnabled = punctuationAutoSpacing
        this.keyboardHeightScale = keyboardHeightScale.coerceIn(
            KeyboardStateStore.KEYBOARD_HEIGHT_MIN,
            KeyboardStateStore.KEYBOARD_HEIGHT_MAX,
        )
        compactModeEnabled = compactMode
        this.themeConfig = themeConfig
        if (themeImagePath != themeConfig.backgroundImagePath) {
            themeImagePath = themeConfig.backgroundImagePath
            themeBitmap = decodeThemeBitmap(themeImagePath)
        }
        applyThemeMode(themeMode)
        this.clipboardEntries = clipboardEntries
        this.snippets = snippets
        this.cornerConfig = cornerConfig
        setActionBarState(
            actionBarState.copy(
                longPressBehavior = actionBarLongPressBehavior,
            ),
            notify = false,
        )
        reconcileActionBarState()
        recentEmojis = if (fieldPolicy.privateMode) emptyList() else recents
        if (fieldPolicy.privateMode && emojiCategory == KeyboardEmojiCategory.Recents) {
            emojiCategory = KeyboardEmojiCategory.Smileys
        }
        requestLayout()
        refreshLayout()
    }

    private fun applyThemeMode(mode: String) {
        themeMode =
            if (mode in setOf(
                    KeyboardStateStore.THEME_SYSTEM,
                    KeyboardStateStore.THEME_LIGHT,
                    KeyboardStateStore.THEME_DARK,
                )
            ) {
                mode
            } else {
                KeyboardStateStore.THEME_SYSTEM
            }
        nativeColors =
            if (themeMode == KeyboardStateStore.THEME_DARK ||
                (themeMode == KeyboardStateStore.THEME_SYSTEM && isSystemDark())
            ) {
                NativeKeyboardColors.Dark
            } else {
                NativeKeyboardColors.Light
            }
        val defaultBackground =
            if (themeConfig.presetId == "system") {
                nativeColors.background
            } else {
                themeConfig.backgroundStartColor
            }
        backgroundPaint.shader = null
        backgroundPaint.color = defaultBackground
        privateBackgroundPaint.color = nativeColors.privateBackground
        keyPaint.color = if (themeConfig.presetId == "system") nativeColors.key else themeConfig.keyColor
        specialKeyPaint.color = if (themeConfig.presetId == "system") nativeColors.specialKey else themeConfig.specialKeyColor
        activeKeyPaint.color = if (themeConfig.presetId == "system") nativeColors.activeKey else themeConfig.activeKeyColor
        pressedKeyPaint.color = if (themeConfig.presetId == "system") nativeColors.pressedKey else themeConfig.pressedKeyColor
        disabledKeyPaint.color = nativeColors.disabledKey
        resolvedTextColor = if (themeConfig.presetId == "system") nativeColors.text else themeConfig.textColor
        resolvedCornerTextColor =
            if (themeConfig.presetId == "system") nativeColors.secondaryText else themeConfig.cornerTextColor
        resolvedStatusTextColor =
            if (themeConfig.presetId == "system") nativeColors.statusText else themeConfig.statusTextColor
        resolvedKeyRadius = if (themeConfig.presetId == "system") keyRadius else dp(themeConfig.keyRadius)
        keyBorderPaint.color = if (themeConfig.presetId == "system") Color.TRANSPARENT else themeConfig.borderColor
        keyBorderPaint.strokeWidth = if (themeConfig.presetId == "system") 0f else dp(themeConfig.borderWidth)
        keyShadowPaint.color = if (themeConfig.presetId == "system") Color.TRANSPARENT else themeConfig.shadowColor
        textPaint.color = resolvedTextColor
        secondaryTextPaint.color = resolvedCornerTextColor
        statusPaint.color = resolvedStatusTextColor
    }

    private fun isSystemDark(): Boolean {
        return (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) ==
            Configuration.UI_MODE_NIGHT_YES
    }

    fun applyInputContext(
        contextMode: KeyboardFieldContextMode,
        enterActionLabel: String,
    ) {
        fieldContext = contextMode
        enterLabel = enterActionLabel
        reconcileActionBarState()
        refreshLayout()
    }

    fun applyTypingAssistant(
        autoCapitalized: Boolean,
        candidates: List<String>,
    ) {
        if (layoutMode == KeyboardLayoutMode.Letters && !shiftLocked && shifted != autoCapitalized) {
            shifted = autoCapitalized
        }
        suggestions = candidates.take(3)
        refreshLayout()
    }

    private fun actionEnvironment(
        mode: KeyboardLayoutMode = layoutMode,
        panel: KeyboardPanelMode = panelMode,
    ): KeyboardActionEnvironment {
        return KeyboardActionEnvironment(
            fieldPolicy = fieldPolicy,
            layoutMode = mode,
            panelMode = panel,
            clipboardAllowed = fieldPolicy.clipboardAllowed,
            voiceAllowed = fieldPolicy.voiceAllowed,
            snippetsAllowed = fieldPolicy.snippetsAllowed,
            mediaControlsEnabled = mediaControlsEnabled,
            snippets = snippets,
        )
    }

    private fun reconcileActionBarState(
        mode: KeyboardLayoutMode = layoutMode,
        panel: KeyboardPanelMode = panelMode,
    ) {
        val next =
            actionBarController.sanitizeState(
                state = actionBarState,
                environment = actionEnvironment(mode = mode, panel = panel),
            )
        setActionBarState(next)
    }

    private fun setActionBarState(
        state: KeyboardActionBarState,
        notify: Boolean = true,
    ) {
        val changed = state != actionBarState
        actionBarState = state
        if (notify && changed) {
            callbacks.onActionBarStateChanged(state)
        }
    }

    fun setStatus(message: String) {
        statusText = message
        invalidate()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val desiredHeight = desiredKeyboardHeight()
        val height =
            when (MeasureSpec.getMode(heightMeasureSpec)) {
                MeasureSpec.AT_MOST -> minOf(desiredHeight, MeasureSpec.getSize(heightMeasureSpec))
                else -> desiredHeight
            }
        setMeasuredDimension(width, height)
    }

    override fun onDraw(canvas: Canvas) {
        runKeyboardSafely("onDraw") {
            super.onDraw(canvas)
            drawKeyboard(canvas)
        } ?: drawRecoveredFallback(canvas)
    }

    private fun drawKeyboard(canvas: Canvas) {
        keyFrames.clear()
        horizontalRowMaxOffsetById.clear()
        if (!fieldPolicy.privateMode && themeConfig.useGradient && themeConfig.presetId != "system" && !themeConfig.useImage) {
            backgroundPaint.shader =
                if (themeConfig.gradientStyle == "radial") {
                    RadialGradient(
                        width * 0.28f,
                        height * 0.18f,
                        max(width, height).toFloat(),
                        themeConfig.backgroundEndColor,
                        themeConfig.backgroundStartColor,
                        Shader.TileMode.CLAMP,
                    )
                } else {
                    LinearGradient(
                        0f,
                        0f,
                        width.toFloat(),
                        height.toFloat(),
                        themeConfig.backgroundStartColor,
                        themeConfig.backgroundEndColor,
                        Shader.TileMode.CLAMP,
                    )
                }
        } else {
            backgroundPaint.shader = null
        }
        canvas.drawRect(
            0f,
            0f,
            width.toFloat(),
            height.toFloat(),
            if (fieldPolicy.privateMode) privateBackgroundPaint else backgroundPaint,
        )
        if (!fieldPolicy.privateMode && themeConfig.useImage) {
            themeBitmap?.let { bitmap ->
                canvas.drawBitmap(bitmap, null, RectF(0f, 0f, width.toFloat(), height.toFloat()), null)
            }
        }

        val left = outerPadding
        val right = width - outerPadding
        var y = outerPadding

        drawStatus(canvas, y, right - left)
        y += statusHeight + rowGap()

        layoutSnapshot.rows.forEachIndexed { index, row ->
            if (usesVerticalPanelScroll() && index == firstPanelRowIndex()) {
                val panelHeight = visiblePanelHeight()
                drawVerticalPanelRows(canvas, left, y, right - left, panelHeight)
                y += panelHeight + rowGap()
                return@forEachIndexed
            }
            if (usesVerticalPanelScroll() && index in firstPanelRowIndex() until firstPanelRowIndex() + layoutSnapshot.panelRowCount) {
                return@forEachIndexed
            }
            val rowHeight = rowHeightFor(index)
            drawRow(canvas, row, left, y, right - left, rowHeight)
            y += rowHeight + rowGap()
        }

        if (pressEffects.draw(canvas, resolvedKeyRadius, activeKeyPaint.color)) {
            postInvalidateOnAnimation()
        }

        if (debugTouchOverlayEnabled) {
            drawDebugOverlay(canvas)
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        return runKeyboardSafely("onTouchEvent:${event.actionMasked}") {
            handleTouchEvent(event)
        } ?: true
    }

    private fun handleTouchEvent(event: MotionEvent): Boolean {
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
                handleVerticalPanelScroll(dy, gestureLatestY)
                debugGestureText =
                    "move dir=${directionFrom(dx, dy)} dist=${distance.toInt()} max=${gestureMaxDistance.toInt()} slide=$slidingSpace scroll=$scrollingHorizontalRow vscroll=$scrollingVerticalPanel"
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
        if (hit.rowScrollable && !hit.rowId.isNullOrBlank()) {
            cancelHorizontalRowAnimation(hit.rowId)
        }
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
        if (slidingSpace || scrollingHorizontalRow || scrollingVerticalPanel || longPressTriggered) {
            if (scrollingHorizontalRow) {
                finishHorizontalRowScroll()
            }
            debugGestureText = "up key=${key.id} consumed slide=$slidingSpace scroll=$scrollingHorizontalRow vscroll=$scrollingVerticalPanel long=$longPressTriggered"
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
        if (scrollingHorizontalRow) {
            finishHorizontalRowScroll()
        }
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
        activeHorizontalRowId = null
        horizontalGestureStartOffset = 0f
        horizontalGestureDragDx = 0f
        scrollingVerticalPanel = false
        lastVerticalScrollY = 0f
    }

    private fun handleLongPress() {
        runKeyboardSafely("handleLongPress:${gestureStartFrame?.key?.id ?: "none"}") {
            handleLongPressUnsafe()
        }
    }

    private fun handleLongPressUnsafe() {
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
        } else if (key.actionDescriptorPrimary && key.actionDescriptorId != null) {
            val result =
                actionBarController.onLongPress(
                    actionId = key.actionDescriptorId,
                    state = actionBarState,
                    environment = actionEnvironment(),
                )
            if (!result.consumed) {
                invalidate()
                return
            }
            longPressTriggered = true
            setActionBarState(result.nextState)
            if (key.actionDescriptorId == "numbers" && layoutMode == KeyboardLayoutMode.Numbers) {
                layoutMode = KeyboardLayoutMode.Letters
                panelMode = KeyboardPanelMode.None
                shifted = false
            }
            result.status?.let { setStatus(it) }
            clearHorizontalRowScrollState()
            reconcileActionBarState()
            refreshLayout()
        } else if (key.action == KeyboardKeyAction.Shift) {
            longPressTriggered = true
            shiftLocked = true
            shifted = true
            setStatus("Shift locked")
            refreshLayout()
        } else if (dispatchLongPressShortcut(key)) {
            longPressTriggered = true
        } else {
            invalidate()
            return
        }
        performKeyboardHaptic(HapticFeedbackConstants.LONG_PRESS)
        invalidate()
    }

    private fun dispatchLongPressShortcut(key: KeyboardKeySpec): Boolean {
        if (cornerModeEnabled && allowsCornerGesture(key)) {
            val shortcut = key.cornerAssignments.topLeft
            if (shortcut != null) {
                if (!dispatchKeyValue(shortcut.value, GestureSelection.TopLeft, clearModifiersAfter = true)) {
                    setStatus("Long press shortcut unavailable")
                }
                return true
            }
        }
        dispatch(key, GestureSelection.PrimaryTap)
        return true
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
        val frame = gestureStartFrame
        val rowId = frame?.rowId
        if (!frame.isScrollableRowFrame() || rowId.isNullOrBlank() || abs(dxFromStart) < dp(8f)) {
            return
        }
        if (abs(dxFromStart) < abs(gestureLatestY - gestureStartY) * 1.2f) {
            return
        }
        removeCallbacks(longPressRunnable)
        val maxOffset = horizontalRowMaxOffsetById[rowId] ?: 0f
        if (maxOffset <= 0f) {
            return
        }
        val currentOffset = horizontalRowScrollOffsetById[rowId] ?: 0f
        if (!scrollingHorizontalRow) {
            scrollingHorizontalRow = true
            activeHorizontalRowId = rowId
            horizontalGestureStartOffset = currentOffset
            lastHorizontalScrollX = gestureStartX
            cancelHorizontalRowAnimation(rowId)
        }
        if (frame.isPagedScrollableRowFrame()) {
            val pageWidth = max(dp(1f), horizontalRowPageWidthById[rowId] ?: frame?.rowVisibleWidth ?: width.toFloat())
            val maxPage = ceil(maxOffset / pageWidth).toInt().coerceAtLeast(0)
            val startPage = (horizontalGestureStartOffset / pageWidth).roundToInt().coerceIn(0, maxPage)
            val startOffset = pageOffset(startPage, pageWidth, maxOffset)
            val dragPreview = (-dxFromStart * 0.28f).coerceIn(-pageWidth * 0.18f, pageWidth * 0.18f)
            val previewOffset = (startOffset + dragPreview).coerceIn(0f, maxOffset)
            horizontalGestureDragDx = dxFromStart
            horizontalRowScrollOffsetById[rowId] = previewOffset
            postInvalidateOnAnimation()
            lastHorizontalScrollX = x
            return
        }
        val delta = lastHorizontalScrollX - x
        val next = resistedHorizontalOffset(currentOffset + delta, maxOffset)
        if (next != currentOffset) {
            horizontalRowScrollOffsetById[rowId] = next
            postInvalidateOnAnimation()
        }
        lastHorizontalScrollX = x
    }

    private fun finishHorizontalRowScroll() {
        val rowId = activeHorizontalRowId ?: gestureStartFrame?.rowId ?: return
        val maxOffset = horizontalRowMaxOffsetById[rowId] ?: 0f
        val currentOffset = horizontalRowScrollOffsetById[rowId] ?: 0f
        val frame = gestureStartFrame
        if (frame.isPagedScrollableRowFrame()) {
            val pageWidth = max(dp(1f), horizontalRowPageWidthById[rowId] ?: frame?.rowVisibleWidth ?: width.toFloat())
            val maxPage = ceil(maxOffset / pageWidth).toInt().coerceAtLeast(0)
            val startPage = (horizontalGestureStartOffset / pageWidth).roundToInt().coerceIn(0, maxPage)
            val threshold = min(pageWidth * 0.22f, dp(96f))
            val targetPage =
                when {
                    horizontalGestureDragDx <= -threshold -> startPage + 1
                    horizontalGestureDragDx >= threshold -> startPage - 1
                    else -> startPage
                }.coerceIn(0, maxPage)
            val targetOffset = pageOffset(targetPage, pageWidth, maxOffset)
            if (targetPage != startPage) {
                performKeyboardHaptic(HapticFeedbackConstants.CLOCK_TICK)
            }
            horizontalRowPageById[rowId] = targetPage
            if (rowId.startsWith("action-row-")) {
                setActionBarState(
                    actionBarController.setRowPage(
                        rowId = rowId,
                        page = targetPage,
                        state = actionBarState,
                        environment = actionEnvironment(),
                    ),
                )
            }
            animateHorizontalRowOffset(rowId, currentOffset, targetOffset)
            return
        }
        val targetOffset = currentOffset.coerceIn(0f, maxOffset)
        animateHorizontalRowOffset(rowId, currentOffset, targetOffset)
    }

    private fun resistedHorizontalOffset(
        rawOffset: Float,
        maxOffset: Float,
    ): Float {
        val overscrollLimit = dp(42f)
        return when {
            rawOffset < 0f -> (rawOffset * 0.34f).coerceAtLeast(-overscrollLimit)
            rawOffset > maxOffset -> (maxOffset + (rawOffset - maxOffset) * 0.34f).coerceAtMost(maxOffset + overscrollLimit)
            else -> rawOffset
        }
    }

    private fun pageOffset(
        page: Int,
        pageWidth: Float,
        maxOffset: Float,
    ): Float {
        return (page.coerceAtLeast(0) * pageWidth).coerceIn(0f, maxOffset)
    }

    private fun animateHorizontalRowOffset(
        rowId: String,
        fromOffset: Float,
        toOffset: Float,
    ) {
        cancelHorizontalRowAnimation(rowId)
        if (abs(fromOffset - toOffset) < 0.5f) {
            horizontalRowScrollOffsetById[rowId] = toOffset
            postInvalidateOnAnimation()
            return
        }
        horizontalRowScrollOffsetById[rowId] = fromOffset
        val animator =
            ValueAnimator.ofFloat(fromOffset, toOffset).apply {
                duration = horizontalSnapDurationMs
                interpolator = horizontalSnapInterpolator
                addUpdateListener { animation ->
                    horizontalRowScrollOffsetById[rowId] = animation.animatedValue as Float
                    postInvalidateOnAnimation()
                }
                addListener(
                    object : AnimatorListenerAdapter() {
                        override fun onAnimationEnd(animation: Animator) {
                            if (horizontalRowAnimatorById[rowId] === animation) {
                                horizontalRowAnimatorById.remove(rowId)
                                horizontalRowScrollOffsetById[rowId] = toOffset
                                postInvalidateOnAnimation()
                            }
                        }

                        override fun onAnimationCancel(animation: Animator) {
                            if (horizontalRowAnimatorById[rowId] === animation) {
                                horizontalRowAnimatorById.remove(rowId)
                            }
                        }
                    },
                )
            }
        horizontalRowAnimatorById[rowId] = animator
        animator.start()
    }

    private fun cancelHorizontalRowAnimation(rowId: String?) {
        if (rowId.isNullOrBlank()) {
            horizontalRowAnimatorById.values.toList().forEach { it.cancel() }
            horizontalRowAnimatorById.clear()
            return
        }
        horizontalRowAnimatorById.remove(rowId)?.cancel()
    }

    private fun clearHorizontalRowScrollState() {
        cancelHorizontalRowAnimation(null)
        horizontalRowScrollOffsetById.clear()
        horizontalRowPageWidthById.clear()
        horizontalRowMaxOffsetById.clear()
        activeHorizontalRowId = null
        horizontalGestureStartOffset = 0f
        horizontalGestureDragDx = 0f
    }

    private fun handleVerticalPanelScroll(
        dyFromStart: Float,
        y: Float,
    ) {
        if (!gestureStartFrame.isScrollablePanelFrame() || abs(dyFromStart) < dp(8f)) {
            return
        }
        if (abs(dyFromStart) < abs(gestureLatestX - gestureStartX) * 1.2f) {
            return
        }
        removeCallbacks(longPressRunnable)
        if (!scrollingVerticalPanel) {
            scrollingVerticalPanel = true
            lastVerticalScrollY = y
        }
        val delta = lastVerticalScrollY - y
        val next = (verticalPanelScrollOffset + delta).coerceIn(0f, verticalPanelMaxScrollOffset)
        if (next != verticalPanelScrollOffset) {
            verticalPanelScrollOffset = next
            invalidate()
        }
        lastVerticalScrollY = y
    }

    private fun KeyFrame?.isScrollableRowFrame(): Boolean {
        return this?.rowScrollable == true
    }

    private fun KeyFrame?.isPagedScrollableRowFrame(): Boolean {
        return this?.rowPagedScrollable == true
    }

    private fun KeyFrame?.isScrollablePanelFrame(): Boolean {
        return this?.panelScrollable == true
    }

    private fun isSpaceKey(key: KeyboardKeySpec): Boolean {
        return key.action == KeyboardKeyAction.Text &&
            (key.glyph?.primary == " " || key.keyValue?.text == " ")
    }

    private fun decodeThemeBitmap(path: String?): Bitmap? {
        val source = path?.trim().orEmpty()
        if (source.isEmpty()) {
            return null
        }
        return runCatching { BitmapFactory.decodeFile(source) }.getOrNull()
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
        val usableWidth = width - keyGap() * max(0, row.keys.size - 1)
        val unit = usableWidth / totalWeight
        var x = left + unit * row.leadingWeight
        row.keys.forEach { key ->
            val slotWidth = unit * key.weight
            val keyWidth = slotWidth * keyWidthScale()
            val keyLeft = x + (slotWidth - keyWidth) / 2f
            val rect = RectF(keyLeft, top, keyLeft + keyWidth, top + height)
            keyFrames.add(KeyFrame(key, rect, rowId = row.rowId))
            drawKey(canvas, key, rect)
            x += slotWidth + keyGap()
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
        val rowId = row.rowId ?: "scroll-row-${top.toInt()}"
        val visibleCount = row.visiblePageKeyCount
        val baseKeyWidth =
            if (visibleCount != null && visibleCount > 0) {
                val visibleGaps = keyGap() * max(0, visibleCount - 1)
                ((width - visibleGaps) / visibleCount).coerceAtLeast(dp(1f))
            } else {
                dp(76f) * keyWidthScale()
            }
        val keyWidths =
            row.keys.map { key ->
                if (visibleCount != null && visibleCount > 0) {
                    baseKeyWidth * keyWidthScale()
                } else {
                    max(dp(54f), baseKeyWidth * key.weight)
                }
            }
        val contentWidth = keyWidths.sum() + keyGap() * max(0, row.keys.size - 1)
        val maxOffset = max(0f, contentWidth - width)
        horizontalRowMaxOffsetById[rowId] = maxOffset
        horizontalRowPageWidthById[rowId] = max(dp(1f), width)
        if (row.pagedHorizontalScrollable) {
            val pageWidth = horizontalRowPageWidthById[rowId] ?: max(dp(1f), width)
            val page = horizontalRowPageById[rowId] ?: actionBarState.rowPageById[rowId] ?: 0
            val targetOffset = pageOffset(page, pageWidth, maxOffset)
            val isActiveGesture = scrollingHorizontalRow && activeHorizontalRowId == rowId
            val isAnimating = horizontalRowAnimatorById.containsKey(rowId)
            val currentOffset = horizontalRowScrollOffsetById[rowId]
            if (currentOffset == null || (!isActiveGesture && !isAnimating && abs(currentOffset - targetOffset) > 0.5f)) {
                horizontalRowScrollOffsetById[rowId] = targetOffset
            }
        }
        val isActiveGesture = scrollingHorizontalRow && activeHorizontalRowId == rowId
        val isAnimating = horizontalRowAnimatorById.containsKey(rowId)
        val rawRowOffset = horizontalRowScrollOffsetById[rowId] ?: 0f
        val rowOffset =
            if (isActiveGesture || isAnimating) {
                rawRowOffset
            } else {
                rawRowOffset.coerceIn(0f, maxOffset)
            }
        horizontalRowScrollOffsetById[rowId] = rowOffset

        val clipSave = canvas.save()
        canvas.clipRect(left, top, left + width, top + height)
        var x = left - rowOffset
        row.keys.forEachIndexed { index, key ->
            val keyWidth = keyWidths[index]
            val rect = RectF(x, top, x + keyWidth, top + height)
            if (rect.right >= left && rect.left <= left + width) {
                keyFrames.add(
                    KeyFrame(
                        key = key,
                        rect = rect,
                        rowId = rowId,
                        rowScrollable = true,
                        rowPagedScrollable = row.pagedHorizontalScrollable,
                        rowVisibleWidth = width,
                    ),
                )
                drawKey(canvas, key, rect)
            }
            x += keyWidth + keyGap()
        }
        canvas.restoreToCount(clipSave)
    }

    private fun drawVerticalPanelRows(
        canvas: Canvas,
        left: Float,
        top: Float,
        width: Float,
        height: Float,
    ) {
        val firstPanelIndex = firstPanelRowIndex()
        val panelRows = layoutSnapshot.rows.drop(firstPanelIndex).take(layoutSnapshot.panelRowCount)
        val contentHeight = panelRows.size * panelRowHeight + rowGap() * max(0, panelRows.size - 1)
        verticalPanelMaxScrollOffset = max(0f, contentHeight - height)
        verticalPanelScrollOffset = verticalPanelScrollOffset.coerceIn(0f, verticalPanelMaxScrollOffset)

        val clipSave = canvas.save()
        canvas.clipRect(left, top, left + width, top + height)
        var y = top - verticalPanelScrollOffset
        panelRows.forEach { row ->
            if (y + panelRowHeight >= top && y <= top + height) {
                drawPanelScrollRow(canvas, row, left, y, width, panelRowHeight)
            }
            y += panelRowHeight + rowGap()
        }
        canvas.restoreToCount(clipSave)
    }

    private fun drawPanelScrollRow(
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
        val usableWidth = width - keyGap() * max(0, row.keys.size - 1)
        val unit = usableWidth / totalWeight
        var x = left + unit * row.leadingWeight
        row.keys.forEach { key ->
            val slotWidth = unit * key.weight
            val keyWidth = slotWidth * keyWidthScale()
            val keyLeft = x + (slotWidth - keyWidth) / 2f
            val rect = RectF(keyLeft, top, keyLeft + keyWidth, top + height)
            keyFrames.add(KeyFrame(key, rect, rowId = row.rowId, panelScrollable = true))
            drawKey(canvas, key, rect)
            x += slotWidth + keyGap()
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
            key.active || isActiveModifierKey(key) -> activeKeyPaint
            key.actionSurface -> specialKeyPaint
            key.action == KeyboardKeyAction.Text -> keyPaint
            else -> specialKeyPaint
        }
        if (!fieldPolicy.privateMode && themeConfig.presetId != "system" && themeConfig.shadowBlur > 0f) {
            val shadowRect = RectF(rect).apply {
                offset(0f, dp(themeConfig.shadowOffsetY))
                inset(-dp(themeConfig.shadowBlur) * 0.18f, -dp(themeConfig.shadowBlur) * 0.10f)
            }
            canvas.drawRoundRect(shadowRect, resolvedKeyRadius, resolvedKeyRadius, keyShadowPaint)
        }
        canvas.drawRoundRect(rect, resolvedKeyRadius, resolvedKeyRadius, paint)
        if (!fieldPolicy.privateMode && keyBorderPaint.strokeWidth > 0f && Color.alpha(keyBorderPaint.color) > 0) {
            canvas.drawRoundRect(rect, resolvedKeyRadius, resolvedKeyRadius, keyBorderPaint)
        }

        textPaint.color =
            if (key.active || isActiveModifierKey(key)) {
                nativeColors.activeText
            } else if (key.enabled) {
                resolvedTextColor
            } else {
                nativeColors.disabledText
            }
        textPaint.textSize = keyTextSize(key)
        val baseline = rect.centerY() - (textPaint.descent() + textPaint.ascent()) / 2f
        canvas.drawText(displayLabel(key), rect.centerX(), baseline, textPaint)

        if (shouldRenderCorners(key)) {
            renderCornerGlyphs(canvas, rect, key.cornerAssignments)
        }

        if (key.pinned && key.actionDescriptorPrimary) {
            drawPinnedBadge(canvas, rect, paint.color)
        }
    }

    private fun drawPinnedBadge(
        canvas: Canvas,
        rect: RectF,
        keyColor: Int,
    ) {
        val cx = rect.right - dp(8f)
        val cy = rect.top + dp(8f)
        when (themeConfig.presetId) {
            "pixel_candy" -> drawCandyPinnedBadge(canvas, cx, cy, keyColor)
            "sunset_gradient" -> drawCloudPinnedBadge(canvas, cx, cy, keyColor)
            "glass_mint" -> drawDropPinnedBadge(canvas, cx, cy, contrastBadgeAccentColor(keyColor))
            "midnight_aurora" -> drawStarPinnedBadge(canvas, cx, cy, contrastBadgeAccentColor(keyColor))
            else -> drawLedPinnedBadge(canvas, cx, cy, contrastBadgeAccentColor(keyColor), contrastBadgeBaseColor(keyColor))
        }
    }

    private fun drawCandyPinnedBadge(
        canvas: Canvas,
        cx: Float,
        cy: Float,
        keyColor: Int,
    ) {
        pinnedBadgePaint.color = contrastBadgeBaseColor(keyColor)
        pinnedBadgeAccentPaint.color = contrastBadgeAccentColor(keyColor)
        val body = RectF(cx - dp(4.5f), cy - dp(3f), cx + dp(4.5f), cy + dp(3f))
        canvas.drawRoundRect(body, dp(3f), dp(3f), pinnedBadgeAccentPaint)
        canvas.drawCircle(cx, cy, dp(2.1f), pinnedBadgePaint)
        val left = Path().apply {
            moveTo(cx - dp(4.5f), cy)
            lineTo(cx - dp(8f), cy - dp(3f))
            lineTo(cx - dp(8f), cy + dp(3f))
            close()
        }
        val right = Path().apply {
            moveTo(cx + dp(4.5f), cy)
            lineTo(cx + dp(8f), cy - dp(3f))
            lineTo(cx + dp(8f), cy + dp(3f))
            close()
        }
        canvas.drawPath(left, pinnedBadgePaint)
        canvas.drawPath(right, pinnedBadgePaint)
    }

    private fun drawCloudPinnedBadge(
        canvas: Canvas,
        cx: Float,
        cy: Float,
        keyColor: Int,
    ) {
        pinnedBadgePaint.color = contrastBadgeBaseColor(keyColor)
        canvas.drawCircle(cx - dp(3f), cy + dp(1f), dp(3.3f), pinnedBadgePaint)
        canvas.drawCircle(cx + dp(1f), cy - dp(1f), dp(4.1f), pinnedBadgePaint)
        canvas.drawCircle(cx + dp(5f), cy + dp(1.2f), dp(3f), pinnedBadgePaint)
        canvas.drawRoundRect(RectF(cx - dp(6.5f), cy, cx + dp(7f), cy + dp(4.7f)), dp(2f), dp(2f), pinnedBadgePaint)
    }

    private fun drawLedPinnedBadge(
        canvas: Canvas,
        cx: Float,
        cy: Float,
        color: Int,
        baseColor: Int = Color.argb(85, Color.red(color), Color.green(color), Color.blue(color)),
    ) {
        pinnedBadgePaint.color = baseColor
        pinnedBadgeAccentPaint.color = color
        canvas.drawCircle(cx, cy, dp(6.2f), pinnedBadgePaint)
        canvas.drawCircle(cx, cy, dp(3.4f), pinnedBadgeAccentPaint)
    }

    private fun drawDropPinnedBadge(
        canvas: Canvas,
        cx: Float,
        cy: Float,
        color: Int,
    ) {
        pinnedBadgeAccentPaint.color = color
        val drop = Path().apply {
            moveTo(cx, cy - dp(6f))
            cubicTo(cx + dp(5f), cy - dp(1f), cx + dp(4f), cy + dp(5f), cx, cy + dp(5f))
            cubicTo(cx - dp(4f), cy + dp(5f), cx - dp(5f), cy - dp(1f), cx, cy - dp(6f))
            close()
        }
        canvas.drawPath(drop, pinnedBadgeAccentPaint)
    }

    private fun drawPaperPinnedBadge(
        canvas: Canvas,
        cx: Float,
        cy: Float,
    ) {
        drawLedPinnedBadge(canvas, cx, cy, contrastBadgeAccentColor(specialKeyPaint.color), contrastBadgeBaseColor(specialKeyPaint.color))
    }

    private fun contrastBadgeBaseColor(keyColor: Int): Int {
        return if (relativeLuminance(keyColor) > 0.55f) Color.argb(235, 24, 28, 32) else Color.argb(235, 255, 255, 255)
    }

    private fun contrastBadgeAccentColor(keyColor: Int): Int {
        return if (relativeLuminance(keyColor) > 0.55f) Color.WHITE else Color.BLACK
    }

    private fun relativeLuminance(color: Int): Float {
        fun channel(value: Int): Float {
            val normalized = value / 255f
            return if (normalized <= 0.03928f) normalized / 12.92f else Math.pow(((normalized + 0.055f) / 1.055f).toDouble(), 2.4).toFloat()
        }
        return 0.2126f * channel(Color.red(color)) + 0.7152f * channel(Color.green(color)) + 0.0722f * channel(Color.blue(color))
    }

    private fun drawStarPinnedBadge(
        canvas: Canvas,
        cx: Float,
        cy: Float,
        color: Int,
    ) {
        pinnedBadgeAccentPaint.color = color
        val star = Path().apply {
            moveTo(cx, cy - dp(6f))
            lineTo(cx + dp(1.8f), cy - dp(1.8f))
            lineTo(cx + dp(6f), cy)
            lineTo(cx + dp(1.8f), cy + dp(1.8f))
            lineTo(cx, cy + dp(6f))
            lineTo(cx - dp(1.8f), cy + dp(1.8f))
            lineTo(cx - dp(6f), cy)
            lineTo(cx - dp(1.8f), cy - dp(1.8f))
            close()
        }
        canvas.drawPath(star, pinnedBadgeAccentPaint)
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
        secondaryTextPaint.color = resolvedCornerTextColor
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
        runKeyboardSafely("dispatch:${key.id}") {
            dispatchUnsafe(key, selection)
        }
    }

    private fun dispatchUnsafe(
        key: KeyboardKeySpec,
        selection: GestureSelection,
    ) {
        if (selection == GestureSelection.Canceled) {
            setStatus("Gesture canceled")
            performKeyboardHaptic(HapticFeedbackConstants.REJECT)
            return
        }
        var commandKey = key
        if (selection == GestureSelection.PrimaryTap && key.actionDescriptorId != null) {
            val result =
                actionBarController.onTap(
                    actionId = key.actionDescriptorId,
                    state = actionBarState,
                    environment = actionEnvironment(),
                )
            setActionBarState(result.nextState)
            if (result.command == null) {
                setStatus(result.status ?: "Action unavailable")
                refreshLayout()
                return
            }
            commandKey =
                if (result.command == key.action) {
                    key
                } else {
                    key.copy(
                        action = result.command,
                        actionDescriptorId = null,
                        actionDescriptorPrimary = false,
                    )
                }
        }
        triggerPressEffect(key)
        performKeyboardHaptic(HapticFeedbackConstants.KEYBOARD_TAP)
        performKeySound()
        if (selection != GestureSelection.PrimaryTap) {
            val cornerValue = keyValueForSelection(key, selection)
            if (cornerValue == null || !dispatchKeyValue(cornerValue, selection, clearModifiersAfter = true)) {
                setStatus("Corner shortcut unavailable")
            }
            return
        }
        val previousMode = layoutMode
        val previousPanel = panelMode
        when (commandKey.action) {
            KeyboardKeyAction.KeyValue -> {
                val keyValue = commandKey.keyValue ?: return
                if (!dispatchKeyValue(keyValue, selection, clearModifiersAfter = true)) {
                    setStatus("Key unavailable")
                }
            }
            KeyboardKeyAction.Text -> {
                val keyValue = keyValueForSelection(commandKey, selection) ?: return
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
            KeyboardKeyAction.InsertTab -> {
                if (!callbacks.onText("\t")) {
                    setStatus("Tab unavailable")
                }
            }
            KeyboardKeyAction.Escape -> {
                if (!callbacks.onKeyEvent(android.view.KeyEvent.KEYCODE_ESCAPE, metaState = 0)) {
                    setStatus("Esc unavailable")
                }
            }
            KeyboardKeyAction.Enter -> {
                if (!callbacks.onEnter()) {
                    setStatus("Enter action unavailable")
                }
            }
            KeyboardKeyAction.Shift -> {
                if (shiftLocked) {
                    shiftLocked = false
                    shifted = false
                } else {
                    shifted = !shifted
                }
            }
            KeyboardKeyAction.ModeLetters -> {
                layoutMode = KeyboardLayoutMode.Letters
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.ModeNumbers -> {
                layoutMode =
                    if (layoutMode == KeyboardLayoutMode.Numbers) {
                        KeyboardLayoutMode.Letters
                    } else {
                        KeyboardLayoutMode.Numbers
                    }
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.ModeAccents -> {
                layoutMode = KeyboardLayoutMode.Accents
                panelMode = KeyboardPanelMode.None
            }
            KeyboardKeyAction.ModeSymbols -> {
                layoutMode =
                    if (layoutMode == KeyboardLayoutMode.Symbols) {
                        KeyboardLayoutMode.Letters
                    } else {
                        KeyboardLayoutMode.Symbols
                    }
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
                val content = commandKey.suggestion
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
                val suggestion = commandKey.suggestion ?: return
                if (!callbacks.onSuggestionSelected(suggestion)) {
                    setStatus("Suggestion unavailable")
                }
            }
            KeyboardKeyAction.ShowClipboardPins -> {
                setStatus("Pinned clipboard list is in WinFlowz app")
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
            KeyboardKeyAction.OpenMediaApp -> callbacks.onOpenMediaApp()
            KeyboardKeyAction.MediaStop -> callbacks.onMediaStop()
            KeyboardKeyAction.MediaShuffle -> callbacks.onMediaShuffle()
            KeyboardKeyAction.MediaLoop -> callbacks.onMediaLoop()
            KeyboardKeyAction.VolumeDown -> callbacks.onVolumeDown()
            KeyboardKeyAction.VolumeUp -> callbacks.onVolumeUp()
            KeyboardKeyAction.BrightnessDown -> callbacks.onBrightnessDown()
            KeyboardKeyAction.BrightnessUp -> callbacks.onBrightnessUp()
            KeyboardKeyAction.InsertSnippetOne -> {
                val snippet = commandKey.suggestion
                if (snippet.isNullOrBlank()) {
                    callbacks.onSnippets()
                } else if (callbacks.onText(snippet)) {
                    panelMode = KeyboardPanelMode.None
                } else {
                    setStatus("Snippet rejected by field")
                }
            }
            KeyboardKeyAction.OpenWinFlowzSnippets -> callbacks.onSnippets()
            KeyboardKeyAction.OpenWinFlowzSettings -> callbacks.onSettings()
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
            KeyboardKeyAction.DecreaseKeyboardHeight -> {
                updateKeyboardHeightScale(-keyboardHeightStep)
            }
            KeyboardKeyAction.IncreaseKeyboardHeight -> {
                updateKeyboardHeightScale(keyboardHeightStep)
            }
            KeyboardKeyAction.ToggleCompactMode -> {
                toggleCompactMode()
            }
            KeyboardKeyAction.SelectEmojiRecents -> emojiCategory = KeyboardEmojiCategory.Recents
            KeyboardKeyAction.SelectEmojiSmileys -> emojiCategory = KeyboardEmojiCategory.Smileys
            KeyboardKeyAction.SelectEmojiHands -> emojiCategory = KeyboardEmojiCategory.Hands
            KeyboardKeyAction.SelectEmojiSymbols -> emojiCategory = KeyboardEmojiCategory.Symbols
            KeyboardKeyAction.SelectEmojiNature -> emojiCategory = KeyboardEmojiCategory.Nature
            KeyboardKeyAction.SelectEmojiFood -> emojiCategory = KeyboardEmojiCategory.Food
            KeyboardKeyAction.SelectEmojiObjects -> emojiCategory = KeyboardEmojiCategory.Objects
            KeyboardKeyAction.SelectEmojiActivities -> emojiCategory = KeyboardEmojiCategory.Activities
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
        if (previousMode != layoutMode || previousPanel != panelMode) {
            clearHorizontalRowScrollState()
            verticalPanelScrollOffset = 0f
        }
        reconcileActionBarState()
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

    private fun triggerPressEffect(key: KeyboardKeySpec) {
        val frame = gestureStartFrame?.takeIf { it.key.id == key.id } ?: return
        val spec = KeyboardPressEffectPolicy.resolve(themeConfig, fieldPolicy.privateMode)
        if (pressEffects.trigger(key.id, frame.rect, spec)) {
            postInvalidateOnAnimation()
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
            KeyboardSystemModifier.Shift -> {
                if (shiftLocked) {
                    shiftLocked = false
                    shifted = false
                } else {
                    shifted = !shifted
                }
            }
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
        if (!shiftLocked && shifted && layoutSnapshot.mode == KeyboardLayoutMode.Letters) {
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
        clearHorizontalRowScrollState()
        verticalPanelScrollOffset = 0f
        panelMode = if (panelMode == target) KeyboardPanelMode.None else target
        reconcileActionBarState()
    }

    private fun toggleClipboardPanel() {
        clearHorizontalRowScrollState()
        verticalPanelScrollOffset = 0f
        panelMode =
            if (panelMode == KeyboardPanelMode.Clipboard || panelMode == KeyboardPanelMode.ClipboardFull) {
                KeyboardPanelMode.None
            } else {
                KeyboardPanelMode.Clipboard
            }
        reconcileActionBarState()
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
        reconcileActionBarState(mode = effectiveMode, panel = panelMode)
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
                keyboardHeightScale = keyboardHeightScale,
                compactModeEnabled = compactModeEnabled,
                emojiCategory = emojiCategory,
                recentEmojis = recentEmojis,
                enterLabel = enterLabel,
                clipboardAllowed = fieldPolicy.clipboardAllowed,
                clipboardEntries = clipboardEntries,
                voiceAllowed = fieldPolicy.voiceAllowed,
                snippetsAllowed = fieldPolicy.snippetsAllowed,
                mediaControlsEnabled = mediaControlsEnabled,
                snippets = snippets,
                suggestions = suggestions,
                actionBarState = actionBarState,
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
            if (usesVerticalPanelScroll()) {
                actionRowHeight + visiblePanelHeight()
            } else {
                layoutSnapshot.rows.indices.sumOf { index ->
                    rowHeightFor(index).toDouble()
                }.toFloat()
        }
        val effectiveRowCount = if (usesVerticalPanelScroll()) 2 else rowCount
        val baseHeight = outerPadding * 2 + statusHeight + rowsHeight + rowGap() * effectiveRowCount
        return (baseHeight * keyboardHeightScale).toInt()
    }

    private fun usesVerticalPanelScroll(): Boolean {
        return panelMode == KeyboardPanelMode.ClipboardFull ||
            (panelMode == KeyboardPanelMode.Settings && compactModeEnabled)
    }

    private fun firstPanelRowIndex(): Int {
        return 1 + layoutSnapshot.suggestionRowCount
    }

    private fun visiblePanelHeight(): Float {
        val visibleRows =
            if (panelMode == KeyboardPanelMode.Settings) {
                3
            } else if (compactModeEnabled) {
                2
            } else {
                3
            }
        return panelRowHeight * visibleRows + rowGap() * (visibleRows - 1)
    }

    private fun toggleCompactMode() {
        compactModeEnabled = !compactModeEnabled
        callbacks.onCompactModeChanged(compactModeEnabled)
        setStatus(if (compactModeEnabled) "Compact keyboard on" else "Compact keyboard off")
        requestLayout()
        refreshLayout()
    }

    private fun updateKeyboardHeightScale(delta: Float) {
        if (delta < 0f &&
            !compactModeEnabled &&
            keyboardHeightScale <= KeyboardStateStore.KEYBOARD_HEIGHT_MIN + 0.001f
        ) {
            compactModeEnabled = true
            callbacks.onCompactModeChanged(true)
            setStatus("Compact keyboard on")
            requestLayout()
            refreshLayout()
            return
        }
        if (delta > 0f && compactModeEnabled) {
            compactModeEnabled = false
            callbacks.onCompactModeChanged(false)
            setStatus("Compact keyboard off")
            requestLayout()
            refreshLayout()
            return
        }
        val next = (keyboardHeightScale + delta).coerceIn(
            KeyboardStateStore.KEYBOARD_HEIGHT_MIN,
            KeyboardStateStore.KEYBOARD_HEIGHT_MAX,
        )
        if (next == keyboardHeightScale) {
            setStatus(if (compactModeEnabled) "Compact keyboard on" else "Keyboard height ${(keyboardHeightScale * 100).toInt()}%")
            return
        }
        keyboardHeightScale = next
        callbacks.onKeyboardHeightScaleChanged(next)
        setStatus("Keyboard height ${(keyboardHeightScale * 100).toInt()}%")
        requestLayout()
        refreshLayout()
    }

    private fun drawDebugOverlay(canvas: Canvas) {
        keyFrames.forEach { frame ->
            canvas.drawRoundRect(frame.rect, resolvedKeyRadius, resolvedKeyRadius, debugStrokePaint)
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
        runKeyboardSafely("refreshLayout") {
            layoutSnapshot = buildSnapshot()
            requestLayout()
            invalidate()
        }
    }

    private fun <T> runKeyboardSafely(
        actionId: String,
        block: () -> T,
    ): T? {
        return try {
            block()
        } catch (error: Throwable) {
            recoverFromKeyboardError(actionId, error)
            null
        }
    }

    private fun recoverFromKeyboardError(
        actionId: String,
        error: Throwable,
    ) {
        if (recoveringFromKeyboardError) {
            return
        }
        recoveringFromKeyboardError = true
        try {
            stopRepeat()
            removeCallbacks(longPressRunnable)
            resetGesture()
            val source =
                when {
                    themeConfig.useImage -> "image"
                    themeConfig.useGradient -> "gradient"
                    else -> "solid"
                }
            KeyboardCrashReporter.report(
                context = context,
                crashContext =
                    KeyboardCrashContext(
                        actionId = actionId,
                        panel = panelMode.name,
                        mode = layoutMode.name,
                        layoutProfile = layoutProfile.name,
                        compactMode = compactModeEnabled,
                        heightScale = keyboardHeightScale,
                        themePresetId = themeConfig.presetId,
                        themeSource = source,
                        privateMode = fieldPolicy.privateMode,
                    ),
                error = error,
            )
            layoutMode = KeyboardLayoutMode.Letters
            panelMode = KeyboardPanelMode.None
            layoutSnapshot = KeyboardLayoutBuilder.safeFallback()
            themeConfig = KeyboardThemeConfig()
            themeImagePath = null
            themeBitmap = null
            applyThemeMode(KeyboardStateStore.THEME_SYSTEM)
            statusText = "Keyboard recovered"
            requestLayout()
            invalidate()
        } catch (_: Throwable) {
            layoutSnapshot = KeyboardLayoutBuilder.safeFallback()
            statusText = "Keyboard recovered"
        } finally {
            recoveringFromKeyboardError = false
        }
    }

    private fun drawRecoveredFallback(canvas: Canvas) {
        runCatching {
            canvas.drawColor(nativeColors.background)
            statusPaint.color = nativeColors.statusText
            statusPaint.textSize = sp(14f)
            canvas.drawText("Keyboard recovered", width / 2f, max(dp(28f), height / 2f), statusPaint)
        }
    }

    private fun dp(value: Float): Float = value * density

    private fun sp(value: Float): Float = value * resources.displayMetrics.scaledDensity
}
