package com.example.flutter_camera

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_camera/exoplayer"
    private lateinit var exoPlayerManager: ExoPlayerManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        exoPlayerManager = ExoPlayerManager(this)
        exoPlayerManager.setTextureRegistry(flutterEngine.renderer)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createPlayer" -> {
                    val playerId = call.argument<String>("playerId") ?: ""
                    val textureId = exoPlayerManager.createPlayer(playerId)
                    result.success(textureId)
                }
                "playRtsp" -> {
                    val playerId = call.argument<String>("playerId") ?: ""
                    val rtspUrl = call.argument<String>("rtspUrl") ?: ""
                    exoPlayerManager.playRtsp(playerId, rtspUrl)
                    result.success(null)
                }
                "pause" -> {
                    val playerId = call.argument<String>("playerId") ?: ""
                    exoPlayerManager.pause(playerId)
                    result.success(null)
                }
                "resume" -> {
                    val playerId = call.argument<String>("playerId") ?: ""
                    exoPlayerManager.resume(playerId)
                    result.success(null)
                }
                "dispose" -> {
                    val playerId = call.argument<String>("playerId") ?: ""
                    exoPlayerManager.dispose(playerId)
                    result.success(null)
                }
                "disposeAll" -> {
                    exoPlayerManager.disposeAll()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::exoPlayerManager.isInitialized) {
            exoPlayerManager.disposeAll()
        }
    }
}
