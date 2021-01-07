package com.bule.free.ireader.common.adv.ttad.del;

import android.app.Activity;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.common.adv.ttad.config.TTAdManagerHolder;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.model.ApiConfig;
import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAppDownloadListener;
import com.bytedance.sdk.openadsdk.TTInteractionAd;

/**
 * Created by suikajy on 2019-06-04
 */
@Deprecated
public class TTAdInterstitialDel {

    public static void show(Activity activity) {
        if (ApiConfig.INSTANCE.isNoAd()) {
            return;
        }
        TTAdNative adNative = TTAdManagerHolder.get().createAdNative(activity);
        //step4:创建插屏广告请求参数AdSlot,具体参数含义参考文档
        AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(Const.INSTANCE.getChannelConfig().getTtad().getInterstitial_pos_id())
                .setSupportDeepLink(true)
                .setImageAcceptedSize(600, 600) //根据广告平台选择的尺寸，传入同比例尺寸
                .build();
        //step5:请求广告，调用插屏广告异步请求接口
        adNative.loadInteractionAd(adSlot, new TTAdNative.InteractionAdListener() {
            @Override
            public void onError(int code, String message) {
                LogUtils.i("code: " + code + "  message: " + message);
            }

            @Override
            public void onInteractionAdLoad(TTInteractionAd ttInteractionAd) {
                LogUtils.i("type:  " + ttInteractionAd.getInteractionType());
                ttInteractionAd.setAdInteractionListener(new TTInteractionAd.AdInteractionListener() {
                    @Override
                    public void onAdClicked() {
                        LogUtils.i("广告被点击");
                    }

                    @Override
                    public void onAdShow() {
                        LogUtils.i("广告被展示");
                    }

                    @Override
                    public void onAdDismiss() {
                        LogUtils.i("广告消失");
                    }
                });
                //如果是下载类型的广告，可以注册下载状态回调监听
                if (ttInteractionAd.getInteractionType() == TTAdConstant.INTERACTION_TYPE_DOWNLOAD) {
                    ttInteractionAd.setDownloadListener(new TTAppDownloadListener() {
                        @Override
                        public void onIdle() {
                            LogUtils.i("点击开始下载");
                        }

                        @Override
                        public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
                            LogUtils.i("下载中");
                        }

                        @Override
                        public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
                            LogUtils.i("下载暂停");
                        }

                        @Override
                        public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
                            LogUtils.i("下载失败");
                        }

                        @Override
                        public void onDownloadFinished(long totalBytes, String fileName, String appName) {
                            LogUtils.i("下载完成");
                        }

                        @Override
                        public void onInstalled(String fileName, String appName) {
                            LogUtils.i("安装完成");
                        }
                    });
                }
                //弹出插屏广告
                ttInteractionAd.showInteractionAd(activity);
            }
        });
    }

}
