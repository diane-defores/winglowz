package com.winflowz_app.winflowz_app.ime

object KeyboardVoiceRuntimeEventQueue {
    private const val maxEvents = 100
    private val events = ArrayDeque<Map<String, Any>>()

    @Synchronized
    fun enqueue(
        status: KeyboardVoiceRuntimeStatus,
        source: String = "ime_voice_controller",
        capturedAtEpochMillis: Long = System.currentTimeMillis(),
    ) {
        while (events.size >= maxEvents) {
            events.removeFirst()
        }
        events.addLast(
            mapOf(
                "runtime_state" to status.runtimeMode,
                "fallback_reason" to status.fallbackReason,
                "active_pack_id" to status.packId,
                "last_error_code" to status.lastErrorCode,
                "language_tag" to status.languageTag,
                "engine" to status.engine,
                "source" to source.take(48).ifBlank { "ime_voice_controller" },
                "captured_at_epoch_millis" to capturedAtEpochMillis,
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
}
