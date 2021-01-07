package com.bule.free.ireader.api.apiconvert;

import com.google.gson.Gson;
import com.google.gson.TypeAdapter;
import com.google.gson.reflect.TypeToken;

import java.lang.annotation.Annotation;
import java.lang.reflect.Type;

import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Converter;
import retrofit2.Retrofit;

/**
 * Created by suikajy on 2019/2/18
 * <p>
 * 刘冰轩的接口转换器
 */
public class ApiConverterFactory extends Converter.Factory {
    public static ApiConverterFactory create() {
        return create(new Gson());
    }

    public static ApiConverterFactory create(Gson gson) {
        return new ApiConverterFactory(gson);

    }

    private final Gson gson;

    private ApiConverterFactory(Gson gson) {
        if (gson == null) throw new NullPointerException("gson == null");
        this.gson = gson;
    }


    @Override
    public Converter<ResponseBody, ?> responseBodyConverter(Type type, Annotation[] annotations,
                                                            Retrofit retrofit) {

        TypeAdapter<?> adapter = gson.getAdapter(TypeToken.get(type));
        return new ApiResponseBodyConverter<>(gson, adapter); //响应
    }

    @Override
    public Converter<?, RequestBody> requestBodyConverter(Type type,
                                                          Annotation[] parameterAnnotations, Annotation[] methodAnnotations, Retrofit retrofit) {

        TypeAdapter<?> adapter = gson.getAdapter(TypeToken.get(type));
        return new ApiRequestBodyConverter<>(gson, adapter); //请求
    }


}
