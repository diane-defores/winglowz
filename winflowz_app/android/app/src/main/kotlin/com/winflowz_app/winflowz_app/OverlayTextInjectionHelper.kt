package com.winflowz_app.winflowz_app

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Bundle
import android.text.InputType
import android.view.accessibility.AccessibilityNodeInfo

object OverlayTextInjectionHelper {
    fun deliverText(context: Context, text: String): Map<String, Any> {
        val normalizedText = text.trim()
        if (normalizedText.isEmpty()) {
            return mapOf(
                "injected" to false,
                "clipboardCopied" to false,
                "sensitiveField" to false,
            )
        }
        val dictatedText = "$normalizedText "

        var sensitiveField = false
        val injected =
            injectViaAccessibility(dictatedText) { isSensitive -> sensitiveField = isSensitive }
        val clipboardCopied = copyToClipboard(context, dictatedText)
        return mapOf(
            "injected" to injected,
            "clipboardCopied" to clipboardCopied,
            "sensitiveField" to sensitiveField,
        )
    }

    private fun injectViaAccessibility(text: String, onSensitive: (Boolean) -> Unit): Boolean {
        val service = OverlayAccessibilityService.instance ?: return false
        val rootNode = service.rootInActiveWindow ?: return false
        val focusedNode = rootNode.findFocus(AccessibilityNodeInfo.FOCUS_INPUT)
        if (focusedNode == null) {
            rootNode.recycle()
            return false
        }
        onSensitive(false)
        return try {
            if (isSensitiveField(focusedNode)) {
                onSensitive(true)
                false
            } else if (!focusedNode.isEditable) {
                false
            } else {
                val args = Bundle().apply {
                    putCharSequence(
                        AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE,
                        text,
                    )
                }
                focusedNode.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
            }
        } catch (_: Exception) {
            false
        } finally {
            focusedNode.recycle()
            rootNode.recycle()
        }
    }

    private fun isSensitiveField(node: AccessibilityNodeInfo): Boolean {
        if (node.isPassword) {
            return true
        }
        val inputType = node.inputType

        val classType = inputType and InputType.TYPE_MASK_CLASS
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        val isTextPassword =
            classType == InputType.TYPE_CLASS_TEXT &&
                (
                    variation == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
                        variation == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD ||
                        variation == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD
                )
        val isNumberPassword =
            classType == InputType.TYPE_CLASS_NUMBER &&
                variation == InputType.TYPE_NUMBER_VARIATION_PASSWORD
        return isTextPassword || isNumberPassword
    }

    private fun copyToClipboard(context: Context, text: String): Boolean {
        return try {
            val clipboard =
                context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clip = ClipData.newPlainText("WinFlowz", text)
            clipboard.setPrimaryClip(clip)
            true
        } catch (_: Exception) {
            false
        }
    }
}
