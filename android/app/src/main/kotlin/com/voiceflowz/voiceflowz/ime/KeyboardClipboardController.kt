package com.voiceflowz.voiceflowz.ime

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.PersistableBundle
import android.view.inputmethod.InputConnection

class KeyboardClipboardController(private val context: Context) {
    private val clipboard =
        context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

    fun copySelection(inputConnection: InputConnection?, syncDesired: Boolean): Boolean {
        val selectedText = inputConnection?.getSelectedText(0)?.toString()?.trim()
        if (selectedText.isNullOrEmpty()) {
            return false
        }
        val clip = ClipData.newPlainText("VoiceFlowz selection", selectedText)
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
        val item = clip.getItemAt(0) ?: return false
        val value = item.coerceToText(context)?.toString()?.takeIf { it.isNotBlank() }
            ?: return false
        val pasted = inputConnection?.commitText(value, 1) == true
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

    private fun markSensitive(clip: ClipData) {
        val extras = PersistableBundle()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            extras.putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
        } else {
            extras.putBoolean("android.content.extra.IS_SENSITIVE", true)
        }
        clip.description.extras = extras
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
