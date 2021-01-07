package com.bule.free.ireader.common.adv.ttad.del;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.R;
import com.bule.free.ireader.common.adv.ttad.config.TTAdManagerHolder;
import com.bule.free.ireader.common.library.glide.GlideExtKt;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.model.ApiConfig;
import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.FilterWord;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdDislike;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAppDownloadListener;
import com.bytedance.sdk.openadsdk.TTNativeExpressAd;
import com.bytedance.sdk.openadsdk.TTImage;
import com.bytedance.sdk.openadsdk.TTNativeAd;
import com.umeng.analytics.MobclickAgent;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by suikajy on 2019-05-10
 * <p>
 * 采用的是NativeBanner
 */
public class TTAdBannerDel2 {
    private TTAdNative mTTAdNative;
    private FrameLayout mBannerContainer;
    private final Activity mActivity;
    private final Runnable mCloseAction;
    private TTNativeExpressAd mTTAd;

    public TTAdBannerDel2(Activity activity, FrameLayout adContainer, @NonNull Runnable closeAction) {
        this.mBannerContainer = adContainer;
        this.mActivity = activity;
        mCloseAction = closeAction;
        //step2:创建TTAdNative对象
        mTTAdNative = TTAdManagerHolder.get().createAdNative(activity);
        //step3:可选，强烈建议在合适的时机调用):申请部分权限，如read_phone_state,防止获取不了imei时候，下载类广告没有填充的问题。
        //TTAdManagerHolder.get().requestPermissionIfNecessary(activity);
    }

    public void show() {
        if ("1".equals(ApiConfig.INSTANCE.getBanner_ad_switch())) {
            if (!ApiConfig.INSTANCE.isNoAd()) {
               // loadBannerAd(Const.INSTANCE.getChannelConfig().getTtad().getBanner_common_id(), false);
                loadBannerAdUpdate(Const.INSTANCE.getChannelConfig().getTtad().getBanner_common_id(), false);
            } else {
                LogUtils.e("阅读底部banner关闭，广告类型穿山甲，原因：用户是vip");
            }
        } else {
            LogUtils.e("阅读底部banner关闭，广告类型穿山甲，原因：后台控制关闭");
        }

    }

    public void showInRead() {
        if ("1".equals(ApiConfig.INSTANCE.getBanner_ad_switch())) {
            if (!ApiConfig.INSTANCE.isNoAd()) {
                loadBannerAd(Const.INSTANCE.getChannelConfig().getTtad().getBanner_read_bottom_pos_id(), true);
            } else {
                LogUtils.e("阅读底部banner关闭，广告类型穿山甲，原因：用户是vip");
            }
        } else {
            LogUtils.e("阅读底部banner关闭，广告类型穿山甲，原因：后台控制关闭");
        }

    }

    // 加载banner广告
    private void loadBannerAd(String bannerId, boolean isInReadPage) {

        final String loadEvent = isInReadPage ? "ttad_banner_adv_load" : "ttad_banner_adv_load_other";
        final String showEvent = isInReadPage ? "ttad_banner_adv_show" : "ttad_banner_adv_show_other";
        final String clickEvent = isInReadPage ? "ttad_banner_adv_click" : "ttad_banner_adv_click_other";
        final String loadFailEvent = isInReadPage ? "ttad_banner_adv_load_fail" : "ttad_banner_adv_load_fail_other";
        final String loadSuccessEvent = isInReadPage ? "ttad_banner_adv_load_success" : "ttad_banner_adv_load_success_other";
        //step4:创建广告请求参数AdSlot,注意其中的setNativeAdtype方法，具体参数含义参考文档
        final AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(bannerId)
                .setSupportDeepLink(true)
                .setImageAcceptedSize(600, 257)
                .setNativeAdType(AdSlot.TYPE_BANNER) //请求原生广告时候，请务必调用该方法，设置参数为TYPE_BANNER或TYPE_INTERACTION_AD
                .setAdCount(1)
                .build();

        //step5:请求广告，对请求回调的广告作渲染处理
        MobclickAgent.onEvent(mActivity, loadEvent);
        mTTAdNative.loadNativeAd(adSlot, new TTAdNative.NativeAdListener() {


            @Override
            public void onError(int code, String message) {
                //LogUtils.e("load error : " + code + ", " + message);
                MobclickAgent.onEvent(mActivity, loadFailEvent);
            }

            @Override
            public void onNativeAdLoad(List<TTNativeAd> ads) {
                if (ads == null || ads.get(0) == null) {
                    return;
                }
                View bannerView = LayoutInflater.from(mActivity).inflate(R.layout.ttad_banner, mBannerContainer, false);
                if (bannerView == null) {
                    return;
                }
                MobclickAgent.onEvent(mActivity, "ttad_banner_adv_load_count", String.valueOf(ads.size()));
                mBannerContainer.removeAllViews();
                mBannerContainer.setVisibility(View.VISIBLE);
                mBannerContainer.addView(bannerView);
                MobclickAgent.onEvent(mActivity, showEvent);
                MobclickAgent.onEvent(mActivity, loadSuccessEvent);
                //绑定原生广告的数据
                setAdData(bannerView, ads.get(0));
            }
        });
    }


