package com.voiceflowz.voiceflowz.ime

import android.content.Intent
import android.inputmethodservice.InputMethodService
import android.view.KeyCharacterMap
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.ExtractedTextRequest
import android.view.inputmethod.InputConnection
import android.widget.Toast
import com.voiceflowz.voiceflowz.MainActivity

class VoiceFlowzInputMethodService : InputMethodService(), VoiceFlowzKeyboardView.Callbacks {
    private lateinit var stateStore: KeyboardStateStore
    private lateinit var mediaController: KeyboardMediaController
    private lateinit var clipboardController: KeyboardClipboardController
    private lateinit var voiceController: KeyboardVoiceController
    private var keyboardView: VoiceFlowzKeyboardView? = null
    private var fieldPolicy =
        KeyboardSecurityPolicy.evaluate(null, KeyboardStateStore.PRIVACY_AUTO)
    private var inputContext = KeyboardInputContextResolver.resolve(null)

    override fun onCreate() {
        super.onCreate()
        stateStore = KeyboardStateStore(this)
        mediaController = KeyboardMediaController(this)
        clipboardController = KeyboardClipboardController(this)
        voiceController =
            KeyboardVoiceController(
                context = this,
                onState = { message -> keyboardView?.setStatus(message) },
                onResult = { text ->
                    val inputConnection = currentInputConnection
                    if (inputConnection == null) {
                        showStatus("Dictation result ignored: no active field")
                        return@KeyboardVoiceController
                    }
                    val committed =
                        commitTextSafely(
                            inputConnection = inputConnection,
                            text = text,
                            failureStatus = "Dictation text rejected by field",
                        )
                    if (!committed) {
                        return@KeyboardVoiceController
                    }
                    if (stateStore.clipboardSyncDesired && fieldPolicy.clipboardAllowed) {
                        KeyboardClipboardEventQueue.enqueue(
                            context = this,
                            content = text,
                            source = "keyboard_voice",
                            action = "voice_result",
                        )
                    }
                },
            )
    }

    override fun onCreateInputView(): View {
        val view = VoiceFlowzKeyboardView(this, this)
        keyboardView = view
        view.applyPolicy(fieldPolicy)
        applyRuntimePreferencesToView()
        view.applyInputContext(
            contextMode = inputContext.fieldContext,
            enterActionLabel = inputContext.enterLabel,
        )
        return view
    }

