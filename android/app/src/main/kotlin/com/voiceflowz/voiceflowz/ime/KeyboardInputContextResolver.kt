package com.voiceflowz.voiceflowz.ime

import android.text.InputType
import android.view.inputmethod.EditorInfo

data class KeyboardInputContext(
    val fieldContext: KeyboardFieldContextMode,
    val enterLabel: String,
)

object KeyboardInputContextResolver {
    fun resolve(editorInfo: EditorInfo?): KeyboardInputContext {
        val info = editorInfo ?: return KeyboardInputContext(KeyboardFieldContextMode.Text, "Enter")
        val action = info.imeOptions and EditorInfo.IME_MASK_ACTION
        val fieldContext = contextFromInputType(info.inputType, action)
        return KeyboardInputContext(
            fieldContext = fieldContext,
            enterLabel = enterLabel(info),
        )
    }

    private fun contextFromInputType(
        inputType: Int,
        action: Int,
    ): KeyboardFieldContextMode {
        val klass = inputType and InputType.TYPE_MASK_CLASS
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        if (action == EditorInfo.IME_ACTION_SEARCH) {
            return KeyboardFieldContextMode.Search
        }
        if (klass == InputType.TYPE_CLASS_PHONE) {
            return KeyboardFieldContextMode.Phone
        }
        if (klass == InputType.TYPE_CLASS_TEXT && variation == InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS) {
            return KeyboardFieldContextMode.Email
        }
        if (klass == InputType.TYPE_CLASS_TEXT && variation == InputType.TYPE_TEXT_VARIATION_URI) {
            return KeyboardFieldContextMode.Url
        }
        return KeyboardFieldContextMode.Text
    }

    private fun enterLabel(info: EditorInfo): String {
        val action = info.imeOptions and EditorInfo.IME_MASK_ACTION
        return when {
            info.actionLabel != null -> info.actionLabel.toString()
            action == EditorInfo.IME_ACTION_SEARCH -> "Search"
            action == EditorInfo.IME_ACTION_SEND -> "Send"
            action == EditorInfo.IME_ACTION_GO -> "Go"
            action == EditorInfo.IME_ACTION_NEXT -> "Next"
            action == EditorInfo.IME_ACTION_DONE -> "Done"
            else -> "Enter"
        }
    }
}
