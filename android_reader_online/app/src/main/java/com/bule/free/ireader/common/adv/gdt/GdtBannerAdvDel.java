package com.bule.free.ireader.common.adv.gdt;

import android.app.Activity;
import android.support.annotation.Nullable;
import android.view.View;
import android.widget.FrameLayout;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.common.library.java1_8.Consumer;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.model.ApiConfig;
import com.qq.e.ads.banner2.UnifiedBannerADListener;
import com.qq.e.ads.banner2.UnifiedBannerView;
import com.qq.e.comm.util.AdError;
import com.umeng.analytics.MobclickAgent;

/**
 * Created by suikajy on 2019-05-09
 */
public class GdtBannerAdvDel {

    @Nullable
    private final FrameLayout bannerContainer;
    private UnifiedBannerView bv;
    private final Consumer<Boolean> successCallback;
    private final Activity mActivity;
    private final Runnable mCloseAction;

    public GdtBannerAdvDel(Activity activity, FrameLayout bannerContainer, Runnable closeAction, Consumer<Boolean> successCallback) {
        this.bannerContainer = bannerContainer;
        mActivity = activity;
        this.successCallback = successCallback;
        this.mCloseAction = closeAction;
    }

    public void show() {
        if ("1".equals(ApiConfig.INSTANCE.getBanner_ad_switch())) {
            if (ApiConfig.INSTANCE.isNoAd()) {
                LogUtils.e("阅读底部banner关闭，广告类型广点通，原因：用户是vip");
            } else {
                this.load(Const.INSTANCE.getChannelConfig().getGdt().getBanner_pos_id(), false);
            }
        } else {
            LogUtils.e("阅读底部banner关闭，广告类型广点通，原因：后台控制关闭");
        }
    }

    public void showInRead() {
        if ("1".equals(ApiConfig.INSTANCE.getBanner_ad_switch())) {
            if (ApiConfig.INSTANCE.isNoAd()) {
                LogUtils.e("阅读底部banner关闭，广告类型广点通，原因：用户是vip");
            } else {
                this.load(Const.INSTANCE.getChannelConfig().getGdt().getRead_banner_pos_id(), true);
            }
        } else {
            LogUtils.e("阅读底部banner关闭，广告类型广点通，原因：后台控制关闭");
        }
    }

    private void load(String bannerId, boolean isInReadPage) {
        if (bannerContainer == null) return;
        bannerContainer.removeAllViews();
        if (this.bv != null) {
            bv.destroy();
        }
        final String loadEvent = isInReadPage ? "gdt_banner_adv_load" : "gdt_banner_adv_load_other";
        final String showEvent = isInReadPage ? "gdt_banner_adv_show" : "gdt_banner_adv_show_other";
        final String clickEvent = isInReadPage ? "gdt_banner_adv_click" : "gdt_banner_adv_click_other";
        final String loadFailEvent = isInReadPage ? "gdt_banner_adv_load_fail" : "gdt_banner_adv_load_fail_other";
        final String loadSuccessEvent = isInReadPage ? "gdt_banner_adv_load_success" : "gdt_banner_adv_load_success_other";
        MobclickAgent.onEvent(mActivity, "gdt_banner_adv_load");
        this.bv = new UnifiedBannerView(mActivity, Const.INSTANCE.getChannelConfig().getGdt().getApp_id(),
                bannerId, new UnifiedBannerADListener() {
            @Override
            public void onNoAD(AdError adError) {
                successCallback.accept(false);
                MobclickAgent.onEvent(mActivity, loadEvent);
                MobclickAgent.onEvent(mActivity, loadFailEvent);
//                LogUtils.e(String.format("Banner onNoAD，eCode = %d, eMsg = %s", adError.getErrorCode(),
//                        adError.getErrorMsg()));
            }

            @Override
            public void onADReceive() {
//                LogUtils.e("onADReceive");
            }

            @Override
            public void onADExposure() {
//                LogUtils.e("onADExposure");
                MobclickAgent.onEvent(mActivity, loadEvent);
                MobclickAgent.onEvent(mActivity, showEvent);
                MobclickAgent.onEvent(mActivity, loadSuccessEvent);
                successCallback.accept(true);
            }

            @Override
            public void onADClosed() {
                mCloseAction.run();
//                LogUtils.e("onADClosed");
            }

            @Override
            public void onADClicked() {
                MobclickAgent.onEvent(mActivity, clickEvent);
//                LogUtils.e("onADClicked");
            }

            @Override
            public void onADLeftApplication() {
//                LogUtils.e("onADLeftApplication");
            }

            @Override
            public void onADOpenOverlay() {
//                LogUtils.e("onADOpenOverlay");
            }

            @Override
            public void onADCloseOverlay() {
//                LogUtils.e("onADCloseOverlay");
            }
        });
        bannerContainer.setVisibility(View.VISIBLE);
        bannerContainer.addView(bv);
        if (bv != null) {
            bv.loadAD();
        }
    }

    public void doCloseBanner() {
        if (bannerContainer != null) {
            bannerContainer.removeAllViews();
            bannerContainer.setVisibility(View.GONE);
        }
        if (bv != null) {
            bv.destroy();
            bv = null;
        }
    }
}
