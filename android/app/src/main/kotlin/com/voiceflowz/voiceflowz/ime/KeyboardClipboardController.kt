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

    fun copySelection(inputConnection: InputConnection?, sensitive: Boolean): Boolean {
        val selectedText = inputConnection?.getSelectedText(0)?.toString()?.trim()
        if (selectedText.isNullOrEmpty()) {
            return false
        }
        val clip = ClipData.newPlainText("VoiceFlowz selection", selectedText)
        if (sensitive) {
            markSensitive(clip)
        }
        clipboard.setPrimaryClip(clip)
        return true
    }

    fun pastePrimaryText(inputConnection: InputConnection?): Boolean {
        val item = clipboard.primaryClip?.getItemAt(0) ?: return false
        val value = item.coerceToText(context)?.toString()?.takeIf { it.isNotBlank() }
            ?: return false
        return inputConnection?.commitText(value, 1) == true
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
}
