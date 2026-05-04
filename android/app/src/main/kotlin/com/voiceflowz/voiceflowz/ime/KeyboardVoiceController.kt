package com.voiceflowz.voiceflowz.ime

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import java.util.Locale

class KeyboardVoiceController(
    private val context: Context,
    private val onState: (String) -> Unit,
    private val onResult: (String) -> Unit,
) {
    private var recognizer: SpeechRecognizer? = null
    private var listening = false

    fun start() {
        if (listening) {
            stop()
            return
        }
        if (!hasAudioPermission()) {
            onState("Microphone permission required")
            return
        }
        if (!SpeechRecognizer.isRecognitionAvailable(context)) {
            onState("Speech recognition unavailable")
            return
        }
        val speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context)
        recognizer = speechRecognizer
        speechRecognizer.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                listening = true
                onState("Listening")
            }

            override fun onBeginningOfSpeech() {
                onState("Recording")
            }

            override fun onRmsChanged(rmsdB: Float) = Unit
            override fun onBufferReceived(buffer: ByteArray?) = Unit
            override fun onEndOfSpeech() {
                onState("Processing")
            }

            override fun onError(error: Int) {
                listening = false
                destroy()
                onState("Dictation failed")
            }

            override fun onResults(results: Bundle?) {
                listening = false
                val matches =
                    results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        .orEmpty()
                val best = matches.firstOrNull()?.trim().orEmpty()
                destroy()
                if (best.isNotEmpty()) {
                    onResult(best)
                    onState("Inserted dictation")
                } else {
                    onState("No speech detected")
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches =
                    partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        .orEmpty()
                val best = matches.firstOrNull()?.trim().orEmpty()
                if (best.isNotEmpty()) {
                    onState(best)
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) = Unit
        })
        speechRecognizer.startListening(
            Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(
                    RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                    RecognizerIntent.LANGUAGE_MODEL_FREE_FORM,
                )
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault().toLanguageTag())
            },
        )
    }

    fun stop() {
        recognizer?.stopListening()
        listening = false
        onState("Processing")
    }

    fun cancel() {
        recognizer?.cancel()
        listening = false
        destroy()
        onState("Canceled")
    }

    fun destroy() {
        recognizer?.destroy()
        recognizer = null
    }

    private fun hasAudioPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
                PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }
}
