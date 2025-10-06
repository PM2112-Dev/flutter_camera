package com.example.flutter_camera

import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.datasource.HttpDataSource
import java.security.cert.X509Certificate
import javax.net.ssl.*

class UnsafeHttpDataSourceFactory : HttpDataSource.Factory {
    
    private val defaultFactory = DefaultHttpDataSource.Factory()
    
    init {
        // Configure to trust all certificates (ONLY for development!)
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
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    override fun createDataSource(): HttpDataSource {
        return defaultFactory.createDataSource()
    }
    
    override fun setDefaultRequestProperties(defaultRequestProperties: Map<String, String>): HttpDataSource.Factory {
        defaultFactory.setDefaultRequestProperties(defaultRequestProperties)
        return this
    }
}