    private void loadBannerAdUpdate(String bannerId, boolean isInReadPage) {

        final String loadEvent = isInReadPage ? "ttad_banner_adv_load" : "ttad_banner_adv_load_other";
        final String showEvent = isInReadPage ? "ttad_banner_adv_show" : "ttad_banner_adv_show_other";
        final String clickEvent = isInReadPage ? "ttad_banner_adv_click" : "ttad_banner_adv_click_other";
        final String loadFailEvent = isInReadPage ? "ttad_banner_adv_load_fail" : "ttad_banner_adv_load_fail_other";
        final String loadSuccessEvent = isInReadPage ? "ttad_banner_adv_load_success" : "ttad_banner_adv_load_success_other";
        //step4:创建广告请求参数AdSlot,注意其中的setNativeAdtype方法，具体参数含义参考文档
        final AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(bannerId)
                .setSupportDeepLink(true)
                .setImageAcceptedSize(600, 257)
                .setExpressViewAcceptedSize(600,257) //期望模板广告view的size,单位dp
                .setAdCount(1)
                .build();

        //step5:请求广告，对请求回调的广告作渲染处理
        MobclickAgent.onEvent(mActivity, loadEvent);


        //step5:请求广告，对请求回调的广告作渲染处理
        mTTAdNative.loadBannerExpressAd(adSlot, new TTAdNative.NativeExpressAdListener() {
            @Override
            public void onError(int code, String message) {
                MobclickAgent.onEvent(mActivity, loadFailEvent);
                mBannerContainer.removeAllViews();
            }

            @Override
            public void onNativeExpressAdLoad(List<TTNativeExpressAd> ads) {
                if (ads == null || ads.get(0) == null) {
                    return;
                }

                mTTAd = ads.get(0);
                bindAdListener(mTTAd);
                mTTAd.render();

                MobclickAgent.onEvent(mActivity, "ttad_banner_adv_load_count", String.valueOf(ads.size()));

                /*

                View bannerView = LayoutInflater.from(mActivity).inflate(R.layout.ttad_banner, mBannerContainer, false);
                if (bannerView == null) {
                    return;
                }

                mBannerContainer.removeAllViews();
                mBannerContainer.setVisibility(View.VISIBLE);
                mBannerContainer.addView(bannerView);
                MobclickAgent.onEvent(mActivity, showEvent);
                MobclickAgent.onEvent(mActivity, loadSuccessEvent);
                //绑定原生广告的数据
                setAdData(bannerView, ads.get(0));
                */
            }
        });


    }

    private void bindAdListener(TTNativeExpressAd ad) {
        ad.setExpressInteractionListener(new TTNativeExpressAd.ExpressAdInteractionListener() {
            @Override
            public void onAdClicked(View view, int type) {
               // TToast.show(mContext, "广告被点击");
                MobclickAgent.onEvent(mActivity, "ttad_banner_adv_click");
            }

            @Override
            public void onAdShow(View view, int type) {
               // TToast.show(mContext, "广告展示");
            }

            @Override
            public void onRenderFail(View view, String msg, int code) {
                //TToast.show(mContext, msg+" code:"+code);
            }

            @Override
            public void onRenderSuccess(View view, float width, float height) {
                //返回view的宽高 单位 dp
               // TToast.show(mContext, "渲染成功");
                mBannerContainer.removeAllViews();
                mBannerContainer.setVisibility(View.VISIBLE);
                mBannerContainer.addView(view);
            }
        });
        //dislike设置
        //bindDislike(ad, false);
        if (ad.getInteractionType() != TTAdConstant.INTERACTION_TYPE_DOWNLOAD){
            return;
        }
        ad.setDownloadListener(new TTAppDownloadListener() {
            @Override
            public void onIdle() {
                //Toast.show(BannerExpressActivity.this, "点击开始下载", Toast.LENGTH_LONG);
            }

            @Override
            public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
              /*  if (!mHasShowDownloadActive) {
                    mHasShowDownloadActive = true;
                    TToast.show(BannerExpressActivity.this, "下载中，点击暂停", Toast.LENGTH_LONG);
                }
                */
            }

            @Override
            public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
                //TToast.show(BannerExpressActivity.this, "下载暂停，点击继续", Toast.LENGTH_LONG);
            }

            @Override
            public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
                //TToast.show(BannerExpressActivity.this, "下载失败，点击重新下载", Toast.LENGTH_LONG);
            }

