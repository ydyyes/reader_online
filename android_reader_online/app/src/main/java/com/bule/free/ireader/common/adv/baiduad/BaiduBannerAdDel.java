package com.bule.free.ireader.common.adv.baiduad;

import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.baidu.mobads.AdView;
import com.baidu.mobads.AdViewListener;
import com.baidu.mobads.AppActivity;
import com.bule.free.ireader.Const;
import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.model.Global;
import com.bule.free.ireader.common.utils.ExtKt;
import com.bule.free.ireader.common.library.java1_8.Consumer;
import com.umeng.analytics.MobclickAgent;

import org.json.JSONObject;


/**
 * Created by suikajy on 2019/4/8
 */
public class BaiduBannerAdDel {

    private final Context context;
    private final FrameLayout mFlAdvContainer;
    private final Consumer<Boolean> mSuccessCallback;
    private AdView adView;

    public BaiduBannerAdDel(Context context, FrameLayout flAdvContainer, Consumer<Boolean> successCallback) {
        this.context = context;
        this.mFlAdvContainer = flAdvContainer;
        this.mSuccessCallback = successCallback;
    }

    public void show() {
        if (ApiConfig.INSTANCE.isNoAd() || !Global.INSTANCE.isCanShowNativeAd()) {
            mSuccessCallback.accept(false);
            return;
        }
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
        String adPlaceId = Const.BDAD.BANNER_POS_ID; //  重要：请填上您的广告位ID，代码位错误会导致无法请求到广告
        adView = new AdView(context, adPlaceId);
        // 设置监听器
        adView.setListener(new AdViewListener() {
            public void onAdSwitch() {
                Log.e("suika", "onAdSwitch");
            }

            public void onAdShow(JSONObject info) {
                // 广告已经渲染出来
                MobclickAgent.onEvent(context, "baidu_banner_adv_show");
                Log.e("suika", "onAdShow " + info.toString());
            }

            public void onAdReady(AdView adView) {
                // 资源已经缓存完毕，还没有渲染出来
                MobclickAgent.onEvent(context, "baidu_banner_adv_load");
                Log.e("suika", "onAdReady " + adView);
            }

            public void onAdFailed(String reason) {
                MobclickAgent.onEvent(context, "baidu_banner_adv_load");
                Log.e("suika", "onAdFailed " + reason);
            }

            public void onAdClick(JSONObject info) {
                // Log.w("", "onAdClick " + info.toString());
                MobclickAgent.onEvent(context, "baidu_banner_adv_click");
            }

            @Override
            public void onAdClose(JSONObject arg0) {
                Log.e("suika", "onAdClose");
            }
        });

        DisplayMetrics dm = new DisplayMetrics();
        ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getMetrics(dm);
        int winW = dm.widthPixels;
        int winH = dm.heightPixels;
        int width = Math.min(winW, winH) - ExtKt.dp(30);
        int height = width * 2 / 3;
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height);
        // 将adView添加到父控件中(注：该父控件不一定为您的根控件，只要该控件能通过addView能添加广告视图即可)

        mFlAdvContainer.postDelayed(new Runnable() {
            @Override
            public void run() {
                mFlAdvContainer.addView(adView, lp);
            }
        }, 500);

    }

    /**
     * Activity销毁时，销毁adView
     */
    public void onDestroy() {
        if (adView != null) {
            adView.destroy();
        }
    }
}
