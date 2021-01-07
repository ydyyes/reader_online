/**
 * Copyright 2016 JustWayward Team
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.bule.free.ireader.common.utils;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

public class AppUtils {

    public static int getVersionCode(Context context) {
        try {
            PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            return packageInfo.versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static String getVersionName(Context context) {
        try {
            PackageInfo packageInfo = context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
            return packageInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String getChannel(Context context) {
        PackageManager packageManager = context.getPackageManager();
        try {
            PackageInfo packageInfo = packageManager.getPackageInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = packageInfo.applicationInfo.metaData;
            return bundle.getString("UMENG_CHANNEL");
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return "";
    }

    public static boolean isInstalled(Context context, String pname) {
        PackageManager pm = context.getPackageManager();
        try {
            PackageInfo info = pm.getPackageInfo(pname, 0);
            if(info != null) {
                return true;
            }
        } catch (Exception e) {
        }
        return false;
    }

//    /**
//     * Description:MD5工具生成token
//     * @param value
//     * @return
//     */
//    public static String getMD5Value(String value){
//        try {
//            MessageDigest messageDigest = MessageDigest.getInstance("MD5");
//            byte[] md5ValueByteArray = messageDigest.digest(value.getBytes());
//            BigInteger bigInteger = new BigInteger(1 , md5ValueByteArray);
//            return bigInteger.toString(16).toUpperCase();
//        } catch (Exception e) {
//            throw new RuntimeException(e);
//        }
//    }
//    /**
//     * 生成签名
//     * @param map
//     * @return
//     */
//    public static String getSignToken(Map<String, String> map) {
//        String result = "";
//        try {
//            List<Map.Entry<String, String>> infoIds = new ArrayList<Map.Entry<String, String>>(map.entrySet());
//            // 对所有传入参数按照字段名的 ASCII 码从小到大排序（字典序）
//            Collections.sort(infoIds, new Comparator<Map.Entry<String, String>>() {
//
//                public int compare(Map.Entry<String, String> o1, Map.Entry<String, String> o2) {
//                    return (o1.getKey()).toString().compareTo(o2.getKey());
//                }
//            });
//            // 构造签名键值对的格式
//            StringBuilder sb = new StringBuilder();
//            for (Map.Entry<String, String> item : infoIds) {
//                if (item.getKey() != null || item.getKey() != "") {
//                    String key = item.getKey();
//                    String val = item.getValue();
//                    if (!(val == "" || val == null)) {
//                        sb.append(key + "=" + val + "&");
//                    }
//                }
//            }
//            result = sb.toString();
//            //进行MD5加密
//            result = getMD5Value(result);
//        } catch (Exception e) {
//            return null;
//        }
//        return result;
//    }
//
//
//    public static String md5SignByMapAndKey(Map<String, String> map,String mchntKey) {
//        Object[] keys =  map.keySet().toArray();
//        Arrays.sort(keys);
//        StringBuilder originStr = new StringBuilder();
//        for(Object key:keys){
//            if(null!=map.get(key)&&!TextUtils.isEmpty(map.get(key).toString()))
//                originStr.append(key).append("=").append(map.get(key)).append("&");
//        }
////        originStr.append("key=").append(mchntKey);
//        LogUtils.e("sign map : " + originStr.toString());
//        String sign = getMD5Value(originStr.toString());
//        return sign;
//    }
}
