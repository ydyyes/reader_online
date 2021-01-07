package com.bule.free.ireader.common.adv.baiduad;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.widget.FrameLayout;

import com.baidu.mobads.AdSettings;
import com.baidu.mobads.SplashAd;
import com.baidu.mobads.SplashLpCloseListener;
import com.bule.free.ireader.Const;
import com.bule.free.ireader.main.SplashActivity;
import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.model.User;
import com.bule.free.ireader.common.utils.LogUtils;
import com.umeng.analytics.MobclickAgent;

/**
 * Created by suikajy on 2019/4/8
 */
public class BaiduSplashAdDel {

    private final Context mContext;
    private final FrameLayout mFlAdvContainer;
    private final Runnable mSkipAction;
    private final Handler handler = new Handler(Looper.getMainLooper());
    /**
     * 当设置开屏可点击时，需要等待跳转页面关闭后，再切换至您的主窗口。故此时需要增加canJumpImmediately判断。 另外，点击开屏还需要在onResume中
     * 调用jumpWhenCanClick接口。
     */
    private boolean canJumpImmediately = false;

    public BaiduSplashAdDel(Context context, FrameLayout frameLayout, Runnable skipAction) {
        this.mContext = context;
        this.mFlAdvContainer = frameLayout;
        this.mSkipAction = skipAction;
    }

    public void show() {
        // 会员不免开屏广告
        if (!ApiConfig.INSTANCE.getStrategy_ad_open() || User.INSTANCE.isFirstRun()) {
            handler.postDelayed(mSkipAction, SplashActivity.BASE_WAIT_TIME);
            return;
        }
        // 默认请求http广告，若需要请求https广告，请设置AdSettings.setSupportHttps为true
        // AdSettings.setSupportHttps(true);
        // 设置视频广告最大缓存占用空间(15MB~100MB),默认30MB,单位MB
        // SplashAd.setMaxVideoCacheCapacityMb(30);
        // adUnitContainer

        // 不需要使用lp关闭之后回调方法的，可以继续使用该接口
//        SplashAdListener listener = new SplashAdListener() {
//            @Override
//            public void onAdDismissed() {
//                Log.i("RSplashActivity", "onAdDismissed");
//                next(); // 跳转至您的应用主界面
//            }
//
//            @Override
//            public void onAdFailed(String arg0) {
//                Log.i("RSplashActivity", arg0);
//                jump();
//            }
//
//            @Override
//            public void onAdPresent() {
//                Log.i("RSplashActivity", "onAdPresent");
//            }
//
//            @Override
//            public void onAdClick() {
//                Log.i("RSplashActivity", "onAdClick");
//                // 设置开屏可接受点击时，该回调可用
//            }
//        };
        // 增加lp页面关闭回调，不需要该回调的继续使用原来接口就可以
        SplashLpCloseListener listener = new SplashLpCloseListener() {
            @Override
            public void onLpClosed() {
                LogUtils.e("onLpClosed");
            }

            @Override
            public void onAdDismissed() {
                LogUtils.e("onAdDismissed");
                next(); // 跳转至您的应用主界面
            }

            @Override
            public void onAdFailed(String arg0) {
                LogUtils.e("onAdFailed: " + arg0);
                mSkipAction.run();
            }

            @Override
            public void onAdPresent() {
                MobclickAgent.onEvent(mContext, "baidu_splash_adv_show");
                LogUtils.e("onAdPresent");
            }

            @Override
            public void onAdClick() {
                LogUtils.e("onAdClick");
                MobclickAgent.onEvent(mContext, "baidu_splash_adv_click");
                // 设置开屏可接受点击时，该回调可用
            }
        };
        AdSettings.setSupportHttps(false);
        // 如果开屏需要支持vr,needRequestVRAd(true)
//        SplashAd.needRequestVRAd(true);
        // 等比缩小放大，裁剪边缘部分
//        SplashAd.setBitmapDisplayMode(BitmapDisplayMode.DISPLAY_MODE_CENTER_CROP);
        MobclickAgent.onEvent(mContext, "baidu_splash_adv_load");
        new SplashAd(mContext, mFlAdvContainer, listener, Const.BDAD.SPLASH_POS_ID, true);
    }

    private void next() {
        if (canJumpImmediately) {
            mSkipAction.run();
        } else {
            canJumpImmediately = true;
        }
    }

    public void onPause() {
        canJumpImmediately = false;
    }

    public void onResume() {
        if (canJumpImmediately) {
            next();
        }
        canJumpImmediately = true;
    }
}
