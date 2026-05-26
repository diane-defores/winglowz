package com.winflowz_app.winflowz_app.ime

import android.graphics.Color
import org.json.JSONObject
import kotlin.math.roundToInt

data class KeyboardThemePreset(
    val id: String,
    val name: String,
)

object KeyboardThemePresets {
    const val SYSTEM = "system"
    const val WINFLOWZ = "winflowz"
    const val WINFLOWZ_LIGHT = "winflowz_light"
    const val WINFLOWZ_DARK = "winflowz_dark"
    const val NEON_TERMINAL = "neon_terminal"
    const val GLASS_MINT = "glass_mint"
    const val SUNSET_GRADIENT = "sunset_gradient"
    const val MIDNIGHT_AURORA = "midnight_aurora"
    const val PAPER_INK = "paper_ink"
    const val PIXEL_CANDY = "pixel_candy"
    const val MINIMAL_CONTRAST = "minimal_contrast"

    val all =
        listOf(
            KeyboardThemePreset(SYSTEM, "System"),
            KeyboardThemePreset(WINFLOWZ, "WinFlowz"),
            KeyboardThemePreset(NEON_TERMINAL, "Neon"),
            KeyboardThemePreset(GLASS_MINT, "Glass"),
            KeyboardThemePreset(SUNSET_GRADIENT, "Sunset"),
            KeyboardThemePreset(MIDNIGHT_AURORA, "Aurora"),
            KeyboardThemePreset(PAPER_INK, "Paper"),
            KeyboardThemePreset(PIXEL_CANDY, "Candy"),
            KeyboardThemePreset(MINIMAL_CONTRAST, "Contrast"),
        )

    fun labelFor(presetId: String): String =
        all.firstOrNull { it.id == presetId }?.name ?: "Theme"

