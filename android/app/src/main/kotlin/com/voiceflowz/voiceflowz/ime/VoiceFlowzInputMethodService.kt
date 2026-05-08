package com.voiceflowz.voiceflowz.ime

import android.inputmethodservice.InputMethodService
import android.content.Intent
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
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
                    currentInputConnection?.commitText(text, 1)
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
        return view
    }

    override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInput(attribute, restarting)
        fieldPolicy = KeyboardSecurityPolicy.evaluate(attribute, stateStore.privacyMode)
        keyboardView?.applyPolicy(fieldPolicy)
    }

    override fun onFinishInput() {
        voiceController.cancel()
        super.onFinishInput()
    }

    override fun onDestroy() {
        voiceController.destroy()
        super.onDestroy()
    }

    override fun onText(text: String) {
        if (!fieldPolicy.inputAllowed) {
            showStatus("Input unavailable")
            return
        }
        currentInputConnection?.commitText(text, 1)
    }

    override fun onBackspace() {
        currentInputConnection?.deleteSurroundingText(1, 0)
    }

    override fun onEnter() {
        val actionId = currentInputEditorInfo?.imeOptions?.and(EditorInfo.IME_MASK_ACTION)
            ?: EditorInfo.IME_ACTION_NONE
        if (actionId != EditorInfo.IME_ACTION_NONE) {
            currentInputConnection?.performEditorAction(actionId)
        } else {
            currentInputConnection?.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
            currentInputConnection?.sendKeyEvent(KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_ENTER))
        }
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

    override fun onPasteClipboard() {
        if (!fieldPolicy.clipboardAllowed) {
            showStatus("Clipboard paste disabled for private field")
            return
        }
        val pasted =
            clipboardController.pastePrimaryText(
                currentInputConnection,
                syncDesired = stateStore.clipboardSyncDesired,
            )
        showStatus(if (pasted) "Clipboard pasted" else "No text clipboard")
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

    private fun showStatus(message: String) {
        keyboardView?.setStatus(message)
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }
}
