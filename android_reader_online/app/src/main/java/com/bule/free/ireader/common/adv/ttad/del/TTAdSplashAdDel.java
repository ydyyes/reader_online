package com.bule.free.ireader.common.adv.ttad.del;

import android.os.Message;
import android.support.annotation.MainThread;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.main.BaseSplashActivity;
import com.bule.free.ireader.main.SplashActivity;
import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.model.User;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.adv.ttad.config.TTAdManagerHolder;
import com.bule.free.ireader.common.adv.ttad.util.WeakHandler;
import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTSplashAd;
import com.umeng.analytics.MobclickAgent;

/**
 * Created by suikajy on 2019/3/18
 * <p>
 * 开屏广告
 */
public class TTAdSplashAdDel implements WeakHandler.IHandler {

    private static final String TAG = "SplashActivity";
    private TTAdNative mTTAdNative;
    private FrameLayout mSplashContainer;
    //是否强制跳转到主页面
    private boolean mForceGoMain;
    private final Runnable goToMainActivity;

    //开屏广告加载发生超时但是SDK没有及时回调结果的时候，做的一层保护。
    private final WeakHandler mHandler = new WeakHandler(this);
    //开屏广告加载超时时间,建议大于1000,这里为了冷启动第一次加载到广告并且展示,示例设置了2000ms
    private static final int AD_TIME_OUT = (int) SplashActivity.BASE_WAIT_TIME;
    private static final int MSG_GO_MAIN = 1;
    //开屏广告是否已经加载
    private boolean mHasLoaded;

    private final BaseSplashActivity mActivity;

    public TTAdSplashAdDel(BaseSplashActivity splashActivity, FrameLayout mSplashContainer, Runnable goToMainActivity) {
        this.mSplashContainer = mSplashContainer;
        this.mActivity = splashActivity;
        this.goToMainActivity = goToMainActivity;
    }

    @SuppressWarnings("RedundantCast")
    public void onCreate() {
        if (!ApiConfig.INSTANCE.getStrategy_ad_open() || User.INSTANCE.isFirstRun()) {
            mHandler.postDelayed(goToMainActivity, SplashActivity.BASE_WAIT_TIME);
            return;
        }
        //step2:创建TTAdNative对象
        mTTAdNative = TTAdManagerHolder.get().createAdNative(mActivity);
        //在合适的时机申请权限，如read_phone_state,防止获取不了imei时候，下载类广告没有填充的问题
        //在开屏时候申请不太合适，因为该页面倒计时结束或者请求超时会跳转，在该页面申请权限，体验不好
        // TTAdManagerHolder.getInstance(this).requestPermissionIfNecessary(this);
        //定时，AD_TIME_OUT时间到时执行，如果开屏广告没有加载则跳转到主页面
        mHandler.sendEmptyMessageDelayed(MSG_GO_MAIN, AD_TIME_OUT);
        //加载开屏广告
        loadSplashAd();
    }

    public void onResume() {
        //判断是否该跳转到主页面
        if (mForceGoMain) {
            mHandler.removeCallbacksAndMessages(null);
            goToMainActivity();
        }
    }

    public void onStop() {
        mForceGoMain = true;
    }

    /**
     * 加载开屏广告
     */
    private void loadSplashAd() {
        //step3:创建开屏广告请求参数AdSlot,具体参数含义参考文档
        MobclickAgent.onEvent(mActivity, "ttad_splash_adv_load");
        AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(Const.INSTANCE.getChannelConfig().getTtad().getSplash_pos_id())
                .setSupportDeepLink(true)
                .setImageAcceptedSize(1080, 1920)
                .build();
        //step4:请求广告，调用开屏广告异步请求接口，对请求回调的广告作渲染处理
        mTTAdNative.loadSplashAd(adSlot, new TTAdNative.SplashAdListener() {
            @Override
            @MainThread
            public void onError(int code, String message) {
                LogUtils.e(String.format("message: %s", message));
                MobclickAgent.onEvent(mActivity, "ttad_splash_adv_load_fail");
                mHasLoaded = true;
                goToMainActivity();
            }

            @Override
            @MainThread
            public void onTimeout() {
                mHasLoaded = true;
//                showToast("开屏广告加载超时");
                goToMainActivity();
            }

            @Override
            @MainThread
            public void onSplashAdLoad(TTSplashAd ad) {
                Log.d(TAG, "开屏广告请求成功");
                MobclickAgent.onEvent(mActivity, "ttad_splash_adv_show");
                MobclickAgent.onEvent(mActivity, "ttad_splash_adv_load_success");
                mHasLoaded = true;
                mHandler.removeCallbacksAndMessages(null);
                if (ad == null) {
                    return;
                }
                //获取SplashView
                View view = ad.getSplashView();
                mSplashContainer.removeAllViews();
                //把SplashView 添加到ViewGroup中,注意开屏广告view：width >=70%屏幕宽；height >=50%屏幕宽
                mSplashContainer.addView(view);
                //设置不开启开屏广告倒计时功能以及不显示跳过按钮,如果这么设置，您需要自定义倒计时逻辑
                //ad.setNotAllowSdkCountdown();

                //设置SplashView的交互监听器
                ad.setSplashInteractionListener(new TTSplashAd.AdInteractionListener() {
                    @Override
                    public void onAdClicked(View view, int type) {
                        MobclickAgent.onEvent(mActivity, "ttad_splash_adv_click");
                        Log.d(TAG, "onAdClicked");
                    }

                    @Override
                    public void onAdShow(View view, int type) {
                        Log.d(TAG, "onAdShow");
                    }

                    @Override
                    public void onAdSkip() {
                        Log.d(TAG, "onAdSkip");
                        goToMainActivity();
                    }

                    @Override
                    public void onAdTimeOver() {
                        Log.d(TAG, "onAdTimeOver");
                        goToMainActivity();
                    }
                });
            }
        }, AD_TIME_OUT);
    }

    /**
     * 跳转到主页面
     */
    private void goToMainActivity() {
        goToMainActivity.run();
    }

    @Override
    public void handleMsg(Message msg) {
        if (msg.what == MSG_GO_MAIN) {
            if (!mHasLoaded) {
                goToMainActivity();
            }
        }
    }

}