    fun configFor(presetId: String, dark: Boolean = false): KeyboardThemeConfig {
        val normalizedPresetId =
            when (presetId) {
                WINFLOWZ_LIGHT, WINFLOWZ_DARK -> WINFLOWZ
                else -> presetId
            }
        val base = KeyboardThemeConfig(presetId = normalizedPresetId, useImage = false, backgroundImagePath = null)
        if (dark) {
            return darkConfigFor(normalizedPresetId, base)
        }
        return when (normalizedPresetId) {
            SYSTEM -> KeyboardThemeConfig()
            WINFLOWZ -> base
            NEON_TERMINAL ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#07120F"),
                    backgroundEndColor = Color.parseColor("#12241E"),
                    useGradient = true,
                    keyColor = Color.parseColor("#0D1C18"),
                    specialKeyColor = Color.parseColor("#143127"),
                    activeKeyColor = Color.parseColor("#00F5A0"),
                    pressedKeyColor = Color.parseColor("#1D4D3C"),
                    textColor = Color.parseColor("#E9FFF6"),
                    cornerTextColor = Color.parseColor("#7CFFD3"),
                    statusTextColor = Color.parseColor("#B8FFE8"),
                    borderColor = Color.parseColor("#00A76E"),
                    shadowColor = 0x8800F5A0.toInt(),
                    shadowBlur = 7f,
                    pressEffect = "glow",
                )
            GLASS_MINT ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#DFFAF0"),
                    backgroundEndColor = Color.parseColor("#BEEBD9"),
                    useGradient = true,
                    keyColor = 0xCCFFFFFF.toInt(),
                    specialKeyColor = 0xBFE5FFF6.toInt(),
                    activeKeyColor = Color.parseColor("#168765"),
                    pressedKeyColor = Color.parseColor("#D0EEE3"),
                    textColor = Color.parseColor("#17342B"),
                    cornerTextColor = Color.parseColor("#4F7C6C"),
                    statusTextColor = Color.parseColor("#254C3F"),
                    borderColor = 0x80FFFFFF.toInt(),
                    keyRadius = 14f,
                    shadowBlur = 9f,
                )
            SUNSET_GRADIENT ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#FFC371"),
                    backgroundEndColor = Color.parseColor("#FF5F6D"),
                    useGradient = true,
                    keyColor = Color.parseColor("#FFF8EB"),
                    specialKeyColor = Color.parseColor("#FFDEB8"),
                    activeKeyColor = Color.parseColor("#8A1F3D"),
                    pressedKeyColor = Color.parseColor("#FFCFB0"),
                    textColor = Color.parseColor("#3B1820"),
                    cornerTextColor = Color.parseColor("#754252"),
                    statusTextColor = Color.parseColor("#471D28"),
                    borderColor = 0x33FFFFFF,
                    pressEffect = "pulse",
                )
            MIDNIGHT_AURORA ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#07111F"),
                    backgroundEndColor = Color.parseColor("#204B6D"),
                    useGradient = true,
                    gradientStyle = "radial",
                    keyColor = Color.parseColor("#111C2E"),
                    specialKeyColor = Color.parseColor("#1E2E48"),
                    activeKeyColor = Color.parseColor("#64D2FF"),
                    pressedKeyColor = Color.parseColor("#2D4667"),
                    textColor = Color.parseColor("#EAF7FF"),
                    cornerTextColor = Color.parseColor("#A7DFFF"),
                    statusTextColor = Color.parseColor("#D7F0FF"),
                    borderColor = Color.parseColor("#3B6D8D"),
                    shadowColor = 0x995BD6FF.toInt(),
                    pressEffect = "ripple",
                )
            PAPER_INK ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#F5EFE2"),
                    backgroundEndColor = Color.parseColor("#F5EFE2"),
                    keyColor = Color.parseColor("#FFFCF4"),
                    specialKeyColor = Color.parseColor("#E9DDC9"),
                    activeKeyColor = Color.parseColor("#2D2A26"),
                    pressedKeyColor = Color.parseColor("#E1D2BB"),
                    textColor = Color.parseColor("#1D1A16"),
                    cornerTextColor = Color.parseColor("#6A5D4A"),
                    statusTextColor = Color.parseColor("#40382D"),
                    borderColor = Color.parseColor("#B9A98F"),
                    shadowColor = 0x33000000,
                    shadowBlur = 3f,
                )
            PIXEL_CANDY ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#FFE0F1"),
                    backgroundEndColor = Color.parseColor("#D4F1FF"),
                    useGradient = true,
                    keyColor = Color.WHITE,
                    specialKeyColor = Color.parseColor("#FFC6E2"),
                    activeKeyColor = Color.parseColor("#005A9C"),
                    pressedKeyColor = Color.parseColor("#FFD166"),
                    textColor = Color.parseColor("#15213A"),
                    cornerTextColor = Color.parseColor("#37527A"),
                    statusTextColor = Color.parseColor("#1A3150"),
                    borderColor = Color.parseColor("#15213A"),
                    borderWidth = 1.5f,
                    keyRadius = 5f,
                    shadowBlur = 1f,
                    pressEffect = "confettiLite",
                )
            MINIMAL_CONTRAST ->
                base.copy(
                    backgroundStartColor = Color.BLACK,
                    backgroundEndColor = Color.BLACK,
                    keyColor = Color.WHITE,
                    specialKeyColor = Color.parseColor("#E8E8E8"),
                    activeKeyColor = Color.YELLOW,
                    pressedKeyColor = Color.parseColor("#CFCFCF"),
                    textColor = Color.BLACK,
                    cornerTextColor = Color.parseColor("#303030"),
                    statusTextColor = Color.WHITE,
                    borderColor = Color.WHITE,
                    borderWidth = 1f,
                    shadowBlur = 0f,
                )
            else -> KeyboardThemeConfig()
        }
    }

    private fun darkConfigFor(
        presetId: String,
        base: KeyboardThemeConfig,
    ): KeyboardThemeConfig =
        when (presetId) {
            SYSTEM -> KeyboardThemeConfig()
            WINFLOWZ ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#121815"),
                    backgroundEndColor = Color.parseColor("#121815"),
                    keyColor = Color.parseColor("#232B27"),
                    specialKeyColor = Color.parseColor("#2E3833"),
                    activeKeyColor = Color.parseColor("#36B384"),
                    pressedKeyColor = Color.parseColor("#43524B"),
                    textColor = Color.parseColor("#EBF2EE"),
                    cornerTextColor = Color.parseColor("#B7C8BF"),
                    statusTextColor = Color.parseColor("#CCD9D2"),
                    borderColor = Color.parseColor("#516158"),
                    shadowColor = 0x66000000,
                )
            NEON_TERMINAL -> configFor(NEON_TERMINAL)
            GLASS_MINT ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#10251F"),
                    backgroundEndColor = Color.parseColor("#1E4A3C"),
                    useGradient = true,
                    keyColor = 0xCC1A2E28.toInt(),
                    specialKeyColor = 0xCC24463B.toInt(),
                    activeKeyColor = Color.parseColor("#7FF0C8"),
                    pressedKeyColor = Color.parseColor("#315F51"),
                    textColor = Color.parseColor("#E8FFF7"),
                    cornerTextColor = Color.parseColor("#A7D8C8"),
                    statusTextColor = Color.parseColor("#C8F5E6"),
                    borderColor = 0x6635E0AC,
                    keyRadius = 14f,
                    shadowColor = 0x66000000,
                    shadowBlur = 9f,
                )
            SUNSET_GRADIENT ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#351422"),
                    backgroundEndColor = Color.parseColor("#7A2636"),
                    useGradient = true,
                    keyColor = Color.parseColor("#2C1B22"),
                    specialKeyColor = Color.parseColor("#4A2630"),
                    activeKeyColor = Color.parseColor("#FFB36E"),
                    pressedKeyColor = Color.parseColor("#6A3542"),
                    textColor = Color.parseColor("#FFF1E6"),
                    cornerTextColor = Color.parseColor("#FFC9B5"),
                    statusTextColor = Color.parseColor("#FFE0D2"),
                    borderColor = 0x44FFFFFF,
                    shadowColor = 0x66000000,
                    pressEffect = "pulse",
                )
            MIDNIGHT_AURORA -> configFor(MIDNIGHT_AURORA)
            PAPER_INK ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#181512"),
                    backgroundEndColor = Color.parseColor("#241F1A"),
                    keyColor = Color.parseColor("#2C2721"),
                    specialKeyColor = Color.parseColor("#3A332A"),
                    activeKeyColor = Color.parseColor("#E9D7B8"),
                    pressedKeyColor = Color.parseColor("#4A4034"),
                    textColor = Color.parseColor("#F7EFE3"),
                    cornerTextColor = Color.parseColor("#C9B99F"),
                    statusTextColor = Color.parseColor("#E6D8C1"),
                    borderColor = Color.parseColor("#756850"),
                    shadowColor = 0x66000000,
                    shadowBlur = 3f,
                )
            PIXEL_CANDY ->
                base.copy(
                    backgroundStartColor = Color.parseColor("#27172A"),
                    backgroundEndColor = Color.parseColor("#102840"),
                    useGradient = true,
                    keyColor = Color.parseColor("#23172F"),
                    specialKeyColor = Color.parseColor("#472047"),
                    activeKeyColor = Color.parseColor("#66D9FF"),
                    pressedKeyColor = Color.parseColor("#7A4B12"),
                    textColor = Color.parseColor("#FFF4FF"),
                    cornerTextColor = Color.parseColor("#FFBFE2"),
                    statusTextColor = Color.parseColor("#D4F1FF"),
                    borderColor = Color.parseColor("#FFBFE2"),
                    borderWidth = 1.5f,
                    keyRadius = 5f,
                    shadowColor = 0x66000000,
                    shadowBlur = 1f,
                    pressEffect = "confettiLite",
                )
            MINIMAL_CONTRAST ->
                base.copy(
                    backgroundStartColor = Color.BLACK,
                    backgroundEndColor = Color.BLACK,
                    keyColor = Color.parseColor("#111111"),
                    specialKeyColor = Color.parseColor("#222222"),
                    activeKeyColor = Color.YELLOW,
                    pressedKeyColor = Color.parseColor("#333333"),
                    textColor = Color.WHITE,
                    cornerTextColor = Color.parseColor("#E0E0E0"),
                    statusTextColor = Color.WHITE,
                    borderColor = Color.WHITE,
                    borderWidth = 1f,
                    shadowBlur = 0f,
                )
            else -> KeyboardThemeConfig()
        }
}

