package com.winflowz_app.winflowz_app.ime

import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.view.KeyEvent

class KeyboardMediaController(context: Context) {
    private val appContext = context.applicationContext
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    fun playPause() {
        dispatch(KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
    }

    fun previous() {
        dispatch(KeyEvent.KEYCODE_MEDIA_PREVIOUS)
    }

    fun next() {
        dispatch(KeyEvent.KEYCODE_MEDIA_NEXT)
    }

    fun nowPlayingLabel(): String {
        val controller =
            try {
                activeController()
            } catch (_: SecurityException) {
                return "Now playing: enable media session access"
            } ?: return "Now playing: nothing detected"
        return controller.metadata?.toNowPlayingLabel() ?: "Now playing: metadata unavailable"
    }

    fun openActiveMediaApp(): String {
        val controller =
            try {
                activeController()
            } catch (_: SecurityException) {
                return "Media app: enable media session access"
            } ?: return "Media app: nothing detected"
        val packageName = controller.packageName ?: return "Media app: unavailable"
        val intent =
            appContext.packageManager.getLaunchIntentForPackage(packageName)
                ?: return "Media app: cannot open $packageName"
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            appContext.startActivity(intent)
        } catch (_: RuntimeException) {
            return "Media app: cannot open $packageName"
        }
        return "Media app opened"
    }

    private fun activeController(): MediaController? {
        val sessionManager =
            appContext.getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
        val controllers =
            try {
                sessionManager.getActiveSessions(null)
            } catch (error: SecurityException) {
                throw error
            }
        return controllers.firstOrNull { it.playbackState?.state == PlaybackState.STATE_PLAYING }
            ?: controllers.firstOrNull { it.metadata != null }
    }

    private fun dispatch(keyCode: Int) {
        val down = KeyEvent(KeyEvent.ACTION_DOWN, keyCode)
        val up = KeyEvent(KeyEvent.ACTION_UP, keyCode)
        audioManager.dispatchMediaKeyEvent(down)
        audioManager.dispatchMediaKeyEvent(up)
    }

    private fun MediaMetadata.toNowPlayingLabel(): String {
        val artist =
            firstText(
                MediaMetadata.METADATA_KEY_ARTIST,
                MediaMetadata.METADATA_KEY_ALBUM_ARTIST,
                MediaMetadata.METADATA_KEY_AUTHOR,
            )
        val title = firstText(MediaMetadata.METADATA_KEY_TITLE, MediaMetadata.METADATA_KEY_DISPLAY_TITLE)
        return when {
            !artist.isNullOrBlank() && !title.isNullOrBlank() -> "$artist - $title"
            !title.isNullOrBlank() -> title
            !artist.isNullOrBlank() -> artist
            else -> "Now playing: metadata unavailable"
        }
    }

    private fun MediaMetadata.firstText(vararg keys: String): String? {
        return keys.firstNotNullOfOrNull { key -> getText(key)?.toString()?.trim()?.takeIf { it.isNotBlank() } }
    }
}
