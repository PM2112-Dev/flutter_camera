package com.example.flutter_camera

import android.content.Context
import android.view.Surface
import androidx.annotation.OptIn
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.rtsp.RtspMediaSource
import androidx.media3.exoplayer.DefaultRenderersFactory
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.view.TextureRegistry

@OptIn(UnstableApi::class)
class ExoPlayerManager(private val context: Context) {
    private val players = mutableMapOf<String, PlayerInfo>()
    private lateinit var flutterRenderer: FlutterRenderer

    data class PlayerInfo(
        val player: ExoPlayer,
        val textureEntry: TextureRegistry.SurfaceTextureEntry,
        val surface: Surface,
        var currentUri: String? = null,
        var retryCount: Int = 0
    )

    fun setTextureRegistry(renderer: FlutterRenderer) {
        flutterRenderer = renderer
    }

    fun createPlayer(playerId: String): Long {
        if (players.containsKey(playerId)) {
            dispose(playerId)
        }

        // Create texture entry for Flutter
        val textureEntry = flutterRenderer.createSurfaceTexture()
        val surface = Surface(textureEntry.surfaceTexture())

        // Create ExoPlayer with custom renderer factory
        val renderersFactory = DefaultRenderersFactory(context)
            .setExtensionRendererMode(DefaultRenderersFactory.EXTENSION_RENDERER_MODE_OFF)

        // Increase buffering to be more resilient to jitter/packet loss on RTSP
        val loadControl = DefaultLoadControl.Builder()
            .setBufferDurationsMs(
                /* minBufferMs= */ 15000,
                /* maxBufferMs= */ 50000,
                /* bufferForPlaybackMs= */ 2500,
                /* bufferForPlaybackAfterRebufferMs= */ 5000
            )
            .build()

        val player = ExoPlayer.Builder(context, renderersFactory)
            .setLoadControl(loadControl)
            .build()
        
        // Set video surface
        player.setVideoSurface(surface)

        // Mute audio by default for RTSP streams to avoid audio sink discontinuity exceptions
        player.volume = 0f

        // Add a listener to detect errors and attempt a small retry
        val handler = Handler(Looper.getMainLooper())
        player.addListener(object : Player.Listener {
            override fun onPlayerError(error: PlaybackException) {
                Log.w("ExoPlayerManager", "Player error: ${error.message}")
                // Find which playerInfo this is
                val infoEntry = players.entries.find { it.value.player == player } ?: return
                val pInfo = infoEntry.value

                // Avoid infinite retry loops
                if (pInfo.retryCount >= 3) {
                    Log.w("ExoPlayerManager", "Max retry attempts reached for player ${infoEntry.key}")
                    return
                }

                pInfo.retryCount += 1
                // Backoff and retry: stop, clear, re-set media source, prepare
                val uri = pInfo.currentUri
                if (uri != null) {
                    handler.postDelayed({
                        try {
                            Log.i("ExoPlayerManager", "Retrying playback for player ${infoEntry.key}, attempt ${pInfo.retryCount}")
                            player.stop()
                            player.clearMediaItems()
                            val mediaItem = MediaItem.fromUri(uri)
                            val mediaSource = RtspMediaSource.Factory()
                                .setForceUseRtpTcp(true)
                                .createMediaSource(mediaItem)
                            player.setMediaSource(mediaSource)
                            player.prepare()
                            player.play()
                        } catch (e: Exception) {
                            Log.e("ExoPlayerManager", "Retry failed: ${e.message}")
                        }
                    }, 1000L * pInfo.retryCount)
                }
            }
        })

        val playerInfo = PlayerInfo(player, textureEntry, surface)
        players[playerId] = playerInfo

        return textureEntry.id()
    }

    fun playRtsp(playerId: String, rtspUrl: String) {
        val playerInfo = players[playerId] ?: return

        // Track current uri so the listener can retry if needed
        playerInfo.currentUri = rtspUrl
        playerInfo.retryCount = 0

        val mediaItem = MediaItem.fromUri(rtspUrl)
        val mediaSource = RtspMediaSource.Factory()
            .setForceUseRtpTcp(true)
            .createMediaSource(mediaItem)

        playerInfo.player.setMediaSource(mediaSource)
        playerInfo.player.prepare()
        playerInfo.player.play()
    }

    fun pause(playerId: String) {
        players[playerId]?.player?.pause()
    }

    fun resume(playerId: String) {
        players[playerId]?.player?.play()
    }

    fun dispose(playerId: String) {
        val playerInfo = players[playerId] ?: return
        
        playerInfo.player.release()
        playerInfo.surface.release()
        playerInfo.textureEntry.release()
        
        players.remove(playerId)
    }

    fun disposeAll() {
        players.keys.toList().forEach { playerId ->
            dispose(playerId)
        }
    }
}
