package com.bule.free.ireader.api.apiconvert

import com.bule.free.ireader.api.Api
import com.bule.free.ireader.api.exception.ApiException
import com.bule.free.ireader.common.utils.AES
import com.bule.free.ireader.common.utils.LogUtils
import com.google.gson.Gson
import com.google.gson.TypeAdapter
import okhttp3.ResponseBody
import org.json.JSONException
import org.json.JSONObject
import retrofit2.Converter

/**
 * Created by suikajy on 2019/2/18
 */
class ApiResponseBodyConverter<T>(private val mGson: Gson, private val adapter: TypeAdapter<T>) : Converter<ResponseBody, T> {

    override fun convert(responseBody: ResponseBody): T {

        val response = responseBody.string()
        LogUtils.d("response: $response")
        val data: String
        //LogUtils.e(String.format("response: %s", response));
        // 这里面的报错RxJava可以在error回调中接收到
        try {
            val jobj = JSONObject(response)
            val errorno = jobj.optInt("errorno")
            if (errorno == 200) {
                val result = jobj.optString("data")
                data = AES.decrypt(result)
                if (Api.IS_API_DEBUG) LogUtils.d("decode data: $data")
            } else {
                val msg = jobj.optString("msg")
                throw ApiException(errorno, msg)
            }
        } catch (e: JSONException) {
            throw ApiException(ApiException.JSON_CAST_EXCEPTION, "JSON decode error, response is :$response")
        }

        return adapter.fromJson(data)
    }

    companion object {
        fun commonConvert(responseBody: ResponseBody): String {
            val response = responseBody.string()
            LogUtils.d("response: $response")
            val data: String
            //LogUtils.e(String.format("response: %s", response));
            // 这里面的报错RxJava可以在error回调中接收到
            try {
                val jobj = JSONObject(response)
                val errorno = jobj.optInt("errorno")
                if (errorno == 200) {
                    val result = jobj.optString("data")
                    data = AES.decrypt(result)
                    if (Api.IS_API_DEBUG) LogUtils.d("decode data: $data")
                } else {
                    val msg = jobj.optString("msg")
                    throw ApiException(errorno, msg)
                }
            } catch (e: JSONException) {
                throw ApiException(ApiException.JSON_CAST_EXCEPTION, "JSON decode error, response is :$response")
            }
            return data
        }
    }
}
