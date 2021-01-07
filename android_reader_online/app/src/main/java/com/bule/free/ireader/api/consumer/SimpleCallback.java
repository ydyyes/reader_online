package com.bule.free.ireader.api.consumer;

import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.NetworkUtils;
import com.bule.free.ireader.common.utils.ToastUtils;

import io.reactivex.functions.BiConsumer;

/**
 * Created by suikajy on 2019/2/27
 */
@FunctionalInterface
public interface SimpleCallback<T> extends BiConsumer<T, Throwable> {

    @Override
    default void accept(T result, Throwable throwable) throws Exception {
        if (throwable != null) {
            ErrorConsumer.INSTANCE.accept(throwable);
            throwable.printStackTrace();
            onException(throwable);
            if (!NetworkUtils.isAvailable()){
                ToastUtils.show("网络异常，请检查后重试");
            }
        } else {
            onSuccess(result);
        }
    }

    void onSuccess(T t);

    default void onException(Throwable throwable) {

    }
}
