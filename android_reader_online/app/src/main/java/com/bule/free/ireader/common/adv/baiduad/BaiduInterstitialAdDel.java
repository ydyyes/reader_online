package com.bule.free.ireader.common.adv.baiduad;

import android.app.Activity;
import android.util.Log;

import com.baidu.mobads.InterstitialAd;
import com.baidu.mobads.InterstitialAdListener;

/**
 * Created by suikajy on 2019-06-04
 *
 * todo 现在没有广告位id
 */
public class BaiduInterstitialAdDel {

    public static void showInterstitialAdv(Activity activity) {
        InterstitialAd interAd = new InterstitialAd(activity, "");
        interAd.setListener(new InterstitialAdListener() {

            @Override
            public void onAdClick(InterstitialAd arg0) {
                Log.i("InterstitialAd", "onAdClick");
            }

            @Override
            public void onAdDismissed() {
                Log.i("InterstitialAd", "onAdDismissed");
            }

            @Override
            public void onAdFailed(String arg0) {
                Log.i("InterstitialAd", "onAdFailed");
            }

            @Override
            public void onAdPresent() {
                Log.i("InterstitialAd", "onAdPresent");
            }

            @Override
            public void onAdReady() {
                Log.i("InterstitialAd", "onAdReady");
                if (!activity.isDestroyed()) {
                    interAd.showAd(activity);
                }
            }
        });
    }

}
