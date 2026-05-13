package com.winflowz_app.winflowz_app.ime

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.view.inputmethod.InputConnection

class KeyboardClipboardController(private val context: Context) {
    private val clipboard =
        context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

    fun copySelection(inputConnection: InputConnection?, syncDesired: Boolean): Boolean {
        val selectedText = InputConnectionEditor(inputConnection).selectedText()?.toString()?.trim()
        if (selectedText.isNullOrEmpty()) {
            return false
        }
        val clip = ClipData.newPlainText("WinFlowzApp selection", selectedText)
        clipboard.setPrimaryClip(clip)
        if (syncDesired) {
            KeyboardClipboardEventQueue.enqueue(
                context = context,
                content = selectedText,
                source = "keyboard_clipboard",
                action = "copy_selection",
            )
        }
        return true
    }

    fun pastePrimaryText(inputConnection: InputConnection?, syncDesired: Boolean): Boolean {
        val clip = clipboard.primaryClip ?: return false
        val value = primaryText() ?: return false
        val pasted = InputConnectionEditor(inputConnection).commitText(value).applied
        if (pasted && syncDesired && !clip.isSensitive()) {
            KeyboardClipboardEventQueue.enqueue(
                context = context,
                content = value,
                source = "keyboard_clipboard",
                action = "paste_primary_clip",
            )
        }
        return pasted
    }

    fun primaryText(): String? {
        val clip = clipboard.primaryClip ?: return null
        val item = clip.getItemAt(0) ?: return null
        return item.coerceToText(context)?.toString()?.trim()?.takeIf { it.isNotBlank() }
    }

    private fun ClipData.isSensitive(): Boolean {
        val extras = description.extras ?: return false
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            extras.getBoolean(ClipDescription.EXTRA_IS_SENSITIVE, false)
        } else {
            extras.getBoolean("android.content.extra.IS_SENSITIVE", false)
        }
    }
}
