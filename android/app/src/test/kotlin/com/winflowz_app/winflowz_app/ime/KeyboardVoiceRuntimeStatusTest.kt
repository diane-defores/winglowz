package com.winflowz_app.winflowz_app.ime

import org.junit.Assert.assertEquals
import org.junit.Test

class KeyboardVoiceRuntimeStatusTest {
    @Test
    fun `voice runtime status exposes explicit diagnostic map`() {
        val status =
            KeyboardVoiceRuntimeStatus.normalized(
                runtimeMode = "android_fallback",
                languageTag = "fr-FR",
                packId = "none",
                engine = "android_speech_recognizer",
                fallbackReason = "missing_pack",
                lastErrorCode = "none",
            ).toMap()

        assertEquals("android_fallback", status["voiceRuntimeMode"])
        assertEquals("fr-FR", status["voiceLanguageTag"])
        assertEquals("none", status["voicePackId"])
        assertEquals("android_speech_recognizer", status["voiceEngine"])
        assertEquals("missing_pack", status["voiceFallbackReason"])
        assertEquals("none", status["voiceLastErrorCode"])
    }

    @Test
    fun `voice runtime status normalizes unsupported runtime`() {
        val status =
            KeyboardVoiceRuntimeStatus.normalized(
                runtimeMode = "secret_cloud",
                languageTag = "",
                packId = "",
                engine = "",
                fallbackReason = "",
                lastErrorCode = "",
            )

        assertEquals("unavailable", status.runtimeMode)
        assertEquals("und", status.languageTag)
        assertEquals("none", status.packId)
        assertEquals("unavailable", status.engine)
        assertEquals("unsupported_language", status.fallbackReason)
        assertEquals("none", status.lastErrorCode)
    }
}
