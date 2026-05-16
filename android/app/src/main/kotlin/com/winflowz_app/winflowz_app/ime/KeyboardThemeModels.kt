package com.winflowz_app.winflowz_app.ime

import android.graphics.Color
import org.json.JSONObject

data class KeyboardThemeConfig(
    val version: Int = 1,
    val presetId: String = "system",
    val backgroundStartColor: Int = Color.parseColor("#EEF1EE"),
    val backgroundEndColor: Int = Color.parseColor("#EEF1EE"),
    val useGradient: Boolean = false,
    val gradientStyle: String = "linear",
    val useImage: Boolean = false,
    val backgroundImagePath: String? = null,
    val keyColor: Int = Color.WHITE,
    val specialKeyColor: Int = Color.parseColor("#E0E6E3"),
    val activeKeyColor: Int = Color.parseColor("#17795D"),
    val pressedKeyColor: Int = Color.parseColor("#CADAD3"),
    val textColor: Int = Color.parseColor("#1D2320"),
    val cornerTextColor: Int = Color.parseColor("#5C6762"),
    val statusTextColor: Int = Color.parseColor("#333D38"),
    val borderColor: Int = Color.TRANSPARENT,
    val borderWidth: Float = 0f,
    val keyRadius: Float = 8f,
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
            "keyColor" to keyColor,
            "specialKeyColor" to specialKeyColor,
            "activeKeyColor" to activeKeyColor,
            "pressedKeyColor" to pressedKeyColor,
            "textColor" to textColor,
            "cornerTextColor" to cornerTextColor,
            "statusTextColor" to statusTextColor,
            "borderColor" to borderColor,
            "borderWidth" to borderWidth,
            "keyRadius" to keyRadius,
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
        return copy(
            version = version.coerceAtLeast(1),
            gradientStyle = if (gradientStyle in allowedGradientStyles) gradientStyle else "linear",
            borderWidth = borderWidth.coerceIn(0f, 4f),
            keyRadius = keyRadius.coerceIn(0f, 24f),
            shadowBlur = shadowBlur.coerceIn(0f, 18f),
            shadowOffsetY = shadowOffsetY.coerceIn(-4f, 10f),
            effectIntensity = effectIntensity.coerceIn(0f, 1f),
            effectDurationMs = effectDurationMs.coerceIn(80, 600),
            pressEffect = if (pressEffect in allowedEffects) pressEffect else "none",
            effectEasing = if (effectEasing in allowedEasings) effectEasing else "easeOut",
            useImage = useImage && normalizedPath != null,
            backgroundImagePath = normalizedPath,
        )
    }

    companion object {
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
                        "keyColor" to json.optInt("keyColor", Color.WHITE),
                        "specialKeyColor" to json.optInt("specialKeyColor", Color.parseColor("#E0E6E3")),
                        "activeKeyColor" to json.optInt("activeKeyColor", Color.parseColor("#17795D")),
                        "pressedKeyColor" to json.optInt("pressedKeyColor", Color.parseColor("#CADAD3")),
                        "textColor" to json.optInt("textColor", Color.parseColor("#1D2320")),
                        "cornerTextColor" to json.optInt("cornerTextColor", Color.parseColor("#5C6762")),
                        "statusTextColor" to json.optInt("statusTextColor", Color.parseColor("#333D38")),
                        "borderColor" to json.optInt("borderColor", Color.TRANSPARENT),
                        "borderWidth" to json.optDouble("borderWidth", 0.0),
                        "keyRadius" to json.optDouble("keyRadius", 8.0),
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
                    keyColor = (raw["keyColor"] as? Number)?.toInt() ?: Color.WHITE,
                    specialKeyColor = (raw["specialKeyColor"] as? Number)?.toInt() ?: Color.parseColor("#E0E6E3"),
                    activeKeyColor = (raw["activeKeyColor"] as? Number)?.toInt() ?: Color.parseColor("#17795D"),
                    pressedKeyColor = (raw["pressedKeyColor"] as? Number)?.toInt() ?: Color.parseColor("#CADAD3"),
                    textColor = (raw["textColor"] as? Number)?.toInt() ?: Color.parseColor("#1D2320"),
                    cornerTextColor = (raw["cornerTextColor"] as? Number)?.toInt() ?: Color.parseColor("#5C6762"),
                    statusTextColor = (raw["statusTextColor"] as? Number)?.toInt() ?: Color.parseColor("#333D38"),
                    borderColor = (raw["borderColor"] as? Number)?.toInt() ?: Color.TRANSPARENT,
                    borderWidth = (raw["borderWidth"] as? Number)?.toFloat() ?: 0f,
                    keyRadius = (raw["keyRadius"] as? Number)?.toFloat() ?: 8f,
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
    }
}
