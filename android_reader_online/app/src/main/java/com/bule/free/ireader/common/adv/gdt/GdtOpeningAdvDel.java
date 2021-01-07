package com.bule.free.ireader.common.adv.gdt;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.main.BaseSplashActivity;
import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.model.User;
import com.bule.free.ireader.main.SplashActivity;
import com.bule.free.ireader.common.utils.LogUtils;
import com.qq.e.ads.splash.SplashAD;
import com.qq.e.ads.splash.SplashADListener;
import com.qq.e.comm.util.AdError;
import com.umeng.analytics.MobclickAgent;

import java.util.Locale;

/**
 * Created by suikajy on 2019/2/21
 */
public class GdtOpeningAdvDel implements SplashADListener {

    private final BaseSplashActivity activity;
    private final TextView skipView;
    private final FrameLayout flContainer;
    private final Runnable mSkipAction;
    private static final String SKIP_TEXT = "跳过 %d";
    private final Handler handler = new Handler(Looper.getMainLooper());
    /**
     * 记录拉取广告的时间
     */
    private long fetchSplashADTime = 0;
    /**
     * 为防止无广告时造成视觉上类似于"闪退"的情况，设定无广告时页面跳转根据需要延迟一定时间，demo
     * 给出的延时逻辑是从拉取广告开始算开屏最少持续多久，仅供参考，开发者可自定义延时逻辑，如果开发者采用demo
     * 中给出的延时逻辑，也建议开发者考虑自定义minSplashTimeWhenNoAD的值（单位ms）
     **/
    private long minSplashTimeWhenNoAD = SplashActivity.BASE_WAIT_TIME;

    public boolean canJump = false;
    private SplashAD splashAD;

    public GdtOpeningAdvDel(@NonNull BaseSplashActivity activity, @NonNull TextView skipView, @NonNull FrameLayout flContainer, @NonNull Runnable nextAction) {
        this.activity = activity;
        this.skipView = skipView;
        this.flContainer = flContainer;
        mSkipAction = nextAction;
    }

    public void init() {
        if (!ApiConfig.INSTANCE.getStrategy_ad_open() || User.INSTANCE.isFirstRun()) {
            handler.postDelayed(mSkipAction, minSplashTimeWhenNoAD);
            return;
        }
        skipView.setVisibility(View.VISIBLE);
        skipView.setAlpha(0);
        fetchSplashAD(activity, flContainer, skipView, Const.INSTANCE.getChannelConfig().getGdt().getApp_id(), Const.INSTANCE.getChannelConfig().getGdt().getSplash_pos_id(), this, 0);
    }

    /**
     * @param activity      展示广告的activity
     * @param adContainer   展示广告的大容器
     * @param skipContainer 自定义的跳过按钮：传入该view给SDK后，SDK会自动给它绑定点击跳过事件。SkipView的样式可以由开发者自由定制，其尺寸限制请参考activity_splash.xml或者接入文档中的说明。
     * @param appId         应用ID
     * @param posId         广告位ID
     * @param adListener    广告状态监听器
     * @param fetchDelay    拉取广告的超时时长：取值范围[3000, 5000]，设为0表示使用广点通SDK默认的超时时长。
     */
    private void fetchSplashAD(Activity activity, ViewGroup adContainer, View skipContainer,
                               String appId, String posId, SplashADListener adListener, int fetchDelay) {
        fetchSplashADTime = System.currentTimeMillis();
        handler.postDelayed(() -> {
            splashAD = new SplashAD(activity, adContainer, skipContainer, appId, posId, adListener, 0);
            MobclickAgent.onEvent(activity, "gdt_splash_adv_load");
        }, 1000);
    }

    @Override
    public void onADDismissed() {
        next();
    }

    @Override
    public void onNoAD(AdError adError) {
        LogUtils.e(String.format(Locale.ENGLISH, "LoadSplashADFail, eCode=%d, errorMsg=%s", adError.getErrorCode(),
                adError.getErrorMsg()));
        /**
         * 为防止无广告时造成视觉上类似于"闪退"的情况，设定无广告时页面跳转根据需要延迟一定时间，demo
         * 给出的延时逻辑是从拉取广告开始算开屏最少持续多久，仅供参考，开发者可自定义延时逻辑，如果开发者采用demo
         * 中给出的延时逻辑，也建议开发者考虑自定义minSplashTimeWhenNoAD的值
         **/
        long alreadyDelayMills = System.currentTimeMillis() - fetchSplashADTime;//从拉广告开始到onNoAD已经消耗了多少时间
        long shouldDelayMills = alreadyDelayMills > minSplashTimeWhenNoAD ? 0 : minSplashTimeWhenNoAD
                - alreadyDelayMills;//为防止加载广告失败后立刻跳离开屏可能造成的视觉上类似于"闪退"的情况，根据设置的minSplashTimeWhenNoAD
        // 计算出还需要延时多久
        handler.postDelayed(mSkipAction, shouldDelayMills);
        MobclickAgent.onEvent(activity, "gdt_splash_adv_load_fail");
    }

    @Override
    public void onADPresent() {

    }

    @Override
    public void onADClicked() {
        Log.e("suikajy", "onADClicked");
        MobclickAgent.onEvent(activity, "gdt_splash_adv_click");
    }

    @Override
    public void onADTick(long l) {
        Log.e("suikajy", "onADTick: " + l);
        skipView.setAlpha(1.0f);
        skipView.setText(String.format(Locale.CHINESE, SKIP_TEXT, Math.round(l / 1000f)));
    }

    @Override
    public void onADExposure() {
        Log.e("suikajy", "SplashADExposure");
        MobclickAgent.onEvent(activity, "gdt_splash_adv_show");
        MobclickAgent.onEvent(activity, "gdt_splash_adv_load_success");
    }

    /**
     * 设置一个变量来控制当前开屏页面是否可以跳转，当开屏广告为普链类广告时，点击会打开一个广告落地页，此时开发者还不能打开自己的App主页。当从广告落地页返回以后，
     * 才可以跳转到开发者自己的App主页；当开屏广告是App类广告时只会下载App。
     */
    private void next() {
        if (canJump) {
            mSkipAction.run();
        } else {
            canJump = true;
        }
    }

    public void onPause() {
        canJump = false;
    }

    public void onResume() {
        if (canJump) {
            next();
        }
        canJump = true;
    }

    public void onDestroy() {
        handler.removeCallbacksAndMessages(null);
    }
}
