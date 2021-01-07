package com.bule.free.ireader.common.adv.yomi;

import android.app.Activity;
import android.content.Context;

import com.bule.free.ireader.App;
import com.bule.free.ireader.Const;
import com.bule.free.ireader.model.User;
import com.bule.free.ireader.model.UserInfoRefreshEvent;
import com.bule.free.ireader.common.utils.CurrentActivityGetter;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.RxBus;
import com.bule.free.ireader.common.utils.ToastUtils;
import com.umeng.analytics.MobclickAgent;

import fsa.wes.ddt.AdManager;
import fsa.wes.ddt.listener.Interface_ActivityListener;
import fsa.wes.ddt.listener.OffersWallDialogListener;
import fsa.wes.ddt.os.EarnPointsOrderList;
import fsa.wes.ddt.os.OffersManager;
import fsa.wes.ddt.os.PointsChangeNotify;
import fsa.wes.ddt.os.PointsEarnNotify;
import fsa.wes.ddt.os.PointsManager;
import io.reactivex.disposables.Disposable;

/**
 * Created by suikajy on 2019/4/3
 */
public abstract class YoMiDel {

    private static PointsChangeNotify sPointsChangeNotify = new PointsChangeNotify() {
        /**
         * 积分余额发生变动时，就会回调本方法（本回调方法执行在UI线程中）
         * <p/>
         * 从5.3.0版本起，客户端积分托管将由 int 转换为 float
         */
        @Override
        public void onPointBalanceChange(float v) {
            if (Const.DEBUG) {
                ToastUtils.show("当前积分余额为" + v);
                LogUtils.e(String.format("msg: %s", v));
            }
            User.INSTANCE.syncToServer();
        }
    };

    private static PointsEarnNotify sPointsEarnNotify = new PointsEarnNotify() {
        /**
         * 积分订单赚取时会回调本方法（本回调方法执行在UI线程中）
         */
        @Override
        public void onPointEarn(Context context, EarnPointsOrderList earnPointsOrderList) {
            if (Const.DEBUG) {
                String msg = "赚取积分余额为" + PointsManager.getInstance(App.instance).queryPoints();
                ToastUtils.show(msg);
                LogUtils.e(String.format("msg: %s", msg));
            }
            User.INSTANCE.syncToServer();
        }
    };

    public static void init() {
        // 自v6.3.0起，所有其他代码必须在初始化接口调用之后才能生效
        // 初始化接口，应用启动的时候调用，参数：appId, appSecret, isEnableYoumiLog
        AdManager.getInstance(App.instance).init(Const.INSTANCE.getChannelConfig().getYomi().getApp_id(), Const.INSTANCE.getChannelConfig().getYomi().getApp_secret(), Const.DEBUG);

        // 有米android 积分墙sdk 5.0.0之后支持定制浏览器顶部标题栏的部分UI
        // setOfferBrowserConfig();

        // 如果开发者使用积分墙的服务器回调,
        // 1.需要告诉sdk，现在采用服务器回调
        // 2.建议开发者传入自己系统中用户id（如：邮箱账号之类的）（请限制在50个字符串以内）
        // 3.务必在下面的OffersManager.getInstance(this).onAppLaunch();代码之前声明使用服务器回调

        OffersManager.getInstance(App.instance).setUsingServerCallBack(true);
        OffersManager.getInstance(App.instance).setCustomUserId(User.INSTANCE.getUniId());

        Disposable disposable = RxBus.INSTANCE.toObservable(UserInfoRefreshEvent.class)
                .subscribe(userInfoRefreshEvent ->
                                OffersManager.getInstance(App.instance).setCustomUserId(User.INSTANCE.getUniId()),
                        throwable -> LogUtils.e(throwable.toString()));

        // 如果使用积分广告，请务必调用积分广告的初始化接口:
        OffersManager.getInstance(App.instance).onAppLaunch();

        // (可选)注册积分监听-随时随地获得积分的变动情况
        PointsManager.getInstance(App.instance).registerNotify(sPointsChangeNotify);

        // (可选)注册积分订单赚取监听（sdk v4.10版本新增功能）
        PointsManager.getInstance(App.instance).registerPointsEarnNotify(sPointsEarnNotify);

        // (可选)设置是否在通知栏显示下载相关提示。默认为true，标识开启；设置为false则关闭。（sdk v4.10版本新增功能）
        // AdManager.getInstance(this).setIsDownloadTipsDisplayOnNotification(false);

        // (可选)设置安装完成后是否在通知栏显示已安装成功的通知。默认为true，标识开启；设置为false则关闭。（sdk v4.10版本新增功能）
        // AdManager.getInstance(this).setIsInstallationSuccessTipsDisplayOnNotification(false);

        // (可选)设置是否在通知栏显示积分赚取提示。默认为true，标识开启；设置为false则关闭。
        // 如果开发者采用了服务器回调积分的方式，那么本方法将不会生效
        // PointsManager.getInstance(this).setEnableEarnPointsNotification(false);

        // (可选)设置是否开启积分赚取的Toast提示。默认为true，标识开启；设置为false这关闭。
        // 如果开发者采用了服务器回调积分的方式，那么本方法将不会生效
        // PointsManager.getInstance(this).setEnableEarnPointsToastTips(false);

        // 查询积分余额
        // 从5.3.0版本起，客户端积分托管将由 int 转换为 float
        float pointsBalance = PointsManager.getInstance(App.instance).queryPoints();
       // LogUtils.e("积分余额：" + pointsBalance);
    }

    // 展示全屏的积分墙界面
    public static void showOffersWall() {
        MobclickAgent.onEvent(App.instance,"yomi_adv_show");
        OffersManager.getInstance(App.instance).showOffersWall();
    }

    // 展示全屏的积分墙界面
    public static void showOffersWall(Interface_ActivityListener listener) {
//        OffersManager.getInstance(App.instance).showOffersWall(new Interface_ActivityListener() {
//
//            /**
//             * 当积分墙销毁的时候，即积分墙的Activity调用了onDestory的时候回调
//             */
//            @Override
//            public void onActivityDestroy(Context context) {
//                Toast.makeText(context, "全屏积分墙退出了", Toast.LENGTH_SHORT).load();
//            }
//        });
        OffersManager.getInstance(App.instance).showOffersWall(listener);
    }

    // 展示对话框的积分墙界面(本方法支持多种重载格式，开发者可以参考文档或者使用代码提示快捷键来了解)
    public static void showOffersWallDialog() {
        Activity currentActivity = CurrentActivityGetter.getCurrentActivity();
        if (currentActivity == null) return;
        OffersManager.getInstance(App.instance).showOffersWallDialog(currentActivity, new OffersWallDialogListener() {

            @Override
            public void onDialogClose() {
                ToastUtils.show("积分墙对话框关闭了");
            }
        });
    }

    // 奖励10积分, 注：调用本方法后，积分余额马上变更，可留意onPointBalanceChange是不是被调用了
    // 从5.3.0版本起，客户端积分托管将由 int 转换为 float
    public static void awardPoints(float points) {
        PointsManager.getInstance(App.instance).awardPoints(points);
    }

    public static void spendPoints(float points) {
        PointsManager.getInstance(App.instance).spendPoints(points);
    }

    public static void onAppExit() {
        OffersManager.getInstance(App.instance).onAppExit();
        PointsManager.getInstance(App.instance).unRegisterPointsEarnNotify(sPointsEarnNotify);
        PointsManager.getInstance(App.instance).unRegisterNotify(sPointsChangeNotify);
    }
}
