package com.bule.free.ireader.newbook.adv;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.adv.AdvController;
import com.bule.free.ireader.common.adv.baiduad.BaiduBannerAdDel;
import com.bule.free.ireader.common.adv.gdt.GdtPageAdvDel;
import com.bule.free.ireader.common.adv.ttad.del.TTAdPageAdDel;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.Res;
import com.bule.free.ireader.common.widget.BatteryView;
import com.bule.free.ireader.common.widget.swipeback.SwipeBackFragment;
import com.bule.free.ireader.common.widget.swipeback.SwipeBackLayout;
import com.bule.free.ireader.newbook.ReadBookConfig;
import com.bule.free.ireader.newbook.ui.NewReadBookViewDel;


/**
 * 阅读页 全屏广告
 * Created by lait on 2018/8/28.
 */
@Deprecated
public class ReadFullAdFragment extends SwipeBackFragment {

    private static final String EXT_BAR = "isTranslucentDecor";
    private FrameLayout adContainer;
    @Nullable
    private GdtPageAdvDel mGdtAd;
    @Nullable
    private BaiduBannerAdDel mBaiduBannerAdvDel;

    public static ReadFullAdFragment getInstance(boolean isTranslucentDecor) {
        ReadFullAdFragment fragment = new ReadFullAdFragment();
        Bundle ext = new Bundle();
        ext.putBoolean(EXT_BAR, isTranslucentDecor);
        fragment.setArguments(ext);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NO_TITLE, R.style.CustomFragmentDialog);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        getDialog().setCanceledOnTouchOutside(false);
//        getDialog().setOnKeyListener(new DialogInterface.OnKeyListener() {
//            @Override
//            public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
//                if (keyCode == KeyEvent.KEYCODE_BACK) {
//                    return true;
//                }
//                return false;
//            }
//        });
        View rootView = inflater.inflate(R.layout.fragment_read_full_ad, container, false);
        //Do something
        final Window window = getDialog().getWindow();
//                window.setBackgroundDrawableResource(R.color.common_bg);
        window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        window.getDecorView().setPadding(0, 0, 0, 0);
        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);// 设置全屏
        WindowManager.LayoutParams wlp = window.getAttributes();
        wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
        wlp.height = WindowManager.LayoutParams.MATCH_PARENT;
        //wlp.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL;
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//            wlp.flags |= WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION;
//        }
        wlp.gravity = Gravity.CENTER;
        wlp.flags &= ~WindowManager.LayoutParams.FLAG_FULLSCREEN;
        window.setAttributes(wlp);
        adContainer = rootView.findViewById(R.id.full_ad);
        RelativeLayout rlBg = rootView.findViewById(R.id.rl_bg);
        BatteryView batteryView = rootView.findViewById(R.id.mBatteryView);
        rlBg.setBackground(Res.INSTANCE.drawable(ReadBookConfig.INSTANCE.getTextBackground()));
        batteryView.setBatteryColor(ReadBookConfig.INSTANCE.getTextColor());
        loadAd();
        // 设置滑动方向
        getSwipeBackLayout().setEdgeOrientation(SwipeBackLayout.EDGE_RIGHT); // EDGE_LEFT(默认),EDGE_ALL
        // EDGE_LEFT
        // (默认),EDGE_ALL
        // 设置侧滑触摸生效区域 MAX,MED,MIN,custom
        setEdgeLevel(SwipeBackLayout.EdgeLevel.MAX);
        // 滑动过程监听
        getSwipeBackLayout().addSwipeListener(new SwipeBackLayout.OnSwipeListener() {
            @Override
            public void onDragStateChange(int state) {
                // Drag state
                LogUtils.d("onDragStateChange");
            }

            @Override
            public void onEdgeTouch(int edgeFlag) {
                // 触摸的边缘flag
                LogUtils.d("onEdgeTouch");
            }

            @Override
            public void onDragScrolled(float scrollPercent) {
                // 滑动百分比
                LogUtils.d("onDragScrolled");
            }

            @Override
            public void onDismiss() {
                dismiss();
            }
        });

        return attachToSwipeBack(rootView);
    }

    private void loadAd() {
        switch (AdvController.INSTANCE.getSCurrentReadPageBottomAdType()) {
            case TTAD:
                new TTAdPageAdDel(getActivity(), adContainer, aBoolean -> {
                    if (!aBoolean) {
                        mGdtAd = GdtPageAdvDel.attach(adContainer, new GdtPageAdvDel.GdtPageAdListener() {
                            @Override
                            public void onSuccess() {

                            }

                            @Override
                            public void onFailure() {
                                dismiss();
                            }

                            @Override
                            public void onAdClose() {

                            }
                        });
                    }
                }).loadListAd();
                break;
            case BDAD: //百度忽略
            case GDT:
                mGdtAd = GdtPageAdvDel.attach(adContainer, new GdtPageAdvDel.GdtPageAdListener() {
                    @Override
                    public void onSuccess() {

                    }

                    @Override
                    public void onFailure() {
                        new TTAdPageAdDel(getActivity(), adContainer, aBoolean -> {
                            if (!aBoolean) {
                                dismiss();
                            }
                        }).loadListAd();
                    }

                    @Override
                    public void onAdClose() {
                        dismiss();
                    }
                });
                break;
            default:
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mGdtAd != null) {
            mGdtAd.destroy();
        }
        if (mBaiduBannerAdvDel != null) {
            mBaiduBannerAdvDel.onDestroy();
        }
        NewReadBookViewDel.Companion.setLastShowInterstitialAdTime(System.currentTimeMillis());
    }
}