data class KeyboardThemeConfig(
    val version: Int = 1,
    val presetId: String = "system",
    val backgroundStartColor: Int = Color.parseColor("#EEF1EE"),
    val backgroundEndColor: Int = Color.parseColor("#EEF1EE"),
    val useGradient: Boolean = false,
    val gradientStyle: String = "linear",
    val useImage: Boolean = false,
    val backgroundImagePath: String? = null,
    val keyboardOpacity: Float = 1f,
    val keyColor: Int = Color.WHITE,
    val specialKeyColor: Int = Color.parseColor("#E0E6E3"),
    val activeKeyColor: Int = Color.parseColor("#17795D"),
    val pressedKeyColor: Int = Color.parseColor("#CADAD3"),
    val pressHighlightDurationMs: Int = 170,
    val textColor: Int = Color.parseColor("#1D2320"),
    val cornerTextColor: Int = Color.parseColor("#5C6762"),
    val cornerTextOpacity: Float = 0.85f,
    val statusTextColor: Int = Color.parseColor("#333D38"),
    val borderColor: Int = Color.TRANSPARENT,
    val borderWidth: Float = 0f,
    val keyRadius: Float = 8f,
    val keyHorizontalGap: Float = 4f,
    val rowVerticalGap: Float = 4f,
    val keyWidthScale: Float = 1f,
    val shadowColor: Int = 0x33000000,
    val shadowBlur: Float = 4f,
    val shadowOffsetY: Float = 1f,
    val pressEffect: String = "none",
    val effectIntensity: Float = 0.35f,
    val effectDurationMs: Int = 170,
    val effectEasing: String = "easeOut",
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "version" to version,
            "presetId" to presetId,
            "backgroundStartColor" to backgroundStartColor,
            "backgroundEndColor" to backgroundEndColor,
            "useGradient" to useGradient,
            "gradientStyle" to gradientStyle,
            "useImage" to useImage,
            "backgroundImagePath" to backgroundImagePath,
            "keyboardOpacity" to keyboardOpacity,
            "keyColor" to keyColor,
            "specialKeyColor" to specialKeyColor,
            "activeKeyColor" to activeKeyColor,
            "pressedKeyColor" to pressedKeyColor,
            "pressHighlightDurationMs" to pressHighlightDurationMs,
            "textColor" to textColor,
            "cornerTextColor" to cornerTextColor,
            "cornerTextOpacity" to cornerTextOpacity,
            "statusTextColor" to statusTextColor,
            "borderColor" to borderColor,
            "borderWidth" to borderWidth,
            "keyRadius" to keyRadius,
            "keyHorizontalGap" to keyHorizontalGap,
            "rowVerticalGap" to rowVerticalGap,
            "shadowColor" to shadowColor,
            "shadowBlur" to shadowBlur,
            "shadowOffsetY" to shadowOffsetY,
            "pressEffect" to pressEffect,
            "effectIntensity" to effectIntensity,
            "effectDurationMs" to effectDurationMs,
            "effectEasing" to effectEasing,
        )
    }

    fun toJson(): String = JSONObject(toMap()).toString()

    fun validated(): KeyboardThemeConfig {
        val normalizedPath = backgroundImagePath?.trim().orEmpty().ifBlank { null }
        val normalizedPresetId =
            when (presetId) {
                KeyboardThemePresets.WINFLOWZ_LIGHT, KeyboardThemePresets.WINFLOWZ_DARK -> KeyboardThemePresets.WINFLOWZ
                else -> presetId
            }
        return copy(
            version = version.coerceAtLeast(1),
            presetId = normalizedPresetId,
            gradientStyle = if (gradientStyle in allowedGradientStyles) gradientStyle else "linear",
            borderWidth = borderWidth.coerceIn(0f, 4f),
            keyRadius = keyRadius.coerceIn(0f, 24f),
            keyHorizontalGap = keyHorizontalGap.snapToImeGrid(max = 16f),
            rowVerticalGap = rowVerticalGap.snapToImeGrid(max = 16f),
            keyWidthScale = 1f,
            keyboardOpacity = keyboardOpacity.coerceIn(KEYBOARD_OPACITY_MIN, 1f),
            shadowBlur = shadowBlur.coerceIn(0f, 18f),
            shadowOffsetY = shadowOffsetY.coerceIn(-4f, 10f),
            effectIntensity = effectIntensity.coerceIn(0f, 1f),
            pressHighlightDurationMs = pressHighlightDurationMs.coerceIn(0, 1200),
            cornerTextOpacity = cornerTextOpacity.coerceIn(0f, 0.85f),
            effectDurationMs = effectDurationMs.coerceIn(80, 600),
            pressEffect = if (pressEffect in allowedEffects) pressEffect else "none",
            effectEasing = if (effectEasing in allowedEasings) effectEasing else "easeOut",
            useImage = useImage && normalizedPath != null,
            backgroundImagePath = normalizedPath,
        )
    }

    companion object {
        private const val KEYBOARD_OPACITY_MIN = 0.25f
        private val allowedEffects =
            setOf("none", "scale", "pulse", "shake", "ripple", "glow", "confettiLite", "fireworksLite")
        private val allowedGradientStyles = setOf("linear", "radial")
        private val allowedEasings = setOf("easeOut", "linear", "spring")

        fun fromJson(raw: String?): KeyboardThemeConfig {
            if (raw.isNullOrBlank()) {
                return KeyboardThemeConfig()
            }
            return runCatching {
                val json = JSONObject(raw)
                fromMap(
                    mapOf(
                        "version" to json.optInt("version", 1),
                        "presetId" to json.optString("presetId", "system"),
                        "backgroundStartColor" to json.optInt("backgroundStartColor", Color.parseColor("#EEF1EE")),
                        "backgroundEndColor" to json.optInt("backgroundEndColor", Color.parseColor("#EEF1EE")),
                        "useGradient" to json.optBoolean("useGradient", false),
                        "gradientStyle" to json.optString("gradientStyle", "linear"),
                        "useImage" to json.optBoolean("useImage", false),
                        "backgroundImagePath" to json.optString("backgroundImagePath", ""),
                        "keyboardOpacity" to json.optDouble("keyboardOpacity", 1.0),
                        "keyColor" to json.optInt("keyColor", Color.WHITE),
                        "specialKeyColor" to json.optInt("specialKeyColor", Color.parseColor("#E0E6E3")),
                        "activeKeyColor" to json.optInt("activeKeyColor", Color.parseColor("#17795D")),
                        "pressedKeyColor" to json.optInt("pressedKeyColor", Color.parseColor("#CADAD3")),
                        "pressHighlightDurationMs" to json.optInt("pressHighlightDurationMs", 170),
                        "textColor" to json.optInt("textColor", Color.parseColor("#1D2320")),
                        "cornerTextColor" to json.optInt("cornerTextColor", Color.parseColor("#5C6762")),
                        "cornerTextOpacity" to json.optDouble("cornerTextOpacity", 0.85),
                        "statusTextColor" to json.optInt("statusTextColor", Color.parseColor("#333D38")),
                        "borderColor" to json.optInt("borderColor", Color.TRANSPARENT),
                        "borderWidth" to json.optDouble("borderWidth", 0.0),
                        "keyRadius" to json.optDouble("keyRadius", 8.0),
                        "keyHorizontalGap" to json.optDouble("keyHorizontalGap", 4.0),
                        "rowVerticalGap" to json.optDouble("rowVerticalGap", 4.0),
                        "shadowColor" to json.optInt("shadowColor", 0x33000000),
                        "shadowBlur" to json.optDouble("shadowBlur", 4.0),
                        "shadowOffsetY" to json.optDouble("shadowOffsetY", 1.0),
                        "pressEffect" to json.optString("pressEffect", "none"),
                        "effectIntensity" to json.optDouble("effectIntensity", 0.35),
                        "effectDurationMs" to json.optInt("effectDurationMs", 170),
                        "effectEasing" to json.optString("effectEasing", "easeOut"),
                    ),
                )
            }.getOrElse { KeyboardThemeConfig() }
        }

        fun fromMap(raw: Map<*, *>): KeyboardThemeConfig {
            val config =
                KeyboardThemeConfig(
                    version = (raw["version"] as? Number)?.toInt() ?: 1,
                    presetId = (raw["presetId"] as? String)?.ifBlank { "system" } ?: "system",
                    backgroundStartColor = (raw["backgroundStartColor"] as? Number)?.toInt() ?: Color.parseColor("#EEF1EE"),
                    backgroundEndColor = (raw["backgroundEndColor"] as? Number)?.toInt() ?: Color.parseColor("#EEF1EE"),
                    useGradient = raw["useGradient"] as? Boolean ?: false,
                    gradientStyle = (raw["gradientStyle"] as? String)?.ifBlank { "linear" } ?: "linear",
                    useImage = raw["useImage"] as? Boolean ?: false,
                    backgroundImagePath = (raw["backgroundImagePath"] as? String)?.ifBlank { null },
                    keyboardOpacity = (raw["keyboardOpacity"] as? Number)?.toFloat() ?: 1f,
                    keyColor = (raw["keyColor"] as? Number)?.toInt() ?: Color.WHITE,
                    specialKeyColor = (raw["specialKeyColor"] as? Number)?.toInt() ?: Color.parseColor("#E0E6E3"),
                    activeKeyColor = (raw["activeKeyColor"] as? Number)?.toInt() ?: Color.parseColor("#17795D"),
                    pressedKeyColor = (raw["pressedKeyColor"] as? Number)?.toInt() ?: Color.parseColor("#CADAD3"),
                    pressHighlightDurationMs = (raw["pressHighlightDurationMs"] as? Number)?.toInt() ?: 170,
                    textColor = (raw["textColor"] as? Number)?.toInt() ?: Color.parseColor("#1D2320"),
                    cornerTextColor = (raw["cornerTextColor"] as? Number)?.toInt() ?: Color.parseColor("#5C6762"),
                    cornerTextOpacity = (raw["cornerTextOpacity"] as? Number)?.toFloat() ?: 0.85f,
                    statusTextColor = (raw["statusTextColor"] as? Number)?.toInt() ?: Color.parseColor("#333D38"),
                    borderColor = (raw["borderColor"] as? Number)?.toInt() ?: Color.TRANSPARENT,
                    borderWidth = (raw["borderWidth"] as? Number)?.toFloat() ?: 0f,
                    keyRadius = (raw["keyRadius"] as? Number)?.toFloat() ?: 8f,
                    keyHorizontalGap = (raw["keyHorizontalGap"] as? Number)?.toFloat() ?: 4f,
                    rowVerticalGap = (raw["rowVerticalGap"] as? Number)?.toFloat() ?: 4f,
                    keyWidthScale = 1f,
                    shadowColor = (raw["shadowColor"] as? Number)?.toInt() ?: 0x33000000,
                    shadowBlur = (raw["shadowBlur"] as? Number)?.toFloat() ?: 4f,
                    shadowOffsetY = (raw["shadowOffsetY"] as? Number)?.toFloat() ?: 1f,
                    pressEffect = (raw["pressEffect"] as? String)?.ifBlank { "none" } ?: "none",
                    effectIntensity = (raw["effectIntensity"] as? Number)?.toFloat() ?: 0.35f,
                    effectDurationMs = (raw["effectDurationMs"] as? Number)?.toInt() ?: 170,
                    effectEasing = (raw["effectEasing"] as? String)?.ifBlank { "easeOut" } ?: "easeOut",
                )
            return config.validated()
        }

        private fun Float.snapToImeGrid(max: Float): Float {
            val clamped = coerceIn(0f, max)
            return (clamped / 4f).roundToInt() * 4f
        }
    }
}
