package com.bule.free.ireader.common.adv.ttad.del;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.bule.free.ireader.App;
import com.bule.free.ireader.Const;
import com.bule.free.ireader.R;
import com.bule.free.ireader.common.adv.ttad.config.TTAdManagerHolder;
import com.bule.free.ireader.common.library.java1_8.Consumer;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.ToastUtils;
import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.model.Global;
import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAppDownloadListener;
import com.bytedance.sdk.openadsdk.TTFeedAd;
import com.bytedance.sdk.openadsdk.TTImage;
import com.bytedance.sdk.openadsdk.TTNativeAd;
import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Created by suikajy on 2019-06-04
 * 用的信息流的广告位，在阅读时弹出
 */
public class TTAdPageAdDel {

    private TTAdNative mTTAdNative;
    private Activity activity;
    private final AQuery mAQuery;
    private Button mCreativeButton;
    private FrameLayout mFlAdvContainer;
    private final Consumer<Boolean> consumer;

    public TTAdPageAdDel(Activity activity, FrameLayout advContainer, Consumer<Boolean> consumer) {
        this.activity = activity;
        this.mFlAdvContainer = advContainer;
        this.mAQuery = new AQuery(activity);
        TTAdManager ttAdManager = TTAdManagerHolder.get();
        mTTAdNative = ttAdManager.createAdNative(App.instance);
        //申请部分权限，如read_phone_state,防止获取不了imei时候，下载类广告没有填充的问题。
        this.consumer = consumer;
    }

    /**
     * 加载feed广告
     */
    public void loadListAd() {
        if (ApiConfig.INSTANCE.isNoAd() || !Global.INSTANCE.isCanShowNativeAd()) {
            consumer.accept(false);
            return;
        }
        //feed广告请求类型参数
        AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(Const.INSTANCE.getChannelConfig().getTtad().getInterstitial_pos_id())
                .setSupportDeepLink(true)
                .setImageAcceptedSize(640, 320)
                .setAdCount(3)
                .build();
        //调用feed广告异步请求接口
        mTTAdNative.loadFeedAd(adSlot, new TTAdNative.FeedAdListener() {
            @Override
            public void onError(int code, String message) {
                MobclickAgent.onEvent(activity, "ttad_page_adv_load");
                LogUtils.e("onError");
                LogUtils.e(String.format(Locale.ENGLISH, "code: %d", code));
                LogUtils.e(String.format("message: %s", message));
            }

            @Override
            public void onFeedAdLoad(List<TTFeedAd> ads) {
                MobclickAgent.onEvent(activity, "ttad_page_adv_load");
                if (ads == null || ads.isEmpty()) {
                    LogUtils.e("on FeedAdLoaded: ad is null!");
                    return;
                }
                MobclickAgent.onEvent(activity, "ttad_page_adv_load_count", String.valueOf(ads.size()));
                View bannerView = LayoutInflater.from(activity).inflate(R.layout.ttad_native_ad, mFlAdvContainer, false);
                if (bannerView == null) {
                    consumer.accept(false);
                    return;
                }
                if (mCreativeButton != null) {
                    //防止内存泄漏
                    mCreativeButton = null;
                }

                mFlAdvContainer.postDelayed(() -> {
                    mFlAdvContainer.removeAllViews();
                    mFlAdvContainer.addView(bannerView);
                }, 100);

                consumer.accept(true);
                MobclickAgent.onEvent(activity, "ttad_page_adv_show");
                //绑定原生广告的数据
                setAdData(bannerView, ads.get(0));
            }
        });
    }

