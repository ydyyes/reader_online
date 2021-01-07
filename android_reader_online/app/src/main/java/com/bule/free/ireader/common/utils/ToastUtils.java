package com.bule.free.ireader.common.utils;

import android.content.Context;
import android.support.annotation.StringRes;
import android.widget.Toast;

import com.bule.free.ireader.App;

/**
 * Created by newbiechen on 17-5-11.
 */

public class ToastUtils {

    private static Toast toast = null;

    public static void show(Context context, String content) {
        if (toast != null) {
            toast.cancel();
        }
        toast = Toast.makeText(context, content, Toast.LENGTH_SHORT);
        toast.show();
    }

    public static void show(@StringRes int resId) {
        show(App.instance, App.instance.getString(resId));
    }

    public static void show(String msg) {
        show(App.instance, msg);
    }
}
