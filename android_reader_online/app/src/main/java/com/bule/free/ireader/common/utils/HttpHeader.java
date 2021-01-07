package com.bule.free.ireader.common.utils;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import com.bule.free.ireader.App;
import com.bule.free.ireader.Const;


public class HttpHeader {


    private static String IMEI = "";
    private static String IMSI = "";
    private static String Resolution = "";
    private static String VCODE = "";
    private static String VNAME = "";
    private static String CHANNEL = "";
    private static String UUID = "";
    private static String NET = "";


    @SuppressLint("MissingPermission")
    public static String getImei() {
        if (!TextUtils.isEmpty(IMEI)) {
            return IMEI;
        }
        Context context = App.instance;
        TelephonyManager mTelephonyMgr = (TelephonyManager) context
                .getSystemService(Context.TELEPHONY_SERVICE);
        String imei = "";
        try {
            imei = mTelephonyMgr.getDeviceId();
            imei = imei == null ? "" : imei;
            IMEI = imei;
        } catch (Exception e) {
            //e.printStackTrace();
        }
        return imei;
    }

    @SuppressLint("MissingPermission")
    public static String getImsi() {
        if (!TextUtils.isEmpty(IMSI)) {
            return IMSI;
        }

        Context context = App.instance;
        String imsi = "";
        try {
            TelephonyManager mTelephonyMgr = (TelephonyManager) context
                    .getSystemService(Context.TELEPHONY_SERVICE);
            imsi = mTelephonyMgr.getSubscriberId();
            IMSI = imsi == null ? "" : imsi;
        } catch (Exception e) {
            //e.printStackTrace();
        }
        return IMSI;
    }

    /**
     * 获取手机型号，如 "HTC Desire"等
     **/
    public static String getModel() {
        return Build.MODEL;
    }

    public static String getManufacturer() {
        return Build.MANUFACTURER;
    }

    public static String getResolution() {
        if (!TextUtils.isEmpty(Resolution)) {
            return Resolution;
        }

        Context context = App.instance;
        String size = "";
        int w = context.getResources().getDisplayMetrics().widthPixels;
        int h = context.getResources().getDisplayMetrics().heightPixels;
        size = w + "x" + h;

        Resolution = size;

        return size;
    }

    public static String getBoard() {
        return Build.BOARD;
    }

    public static String getBrand() {
        return Build.BRAND;
    }

    public static String getVersionCode() {
        if (!TextUtils.isEmpty(VCODE)) {
            return VCODE;
        }

        Context context = App.instance;
        String vcode = String.valueOf(AppUtils.getVersionCode(context));
        VCODE = vcode;

        return vcode;
    }

    public static String getVersionName() {
        if (!TextUtils.isEmpty(VNAME)) {
            return VNAME;
        }

        Context context = App.instance;
        String vname = AppUtils.getVersionName(context);
        VNAME = vname == null ? "" : vname;
        return vname;
    }

    public static String getChannel() {
        if (!TextUtils.isEmpty(CHANNEL)) {
            return CHANNEL;
        }

        Context context = App.instance;
        String channel = Const.INSTANCE.getChannelConfig().getChannelName();

        CHANNEL = channel;

        return channel;
    }

    public static String getUUID() {
        Context context = App.instance;
        return UUIDUtil.getUUID(context);
    }

    public static String getNet() {
        if (!TextUtils.isEmpty(NET)) {
            return NET;
        }
        Context context = App.instance;
        String net = NetworkUtils.getNetWorkTypeName(context);

        NET = net;
        return net;
    }


}
