package com.winflowz_app.winflowz_app.ime

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
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
    private companion object {
        const val LOCAL_RUNTIME_STARTUP_TIMEOUT_MS = 10_000L
    }

    private enum class LocalRuntimeStartResult {
        StartedLocal,
        UseAndroidFallback,
        FallbackUnavailable,
    }

    private data class LocalRuntimeStartDecision(
        val result: LocalRuntimeStartResult,
        val fallbackReason: String = "none",
        val lastErrorCode: String = "none",
    )

    private var recognizer: SpeechRecognizer? = null
    private var localVoiceEngine: KeyboardLocalVoiceEngine? = null
    private var localRuntimeActive = false
    private var localRuntimeStartupInProgress = false
    private val localRuntimeStartupTimeoutHandler = Handler(Looper.getMainLooper())
    private var localRuntimeStartupTimeoutTask: Runnable? = null
    private var localRuntimeStartupTimeoutFired = false
    private var listening = false
    private var pauseRequested = false
    private var manualStopRequested = false
    private var activeAndroidFallbackReason: String? = null
    private var latestPartialResult: String = ""

    fun isListening(): Boolean = listening

    fun start() {
        if (listening) {
            cancel()
            return
        }
        if (localRuntimeActive) {
            stopLocalRuntime()
            return
        }
        if (!hasAudioPermission()) {
            recordUnavailable("permission_denied")
            onState("Microphone permission required")
            return
        }
        clearAndroidFallbackTimeout()
        pauseRequested = false
        manualStopRequested = false
        latestPartialResult = ""
        val localStartDecision = tryStartLocalRuntimePath()
        when (localStartDecision.result) {
            LocalRuntimeStartResult.StartedLocal -> return
            LocalRuntimeStartResult.FallbackUnavailable -> {
                onState("Local runtime unavailable")
                return
            }
            LocalRuntimeStartResult.UseAndroidFallback -> Unit
        }
        recordAndroidFallback(
            localStartDecision.lastErrorCode,
            localStartDecision.fallbackReason,
        )
        onState("Using Android speech fallback")
        startAndroidFallback(
            localStartDecision.lastErrorCode,
            localStartDecision.fallbackReason,
        )
    }

    fun stop() {
        if (localRuntimeActive) {
            stopLocalRuntime()
            return
        }
        clearAndroidFallbackTimeout()
        pauseRequested = false
        manualStopRequested = true
        recognizer?.stopListening()
        listening = false
        onState("Processing")
    }

    fun pause() {
        if (localRuntimeActive) {
            stopLocalRuntime()
            onState("Local runtime paused")
            return
        }
        if (!listening) {
            onState("Dictation already paused")
            return
        }
        clearAndroidFallbackTimeout()
        pauseRequested = true
        manualStopRequested = true
        recognizer?.stopListening()
        listening = false
        onState("Dictation paused")
    }

    fun resume() {
        if (localRuntimeActive) {
            onState("Local runtime active")
            return
        }
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
        if (localRuntimeActive) {
            stopLocalRuntime()
        }
        clearAndroidFallbackTimeout()
        pauseRequested = false
        manualStopRequested = false
        latestPartialResult = ""
        recognizer?.cancel()
        listening = false
        destroy()
        onState("Canceled")
    }

    fun destroy() {
        clearAndroidFallbackTimeout()
        localVoiceEngine?.cancel()
        localVoiceEngine = null
        recognizer?.destroy()
        recognizer = null
        activeAndroidFallbackReason = null
    }

    private fun startAndroidFallback(
        lastErrorCode: String,
        fallbackReasonOverride: String? = null,
    ) {
        clearAndroidFallbackTimeout()
        recordAndroidFallback(
            lastErrorCode = lastErrorCode,
            fallbackReasonOverride = fallbackReasonOverride,
        )
        activeAndroidFallbackReason =
            fallbackReasonOverride
                ?.trim()
                ?.ifBlank { null }
                ?: if (lastErrorCode == "none") "missing_pack" else lastErrorCode
        onState("Using Android speech fallback")
        val speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context)
        recognizer = speechRecognizer
        speechRecognizer.setRecognitionListener(
            object : RecognitionListener {
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
                    val didTimeout = localRuntimeStartupTimeoutFired
                    val fallbackReason = activeAndroidFallbackReason
                    listening = false
                    pauseRequested = false
                    manualStopRequested = false
                    localRuntimeStartupTimeoutFired = false
                    clearAndroidFallbackTimeout()
                    destroy()
                    if (didTimeout) {
                        recordAndroidFallback("runtime_timeout", "runtime_timeout")
                        onState("Dictation timeout")
                    } else if (wasManualStop && !wasPaused && fallback.isNotEmpty()) {
                        recordAndroidFallback("none", fallbackReason)
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
                    val fallbackReason = activeAndroidFallbackReason
                    pauseRequested = false
                    manualStopRequested = false
                    val didTimeout = localRuntimeStartupTimeoutFired
                    localRuntimeStartupTimeoutFired = false
                    clearAndroidFallbackTimeout()
                    val matches =
                        results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                            .orEmpty()
                    val best = matches.firstOrNull()?.trim().orEmpty().ifEmpty {
                        latestPartialResult.trim()
                    }
                    destroy()
                    if (didTimeout) {
                        recordAndroidFallback("runtime_timeout", "runtime_timeout")
                        onState("Dictation timeout")
                    } else if (best.isNotEmpty()) {
                        recordAndroidFallback("none", fallbackReason)
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
            },
        )
        speechRecognizer.startListening(
            Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(
                    RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                    RecognizerIntent.LANGUAGE_MODEL_FREE_FORM,
                )
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault().toLanguageTag())
                putExtra(
                    RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS,
                    LOCAL_RUNTIME_STARTUP_TIMEOUT_MS,
                )
                putExtra(
                    RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS,
                    LOCAL_RUNTIME_STARTUP_TIMEOUT_MS,
                )
            },
        )
        startAndroidFallbackTimeout()
    }

    private fun recordAndroidFallback(
        lastErrorCode: String,
        fallbackReasonOverride: String? = null,
    ) {
        localRuntimeActive = false
        val fallbackReason =
            fallbackReasonOverride
                ?.trim()
                ?.ifBlank { null }
                ?: if (lastErrorCode == "none") "missing_pack" else lastErrorCode
        stateStore.updateVoiceRuntimeStatus(
            runtimeMode = "android_fallback",
            languageTag = Locale.getDefault().toLanguageTag(),
            packId = "none",
            engine = "android_speech_recognizer",
            fallbackReason = fallbackReason,
            lastErrorCode = lastErrorCode,
        )
    }

    private fun recordUnavailable(lastErrorCode: String) {
        localRuntimeActive = false
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

    private fun tryStartLocalRuntimePath(): LocalRuntimeStartDecision {
        val languageTag = Locale.getDefault().toLanguageTag()
        val packId = stateStore.voicePackId
        val engine = stateStore.voiceEngine
        val modelArtifactPath = stateStore.voiceModelArtifactPath
        val androidFallbackAvailable = SpeechRecognizer.isRecognitionAvailable(context)
        val loadingStatus =
            KeyboardVoiceRuntimeStatus.normalized(
                runtimeMode = "local",
                languageTag = languageTag,
                packId = packId,
                engine = engine,
                fallbackReason = "none",
                lastErrorCode = "none",
            )
        KeyboardVoiceRuntimeEventQueue.enqueue(
            status = loadingStatus,
            runtimeStateOverride = "local_loading",
            source = "ime_local_runtime",
        )
        onState("Loading local runtime")
        val validation =
            KeyboardLocalRuntimePath.validate(
                packId = packId,
                engine = engine,
                modelArtifactPath = modelArtifactPath,
                androidFallbackAvailable = androidFallbackAvailable,
            )
        if (!validation.canStartLocal) {
            val fallbackEngine =
                if (validation.fallbackRuntimeMode == "android_fallback") {
                    "android_speech_recognizer"
                } else {
                    "unavailable"
                }
            stateStore.updateVoiceRuntimeStatus(
                runtimeMode = validation.fallbackRuntimeMode,
                languageTag = languageTag,
                packId = if (validation.fallbackRuntimeMode == "android_fallback") "none" else packId,
                engine = fallbackEngine,
                fallbackReason = validation.fallbackReason,
                lastErrorCode = validation.errorCode,
            )
            return if (validation.fallbackRuntimeMode == "android_fallback") {
                LocalRuntimeStartDecision(
                    result = LocalRuntimeStartResult.UseAndroidFallback,
                    fallbackReason = validation.fallbackReason,
                    lastErrorCode = validation.errorCode,
                )
            } else {
                LocalRuntimeStartDecision(
                    result = LocalRuntimeStartResult.FallbackUnavailable,
                    fallbackReason = validation.fallbackReason,
                    lastErrorCode = validation.errorCode,
                )
            }
        }
        val localEngine = KeyboardLocalVoiceEngineFactory.create(engine)
        scheduleLocalRuntimeStartupTimeout()
        val engineStartResult =
            localEngine.start(
                config =
                    KeyboardLocalVoiceEngineConfig(
                        languageTag = languageTag,
                        packId = packId,
                        engine = engine,
                        modelArtifactPath = modelArtifactPath,
                    ),
                callbacks =
                    KeyboardLocalVoiceEngineCallbacks(
                        onState = onState,
                        onPartialResult = { partial ->
                            latestPartialResult = partial
                            onState(partial)
                        },
                        onFinalResult = { finalText ->
                            val normalizedFinal = finalText.trim()
                            if (normalizedFinal.isNotEmpty()) {
                                onResult(normalizedFinal)
                                onState("Inserted dictation")
                            }
                        },
                    ),
            )
        if (!engineStartResult.started) {
            clearLocalRuntimeStartupTimeout()
            localEngine.cancel()
            stateStore.updateVoiceRuntimeStatus(
                runtimeMode = if (androidFallbackAvailable) "android_fallback" else "unavailable",
                languageTag = languageTag,
                packId = if (androidFallbackAvailable) "none" else packId,
                engine = if (androidFallbackAvailable) "android_speech_recognizer" else engine,
                fallbackReason = engineStartResult.fallbackReason,
                lastErrorCode = engineStartResult.lastErrorCode,
            )
            return if (androidFallbackAvailable) {
                LocalRuntimeStartDecision(
                    result = LocalRuntimeStartResult.UseAndroidFallback,
                    fallbackReason = engineStartResult.fallbackReason,
                    lastErrorCode = engineStartResult.lastErrorCode,
                )
            } else {
                LocalRuntimeStartDecision(
                    result = LocalRuntimeStartResult.FallbackUnavailable,
                    fallbackReason = engineStartResult.fallbackReason,
                    lastErrorCode = engineStartResult.lastErrorCode,
                )
            }
        }
        clearLocalRuntimeStartupTimeout()
        localVoiceEngine = localEngine
        localRuntimeActive = true
        listening = false
        stateStore.updateVoiceRuntimeStatus(
            runtimeMode = "local",
            languageTag = languageTag,
            packId = packId,
            engine = engine,
            fallbackReason = "none",
            lastErrorCode = "none",
        )
        KeyboardVoiceRuntimeEventQueue.enqueue(
            status = loadingStatus,
            runtimeStateOverride = "local_active",
            source = "ime_local_runtime",
        )
        onState("Local runtime active")
        return LocalRuntimeStartDecision(result = LocalRuntimeStartResult.StartedLocal)
    }

    private fun emitLocalRuntimeTimeoutEvent() {
        val languageTag = Locale.getDefault().toLanguageTag()
        val packId = stateStore.voicePackId
        val engine = stateStore.voiceEngine
        val timeoutStatus =
            KeyboardVoiceRuntimeStatus.normalized(
                runtimeMode = "unavailable",
                languageTag = languageTag,
                packId = packId,
                engine = engine,
                fallbackReason = "runtime_timeout",
                lastErrorCode = "local_runtime_timeout",
            )
        KeyboardVoiceRuntimeEventQueue.enqueue(
            status = timeoutStatus,
            runtimeStateOverride = "runtime_timeout",
            source = "ime_local_runtime",
        )
    }

    private fun stopLocalRuntime() {
        clearLocalRuntimeStartupTimeout()
        localVoiceEngine?.stop()
        localVoiceEngine = null
        localRuntimeActive = false
        stateStore.updateVoiceRuntimeStatus(
            runtimeMode = "unavailable",
            languageTag = Locale.getDefault().toLanguageTag(),
            packId = stateStore.voicePackId,
            engine = stateStore.voiceEngine,
            fallbackReason = "missing_pack",
            lastErrorCode = "local_runtime_stopped",
        )
    }

    private fun scheduleLocalRuntimeStartupTimeout() {
        clearLocalRuntimeStartupTimeout()
        localRuntimeStartupInProgress = true
        val timeoutTask = Runnable {
            if (!localRuntimeStartupInProgress) {
                return@Runnable
            }
            localRuntimeStartupInProgress = false
            localRuntimeStartupTimeoutFired = true
            localRuntimeActive = false
            emitLocalRuntimeTimeoutEvent()
            startAndroidFallback(
                lastErrorCode = "local_runtime_timeout",
                fallbackReasonOverride = "runtime_timeout",
            )
        }
        localRuntimeStartupTimeoutTask = timeoutTask
        localRuntimeStartupTimeoutHandler.postDelayed(
            timeoutTask,
            LOCAL_RUNTIME_STARTUP_TIMEOUT_MS,
        )
    }

    private fun clearLocalRuntimeStartupTimeout() {
        localRuntimeStartupTimeoutTask?.let {
            localRuntimeStartupTimeoutHandler.removeCallbacks(it)
        }
        localRuntimeStartupTimeoutTask = null
        localRuntimeStartupInProgress = false
        localRuntimeStartupTimeoutFired = false
    }

    private fun clearAndroidFallbackTimeout() {
        localRuntimeStartupTimeoutFired = false
        clearLocalRuntimeStartupTimeout()
    }

    private fun startAndroidFallbackTimeout() {
        clearAndroidFallbackTimeout()
        val timeoutTask = Runnable {
            if (localRuntimeStartupTimeoutFired || recognizer == null || !listening) {
                return@Runnable
            }
            localRuntimeStartupTimeoutFired = true
            onState("Dictation timeout")
            recognizer?.stopListening()
        }
        localRuntimeStartupTimeoutTask = timeoutTask
        localRuntimeStartupTimeoutHandler.postDelayed(
            timeoutTask,
            LOCAL_RUNTIME_STARTUP_TIMEOUT_MS,
        )
    }
}
