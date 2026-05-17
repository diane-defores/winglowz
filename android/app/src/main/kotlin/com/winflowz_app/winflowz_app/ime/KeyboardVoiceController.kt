package com.winflowz_app.winflowz_app.ime

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
    private val stateStore: KeyboardStateStore,
    private val onState: (String) -> Unit,
    private val onResult: (String) -> Unit,
) {
    private var recognizer: SpeechRecognizer? = null
    private var listening = false
    private var pauseRequested = false
    private var manualStopRequested = false
    private var latestPartialResult: String = ""

    fun isListening(): Boolean = listening

    fun start() {
        if (listening) {
            cancel()
            return
        }
        if (!hasAudioPermission()) {
            recordUnavailable("permission_denied")
            onState("Microphone permission required")
            return
        }
        pauseRequested = false
        manualStopRequested = false
        latestPartialResult = ""
        if (!SpeechRecognizer.isRecognitionAvailable(context)) {
            recordUnavailable("android_speech_unavailable")
            onState("Speech recognition unavailable")
            return
        }
        recordAndroidFallback("none")
        onState("Using Android speech fallback")
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
                val fallback = latestPartialResult.trim()
                val wasManualStop = manualStopRequested
                val wasPaused = pauseRequested
                listening = false
                pauseRequested = false
                manualStopRequested = false
                destroy()
                if (wasManualStop && !wasPaused && fallback.isNotEmpty()) {
                    onResult(fallback)
                    onState("Inserted dictation")
                } else if (wasPaused) {
                    recordAndroidFallback("none")
                    onState("Dictation paused")
                } else {
                    recordAndroidFallback("runtime_load_failed")
                    onState("Dictation failed")
                }
            }

            override fun onResults(results: Bundle?) {
                listening = false
                val wasPaused = pauseRequested
                pauseRequested = false
                manualStopRequested = false
                val matches =
                    results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        .orEmpty()
                val best = matches.firstOrNull()?.trim().orEmpty().ifEmpty {
                    latestPartialResult.trim()
                }
                destroy()
                if (best.isNotEmpty()) {
                    recordAndroidFallback("none")
                    onResult(best)
                    onState(if (wasPaused) "Dictation paused" else "Inserted dictation")
                } else if (wasPaused) {
                    recordAndroidFallback("none")
                    onState("Dictation paused")
                } else {
                    recordAndroidFallback("missing_pack")
                    onState("No speech detected")
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches =
                    partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                        .orEmpty()
                val best = matches.firstOrNull()?.trim().orEmpty()
                if (best.isNotEmpty()) {
                    latestPartialResult = best
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
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 600000)
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 600000)
            },
        )
    }

    fun stop() {
        pauseRequested = false
        manualStopRequested = true
        recognizer?.stopListening()
        listening = false
        onState("Processing")
    }

    fun pause() {
        if (!listening) {
            onState("Dictation already paused")
            return
        }
        pauseRequested = true
        manualStopRequested = true
        recognizer?.stopListening()
        listening = false
        onState("Dictation paused")
    }

    fun resume() {
        if (listening) {
            onState("Recording")
            return
        }
        start()
    }

    fun restart() {
        cancel()
        start()
    }

    fun cancel() {
        pauseRequested = false
        manualStopRequested = false
        latestPartialResult = ""
        recognizer?.cancel()
        listening = false
        destroy()
        onState("Canceled")
    }

    fun destroy() {
        recognizer?.destroy()
        recognizer = null
    }

    private fun recordAndroidFallback(lastErrorCode: String) {
        stateStore.updateVoiceRuntimeStatus(
            runtimeMode = "android_fallback",
            languageTag = Locale.getDefault().toLanguageTag(),
            packId = "none",
            engine = "android_speech_recognizer",
            fallbackReason = if (lastErrorCode == "none") "missing_pack" else lastErrorCode,
            lastErrorCode = lastErrorCode,
        )
    }

    private fun recordUnavailable(lastErrorCode: String) {
        stateStore.updateVoiceRuntimeStatus(
            runtimeMode = "unavailable",
            languageTag = Locale.getDefault().toLanguageTag(),
            packId = "none",
            engine = "android_speech_recognizer",
            fallbackReason = "unsupported_language",
            lastErrorCode = lastErrorCode,
        )
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