            @Override
            public void onInstalled(String fileName, String appName) {
                //TToast.show(BannerExpressActivity.this, "安装完成，点击图片打开", Toast.LENGTH_LONG);
            }

            @Override
            public void onDownloadFinished(long totalBytes, String fileName, String appName) {
                //TToast.show(BannerExpressActivity.this, "点击安装", Toast.LENGTH_LONG);
            }
        });
    }


    /**
     * 设置广告的不喜欢, 注意：强烈建议设置该逻辑，如果不设置dislike处理逻辑，则模板广告中的 dislike区域不响应dislike事件。
     * @param ad
     * @param customStyle 是否自定义样式，true:样式自定义
     */

     /*
    private void bindDislike(TTNativeExpressAd ad, boolean customStyle) {
        if (customStyle) {
            //使用自定义样式
            List<FilterWord> words = ad.getFilterWords();
            if (words == null || words.isEmpty()) {
                return;
            }

            final DislikeDialog dislikeDialog = new DislikeDialog(this, words);
            dislikeDialog.setOnDislikeItemClick(new DislikeDialog.OnDislikeItemClick() {
                @Override
                public void onItemClick(FilterWord filterWord) {
                    //屏蔽广告
                    TToast.show(mContext, "点击 " + filterWord.getName());
                    //用户选择不喜欢原因后，移除广告展示
                    mExpressContainer.removeAllViews();
                }
            });
            ad.setDislikeDialog(dislikeDialog);
            return;
        }
        //使用默认模板中默认dislike弹出样式
        ad.setDislikeCallback(BannerExpressActivity.this, new TTAdDislike.DislikeInteractionCallback() {
            @Override
            public void onSelected(int position, String value) {
                TToast.show(mContext, "点击 " + value);
                //用户选择不喜欢原因后，移除广告展示
                mExpressContainer.removeAllViews();
            }

            @Override
            public void onCancel() {
                TToast.show(mContext, "点击取消 ");
            }
        });
    }
    */

    private void setAdData(View bannerView, TTNativeAd nativeAd) {
        ImageView ivDislike = bannerView.findViewById(R.id.iv_dislike);
        TextView tvSubTitle = bannerView.findViewById(R.id.tv_sub_title);
        TextView tvTitle = bannerView.findViewById(R.id.tv_title);
        ImageView ivBannerCover = bannerView.findViewById(R.id.iv_banner_cover);
        tvTitle.setText(nativeAd.getTitle());
        tvSubTitle.setText(nativeAd.getDescription());

//        ((TextView) nativeView.findViewById(R.id.tv_native_ad_title)).setText(nativeAd.getTitle());
//        ((TextView) nativeView.findViewById(R.id.tv_native_ad_desc)).setText(nativeAd.getDescription());
//        ImageView imgDislike = nativeView.findViewById(R.id.img_native_dislike);
        bindDislikeAction(nativeAd, ivDislike);
        if (nativeAd.getImageList() != null && !nativeAd.getImageList().isEmpty()) {
            TTImage image = nativeAd.getImageList().get(0);
            if (image != null && image.isValid()) {
                GlideExtKt.load(ivBannerCover, image.getImageUrl());
            }
        }
//        TTImage icon = nativeAd.getIcon();
//        if (icon != null && icon.isValid()) {
//
//            ImageOptions options = new ImageOptions();
//            mAQuery.id((bannerView.findViewById(R.id.iv_native_icon))).image(icon.getImageUrl(), options);
//        }
//        mCreativeButton = (Button) bannerView.findViewById(R.id.btn_native_creative);
        //可根据广告类型，为交互区域设置不同提示信息
        switch (nativeAd.getInteractionType()) {
            case TTAdConstant.INTERACTION_TYPE_DOWNLOAD:
                //如果初始化ttAdManager.createAdNative(getApplicationContext())没有传入activity 则需要在此传activity，否则影响使用Dislike逻辑
                nativeAd.setActivityForDownloadApp(mActivity);
//                mCreativeButton.setVisibility(View.VISIBLE);
                nativeAd.setDownloadListener(mDownloadListener); // 注册下载监听器
                break;
            case TTAdConstant.INTERACTION_TYPE_DIAL:
                // 拨打电话逻辑
//                mCreativeButton.setVisibility(View.VISIBLE);
//                mCreativeButton.setText("立即拨打");
                break;
            case TTAdConstant.INTERACTION_TYPE_LANDING_PAGE:
            case TTAdConstant.INTERACTION_TYPE_BROWSER:
//                mCreativeButton.setVisibility(View.VISIBLE);
//                mCreativeButton.setText("查看详情");
                break;
            default:
//                mCreativeButton.setVisibility(View.GONE);
                LogUtils.e("交互类型异常");
        }

        //可以被点击的view, 也可以把nativeView放进来意味整个广告区域可被点击
        List<View> clickViewList = new ArrayList<>();
        clickViewList.add(bannerView);

        //触发创意广告的view（点击下载或拨打电话）
        List<View> creativeViewList = new ArrayList<>();
        //如果需要点击图文区域也能进行下载或者拨打电话动作，请将图文区域的view传入
        //creativeViewList.add(nativeView);
        creativeViewList.add(bannerView);

        //重要! 这个涉及到广告计费，必须正确调用。convertView必须使用ViewGroup。
        nativeAd.registerViewForInteraction((ViewGroup) bannerView, clickViewList, creativeViewList, ivDislike, new TTNativeAd.AdInteractionListener() {
            @Override
            public void onAdClicked(View view, TTNativeAd ad) {
                if (ad != null) {
                    MobclickAgent.onEvent(mActivity, "ttad_banner_adv_click");
                    //LogUtils.e("广告" + ad.getTitle() + "被点击");
                }
            }

            @Override
            public void onAdCreativeClick(View view, TTNativeAd ad) {
                if (ad != null) {
                    //LogUtils.e("广告" + ad.getTitle() + "被创意按钮被点击");
                }
            }

            @Override
            public void onAdShow(TTNativeAd ad) {
                if (ad != null) {
                    //LogUtils.e("广告" + ad.getTitle() + "展示");
                }
            }
        });

    }

    //接入网盟的dislike 逻辑，有助于提示广告精准投放度
    private void bindDislikeAction(TTNativeAd ad, View dislikeView) {
        final TTAdDislike ttAdDislike = ad.getDislikeDialog(mActivity);
        if (ttAdDislike != null) {
            ttAdDislike.setDislikeInteractionCallback(new TTAdDislike.DislikeInteractionCallback() {
                @Override
                public void onSelected(int position, String value) {
//                    mBannerContainer.removeAllViews();
                    mCloseAction.run();
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
            //LogUtils.e("ttad: 开始下载");
//            if (mCreativeButton != null) {
//                mCreativeButton.setText("开始下载");
//            }
        }

        @SuppressLint("SetTextI18n")
        @Override
        public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
//            if (mCreativeButton != null) {
            if (totalBytes <= 0L) {
                LogUtils.e("ttad: 下载中 percent: 0");
//                    mCreativeButton.setText("下载中 percent: 0");
            } else {
                LogUtils.e("ttad: 下载中 percent: " + (currBytes * 100 / totalBytes));
//                    mCreativeButton.setText("下载中 percent: " + (currBytes * 100 / totalBytes));
            }
//            }
        }

        @SuppressLint("SetTextI18n")
        @Override
        public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
            if (totalBytes == 0){
                LogUtils.e("下载暂停 percent: 0");
            } else {
                LogUtils.e("下载暂停 percent: " + (currBytes * 100 / totalBytes));
            }

//            if (mCreativeButton != null) {
//                mCreativeButton.setText("下载暂停 percent: " + (currBytes * 100 / totalBytes));
//            }
        }

        @Override
        public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
            LogUtils.e("重新下载");
//            if (mCreativeButton != null) {
//                mCreativeButton.setText("重新下载");
//            }
        }

        @Override
        public void onInstalled(String fileName, String appName) {
            LogUtils.e("点击打开");
//            if (mCreativeButton != null) {
//                mCreativeButton.setText("点击打开");
//            }
        }

        @Override
        public void onDownloadFinished(long totalBytes, String fileName, String appName) {
            LogUtils.e("点击安装");
//            if (mCreativeButton != null) {
//                mCreativeButton.setText("点击安装");
//            }
        }
    };

    public void release() {
        if (mBannerContainer == null) return;
        mBannerContainer.removeAllViews();
        mBannerContainer.setVisibility(View.GONE);
        if (mTTAd != null) {
            mTTAd.destroy();
        }
    }



}
