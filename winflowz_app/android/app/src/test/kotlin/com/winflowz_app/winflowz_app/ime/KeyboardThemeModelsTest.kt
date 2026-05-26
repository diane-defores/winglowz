package com.winflowz_app.winflowz_app.ime

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class KeyboardThemeModelsTest {
    @Test
    fun `falls back from corrupt json`() {
        val config = KeyboardThemeConfig.fromJson("{not-json")

        assertEquals("system", config.presetId)
        assertEquals("none", config.pressEffect)
    }

    @Test
    fun `clamps effect config and unknown effect`() {
        val config =
            KeyboardThemeConfig.fromMap(
                mapOf(
                    "pressEffect" to "expensive",
                    "effectIntensity" to 2.4,
                    "pressHighlightDurationMs" to 3000,
                    "cornerTextOpacity" to 1.0,
                    "effectDurationMs" to 2000,
                    "gradientStyle" to "spiral",
                    "effectEasing" to "bounce",
                    "borderWidth" to 99,
                    "keyRadius" to 99,
                    "shadowBlur" to 99,
                    "keyboardOpacity" to -1,
                ),
            )

        assertEquals("none", config.pressEffect)
        assertEquals(1f, config.effectIntensity)
        assertEquals(1200, config.pressHighlightDurationMs)
        assertEquals(0.85f, config.cornerTextOpacity)
        assertEquals(600, config.effectDurationMs)
        assertEquals("linear", config.gradientStyle)
        assertEquals("easeOut", config.effectEasing)
        assertEquals(4f, config.borderWidth)
        assertEquals(24f, config.keyRadius)
        assertEquals(18f, config.shadowBlur)
        assertEquals(0.25f, config.keyboardOpacity)
    }

    @Test
    fun `round trips advanced theme fields`() {
        val config =
            KeyboardThemeConfig(
                presetId = "midnight_aurora",
                useGradient = true,
                gradientStyle = "radial",
                borderWidth = 1.5f,
                keyRadius = 14f,
                keyHorizontalGap = 10f,
                rowVerticalGap = 5f,
                shadowBlur = 9f,
                shadowOffsetY = 2f,
                pressHighlightDurationMs = 850,
                cornerTextOpacity = 0.5f,
                keyboardOpacity = 0.55f,
                effectEasing = "spring",
            )

        val parsed = KeyboardThemeConfig.fromJson(config.toJson())

        assertEquals("radial", parsed.gradientStyle)
        assertEquals(1.5f, parsed.borderWidth)
        assertEquals(14f, parsed.keyRadius)
        assertEquals(12f, parsed.keyHorizontalGap)
        assertEquals(4f, parsed.rowVerticalGap)
        assertEquals(9f, parsed.shadowBlur)
        assertEquals(2f, parsed.shadowOffsetY)
        assertEquals(850, parsed.pressHighlightDurationMs)
        assertEquals(0.5f, parsed.cornerTextOpacity)
        assertEquals(0.55f, parsed.keyboardOpacity)
        assertEquals("spring", parsed.effectEasing)
    }

    @Test
    fun `ignores legacy key width scale`() {
        val config = KeyboardThemeConfig.fromMap(mapOf("keyWidthScale" to 0.75))

        assertEquals(1f, config.keyWidthScale)
        assertFalse(config.toMap().containsKey("keyWidthScale"))
    }

    @Test
    fun `image flag requires a path`() {
        val config = KeyboardThemeConfig.fromMap(mapOf("useImage" to true))

        assertFalse(config.useImage)
    }

    @Test
    fun `private mode disables press effects`() {
        val config = KeyboardThemeConfig(pressEffect = "fireworksLite")

        assertEquals("none", KeyboardPressEffectPolicy.resolve(config, privateMode = true).effect)
        assertEquals("fireworksLite", KeyboardPressEffectPolicy.resolve(config, privateMode = false).effect)
    }

    @Test
    fun `press effects cap active queue`() {
        val effects = KeyboardPressEffects(density = 1f, clock = { 100L })
        repeat(10) { index ->
            assertTrue(
                effects.trigger(
                    keyId = "key-$index",
                    rect = android.graphics.RectF(0f, 0f, 40f, 40f),
                    spec =
                        KeyboardPressEffectSpec(
                            "confettiLite",
                            durationMs = 100,
                            intensity = 1f,
                            easing = "easeOut",
                        ),
                ),
            )
        }

        assertEquals(8, effects.activeCountForTest())
    }
}
