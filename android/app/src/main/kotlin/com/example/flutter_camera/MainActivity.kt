package com.example.flutter_camera

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.cert.X509Certificate
import javax.net.ssl.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.flutter_camera/exoplayer"
    private lateinit var exoPlayerManager: ExoPlayerManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Disable SSL certificate validation for HTTPS connections (DEVELOPMENT ONLY!)
        disableSSLCertificateChecking()
    }

    private fun disableSSLCertificateChecking() {
        try {
            val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
                override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
                override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
                override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
            })
            
            val sslContext = SSLContext.getInstance("TLS")
            sslContext.init(null, trustAllCerts, java.security.SecureRandom())
            
            HttpsURLConnection.setDefaultSSLSocketFactory(sslContext.socketFactory)
            HttpsURLConnection.setDefaultHostnameVerifier { _, _ -> true }
            
            android.util.Log.i("MainActivity", "SSL certificate validation disabled")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

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
