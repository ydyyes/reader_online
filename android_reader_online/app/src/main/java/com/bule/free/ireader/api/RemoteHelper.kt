@file:JvmName("RemoteHelper")

package com.bule.free.ireader.api

import com.bule.free.ireader.api.apiconvert.ApiConverterFactory
import com.bule.free.ireader.common.utils.HttpHeader
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.SSLSocketClient
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import java.util.concurrent.TimeUnit


/**
 * Created by suikajy on 2019/2/22
 */
@Suppress("ConstantConditionIf")
object RemoteHelper {

    private const val IS_LOG_HEADER = true

    val commonOkClient by lazy {
        val okHttpClientBuilder = OkHttpClient.Builder().connectTimeout(20 * 1000, TimeUnit.MILLISECONDS)
                .readTimeout(20 * 1000, TimeUnit.MILLISECONDS)
//                .sslSocketFactory(SSLSocketClient.getSSLSocketFactory())
//                .hostnameVerifier(SSLSocketClient.getHostnameVerifier())
                .retryOnConnectionFailure(true) // 失败重发
                .addInterceptor {
                    val original = it.request()
                    val request = original.newBuilder()
                            .header("imei", HttpHeader.getImei())
                            .header("imsi", HttpHeader.getImsi())
                            .header("uuid", HttpHeader.getUUID())
                            .header("vcode", HttpHeader.getVersionCode())
                            .header("vname", HttpHeader.getVersionName())
                            .header("model", HttpHeader.getModel())
                            .header("manuFacturer", HttpHeader.getManufacturer())
                            .header("brand", HttpHeader.getBoard())
                            .header("resolution", HttpHeader.getResolution())
                            .header("sdk", android.os.Build.VERSION.SDK_INT.toString())
                            .header("channel", HttpHeader.getChannel())
                            .header("net", HttpHeader.getNet())
                            .method(original.method(), original.body())
                            .build()
                    it.proceed(request)
                }
        if (IS_LOG_HEADER) {
            okHttpClientBuilder.addInterceptor(HttpLoggingInterceptor(LogUtils::d).setLevel(HttpLoggingInterceptor.Level.BODY))
        }
        okHttpClientBuilder.build()
    }

    val simpleOkHttpClient: OkHttpClient = OkHttpClient.Builder().connectTimeout(20 * 1000, TimeUnit.MILLISECONDS)
            .readTimeout(20 * 1000, TimeUnit.MILLISECONDS)
//            .sslSocketFactory(SSLSocketClient.getSSLSocketFactory())
//            .hostnameVerifier(SSLSocketClient.getHostnameVerifier())
            .retryOnConnectionFailure(true) // 失败重发
            .addInterceptor(HttpLoggingInterceptor {
                LogUtils.d("response content: $it")
            }.setLevel(HttpLoggingInterceptor.Level.BODY))
            .build()

    val retrofit: Retrofit by lazy {
        Retrofit.Builder()
                .client(commonOkClient)
                .addConverterFactory(ApiConverterFactory.create())
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .baseUrl(Api.BASE_URL)
                .build()
    }

}