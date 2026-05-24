package com.winflowz_app.winflowz_app.ime

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.sin

data class KeyboardPressEffectSpec(
    val effect: String,
    val durationMs: Int,
    val intensity: Float,
    val easing: String,
)

object KeyboardPressEffectPolicy {
    private val allowedEffects =
        setOf("none", "scale", "pulse", "shake", "ripple", "glow", "confettiLite", "fireworksLite")

    fun resolve(config: KeyboardThemeConfig, privateMode: Boolean): KeyboardPressEffectSpec {
        val effect =
            if (privateMode || config.pressEffect !in allowedEffects) {
                "none"
            } else {
                config.pressEffect
            }
        return KeyboardPressEffectSpec(
            effect = effect,
            durationMs = config.effectDurationMs.coerceIn(80, 600),
            intensity = config.effectIntensity.coerceIn(0f, 1f),
            easing = config.effectEasing,
        )
    }
}

class KeyboardPressEffects(
    private val density: Float,
    private val clock: () -> Long,
) {
    private data class Particle(
        val angle: Float,
        val speed: Float,
        val color: Int,
    )

    private data class ActiveEffect(
        val keyId: String,
        val rect: RectF,
        val spec: KeyboardPressEffectSpec,
        val startedAtMs: Long,
        val particles: List<Particle>,
    )

    private val effects = ArrayDeque<ActiveEffect>()

    private val fillPaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
        }
    private val strokePaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2f * density
        }

    fun trigger(
        keyId: String,
        rect: RectF,
        spec: KeyboardPressEffectSpec,
    ): Boolean {
        if (spec.effect == "none") {
            return false
        }
        while (effects.size >= 8) {
            effects.removeFirst()
        }
        effects.addLast(
            ActiveEffect(
                keyId = keyId,
                rect = RectF(rect),
                spec = spec,
                startedAtMs = clock(),
                particles = particlesFor(spec),
            ),
        )
        return true
    }

    fun draw(
        canvas: Canvas,
        keyRadius: Float,
        accentColor: Int,
    ): Boolean {
        if (effects.isEmpty()) {
            return false
        }
        val now = clock()
        val iterator = effects.iterator()
        var hasActive = false
        while (iterator.hasNext()) {
            val effect = iterator.next()
            val elapsed = now - effect.startedAtMs
            if (elapsed >= effect.spec.durationMs) {
                iterator.remove()
                continue
            }
            hasActive = true
            val progress = (elapsed.toFloat() / effect.spec.durationMs).coerceIn(0f, 1f)
            drawEffect(canvas, effect, progress, keyRadius, accentColor)
        }
        return hasActive
    }

    fun activeCountForTest(): Int = effects.size

    private fun drawEffect(
        canvas: Canvas,
        effect: ActiveEffect,
        progress: Float,
        keyRadius: Float,
        accentColor: Int,
    ) {
        when (effect.spec.effect) {
            "scale" -> drawScale(canvas, effect, progress, keyRadius, accentColor)
            "pulse" -> drawPulse(canvas, effect, progress, keyRadius, accentColor)
            "shake" -> drawShake(canvas, effect, progress, keyRadius, accentColor)
            "ripple" -> drawRipple(canvas, effect, progress, accentColor)
            "glow" -> drawGlow(canvas, effect, progress, keyRadius, accentColor)
            "confettiLite",
            "fireworksLite",
            -> drawParticles(canvas, effect, progress)
        }
    }

    private fun drawScale(
        canvas: Canvas,
        effect: ActiveEffect,
        progress: Float,
        keyRadius: Float,
        accentColor: Int,
    ) {
        val eased = easedProgress(effect.spec, progress)
        val inset = -14f * density * effect.spec.intensity.coerceAtLeast(0.35f) * (1f - eased)
        val rect = RectF(effect.rect).apply { inset(inset, inset) }
        fillPaint.color = alphaColor(accentColor, (135 * (1f - progress)).toInt())
        canvas.drawRoundRect(rect, keyRadius, keyRadius, fillPaint)
    }

    private fun drawPulse(
        canvas: Canvas,
        effect: ActiveEffect,
        progress: Float,
        keyRadius: Float,
        accentColor: Int,
    ) {
        val rect = RectF(effect.rect).apply {
            val inset = -16f * density * effect.spec.intensity.coerceAtLeast(0.35f) * progress
            inset(inset, inset)
        }
        strokePaint.color = alphaColor(accentColor, (210 * (1f - progress)).toInt())
        strokePaint.strokeWidth = max(2f * density, 5f * density * (1f - progress))
        canvas.drawRoundRect(rect, keyRadius, keyRadius, strokePaint)
    }

    private fun drawShake(
        canvas: Canvas,
        effect: ActiveEffect,
        progress: Float,
        keyRadius: Float,
        accentColor: Int,
    ) {
        val offset = ((if ((progress * 10).toInt() % 2 == 0) 1 else -1) * 9f * density * effect.spec.intensity.coerceAtLeast(0.35f) * (1f - progress))
        val rect = RectF(effect.rect).apply { offset(offset, 0f) }
        strokePaint.color = alphaColor(accentColor, (210 * (1f - progress)).toInt())
        strokePaint.strokeWidth = 4f * density
        canvas.drawRoundRect(rect, keyRadius, keyRadius, strokePaint)
    }

    private fun drawRipple(
        canvas: Canvas,
        effect: ActiveEffect,
        progress: Float,
        accentColor: Int,
    ) {
        strokePaint.color = alphaColor(accentColor, (220 * (1f - progress)).toInt())
        strokePaint.strokeWidth = max(2f * density, 6f * density * (1f - progress))
        val radius = max(effect.rect.width(), effect.rect.height()) * (0.2f + progress * 0.65f)
        canvas.drawCircle(effect.rect.centerX(), effect.rect.centerY(), radius, strokePaint)
    }

    private fun drawGlow(
        canvas: Canvas,
        effect: ActiveEffect,
        progress: Float,
        keyRadius: Float,
        accentColor: Int,
    ) {
        val rect = RectF(effect.rect).apply { inset(-8f * density, -8f * density) }
        fillPaint.color = alphaColor(accentColor, (115 * (1f - progress)).toInt())
        canvas.drawRoundRect(rect, keyRadius, keyRadius, fillPaint)
    }

    private fun drawParticles(
        canvas: Canvas,
        effect: ActiveEffect,
        progress: Float,
    ) {
        effect.particles.forEach { particle ->
            val distance = particle.speed * density * easedProgress(effect.spec, progress)
            fillPaint.color = alphaColor(particle.color, (180 * (1f - progress)).toInt())
            canvas.drawCircle(
                effect.rect.centerX() + cos(particle.angle) * distance,
                effect.rect.centerY() + sin(particle.angle) * distance,
                3.8f * density * (1f - progress * 0.45f),
                fillPaint,
            )
        }
    }

    private fun particlesFor(spec: KeyboardPressEffectSpec): List<Particle> {
        val count =
            if (spec.effect == "fireworksLite") {
                (8 + spec.intensity * 10).toInt().coerceAtMost(18)
            } else {
                (5 + spec.intensity * 7).toInt().coerceAtMost(12)
            }
        val palette = intArrayOf(0xFF36B384.toInt(), 0xFFFFD166.toInt(), 0xFFEF476F.toInt(), 0xFF4CC9F0.toInt())
        return List(count) { index ->
            Particle(
                angle = ((PI * 2.0 * index) / count).toFloat(),
                speed = 24f + (index % 4) * 7f + spec.intensity * 22f,
                color = palette[index % palette.size],
            )
        }
    }

    private fun easedProgress(spec: KeyboardPressEffectSpec, progress: Float): Float {
        return when (spec.easing) {
            "linear" -> progress
            "spring" -> spring(progress)
            else -> easeOut(progress)
        }
    }

    private fun easeOut(progress: Float): Float {
        val inverse = 1f - progress
        return 1f - inverse * inverse * inverse
    }

    private fun spring(progress: Float): Float {
        val p = progress.coerceIn(0f, 1f)
        val damping = 5f
        val frequency = 11f
        val value = 1f - kotlin.math.exp(-damping * p) * kotlin.math.cos(frequency * p)
        return value.coerceIn(0f, 1.05f)
    }

    private fun alphaColor(color: Int, alpha: Int): Int {
        return Color.argb(alpha.coerceIn(0, 255), Color.red(color), Color.green(color), Color.blue(color))
    }
}