    override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInput(attribute, restarting)
        fieldPolicy = KeyboardSecurityPolicy.evaluate(attribute, stateStore.privacyMode)
        inputContext = KeyboardInputContextResolver.resolve(attribute)
        keyboardView?.applyPolicy(fieldPolicy)
        applyRuntimePreferencesToView()
        keyboardView?.applyInputContext(
            contextMode = inputContext.fieldContext,
            enterActionLabel = inputContext.enterLabel,
        )
    }

    override fun onFinishInput() {
        voiceController.cancel()
        super.onFinishInput()
    }

    override fun onDestroy() {
        voiceController.destroy()
        super.onDestroy()
    }

    override fun onText(text: String): Boolean {
        if (!fieldPolicy.inputAllowed) {
            showStatus("Input unavailable")
            return false
        }
        val inputConnection = currentInputConnection
        if (inputConnection == null) {
            showStatus("Input unavailable: no active field")
            return false
        }
        return commitWithTypingCorrections(inputConnection, text)
    }

    override fun onEmojiInserted(emoji: String) {
        stateStore.pushEmojiRecent(emoji, privateMode = fieldPolicy.privateMode)
        applyRuntimePreferencesToView()
    }

    override fun onBackspace(): Boolean {
        val inputConnection = currentInputConnection
        if (inputConnection == null) {
            showStatus("Delete unavailable: no active field")
            return false
        }
        val selected = inputConnection.getSelectedText(0)
        if (!selected.isNullOrEmpty()) {
            return commitTextSafely(
                inputConnection = inputConnection,
                text = "",
                failureStatus = "Delete selection rejected by field",
            )
        }
        val deleted = deleteCodePointBefore(inputConnection)
        if (!deleted) {
            showStatus("Delete rejected by field")
        }
        return deleted
    }

    override fun onDeleteWordBefore(): Boolean {
        val inputConnection = currentInputConnection ?: return false
        val selected = inputConnection.getSelectedText(0)
        if (!selected.isNullOrEmpty()) {
            return commitTextSafely(
                inputConnection = inputConnection,
                text = "",
                failureStatus = "Delete selection rejected by field",
            )
        }
        val before = inputConnection.getTextBeforeCursor(128, 0)?.toString().orEmpty()
        if (before.isEmpty()) {
            return false
        }
        var index = before.length - 1
        while (index >= 0 && before[index].isWhitespace()) {
            index--
        }
        if (index < 0) {
            return deleteCodePointsBefore(inputConnection, before.codePointCount(0, before.length))
        }
        while (index >= 0 && !before[index].isWhitespace()) {
            index--
        }
        val segment = before.substring(index + 1)
        val codePointCount = segment.codePointCount(0, segment.length)
        return deleteCodePointsBefore(inputConnection, codePointCount)
    }

    override fun onEnter(): Boolean {
        val inputConnection = currentInputConnection
        if (inputConnection == null) {
            showStatus("Enter unavailable: no active field")
            return false
        }
        val actionId = currentInputEditorInfo?.imeOptions?.and(EditorInfo.IME_MASK_ACTION)
            ?: EditorInfo.IME_ACTION_NONE
        if (actionId != EditorInfo.IME_ACTION_NONE) {
            val handled = inputConnection.performEditorAction(actionId)
            if (handled) {
                return true
            }
        } else {
            return sendSoftKey(KeyEvent.KEYCODE_ENTER, 0)
        }
        return sendSoftKey(KeyEvent.KEYCODE_ENTER, 0)
    }

    override fun onVoice() {
        if (!stateStore.voiceEnabled) {
            showStatus("Dictation disabled in VoiceFlowz settings")
            return
        }
        if (!fieldPolicy.voiceAllowed) {
            showStatus("Dictation disabled for private field")
            return
        }
        voiceController.start()
    }

    override fun onCopySelection() {
        if (!fieldPolicy.clipboardAllowed) {
            showStatus("Clipboard capture disabled for private field")
            return
        }
        val copied =
            clipboardController.copySelection(
                currentInputConnection,
                syncDesired = stateStore.clipboardSyncDesired,
            )
        showStatus(if (copied) "Selection copied" else "No selectable text")
    }

    override fun onPasteClipboard(): Boolean {
        if (!fieldPolicy.clipboardAllowed) {
            showStatus("Clipboard paste disabled for private field")
            return false
        }
        val pasted =
            clipboardController.pastePrimaryText(
                currentInputConnection,
                syncDesired = stateStore.clipboardSyncDesired,
            )
        showStatus(if (pasted) "Clipboard pasted" else "No text clipboard")
        return pasted
    }

    override fun onSnippets() {
        if (!fieldPolicy.snippetsAllowed) {
            showStatus("Snippets disabled for private field")
            return
        }
        showStatus("Snippets sync opens from the app for now")
    }

    override fun onSettings() {
        val intent =
            Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        startActivity(intent)
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

    override fun onNavigateCharLeft(): Boolean = sendSoftKey(KeyEvent.KEYCODE_DPAD_LEFT, 0)

    override fun onNavigateCharRight(): Boolean = sendSoftKey(KeyEvent.KEYCODE_DPAD_RIGHT, 0)

    override fun onNavigateWordLeft(): Boolean {
        val moved = moveWordCursor(left = true)
        return moved || sendSoftKey(KeyEvent.KEYCODE_DPAD_LEFT, KeyEvent.META_CTRL_ON)
    }

    override fun onNavigateWordRight(): Boolean {
        val moved = moveWordCursor(left = false)
        return moved || sendSoftKey(KeyEvent.KEYCODE_DPAD_RIGHT, KeyEvent.META_CTRL_ON)
    }

    override fun onNavigateLineStart(): Boolean {
        val moved = moveLineBoundary(start = true)
        return moved || sendSoftKey(KeyEvent.KEYCODE_MOVE_HOME, 0)
    }

    override fun onNavigateLineEnd(): Boolean {
        val moved = moveLineBoundary(start = false)
        return moved || sendSoftKey(KeyEvent.KEYCODE_MOVE_END, 0)
    }

    override fun onLayoutProfileChanged(profile: KeyboardLayoutProfile) {
        stateStore.layoutProfile = profile
        applyRuntimePreferencesToView()
        showStatus("Layout ${profile.name}")
    }

    override fun onCornerModeChanged(enabled: Boolean) {
        stateStore.cornerModeEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Corner mode enabled" else "Corner mode disabled")
    }

    override fun onDebugTouchOverlayChanged(enabled: Boolean) {
        stateStore.debugTouchOverlayEnabled = enabled
        applyRuntimePreferencesToView()
        showStatus(if (enabled) "Touch debug enabled" else "Touch debug disabled")
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

    private fun applyRuntimePreferencesToView() {
        val emojiRecents =
            if (fieldPolicy.privateMode) {
                emptyList()
            } else {
                stateStore.emojiRecents()
            }
        keyboardView?.applyRuntimePreferences(
            profile = stateStore.layoutProfile,
            cornersEnabled = stateStore.cornerModeEnabled,
            debugTouchOverlay = stateStore.debugTouchOverlayEnabled,
            doubleSpacePeriod = stateStore.doubleSpacePeriodEnabled,
            punctuationAutoSpacing = stateStore.punctuationAutoSpacingEnabled,
            recents = emojiRecents,
        )
    }

    private fun shouldSuppressAutoCorrections(): Boolean {
        if (fieldPolicy.privateMode) {
            return true
        }
        return inputContext.fieldContext in
            setOf(
                KeyboardFieldContextMode.Email,
                KeyboardFieldContextMode.Url,
                KeyboardFieldContextMode.Phone,
            )
    }

    private fun commitWithTypingCorrections(
        inputConnection: InputConnection,
        text: String,
    ): Boolean {
        if (text.isEmpty()) {
            return true
        }

        if (!shouldSuppressAutoCorrections()) {
            if (stateStore.doubleSpacePeriodEnabled && text == " ") {
                when (applyDoubleSpacePeriod(inputConnection)) {
                    TextCorrectionResult.Applied -> return true
                    TextCorrectionResult.Failed -> return false
                    TextCorrectionResult.NotApplied -> Unit
                }
            }
            if (stateStore.punctuationAutoSpacingEnabled) {
                val spaced = applyPunctuationAutoSpacing(inputConnection, text)
                if (spaced != null) {
                    return commitTextSafely(
                        inputConnection = inputConnection,
                        text = spaced,
                        failureStatus = "Punctuation insertion rejected by field",
                    )
                }
            }
        }

        return commitTextSafely(
            inputConnection = inputConnection,
            text = text,
            failureStatus = "Text input rejected by field",
        )
    }

    private fun applyDoubleSpacePeriod(inputConnection: InputConnection): TextCorrectionResult {
        val before = inputConnection.getTextBeforeCursor(3, 0)?.toString().orEmpty()
        if (!before.endsWith(" ") || before.length < 2) {
            return TextCorrectionResult.NotApplied
        }
        val previous = before[before.length - 2]
        if (!previous.isLetterOrDigit()) {
            return TextCorrectionResult.NotApplied
        }
        if (!deleteCodePointBefore(inputConnection)) {
            showStatus("Double-space correction rejected by field")
            return TextCorrectionResult.Failed
        }
        val committed =
            commitTextSafely(
                inputConnection = inputConnection,
                text = ". ",
                failureStatus = "Double-space correction rejected by field",
            )
        return if (committed) {
            TextCorrectionResult.Applied
        } else {
            TextCorrectionResult.Failed
        }
    }

    private fun applyPunctuationAutoSpacing(
        inputConnection: InputConnection,
        text: String,
    ): String? {
        if (text.length != 1) {
            return null
        }
        val symbol = text[0]
        val before = inputConnection.getTextBeforeCursor(1, 0)?.toString().orEmpty()
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

    private fun moveWordCursor(left: Boolean): Boolean {
        val inputConnection = currentInputConnection ?: return false
        val extracted = inputConnection.getExtractedText(ExtractedTextRequest(), 0) ?: return false
        val text = extracted.text?.toString() ?: return false
        val selection = extracted.selectionStart.coerceIn(0, text.length)
        val target =
            if (left) {
                previousWordBoundary(text, selection)
            } else {
                nextWordBoundary(text, selection)
            }
        if (target == selection) {
            return false
        }
        return inputConnection.setSelection(target, target)
    }

    private fun moveLineBoundary(start: Boolean): Boolean {
        val inputConnection = currentInputConnection ?: return false
        val extracted = inputConnection.getExtractedText(ExtractedTextRequest(), 0) ?: return false
        val text = extracted.text?.toString() ?: return false
        val selection = extracted.selectionStart.coerceIn(0, text.length)
        val target =
            if (start) {
                val previousLineBreak = text.lastIndexOf('\n', maxOf(0, selection - 1))
                if (previousLineBreak < 0) 0 else previousLineBreak + 1
            } else {
                val nextLineBreak = text.indexOf('\n', selection)
                if (nextLineBreak < 0) text.length else nextLineBreak
            }
        if (target == selection) {
            return false
        }
        return inputConnection.setSelection(target, target)
    }

    private fun previousWordBoundary(
        text: String,
        cursor: Int,
    ): Int {
        if (cursor <= 0) {
            return 0
        }
        var index = cursor - 1
        while (index >= 0 && text[index].isWhitespace()) {
            index--
        }
        while (index >= 0 && !text[index].isWhitespace()) {
            index--
        }
        return (index + 1).coerceAtLeast(0)
    }

    private fun nextWordBoundary(
        text: String,
        cursor: Int,
    ): Int {
        if (cursor >= text.length) {
            return text.length
        }
        var index = cursor
        while (index < text.length && !text[index].isWhitespace()) {
            index++
        }
        while (index < text.length && text[index].isWhitespace()) {
            index++
        }
        return index.coerceAtMost(text.length)
    }

    private fun sendSoftKey(
        keyCode: Int,
        metaState: Int,
    ): Boolean {
        val inputConnection = currentInputConnection ?: return false
        val down =
            KeyEvent(
                0L,
                0L,
                KeyEvent.ACTION_DOWN,
                keyCode,
                0,
                metaState,
                KeyCharacterMap.VIRTUAL_KEYBOARD,
                0,
                KeyEvent.FLAG_SOFT_KEYBOARD,
            )
        val up =
            KeyEvent(
                0L,
                0L,
                KeyEvent.ACTION_UP,
                keyCode,
                0,
                metaState,
                KeyCharacterMap.VIRTUAL_KEYBOARD,
                0,
                KeyEvent.FLAG_SOFT_KEYBOARD,
        )
        val downSent = inputConnection.sendKeyEvent(down)
        val upSent = inputConnection.sendKeyEvent(up)
        return downSent && upSent
    }

    private fun commitTextSafely(
        inputConnection: InputConnection,
        text: String,
        failureStatus: String,
    ): Boolean {
        val committed = inputConnection.commitText(text, 1)
        if (!committed) {
            showStatus(failureStatus)
        }
        return committed
    }

    private fun deleteCodePointsBefore(
        inputConnection: InputConnection,
        count: Int,
    ): Boolean {
        if (count <= 0) {
            return false
        }
        val deletedCodePoints = inputConnection.deleteSurroundingTextInCodePoints(count, 0)
        if (deletedCodePoints) {
            return true
        }
        return inputConnection.deleteSurroundingText(count, 0)
    }

    private fun deleteCodePointBefore(inputConnection: InputConnection): Boolean {
        return deleteCodePointsBefore(inputConnection, 1)
    }

    private fun showStatus(message: String) {
        keyboardView?.setStatus(message)
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    private enum class TextCorrectionResult {
        NotApplied,
        Applied,
        Failed,
    }
}
