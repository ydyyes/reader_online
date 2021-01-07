package com.bule.free.ireader.common.adv.ttad.del;

import android.app.Activity;

import com.bule.free.ireader.App;
import com.bule.free.ireader.Const;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.ToastUtils;
import com.bule.free.ireader.common.library.java1_8.Consumer;
import com.bule.free.ireader.common.adv.ttad.config.TTAdManagerHolder;
import com.bytedance.sdk.openadsdk.AdSlot;
import com.bytedance.sdk.openadsdk.TTAdConstant;
import com.bytedance.sdk.openadsdk.TTAdManager;
import com.bytedance.sdk.openadsdk.TTAdNative;
import com.bytedance.sdk.openadsdk.TTAppDownloadListener;
import com.bytedance.sdk.openadsdk.TTRewardVideoAd;
import com.umeng.analytics.MobclickAgent;

import java.util.Locale;

/**
 * Created by suikajy on 2019/3/20
 * <p>
 * 视频广告委托
 */
public class TTAdVideoAdDel {

    private boolean mHasShowDownloadActive = false;

    public void loadAd(Activity activity, Consumer<Boolean> consumer) {

        //step1:初始化sdk
        TTAdManager ttAdManager = TTAdManagerHolder.get();
        //step2:(可选，强烈建议在合适的时机调用):申请部分权限，如read_phone_state,防止获取不了imei时候，下载类广告没有填充的问题。
        //step3:创建TTAdNative对象,用于调用广告请求接口
        TTAdNative mTTAdNative = ttAdManager.createAdNative(App.instance);
        //step4:创建广告请求参数AdSlot,具体参数含义参考文档
        AdSlot adSlot = new AdSlot.Builder()
                .setCodeId(Const.INSTANCE.getChannelConfig().getTtad().getVideo_pos_id())
                .setSupportDeepLink(true)
                .setImageAcceptedSize(1080, 1920)
                .setRewardName("金币") //奖励的名称
                .setRewardAmount(3)  //奖励的数量
                .setUserID("user123")//用户id,必传参数
                .setMediaExtra("media_extra") //附加参数，可选
                .setOrientation(TTAdConstant.VERTICAL) //必填参数，期望视频的播放方向：TTAdConstant.HORIZONTAL 或 TTAdConstant.VERTICAL
                .build();
        //step5:请求广告
        mTTAdNative.loadRewardVideoAd(adSlot, new TTAdNative.RewardVideoAdListener() {
            @Override
            public void onError(int code, String message) {
                LogUtils.e("onError");
                LogUtils.e(String.format(Locale.ENGLISH, "code: %d", code));
                LogUtils.e(String.format("message: %s", message));
                MobclickAgent.onEvent(activity, "ttad_video_adv_load_fail");
                consumer.accept(false);
            }

            //视频广告加载后，视频资源缓存到本地的回调，在此回调后，播放本地视频，流畅不阻塞。
            @Override
            public void onRewardVideoCached() {
            }

            //视频广告的素材加载完毕，比如视频url等，在此回调后，可以播放在线视频，网络不好可能出现加载缓冲，影响体验。
            @Override
            public void onRewardVideoAdLoad(TTRewardVideoAd ad) {
//                mttRewardVideoAd.setShowDownLoadBar(false);
                MobclickAgent.onEvent(activity, "ttad_video_adv_load_success");
                ad.setRewardAdInteractionListener(new TTRewardVideoAd.RewardAdInteractionListener() {

                    @Override
                    public void onAdShow() {
                        consumer.accept(true);
                    }

                    @Override
                    public void onAdVideoBarClick() {
                    }

                    @Override
                    public void onAdClose() {
                    }

                    //视频播放完成回调
                    @Override
                    public void onVideoComplete() {
                    }

                    @Override
                    public void onVideoError() {
                        consumer.accept(false);
                    }

                    //视频播放完成后，奖励验证回调，rewardVerify：是否有效，rewardAmount：奖励梳理，rewardName：奖励名称
                    @Override
                    public void onRewardVerify(boolean rewardVerify, int rewardAmount, String rewardName) {

                    }

                    @Override
                    public void onSkippedVideo() {
                    }
                });
                ad.setDownloadListener(new TTAppDownloadListener() {
                    @Override
                    public void onIdle() {
                        mHasShowDownloadActive = false;
                    }

                    @Override
                    public void onDownloadActive(long totalBytes, long currBytes, String fileName, String appName) {
                        if (!mHasShowDownloadActive) {
                            mHasShowDownloadActive = true;
                            ToastUtils.show("下载中，点击下载区域暂停");
                        }
                    }

                    @Override
                    public void onDownloadPaused(long totalBytes, long currBytes, String fileName, String appName) {
                        ToastUtils.show("下载暂停，点击下载区域继续");
                    }

                    @Override
                    public void onDownloadFailed(long totalBytes, long currBytes, String fileName, String appName) {
                        ToastUtils.show("下载失败，点击下载区域重新下载");
                    }

                    @Override
                    public void onDownloadFinished(long totalBytes, String fileName, String appName) {
                        ToastUtils.show("下载失败，点击下载区域重新下载");
                    }

                    @Override
                    public void onInstalled(String fileName, String appName) {
                        ToastUtils.show("安装完成，点击下载区域打开");
                    }
                });
                ad.showRewardVideoAd(activity);
            }
        });
    }

}
