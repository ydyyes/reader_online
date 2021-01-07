package com.bule.free.ireader.api.apiconvert;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.api.Api;
import com.bule.free.ireader.common.utils.AES;
import com.bule.free.ireader.common.utils.HttpHeader;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.ServerTimeUtil;
import com.google.gson.Gson;
import com.google.gson.TypeAdapter;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URLEncoder;

import okhttp3.MediaType;
import okhttp3.RequestBody;
import retrofit2.Converter;

/**
 * Created by suikajy on 2019/2/18
 */
public class ApiRequestBodyConverter<T> implements Converter<T, RequestBody> {
    private static final MediaType MEDIA_TYPE = MediaType.parse("application/x-www-form-urlencoded");
    private final Gson gson;
    private final TypeAdapter<T> adapter;

    /**
     * 构造器
     */
    public ApiRequestBodyConverter(Gson gson, TypeAdapter<T> adapter) {
        this.gson = gson;
        this.adapter = adapter;
    }

    @Override
    public RequestBody convert(T value) throws IOException {
        if (Const.DEBUG) {
            return RequestBody.create(MEDIA_TYPE, "sign=" + getSign(value.toString()));
        }
        //加密
        String postData = "";

        try {
            JSONObject jo = new JSONObject(value.toString());

            jo.put("requestTime", String.valueOf(ServerTimeUtil.INSTANCE.getServerTime()));
            jo.put("vcode", HttpHeader.getVersionCode());
            jo.put("api_vcode", 1);
            jo.put("uuid", HttpHeader.getUUID());

            postData = AES.encrypt(jo.toString());
            postData = URLEncoder.encode(postData, "UTF-8");
            if (Api.IS_API_DEBUG) {
                LogUtils.e("请求参数：" + jo.toString());
                LogUtils.e("sign: " + postData);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return RequestBody.create(MEDIA_TYPE, "sign=" + postData);
    }

    public static String getSign(String json) {
        String sign = "";
        try {
            JSONObject jo = new JSONObject(json);
            sign = getSign(jo);
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sign;
    }

    public static String getSign(JSONObject jo) {
        String sign = "";
        try {
            jo.put("requestTime", String.valueOf(ServerTimeUtil.INSTANCE.getServerTime()));
            jo.put("vcode", HttpHeader.getVersionCode());
            jo.put("api_vcode", 1);
            jo.put("uuid", HttpHeader.getUUID());

            String encode = AES.encrypt(jo.toString());
            sign = URLEncoder.encode(encode, "UTF-8");
            if (Api.IS_API_DEBUG) {
                LogUtils.d("请求参数：" + jo.toString());
                LogUtils.d("sign: " + sign);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sign;
    }

    public static String getSignWithOutUrlEncode(JSONObject jo) {
        String sign = "";
        try {
            jo.put("requestTime", String.valueOf(ServerTimeUtil.INSTANCE.getServerTime()));
            jo.put("vcode", HttpHeader.getVersionCode());
            jo.put("api_vcode", 1);
            jo.put("uuid", HttpHeader.getUUID());

            String encode = AES.encrypt(jo.toString());
            sign = encode;
            if (Api.IS_API_DEBUG) {
                LogUtils.d("请求参数：" + jo.toString());
                LogUtils.d("sign: " + sign);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sign;
    }
}
