package com.winflowz_app.winflowz_app.ime

import android.content.Intent
import android.content.SharedPreferences
import android.content.res.Configuration
import android.inputmethodservice.InputMethodService
import android.content.Context
import android.view.inputmethod.InputMethodSubtype
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import com.winflowz_app.winflowz_app.MainActivity
import com.winflowz_app.winflowz_app.ime.actions.KeyboardActionBarState

class WinFlowzInputMethodService :
    InputMethodService(),
    WinFlowzKeyboardView.Callbacks,
    SharedPreferences.OnSharedPreferenceChangeListener {
    private lateinit var stateStore: KeyboardStateStore
    private lateinit var mediaController: KeyboardMediaController
    private lateinit var clipboardController: KeyboardClipboardController
    private lateinit var voiceController: KeyboardVoiceController
    private var keyboardView: WinFlowzKeyboardView? = null
    private var fieldPolicy =
        KeyboardSecurityPolicy.evaluate(null, KeyboardStateStore.PRIVACY_AUTO)
    private var inputContext = KeyboardInputContextResolver.resolve(null)
    private var selectionState = KeyboardSelectionState.Unavailable

    override fun onCreate() {
        super.onCreate()
        stateStore = KeyboardStateStore(this)
        getSharedPreferences(KeyboardStateStore.PREFERENCES_NAME, Context.MODE_PRIVATE)
            .registerOnSharedPreferenceChangeListener(this)
        mediaController = KeyboardMediaController(this)
        clipboardController = KeyboardClipboardController(this)
        voiceController =
            KeyboardVoiceController(
                context = this,
                stateStore = stateStore,
                onState = { message -> keyboardView?.setStatus(message) },
                onActiveChanged = { active -> keyboardView?.setVoiceRecordingActive(active) },
                onResult = { text ->
                    val editor = editor()
                    if (!editor.hasActiveConnection()) {
                        showStatus("Dictation result ignored: no active field")
                        return@KeyboardVoiceController
                    }
                    val dictatedText = "${text.trim()} "
                    val committed = editor.commitText(dictatedText)
                    if (!committed.reportFailure("Dictation text rejected by field")) {
                        return@KeyboardVoiceController
                    }
                    KeyboardVoiceEventQueue.enqueue(
                        rawText = text,
                        cleanedText = text,
                        language = java.util.Locale.getDefault().toLanguageTag(),
                    )
                },
            )
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if (stateStore.themeMode == KeyboardStateStore.THEME_SYSTEM) {
            runServiceSafely("onConfigurationChanged") {
                applyRuntimePreferencesToView()
            }
        }
    }

    override fun onSharedPreferenceChanged(
        sharedPreferences: SharedPreferences?,
        key: String?,
    ) {
        if (key == KeyboardStateStore.KEY_THEME_MODE || key == KeyboardStateStore.KEY_THEME_CONFIG) {
            runServiceSafely("onSharedPreferenceChanged:$key") {
                applyRuntimePreferencesToView()
            }
        }
    }

    override fun onCreateInputView(): View {
        return runServiceSafely("onCreateInputView") {
            val view = WinFlowzKeyboardView(this, this)
            keyboardView = view
            view.applyPolicy(fieldPolicy)
            applyRuntimePreferencesToView()
            view.applyInputContext(
                contextMode = inputContext.fieldContext,
                enterActionLabel = inputContext.enterLabel,
            )
            view
        } ?: View(this)
    }

    override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInput(attribute, restarting)
        refreshInputState(attribute)
    }

    override fun onStartInputView(
        info: EditorInfo?,
        restarting: Boolean,
    ) {
        super.onStartInputView(info, restarting)
        refreshInputState(info)
    }

    override fun onCurrentInputMethodSubtypeChanged(newSubtype: InputMethodSubtype?) {
        super.onCurrentInputMethodSubtypeChanged(newSubtype)
        refreshInputState(currentInputEditorInfo)
    }

    override fun onEvaluateFullscreenMode(): Boolean {
        return false
    }

    override fun onEvaluateInputViewShown(): Boolean {
        super.onEvaluateInputViewShown()
        return true
    }

    private fun refreshInputState(attribute: EditorInfo?) {
        runServiceSafely("refreshInputState") {
            fieldPolicy = KeyboardSecurityPolicy.evaluate(attribute, stateStore.privacyMode)
            inputContext = KeyboardInputContextResolver.resolve(attribute)
            selectionState =
                KeyboardSelectionState.fromEditorBounds(
                    selectionStart = attribute?.initialSelStart ?: -1,
                    selectionEnd = attribute?.initialSelEnd ?: -1,
                )
            keyboardView?.applyPolicy(fieldPolicy)
            applyRuntimePreferencesToView()
            keyboardView?.applyInputContext(
                contextMode = inputContext.fieldContext,
                enterActionLabel = inputContext.enterLabel,
            )
            refreshTypingAssistantState()
        }
    }

    override fun onUpdateSelection(
        oldSelStart: Int,
        oldSelEnd: Int,
        newSelStart: Int,
        newSelEnd: Int,
        candidatesStart: Int,
        candidatesEnd: Int,
    ) {
        super.onUpdateSelection(
            oldSelStart,
            oldSelEnd,
            newSelStart,
            newSelEnd,
            candidatesStart,
            candidatesEnd,
        )
        selectionState =
            KeyboardSelectionState(
                selectionStart = newSelStart,
                selectionEnd = newSelEnd,
                candidatesStart = candidatesStart,
                candidatesEnd = candidatesEnd,
            )
        refreshTypingAssistantState()
    }

    override fun onFinishInput() {
        selectionState = KeyboardSelectionState.Unavailable
        super.onFinishInput()
    }

    override fun onDestroy() {
        getSharedPreferences(KeyboardStateStore.PREFERENCES_NAME, Context.MODE_PRIVATE)
            .unregisterOnSharedPreferenceChangeListener(this)
        voiceController.destroy()
        super.onDestroy()
    }

    override fun onText(text: String): Boolean {
        if (!fieldPolicy.inputAllowed) {
            showStatus("Input unavailable")
            return false
        }
        val editor = editor()
        if (!editor.hasActiveConnection()) {
            showStatus("Input unavailable: no active field")
            return false
        }
        return commitWithTypingCorrections(editor, text)
    }

    override fun onEmojiInserted(emoji: String) {
        stateStore.pushEmojiRecent(emoji, privateMode = fieldPolicy.privateMode)
        applyRuntimePreferencesToView()
    }

    override fun onSymbolInserted(symbol: String) {
        stateStore.pushSymbolRecent(symbol, privateMode = fieldPolicy.privateMode)
        applyRuntimePreferencesToView()
    }

    override fun onBackspace(): Boolean {
        val editor = editor()
        if (!editor.hasActiveConnection()) {
            showStatus("Delete unavailable: no active field")
            return false
        }
        if (selectionState.hasSelection || !editor.selectedText().isNullOrEmpty()) {
            val deleted = editor.commitText("").reportFailure("Delete selection rejected by field")
            refreshTypingAssistantState(editor)
            return deleted
        }
        val sent = sendSoftKey(KeyEvent.KEYCODE_DEL, 0)
        if (sent) {
            return true
        }
        val deleted = editor.deleteCodePointsBefore(1)
        if (!deleted.applied) {
            showStatus("Delete rejected by field")
        }
        refreshTypingAssistantState(editor)
        return deleted.applied
    }

    override fun onForwardDelete(): Boolean {
        val editor = editor()
        if (!editor.hasActiveConnection()) {
            showStatus("Forward delete unavailable: no active field")
            return false
        }
        if (selectionState.hasSelection || !editor.selectedText().isNullOrEmpty()) {
            val deleted = editor.commitText("").reportFailure("Delete selection rejected by field")
            refreshTypingAssistantState(editor)
            return deleted
        }
        val sent = sendSoftKey(KeyEvent.KEYCODE_FORWARD_DEL, 0)
        if (sent) {
            return true
        }
        val deleted = editor.deleteCodePointsAfter(1)
        refreshTypingAssistantState(editor)
        return deleted.applied
    }

    override fun onDeleteWordBefore(): Boolean {
        val editor = editor()
        if (!editor.hasActiveConnection()) {
            return false
        }
        if (selectionState.hasSelection || !editor.selectedText().isNullOrEmpty()) {
            val deleted = editor.commitText("").reportFailure("Delete selection rejected by field")
            refreshTypingAssistantState(editor)
            return deleted
        }
        if (isTermuxInputTarget()) {
            val sent = sendSoftKey(KeyEvent.KEYCODE_DEL, KeyEvent.META_CTRL_ON or KeyEvent.META_CTRL_LEFT_ON)
            refreshTypingAssistantState(editor)
            return sent
        }
        val deleted = editor.deleteWordBeforeCursor()
        if (deleted.applied) {
            refreshTypingAssistantState(editor)
            return true
        }
        val sent = sendSoftKey(KeyEvent.KEYCODE_DEL, KeyEvent.META_CTRL_ON or KeyEvent.META_CTRL_LEFT_ON)
        refreshTypingAssistantState(editor)
        return sent
    }

    override fun onDeleteWordAfter(): Boolean {
        val editor = editor()
        if (!editor.hasActiveConnection()) {
            return false
        }
        if (selectionState.hasSelection || !editor.selectedText().isNullOrEmpty()) {
            val deleted = editor.commitText("").reportFailure("Delete selection rejected by field")
            refreshTypingAssistantState(editor)
            return deleted
        }
        if (isObsidianInputTarget()) {
            val sent = sendSoftKey(KeyEvent.KEYCODE_FORWARD_DEL, KeyEvent.META_CTRL_ON or KeyEvent.META_CTRL_LEFT_ON)
            refreshTypingAssistantState(editor)
            return sent
        }
        val deleted = editor.deleteWordAfterCursor()
        if (deleted.applied) {
            refreshTypingAssistantState(editor)
            return true
        }
        val sent = sendSoftKey(KeyEvent.KEYCODE_FORWARD_DEL, KeyEvent.META_CTRL_ON or KeyEvent.META_CTRL_LEFT_ON)
        refreshTypingAssistantState(editor)
        return sent
    }

    override fun onEnter(): Boolean {
        if (voiceController.isListening()) {
            voiceController.stop()
            return true
        }
        val editor = editor()
        if (!editor.hasActiveConnection()) {
            showStatus("Enter unavailable: no active field")
            return false
        }
        val actionId = inputContext.actionId
        if (actionId != EditorInfo.IME_ACTION_NONE) {
            if (editor.performEditorAction(actionId).applied) {
                return true
            }
        } else {
            return sendSoftKey(KeyEvent.KEYCODE_ENTER, 0)
        }
        return sendSoftKey(KeyEvent.KEYCODE_ENTER, 0)
    }

    override fun onVoice() {
        if (!stateStore.voiceEnabled) {
            showStatus("Dictation disabled in WinFlowz settings")
            return
        }
        if (!fieldPolicy.voiceAllowed) {
            showStatus("Dictation disabled for private field")
            return
        }
        if (voiceController.isActive()) {
            voiceController.stop()
            return
        }
        voiceController.start()
    }

    override fun onVoicePause() {
        voiceController.pause()
    }

    override fun onVoiceResume() {
        if (!stateStore.voiceEnabled) {
            showStatus("Dictation disabled in WinFlowz settings")
            return
        }
        if (!fieldPolicy.voiceAllowed) {
            showStatus("Dictation disabled for private field")
            return
        }
        voiceController.resume()
    }

    override fun onVoiceRestart() {
        if (!stateStore.voiceEnabled) {
            showStatus("Dictation disabled in WinFlowz settings")
            return
        }
        if (!fieldPolicy.voiceAllowed) {
            showStatus("Dictation disabled for private field")
            return
        }
        voiceController.restart()
    }

    override fun onVoiceCancel() {
        voiceController.cancel()
    }

    override fun onCopySelection() {
        if (!fieldPolicy.clipboardAllowed) {
            showInlineStatus("Clipboard capture disabled for private field")
            return
        }
        val selectedText = editor().selectedText()?.toString()?.trim()
        val copied =
            clipboardController.copySelection(
                currentInputConnection,
                syncDesired = stateStore.clipboardSyncDesired,
            )
        if (copied && !selectedText.isNullOrBlank()) {
            stateStore.pushClipboardEntry(selectedText)
            applyRuntimePreferencesToView()
            showInlineStatus("Selection copied")
            return
        }
        if (editor().performContextMenuAction(android.R.id.copy).applied) {
            showInlineStatus("Copy sent")
            return
        }
        if (isTermuxInputTarget() && sendTermuxClipboardShortcut(KeyEvent.KEYCODE_C)) {
            showInlineStatus("Termux copy shortcut sent")
            return
        }
        showInlineStatus("No selectable text")
    }

    override fun onCutSelection(): Boolean {
        if (!fieldPolicy.clipboardAllowed) {
            showInlineStatus("Clipboard capture disabled for private field")
            return false
        }
        if (!selectionState.hasSelection && editor().selectedText().isNullOrEmpty()) {
            if (isTermuxInputTarget() && sendTermuxClipboardShortcut(KeyEvent.KEYCODE_X)) {
                showInlineStatus("Termux cut shortcut sent")
                return true
            }
            showInlineStatus("No selectable text")
            return false
        }
        val cut = editor().performContextMenuAction(android.R.id.cut)
        if (cut.applied) {
            refreshTypingAssistantState()
            return true
        }
        val sent = isTermuxInputTarget() && sendTermuxClipboardShortcut(KeyEvent.KEYCODE_X)
        refreshTypingAssistantState()
        if (sent) {
            showInlineStatus("Termux cut shortcut sent")
            return true
        }
        if (!cut.applied) {
            showInlineStatus("Cut rejected by field")
        }
        return cut.applied
    }

    override fun onPasteClipboard(): Boolean {
        if (!fieldPolicy.clipboardAllowed) {
            showInlineStatus("Clipboard paste disabled for private field")
            return false
        }
        val targetPaste = editor().performContextMenuAction(android.R.id.paste)
        if (targetPaste.applied) {
            clipboardController.primaryText()?.let { stateStore.pushClipboardEntry(it) }
            applyRuntimePreferencesToView()
            showInlineStatus("Clipboard paste sent")
            return true
        }
        val pasted =
            clipboardController.pastePrimaryText(
                currentInputConnection,
                syncDesired = stateStore.clipboardSyncDesired,
            )
        if (pasted) {
            clipboardController.primaryText()?.let { stateStore.pushClipboardEntry(it) }
            applyRuntimePreferencesToView()
        }
        showInlineStatus(if (pasted) "Clipboard pasted" else "No text clipboard")
        return pasted
    }

    override fun onPastePlainClipboard(): Boolean {
        if (!fieldPolicy.clipboardAllowed) {
            showInlineStatus("Clipboard paste disabled for private field")
            return false
        }
        val plainPaste = editor().performContextMenuAction(android.R.id.pasteAsPlainText)
        if (plainPaste.applied) {
            showInlineStatus("Plain clipboard pasted")
            return true
        }
        return onPasteClipboard()
    }

    override fun onSelectAll(): Boolean {
        if (!inputContext.selectionModeAllowed) {
            showStatus("Selection unavailable in this field")
            return false
        }
        return editor().performContextMenuAction(android.R.id.selectAll).reportFailure("Select all rejected by field")
    }

    override fun onUndo(): Boolean {
        return editor().performContextMenuAction(android.R.id.undo).reportFailure("Undo rejected by field")
    }

    override fun onRedo(): Boolean {
        return editor().performContextMenuAction(android.R.id.redo).reportFailure("Redo rejected by field")
    }

    override fun onCancelSelection(): Boolean {
        if (!selectionState.hasSelection && editor().selectedText().isNullOrEmpty()) {
            showStatus("No active selection")
            return false
        }
        val canceled = editor().cancelSelection().reportFailure("Selection cancel rejected by field")
        refreshTypingAssistantState()
        return canceled
    }

    override fun onSuggestionSelected(suggestion: String): Boolean {
        if (!typingAssistantAllowed()) {
            return false
        }
        val editor = editor()
        if (!editor.hasActiveConnection()) {
            return false
        }
        val before = editor.textBeforeCursor(128)?.toString().orEmpty()
        val deleteCount = KeyboardTextAssistant.deleteCountForCurrentToken(before)
        val replacement = suggestion.trim()
        val result =
            if (deleteCount > 0) {
                editor.replaceTextBeforeCursor(deleteCount, "$replacement ")
            } else {
                editor.commitText("$replacement ")
            }
        refreshTypingAssistantState(editor)
        return result.reportFailure("Suggestion rejected by field")
    }

    override fun onSnippets() {
        if (!fieldPolicy.snippetsAllowed) {
            showStatus("Snippets disabled for private field")
            return
        }
        runServiceSafely("openSnippets") {
            val intent =
                Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra("openRoute", "/snippets")
                }
            startActivity(intent)
            showStatus("Open WinFlowz snippets")
        }
    }

    override fun onSettings() {
        runServiceSafely("openSettings") {
            val intent =
                Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            startActivity(intent)
        }
    }

    override fun onThemeSettings() {
        runServiceSafely("openThemeSettings") {
            val intent =
                Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra("openRoute", "/keyboard/theme")
                }
            startActivity(intent)
            showStatus("Open WinFlowz Keyboard Theme Studio")
        }
    }

    override fun onThemePresetSelected(presetId: String) {
        runServiceSafely("setThemePreset") {
            val config = stateStore.setThemePreset(presetId)
            applyRuntimePreferencesToView()
            showStatus("Theme ${KeyboardThemePresets.labelFor(config.presetId)}")
        }
    }

    private fun openMediaAccessOnboarding() {
        runServiceSafely("openMediaAccessOnboarding") {
            val intent =
                Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra("openRoute", "/settings?onboarding=media")
                }
            startActivity(intent)
            showStatus("Enable media access in WinFlowz")
        }
    }

    private fun openBrightnessOnboarding() {
        runServiceSafely("openBrightnessOnboarding") {
            val intent =
                Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    putExtra("openRoute", "/settings?onboarding=brightness")
                }
            startActivity(intent)
            showStatus("Enable brightness access in WinFlowz")
        }
    }

    override fun onKeyboardPicker() {
        runServiceSafely("showKeyboardPicker") {
            val manager = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            manager.showInputMethodPicker()
            showStatus("Keyboard picker opened")
        }
    }

    override fun onMediaPlayPause() {
        if (!stateStore.mediaControlsEnabled) {
            showStatus("Media controls disabled")
            return
        }
        mediaController.playPause()
        showStatus("Play/pause sent")
    }

    override fun onMediaPrevious() {
        if (!stateStore.mediaControlsEnabled) {
            showStatus("Media controls disabled")
            return
        }
        mediaController.previous()
        showStatus("Previous sent")
    }

    override fun onMediaNext() {
        if (!stateStore.mediaControlsEnabled) {
            showStatus("Media controls disabled")
            return
        }
        mediaController.next()
        showStatus("Next sent")
    }

    override fun onMediaNowPlaying(): String {
        if (!stateStore.mediaControlsEnabled) {
            return "Now playing: media controls disabled"
        }
        val label = mediaController.nowPlayingLabel()
        if (label == KeyboardMediaController.MEDIA_ACCESS_REQUIRED) {
            openMediaAccessOnboarding()
            return "Media access required"
        }
        return label
    }

    override fun onOpenMediaApp() {
        if (!stateStore.mediaControlsEnabled) {
            showStatus("Media controls disabled")
            return
        }
        val status = mediaController.openActiveMediaApp()
        if (status == KeyboardMediaController.MEDIA_ACCESS_REQUIRED) {
            openMediaAccessOnboarding()
            return
        }
        showStatus(status)
    }

    override fun onMediaStop() {
        runMediaAction { mediaController.stop() }
    }

    override fun onVolumeDown() {
        runMediaAction { mediaController.volumeDown(stateStore.mediaVolumeStepPercent) }
    }

    override fun onVolumeUp() {
        runMediaAction { mediaController.volumeUp(stateStore.mediaVolumeStepPercent) }
    }

    override fun onBrightnessDown() {
        adjustBrightness(delta = -brightnessStepDelta())
    }

    override fun onBrightnessUp() {
        adjustBrightness(delta = brightnessStepDelta())
    }

    private fun brightnessStepDelta(): Int {
        return (255 * stateStore.mediaBrightnessStepPercent / 100f).toInt().coerceAtLeast(1)
    }

    private fun adjustBrightness(delta: Int) {
        if (!stateStore.mediaControlsEnabled) {
            showStatus("Media controls disabled")
            return
        }
        val status = mediaController.adjustBrightness(delta)
        if (status == KeyboardMediaController.BRIGHTNESS_ACCESS_REQUIRED) {
            openBrightnessOnboarding()
            return
        }
        showStatus(status)
    }

    private fun runMediaAction(action: () -> String) {
        if (!stateStore.mediaControlsEnabled) {
            showStatus("Media controls disabled")
            return
        }
        val status = action()
        if (status == KeyboardMediaController.MEDIA_ACCESS_REQUIRED) {
            openMediaAccessOnboarding()
            return
        }
        showStatus(status)
    }

    override fun onNavigateCharLeft(): Boolean = sendSoftKey(KeyEvent.KEYCODE_DPAD_LEFT, 0)

    override fun onNavigateCharRight(): Boolean = sendSoftKey(KeyEvent.KEYCODE_DPAD_RIGHT, 0)

    override fun onNavigateWordLeft(): Boolean {
        val moved = if (inputContext.selectionModeAllowed) editor().moveWordCursor(left = true).applied else false
        return moved || sendSoftKey(KeyEvent.KEYCODE_DPAD_LEFT, KeyEvent.META_CTRL_ON)
    }

    override fun onNavigateWordRight(): Boolean {
        val moved = if (inputContext.selectionModeAllowed) editor().moveWordCursor(left = false).applied else false
        return moved || sendSoftKey(KeyEvent.KEYCODE_DPAD_RIGHT, KeyEvent.META_CTRL_ON)
    }

    override fun onNavigateLineUp(): Boolean = sendSoftKey(KeyEvent.KEYCODE_DPAD_UP, 0)

    override fun onNavigateLineDown(): Boolean = sendSoftKey(KeyEvent.KEYCODE_DPAD_DOWN, 0)

    override fun onNavigateParagraphUp(): Boolean {
        val moved = if (inputContext.selectionModeAllowed) editor().moveParagraphCursor(up = true).applied else false
        return moved || sendSoftKey(KeyEvent.KEYCODE_DPAD_UP, KeyEvent.META_CTRL_ON)
    }

    override fun onNavigateParagraphDown(): Boolean {
        val moved = if (inputContext.selectionModeAllowed) editor().moveParagraphCursor(up = false).applied else false
        return moved || sendSoftKey(KeyEvent.KEYCODE_DPAD_DOWN, KeyEvent.META_CTRL_ON)
    }

    override fun onNavigateLineStart(): Boolean {
        if (isTermuxInputTarget()) {
            return sendSoftKey(KeyEvent.KEYCODE_A, KeyEvent.META_CTRL_ON or KeyEvent.META_CTRL_LEFT_ON)
        }
        val moved = if (inputContext.selectionModeAllowed) editor().moveDocumentBoundary(start = true).applied else false
        return moved || sendSoftKey(KeyEvent.KEYCODE_MOVE_HOME, KeyEvent.META_CTRL_ON)
    }

    override fun onNavigateLineEnd(): Boolean {
        if (isTermuxInputTarget()) {
            return sendSoftKey(KeyEvent.KEYCODE_E, KeyEvent.META_CTRL_ON or KeyEvent.META_CTRL_LEFT_ON)
        }
        val moved = if (inputContext.selectionModeAllowed) editor().moveDocumentBoundary(start = false).applied else false
        return moved || sendSoftKey(KeyEvent.KEYCODE_MOVE_END, KeyEvent.META_CTRL_ON)
    }

    override fun onKeyEvent(
        keyCode: Int,
        metaState: Int,
    ): Boolean = sendSoftKey(keyCode, metaState)

    override fun onLayoutProfileChanged(profile: KeyboardLayoutProfile) {
        stateStore.layoutProfile = profile
        applyRuntimePreferencesToView()
        showStatus("Layout ${profile.name}")
    }

    override fun onCornerModeChanged(enabled: Boolean) {
        stateStore.cornerModeEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Swipe gestures enabled" else "Swipe gestures disabled")
    }

    override fun onDebugTouchOverlayChanged(enabled: Boolean) {
        stateStore.debugTouchOverlayEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Touch debug enabled" else "Touch debug disabled")
    }

    override fun onKeyVibrationChanged(enabled: Boolean) {
        stateStore.keyVibrationEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Key vibration enabled" else "Key vibration disabled")
    }

    override fun onKeySoundChanged(enabled: Boolean) {
        stateStore.keySoundEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Key sound enabled" else "Key sound disabled")
    }

    override fun onSpellingSuggestionsChanged(enabled: Boolean) {
        stateStore.spellingSuggestionsEnabled = enabled
        applyRuntimePreferencesToView()
        refreshTypingAssistantState()
        showStatus(if (enabled) "Suggestions enabled" else "Suggestions disabled")
    }

    override fun onSpecialKeyCornersChanged(enabled: Boolean) {
        stateStore.specialKeyCornersEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Special key gestures enabled" else "Special key gestures disabled")
    }

    override fun onFrenchLanguageChanged(enabled: Boolean) {
        stateStore.frenchLanguageEnabled = enabled
        applyRuntimePreferencesToView()
        refreshTypingAssistantState()
        showStatus(if (enabled) "French enabled" else "French disabled")
    }

    override fun onEnglishLanguageChanged(enabled: Boolean) {
        stateStore.englishLanguageEnabled = enabled
        applyRuntimePreferencesToView()
        refreshTypingAssistantState()
        showStatus(if (enabled) "English enabled" else "English disabled")
    }

    override fun onDoubleSpacePeriodChanged(enabled: Boolean) {
        stateStore.doubleSpacePeriodEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Double-space period enabled" else "Double-space period disabled")
    }

    override fun onPunctuationAutoSpacingChanged(enabled: Boolean) {
        stateStore.punctuationAutoSpacingEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Punctuation spacing enabled" else "Punctuation spacing disabled")
    }

    override fun onKeyboardHeightScaleChanged(scale: Float) {
        stateStore.keyboardHeightScale = scale
        applyRuntimePreferencesToView()
        showStatus("Keyboard height ${(stateStore.keyboardHeightScale * 100).toInt()}%")
    }

    override fun onCompactModeChanged(enabled: Boolean) {
        stateStore.compactModeEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Compact keyboard enabled" else "Compact keyboard disabled")
    }

    override fun onActionBarStateChanged(state: KeyboardActionBarState) {
        stateStore.replaceActionBarState(state)
    }

    private fun applyRuntimePreferencesToView() {
        runServiceSafely("applyRuntimePreferencesToView") {
            val emojiRecents =
                if (fieldPolicy.privateMode) {
                    emptyList()
                } else {
                    stateStore.emojiRecents()
                }
            val symbolRecents =
                if (fieldPolicy.privateMode) {
                    emptyList()
                } else {
                    stateStore.symbolRecents()
                }
            keyboardView?.applyRuntimePreferences(
                profile = stateStore.layoutProfile,
                cornersEnabled = stateStore.cornerModeEnabled,
                debugTouchOverlay = stateStore.debugTouchOverlayEnabled,
                keyVibration = stateStore.keyVibrationEnabled,
                keySound = stateStore.keySoundEnabled,
                spellingSuggestions = stateStore.spellingSuggestionsEnabled,
                mediaControlsEnabled = stateStore.mediaControlsEnabled,
                specialKeyCorners = stateStore.specialKeyCornersEnabled,
                frenchLanguage = stateStore.frenchLanguageEnabled,
                englishLanguage = stateStore.englishLanguageEnabled,
                doubleSpacePeriod = stateStore.doubleSpacePeriodEnabled,
                punctuationAutoSpacing = stateStore.punctuationAutoSpacingEnabled,
                keyboardHeightScale = stateStore.keyboardHeightScale,
                actionRowHeightScale = stateStore.actionRowHeightScale,
                compactMode = stateStore.compactModeEnabled,
                autoCloseModes = stateStore.autoCloseModesEnabled,
                themeMode = stateStore.themeMode,
                themeConfig = stateStore.themeConfig(),
                recents = emojiRecents,
                symbolRecents = symbolRecents,
                clipboardEntries = clipboardEntriesForKeyboard(),
                snippets = stateStore.snippetRules(),
                cornerConfig = stateStore.cornerConfig(),
                actionBarState = actionBarStateForCurrentField(),
                actionBarLongPressBehavior = stateStore.actionBarLongPressBehavior,
                statusBarConfig = stateStore.statusBarConfig,
                accountLabel = stateStore.accountLabel,
                accountLabelMode = stateStore.accountLabelMode,
            )
        }
    }

    private fun actionBarStateForCurrentField(): KeyboardActionBarState {
        return stateStore.actionBarState()
    }

    private fun clipboardEntriesForKeyboard(): List<KeyboardClipboardEntry> {
        val primary = clipboardController.primaryText()
            ?.replace(Regex("\\s+"), " ")
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?.let { KeyboardClipboardEntry(it) }
        return (listOfNotNull(primary) + stateStore.clipboardEntries())
            .dedupeClipboardEntriesForKeyboard()
            .take(60)
    }

    private fun List<KeyboardClipboardEntry>.dedupeClipboardEntriesForKeyboard(): List<KeyboardClipboardEntry> {
        val byKey = linkedMapOf<String, KeyboardClipboardEntry>()
        forEach { entry ->
            val normalized = entry.content.replace(Regex("\\s+"), " ").trim()
            if (normalized.isBlank()) {
                return@forEach
            }
            val key = normalized.lowercase()
            val existing = byKey[key]
            byKey[key] = KeyboardClipboardEntry(
                content = existing?.content ?: normalized,
                pinned = entry.pinned || existing?.pinned == true,
            )
        }
        return byKey.values.toList()
    }

    private fun shouldSuppressAutoCorrections(): Boolean {
        if (fieldPolicy.privateMode) {
            return true
        }
        return !inputContext.typingCorrectionsAllowed
    }

    private fun commitWithTypingCorrections(
        editor: InputConnectionEditor,
        text: String,
    ): Boolean {
        if (text.isEmpty()) {
            return true
        }

        if (!shouldSuppressAutoCorrections()) {
            if (stateStore.doubleSpacePeriodEnabled && text == " ") {
                when (applyDoubleSpacePeriod(editor)) {
                    TextCorrectionResult.Applied -> {
                        refreshTypingAssistantState(editor)
                        return true
                    }
                    TextCorrectionResult.Failed -> return false
                    TextCorrectionResult.NotApplied -> Unit
                }
            }
            if (stateStore.punctuationAutoSpacingEnabled) {
                val spaced = applyPunctuationAutoSpacing(editor, text)
                if (spaced != null) {
                    val committed = editor.commitText(spaced).reportFailure("Punctuation insertion rejected by field")
                    if (committed) {
                        applyTextExpansionAfterBoundary(editor)
                        refreshTypingAssistantState(editor)
                    }
                    return committed
                }
            }
        }

        val committed = editor.commitText(text).reportFailure("Text input rejected by field")
        if (committed) {
            applyTextExpansionAfterBoundary(editor)
            refreshTypingAssistantState(editor)
        }
        return committed
    }

    private fun applyTextExpansionAfterBoundary(editor: InputConnectionEditor): Boolean {
        if (!typingAssistantAllowed()) {
            return false
        }
        val before = editor.textBeforeCursor(192)?.toString().orEmpty()
        val match = KeyboardTextAssistant.expansionAfterBoundary(before, stateStore.textRules()) ?: return false
        val expanded =
            editor.replaceTextBeforeCursor(
                deleteBeforeCodePoints = match.deleteBeforeCodePoints,
                replacement = match.replacement,
            )
        if (expanded.applied) {
            showStatus("Shortcut expanded")
            return true
        }
        expanded.reportFailure("Shortcut expansion rejected by field")
        return false
    }

    private fun refreshTypingAssistantState(editor: InputConnectionEditor = editor()) {
        if (!editor.hasActiveConnection()) {
            keyboardView?.applyTypingAssistant(autoCapitalized = false, candidates = emptyList())
            return
        }
        val before = editor.textBeforeCursor(128)?.toString().orEmpty()
        val allowed = typingAssistantAllowed()
        keyboardView?.applyTypingAssistant(
            autoCapitalized = allowed && KeyboardTextAssistant.shouldAutoCapitalize(before),
            candidates =
                if (allowed && stateStore.spellingSuggestionsEnabled) {
                    KeyboardTextAssistant.suggestions(
                        textBeforeCursor = before,
                        rules = stateStore.textRules(),
                        frenchEnabled = stateStore.frenchLanguageEnabled,
                        englishEnabled = stateStore.englishLanguageEnabled,
                    )
                } else {
                    emptyList()
                },
        )
    }

    private fun typingAssistantAllowed(): Boolean {
        if (!fieldPolicy.inputAllowed || fieldPolicy.privateMode || !fieldPolicy.snippetsAllowed) {
            return false
        }
        if (isTermuxInputTarget()) {
            return false
        }
        return inputContext.fieldContext in setOf(KeyboardFieldContextMode.Text, KeyboardFieldContextMode.Search)
    }

    private fun applyDoubleSpacePeriod(editor: InputConnectionEditor): TextCorrectionResult {
        val before = editor.textBeforeCursor(3)?.toString().orEmpty()
        if (!before.endsWith(" ") || before.length < 2) {
            return TextCorrectionResult.NotApplied
        }
        val previous = before[before.length - 2]
        if (!previous.isLetterOrDigit()) {
            return TextCorrectionResult.NotApplied
        }
        if (!editor.deleteCodePointsBefore(1).applied) {
            showStatus("Double-space correction rejected by field")
            return TextCorrectionResult.Failed
        }
        val committed = editor.commitText(". ").reportFailure("Double-space correction rejected by field")
        return if (committed) {
            TextCorrectionResult.Applied
        } else {
            TextCorrectionResult.Failed
        }
    }

    private fun applyPunctuationAutoSpacing(
        editor: InputConnectionEditor,
        text: String,
    ): String? {
        if (text.length != 1) {
            return null
        }
        val symbol = text[0]
        val before = editor.textBeforeCursor(1)?.toString().orEmpty()
        return when (symbol) {
            ':', ';', '!', '?' -> {
                val prefix = if (before.isNotEmpty() && !before.last().isWhitespace()) " " else ""
                "$prefix$symbol "
            }
            '.', ',' -> {
                if (before.isEmpty()) {
                    symbol.toString()
                } else {
                    "$symbol "
                }
            }
            else -> null
        }
    }

    private fun sendSoftKey(
        keyCode: Int,
        metaState: Int,
    ): Boolean = editor().sendSoftKey(keyCode, metaState).applied

    private fun sendTermuxClipboardShortcut(keyCode: Int): Boolean {
        return sendSoftKey(
            keyCode = keyCode,
            metaState = KeyEvent.META_CTRL_ON or KeyEvent.META_ALT_ON or KeyEvent.META_ALT_LEFT_ON,
        )
    }

    private fun isTermuxInputTarget(): Boolean {
        return currentInputEditorInfo?.packageName?.startsWith("com.termux") == true
    }

    private fun isObsidianInputTarget(): Boolean {
        return currentInputEditorInfo?.packageName?.equals("md.obsidian", ignoreCase = true) == true
    }

    private fun editor(): InputConnectionEditor = InputConnectionEditor(currentInputConnection)

    private fun KeyboardEditorResult.reportFailure(failureStatus: String): Boolean {
        if (!applied) {
            showStatus(failureStatus)
        }
        return applied
    }

    private fun showStatus(message: String) {
        keyboardView?.setStatus(message)
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    private fun showInlineStatus(message: String) {
        keyboardView?.setStatus(message)
    }

    private fun <T> runServiceSafely(
        actionId: String,
        block: () -> T,
    ): T? {
        return try {
            block()
        } catch (error: Throwable) {
            KeyboardCrashReporter.report(
                context = this,
                crashContext =
                    KeyboardCrashContext(
                        actionId = actionId,
                        panel = "service",
                        mode = inputContext.fieldContext.name,
                        layoutProfile = stateStore.layoutProfile.name,
                        compactMode = stateStore.compactModeEnabled,
                        heightScale = stateStore.keyboardHeightScale,
                        themePresetId = stateStore.themeConfig().presetId,
                        themeSource = "service",
                        privateMode = fieldPolicy.privateMode,
                    ),
                error = error,
            )
            keyboardView?.setStatus("Keyboard recovered")
            Toast.makeText(this, "Keyboard recovered", Toast.LENGTH_SHORT).show()
            null
        }
    }

    private enum class TextCorrectionResult {
        NotApplied,
        Applied,
        Failed,
    }
}