    private void setAdData(View nativeView, TTFeedAd ttFeedAd) {
        ((TextView) nativeView.findViewById(R.id.tv_native_ad_title)).setText(ttFeedAd.getTitle());
        ((TextView) nativeView.findViewById(R.id.tv_native_ad_desc)).setText(ttFeedAd.getDescription());
        ImageView imgDislike = nativeView.findViewById(R.id.img_native_dislike);
        bindDislikeAction(ttFeedAd, imgDislike);
        if (ttFeedAd.getImageList() != null && !ttFeedAd.getImageList().isEmpty()) {
            TTImage image = ttFeedAd.getImageList().get(0);
            if (image != null && image.isValid()) {
                mAQuery.id(nativeView.findViewById(R.id.iv_native_image)).image(image.getImageUrl());
            }
        }
        mCreativeButton = (Button) nativeView.findViewById(R.id.btn_native_creative);
        //可根据广告类型，为交互区域设置不同提示信息
        switch (ttFeedAd.getInteractionType()) {
            case TTAdConstant.INTERACTION_TYPE_DOWNLOAD:
                //如果初始化ttAdManager.createAdNative(getApplicationContext())没有传入activity 则需要在此传activity，否则影响使用Dislike逻辑
                ttFeedAd.setActivityForDownloadApp(activity);
                mCreativeButton.setVisibility(View.VISIBLE);
                ttFeedAd.setDownloadListener(mDownloadListener); // 注册下载监听器
                break;
            case TTAdConstant.INTERACTION_TYPE_DIAL:
                mCreativeButton.setVisibility(View.VISIBLE);
                mCreativeButton.setText("立即拨打");
                break;
            case TTAdConstant.INTERACTION_TYPE_LANDING_PAGE:
            case TTAdConstant.INTERACTION_TYPE_BROWSER:
                mCreativeButton.setVisibility(View.VISIBLE);
                mCreativeButton.setText("查看详情");
                break;
            default:
                mCreativeButton.setVisibility(View.GONE);
                ToastUtils.show("交互类型异常");
        }

        //可以被点击的view, 也可以把nativeView放进来意味整个广告区域可被点击
        List<View> clickViewList = new ArrayList<>();
        clickViewList.add(nativeView);

        //触发创意广告的view（点击下载或拨打电话）
        List<View> creativeViewList = new ArrayList<>();
        //如果需要点击图文区域也能进行下载或者拨打电话动作，请将图文区域的view传入
        creativeViewList.add(mCreativeButton);

        //重要! 这个涉及到广告计费，必须正确调用。convertView必须使用ViewGroup。
        ttFeedAd.registerViewForInteraction((ViewGroup) nativeView, clickViewList, creativeViewList, imgDislike, new TTNativeAd.AdInteractionListener() {
            @Override
            public void onAdClicked(View view, TTNativeAd ad) {
                if (ad != null) {
                    MobclickAgent.onEvent(activity, "ttad_page_adv_click");
                    LogUtils.e("广告" + ad.getTitle() + "被点击");
                }
            }

            @Override
            public void onAdCreativeClick(View view, TTNativeAd ad) {
                if (ad != null) {
                    LogUtils.e("广告" + ad.getTitle() + "被创意按钮被点击");
                }
            }

            @Override
            public void onAdShow(TTNativeAd ad) {
                if (ad != null) {
                    MobclickAgent.onEvent(activity, "ttad_page_adv_show");
                    LogUtils.e("广告" + ad.getTitle() + "展示");
                }
            }
        });

    }

    //接入网盟的dislike 逻辑，有助于提示广告精准投放度
    private void bindDislikeAction(TTNativeAd ad, View dislikeView) {
        final TTAdDislike ttAdDislike = ad.getDislikeDialog(activity);
        if (ttAdDislike != null) {
            ttAdDislike.setDislikeInteractionCallback(new TTAdDislike.DislikeInteractionCallback() {
                @Override
                public void onSelected(int position, String value) {
                    mFlAdvContainer.removeAllViews();
                }

                @Override
                public void onCancel() {

                }
            });
        }
        dislikeView.setOnClickListener(v -> {
            if (ttAdDislike != null)
                ttAdDislike.showDislikeDialog();
        });
    }

    private final TTAppDownloadListener mDownloadListener = new TTAppDownloadListener() {
        @Override
        public void onIdle() {
            if (mCreativeButton != null) {
                mCreativeButton.setText("开始下载");
            }
        }

        @SuppressLint("SetTextI18n")
        @Override
        public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
            if (mCreativeButton != null) {
                if (totalBytes <= 0L) {
                    mCreativeButton.setText("下载中 percent: 0");
                } else {
                    mCreativeButton.setText("下载中 percent: " + (currBytes * 100 / totalBytes));
                }
            }
        }

        @SuppressLint("SetTextI18n")
        @Override
        public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
            if (mCreativeButton != null) {
                if (totalBytes == 0) {
                    mCreativeButton.setText("下载暂停 percent: " + 0);
                } else {
                    mCreativeButton.setText("下载暂停 percent: " + (currBytes * 100 / totalBytes));
                }
            }
        }

        @Override
        public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
            if (mCreativeButton != null) {
                mCreativeButton.setText("重新下载");
            }
        }

        @Override
        public void onInstalled(String fileName, String appName) {
            if (mCreativeButton != null) {
                mCreativeButton.setText("点击打开");
            }
        }

        @Override
        public void onDownloadFinished(long totalBytes, String fileName, String appName) {
            if (mCreativeButton != null) {
                mCreativeButton.setText("点击安装");
            }
        }
    };

}
