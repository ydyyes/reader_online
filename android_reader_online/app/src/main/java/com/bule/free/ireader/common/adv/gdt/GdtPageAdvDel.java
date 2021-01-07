package com.bule.free.ireader.common.adv.gdt;

import android.support.annotation.Nullable;
import android.view.View;
import android.widget.FrameLayout;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.model.Global;
import com.qq.e.ads.cfg.VideoOption;
import com.qq.e.ads.nativ.ADSize;
import com.qq.e.ads.nativ.NativeExpressAD;
import com.qq.e.ads.nativ.NativeExpressADView;
import com.qq.e.comm.util.AdError;
import com.umeng.analytics.MobclickAgent;

import java.util.List;

/**
 * Created by suikajy on 2019-06-04
 */
public class GdtPageAdvDel implements NativeExpressAD.NativeExpressADListener {

    final FrameLayout mFlAdvContainer;

    private NativeExpressADView nativeExpressADView;
    private NativeExpressAD nativeExpressAD;
    @Nullable
    private final GdtPageAdListener mLoadListener;

    /**
     * 如果不展示广告，则返回null
     */
    @Nullable
    public static GdtPageAdvDel attach(FrameLayout container, GdtPageAdListener listener) {

        LogUtils.e("attach");
        LogUtils.e("分享免广告，或者后台关闭广告" + ApiConfig.INSTANCE.isNoAd());
        LogUtils.e("展示广告策略：" + Global.INSTANCE.isCanShowNativeAd());
        LogUtils.e("后台是否开启广告：" + ApiConfig.INSTANCE.getStrategy_ad_open());
        if (ApiConfig.INSTANCE.isNoAd() || !Global.INSTANCE.isCanShowNativeAd()) {
            listener.onFailure();
            return null;
        }
        LogUtils.e("展示广告");
        LogUtils.e("attach end");
        GdtPageAdvDel gdtNativeAdvDel = new GdtPageAdvDel(container, listener);
        Global.INSTANCE.setLastShowChapterEndAdvTime(System.currentTimeMillis());
        gdtNativeAdvDel.addTencentAdv();
        return gdtNativeAdvDel;
    }

    private GdtPageAdvDel(FrameLayout mFlAdvContainer, GdtPageAdListener listener) {
        this.mFlAdvContainer = mFlAdvContainer;
        mLoadListener = listener;
    }

    public void addTencentAdv() {
//        if (nativeExpressADView != null) {
//            ViewGroup parent = (ViewGroup) nativeExpressADView.getParent();
//            if (parent != null) {
//                parent.removeAllViews();
//            }
//            mFlAdvContainer.addView(nativeExpressADView);
//            try {
//                nativeExpressADView.render();
//            } catch (Exception e) {
//            }
//        } else {
        nativeExpressAD = new NativeExpressAD(mFlAdvContainer.getContext(), new ADSize(ADSize.FULL_WIDTH, ADSize.AUTO_HEIGHT),
                Const.INSTANCE.getChannelConfig().getGdt().getApp_id(), Const.INSTANCE.getChannelConfig().getGdt().getInterstitial_pos_id(),
                this); // 这里的Context必须为Activity
        nativeExpressAD.setVideoOption(new VideoOption.Builder()
                .setAutoPlayPolicy(VideoOption.AutoPlayPolicy.WIFI) // 设置什么网络环境下可以自动播放视频
                .setAutoPlayMuted(true) // 设置自动播放视频时，是否静音
                .build()); // setVideoOption是可选的，开发者可根据需要选择是否配置
        nativeExpressAD.loadAD(1);
//        }
    }

    @Override
    public void onADLoaded(List<NativeExpressADView> list) {
        if (list == null) {
            return;
        }
        MobclickAgent.onEvent(mFlAdvContainer.getContext(), "adv_load_load_count", String.valueOf(list.size()));
        LogUtils.e("onNoAD : list size : " + list.size());
        for (NativeExpressADView v : list) {
            MobclickAgent.onEvent(mFlAdvContainer.getContext(), "adv_load", "gdt_page_adv");
        }
        // 释放前一个展示的NativeExpressADView的资源
        if (nativeExpressADView != null) {
            nativeExpressADView.destroy();
        }

        if (mFlAdvContainer.getVisibility() != View.VISIBLE) {
            mFlAdvContainer.setVisibility(View.VISIBLE);
        }

        if (mFlAdvContainer.getChildCount() > 0) {
            mFlAdvContainer.removeAllViews();
        }

        nativeExpressADView = list.get(0);
        // 广告可见才会产生曝光，否则将无法产生收益。
        mFlAdvContainer.postDelayed(new Runnable() {
            @Override
            public void run() {
                mFlAdvContainer.addView(nativeExpressADView);
                try {
                    nativeExpressADView.render();
                } catch (Exception e) {
                }
            }
        }, 500);
    }

    @Override
    public void onRenderFail(NativeExpressADView nativeExpressADView) {
        if (mLoadListener != null) {
            mLoadListener.onFailure();
        }
    }

    @Override
    public void onRenderSuccess(NativeExpressADView nativeExpressADView) {
        if (mLoadListener != null) {
            mLoadListener.onSuccess();
        }
    }

    @Override
    public void onADExposure(NativeExpressADView nativeExpressADView) {

    }

    @Override
    public void onADClicked(NativeExpressADView nativeExpressADView) {
        MobclickAgent.onEvent(mFlAdvContainer.getContext(), "adv_click", "gdt_page_adv");
    }

    @Override
    public void onADClosed(NativeExpressADView nativeExpressADView) {
        LogUtils.e("点击广告中的关闭按钮");
        if (mFlAdvContainer.getChildCount() > 0) {
            mFlAdvContainer.removeAllViews();
            mFlAdvContainer.setVisibility(View.GONE);
            //mFlAdvContainer.postDelayed(this::addTencentAdv, 500);
        }
        if (mLoadListener != null) {
            mLoadListener.onAdClose();
        }
    }

    @Override
    public void onADLeftApplication(NativeExpressADView nativeExpressADView) {

    }

    @Override
    public void onADOpenOverlay(NativeExpressADView nativeExpressADView) {

    }

    @Override
    public void onADCloseOverlay(NativeExpressADView nativeExpressADView) {
    }

    @Override
    public void onNoAD(AdError adError) {
        LogUtils.e("onNoAD : message :" + adError.getErrorMsg() + "\ncode:" + adError.getErrorCode());
        MobclickAgent.onEvent(mFlAdvContainer.getContext(), "adv_load", "gdt_page_adv");
        mFlAdvContainer.post(() -> {
            if (mFlAdvContainer.getChildCount() > 0) {
                mFlAdvContainer.removeAllViews();
                mFlAdvContainer.setVisibility(View.GONE);
            }
        });
        if (mLoadListener != null) {
            mLoadListener.onFailure();
        }
    }

    public void destroy() {
        if (nativeExpressADView != null)
            nativeExpressADView.destroy();
    }

    public interface GdtPageAdListener {
        void onSuccess();

        void onFailure();

        void onAdClose();
    }

}
