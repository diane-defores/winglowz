package com.voiceflowz.voiceflowz.ime

import android.content.Context
import android.media.AudioManager
import android.view.KeyEvent

class KeyboardMediaController(context: Context) {
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

    private fun dispatch(keyCode: Int) {
        val down = KeyEvent(KeyEvent.ACTION_DOWN, keyCode)
        val up = KeyEvent(KeyEvent.ACTION_UP, keyCode)
        audioManager.dispatchMediaKeyEvent(down)
        audioManager.dispatchMediaKeyEvent(up)
    }
}
