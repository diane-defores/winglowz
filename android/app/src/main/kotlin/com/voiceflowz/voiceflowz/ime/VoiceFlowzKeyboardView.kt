package com.voiceflowz.voiceflowz.ime

import android.content.Context
import android.graphics.Typeface
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class VoiceFlowzKeyboardView(
    context: Context,
    private val callbacks: Callbacks,
) : LinearLayout(context) {
    interface Callbacks {
        fun onText(text: String)
        fun onBackspace()
        fun onEnter()
        fun onVoice()
        fun onCopySelection()
        fun onPasteClipboard()
        fun onSnippets()
        fun onSettings()
        fun onMediaPlayPause()
    }

    private var shifted = false
    private var fieldPolicy = KeyboardSecurityPolicy.evaluate(null, KeyboardStateStore.PRIVACY_AUTO)
    private val statusView =
        TextView(context).apply {
            gravity = Gravity.CENTER
            text = "VoiceFlowz"
            setTypeface(typeface, Typeface.BOLD)
            setPadding(8, 8, 8, 4)
        }
    private val clipboardPanel = LinearLayout(context).apply {
        orientation = HORIZONTAL
        gravity = Gravity.CENTER
        visibility = GONE
    }
    private val letterButtons = mutableListOf<Button>()
    private lateinit var voiceButton: Button
    private lateinit var clipboardButton: Button
    private lateinit var snippetsButton: Button

    init {
        orientation = VERTICAL
        setPadding(8, 8, 8, 10)
        addView(statusView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        addActionRow()
        addClipboardPanel()
        addLetterRow("qwertyuiop")
        addLetterRow("asdfghjkl")
        addLetterRow("zxcvbnm")
        addControlRow()
        renderLetters()
        applyPolicy(fieldPolicy)
    }

    fun applyPolicy(policy: KeyboardFieldPolicy) {
        fieldPolicy = policy
        statusView.text =
            if (policy.privateMode) {
                "VoiceFlowz - private input (${policy.reason})"
            } else {
                "VoiceFlowz"
            }
        voiceButton.isEnabled = policy.voiceAllowed
        clipboardButton.isEnabled = policy.clipboardAllowed
        snippetsButton.isEnabled = policy.snippetsAllowed
    }

    fun setStatus(message: String) {
        statusView.text = message
    }

    private fun addActionRow() {
        val row = row()
        voiceButton = actionButton("Mic") { callbacks.onVoice() }
        clipboardButton =
            actionButton("Clipboard") {
                clipboardPanel.visibility =
                    if (clipboardPanel.visibility == VISIBLE) GONE else VISIBLE
            }
        snippetsButton = actionButton("Snippets") { callbacks.onSnippets() }
        row.addView(voiceButton, weightedParams())
        row.addView(clipboardButton, weightedParams())
        row.addView(snippetsButton, weightedParams())
        row.addView(actionButton("Settings") { callbacks.onSettings() }, weightedParams())
        row.addView(actionButton("Media") { callbacks.onMediaPlayPause() }, weightedParams())
        addView(row)
    }

    private fun addClipboardPanel() {
        clipboardPanel.addView(actionButton("Copy selection") { callbacks.onCopySelection() }, weightedParams())
        clipboardPanel.addView(actionButton("Paste clipboard") { callbacks.onPasteClipboard() }, weightedParams())
        clipboardPanel.addView(actionButton("Close") { clipboardPanel.visibility = GONE }, weightedParams())
        addView(clipboardPanel)
    }

    private fun addLetterRow(letters: String) {
        val row = row()
        letters.forEach { char ->
            val button =
                actionButton(char.toString()) {
                    callbacks.onText(if (shifted) char.uppercase() else char.toString())
                    if (shifted) {
                        shifted = false
                        renderLetters()
                    }
                }
            letterButtons.add(button)
            row.addView(button, weightedParams())
        }
        addView(row)
    }

    private fun addControlRow() {
        val row = row()
        row.addView(actionButton("Shift") {
            shifted = !shifted
            renderLetters()
        }, weightedParams())
        row.addView(actionButton("123") { callbacks.onText("123") }, weightedParams())
        row.addView(actionButton(",") { callbacks.onText(",") }, weightedParams())
        row.addView(actionButton("Space") { callbacks.onText(" ") }, weightedParams(weight = 3f))
        row.addView(actionButton(".") { callbacks.onText(".") }, weightedParams())
        row.addView(actionButton("Enter") { callbacks.onEnter() }, weightedParams())
        row.addView(actionButton("Del") { callbacks.onBackspace() }, weightedParams())
        addView(row)
    }

    private fun renderLetters() {
        letterButtons.forEach { button ->
            button.text = if (shifted) button.text.toString().uppercase() else button.text.toString().lowercase()
        }
    }

    private fun row() =
        LinearLayout(context).apply {
            orientation = HORIZONTAL
            gravity = Gravity.CENTER
        }

    private fun actionButton(label: String, onClick: () -> Unit): Button =
        Button(context).apply {
            text = label
            textSize = 13f
            isAllCaps = false
            minHeight = 48
            setOnClickListener { onClick() }
        }

    private fun weightedParams(weight: Float = 1f) =
        LayoutParams(0, LayoutParams.WRAP_CONTENT, weight).apply {
            setMargins(3, 3, 3, 3)
        }
}
