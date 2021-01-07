package com.bule.free.ireader.common.adv.baiduad;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.baidu.mobads.AdView;
import com.baidu.mobads.AdViewListener;
import com.baidu.mobads.AppActivity;
import com.bule.free.ireader.Const;
import com.bule.free.ireader.common.library.java1_8.Consumer;
import com.bule.free.ireader.common.utils.ExtKt;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.model.ApiConfig;
import com.umeng.analytics.MobclickAgent;

import org.json.JSONObject;

/**
 * Created by suikajy on 2019-05-10
 */
public class BaiduPageBottomBannerAdDel {
    private final Context context;
    private final FrameLayout mFlAdvContainer;
    private final Consumer<Boolean> mSuccessCallback;
    @Nullable
    private AdView adView;

    public BaiduPageBottomBannerAdDel(Context context, FrameLayout flAdvContainer, Consumer<Boolean> successCallback) {
        this.context = context;
        this.mFlAdvContainer = flAdvContainer;
        this.mSuccessCallback = successCallback;
    }

    public void show() {
//        if (!Const.DEBUG) {
            if ("1".equals(ApiConfig.INSTANCE.getBanner_ad_switch())) {
                if (ApiConfig.INSTANCE.isNoAd()) {
                    LogUtils.e("阅读底部banner关闭，广告类型百度，原因：用户是vip");
                    return;
                }
            } else {
                LogUtils.e("阅读底部banner关闭，广告类型百度，原因：后台控制关闭");
                return;
            }
//        }
        // 默认请求http广告，若需要请求https广告，请设置AdSettings.setSupportHttps为true
        // AdSettings.setSupportHttps(true);

        // 代码设置AppSid，此函数必须在AdView实例化前调用
        // AdView.setAppSid("debug");

        // 设置'广告着陆页'动作栏的颜色主题
        // 目前开放了七大主题：黑色、蓝色、咖啡色、绿色、藏青色、红色、白色(默认) 主题
        AppActivity.setActionBarColorTheme(AppActivity.ActionBarColorTheme.ACTION_BAR_WHITE_THEME);
        // 另外，也可设置动作栏中单个元素的颜色, 颜色参数为四段制，0xFF(透明度, 一般填FF)DE(红)DA(绿)DB(蓝)
        // AppActivity.getActionBarColorTheme().set[Background|Title|Progress|Close]Color(0xFFDEDADB);

        // 创建广告View
        String adPlaceId = Const.BDAD.BANNER_READ_BOTTOM_POS_ID; //  重要：请填上您的广告位ID，代码位错误会导致无法请求到广告
        adView = new AdView(context, adPlaceId);
        // 设置监听器
        adView.setListener(new AdViewListener() {
            public void onAdSwitch() {
                MobclickAgent.onEvent(context, "baidu_bottom_banner_adv_load");
                LogUtils.e("onAdSwitch");
            }

            public void onAdShow(JSONObject info) {
                // 广告已经渲染出来
                LogUtils.e("onAdShow " + info.toString());
                mSuccessCallback.accept(true);
            }

            public void onAdReady(AdView adView) {
                // 资源已经缓存完毕，还没有渲染出来
                LogUtils.e("onAdReady");
                MobclickAgent.onEvent(context, "baidu_bottom_banner_adv_load");
                MobclickAgent.onEvent(context, "baidu_bottom_banner_adv_show");
            }

            public void onAdFailed(String reason) {
                mSuccessCallback.accept(false);
                LogUtils.e("onAdFailed " + reason);
                MobclickAgent.onEvent(context, "baidu_bottom_banner_adv_load");
            }

            public void onAdClick(JSONObject info) {
                MobclickAgent.onEvent(context, "baidu_bottom_banner_adv_click");
                LogUtils.e(info.toString());
            }

            @Override
            public void onAdClose(JSONObject arg0) {
                LogUtils.e("onAdClose");
            }
        });

        DisplayMetrics dm = new DisplayMetrics();
        ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(dm);
        int winW = dm.widthPixels;
        int winH = dm.heightPixels;
        int width = Math.min(winW, winH) - ExtKt.dp(30);
        int height = width * 3 / 20;
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height);
        // 将adView添加到父控件中(注：该父控件不一定为您的根控件，只要该控件能通过addView能添加广告视图即可)
        if (mFlAdvContainer != null && adView != null) {
            mFlAdvContainer.setVisibility(View.VISIBLE);
            MobclickAgent.onEvent(context, "baidu_bottom_banner_adv_load");
            mFlAdvContainer.addView(adView, lp);
        }

    }

    /**
     * Activity销毁时，销毁adView
     */
    public void onDestroy() {
        mFlAdvContainer.removeAllViews();
        mFlAdvContainer.setVisibility(View.GONE);
        if (adView != null) {
            adView.destroy();
        }
    }
}
