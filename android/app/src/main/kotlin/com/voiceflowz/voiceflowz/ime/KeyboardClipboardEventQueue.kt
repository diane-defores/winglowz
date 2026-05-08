package com.voiceflowz.voiceflowz.ime

import android.content.Context
import android.provider.Settings

object KeyboardClipboardEventQueue {
    private const val maxEvents = 50
    private val events = ArrayDeque<Map<String, Any>>()

    @Synchronized
    fun enqueue(
        context: Context,
        content: String,
        source: String,
        action: String,
        capturedAtEpochMillis: Long = System.currentTimeMillis(),
    ) {
        val normalized = content.trim()
        if (normalized.isEmpty()) {
            return
        }
        while (events.size >= maxEvents) {
            events.removeFirst()
        }
        events.addLast(
            mapOf(
                "content" to normalized,
                "source" to source,
                "deviceId" to deviceId(context),
                "capturedAtEpochMillis" to capturedAtEpochMillis,
                "sourceMetadata" to mapOf(
                    "surface" to "keyboard",
                    "action" to action,
                ),
            ),
        )
    }

    @Synchronized
    fun drain(): List<Map<String, Any>> {
        val drained = events.toList()
        events.clear()
        return drained
    }

    @Synchronized
    fun size(): Int = events.size

    private fun deviceId(context: Context): String {
        val androidId =
            Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ANDROID_ID,
            )
                ?.takeIf { it.isNotBlank() }
                ?: "unknown"
        return "android:$androidId"
    }
}
