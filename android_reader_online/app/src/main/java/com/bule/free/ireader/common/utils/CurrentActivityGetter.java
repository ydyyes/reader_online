package com.bule.free.ireader.common.utils;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.ui.activity.SplashAdvActivity;

import java.lang.ref.WeakReference;

/**
 * Created by suikajy on 2019/3/1
 * <p>
 * 获取当前屏幕展示的Activity对象
 * 3.3.5 - 加入判断推啊广告的Web页关闭按钮
 * 3.3.8 - 加入App退至后台时，超过30秒返回时的监听，返回时展示开屏广告
 */
public enum CurrentActivityGetter {

    instance;

    private WeakReference<Activity> sCurrentActivity;
    private static int sForegroundActivityCount = 0;
    private static long sLastBackgroundTime = Long.MAX_VALUE;

    public void register(Application app) {
        app.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

            }

            @Override
            public void onActivityStarted(Activity activity) {
                sForegroundActivityCount++;
                //LogUtils.e(String.format("sForegroundActivityCount: %s", sForegroundActivityCount));
                final long currentTime = System.currentTimeMillis();
                final long differ = currentTime - sLastBackgroundTime;
                if (differ > ApiConfig.INSTANCE.getStrategy_start_load() && !ApiConfig.INSTANCE.isNoAd()) {
                    LogUtils.e(String.format("differ: %s", differ));
                    sLastBackgroundTime = Long.MAX_VALUE;
                    SplashAdvActivity.Companion.start(activity);
                } else {
                    sLastBackgroundTime = Long.MAX_VALUE;
                }
                //fixTuiaIssue(activity);
            }

            @Override
            public void onActivityResumed(Activity activity) {
                instance.setCurrentActivity(activity);
            }

            @Override
            public void onActivityPaused(Activity activity) {

            }

            @Override
            public void onActivityStopped(Activity activity) {
                sForegroundActivityCount--;
                //LogUtils.e(String.format("sForegroundActivityCount: %s", sForegroundActivityCount));

                if (sForegroundActivityCount == 0) {// 应用进入后台
                    sLastBackgroundTime = System.currentTimeMillis();
                } else {
                    sLastBackgroundTime = Long.MAX_VALUE;
                }
            }

            @Override
            public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

            }

            @Override
            public void onActivityDestroyed(Activity activity) {

            }
        });
    }

    private void setCurrentActivity(Activity activity) {
        sCurrentActivity = new WeakReference<>(activity);
    }

    /**
     * 获取当前有焦点的Activity
     */
    @Nullable
    public static synchronized Activity getCurrentActivity() {
        if (instance.sCurrentActivity == null) {
            return null;
        }
        return instance.sCurrentActivity.get();
    }

//    private void fixTuiaIssue(Activity activity) {
//        if (activity.getClass().getSimpleName().equals("LionActivity")) {
//            TextView closeView = new TextView(activity);
//            closeView.setText("关闭");
//            FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
//            lp.gravity = Gravity.RIGHT | Gravity.TOP;
//            lp.topMargin = ScreenUtils.getStatusBarHeight() + ExtKt.dp(5);
//            lp.rightMargin = ExtKt.dp(4);
//            closeView.setLayoutParams(lp);
//            closeView.setOnClickListener(v -> activity.finish());
//            closeView.setGravity(Gravity.CENTER);
//            closeView.setTextColor(0xFF666666);
//            closeView.setTextSize(16);
//            closeView.setPadding(ExtKt.dp(10), ExtKt.dp(6), ExtKt.dp(10), ExtKt.dp(6));
//            FrameLayout rootView = (FrameLayout) activity.getWindow().getDecorView();
//            rootView.addView(closeView);
//        }
//    }
}
