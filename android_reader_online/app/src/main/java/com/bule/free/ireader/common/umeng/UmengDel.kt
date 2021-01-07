package com.bule.free.ireader.common.umeng

import android.app.Notification
import android.content.Context
import com.bule.free.ireader.Const

import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.NotificationDelegate
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import com.umeng.message.IUmengRegisterCallback
import com.umeng.message.PushAgent
import com.umeng.message.UmengMessageHandler
import com.umeng.message.UmengNotificationClickHandler
import com.umeng.message.entity.UMessage

/**
 * Created by suikajy on 2019/4/4
 */
object UmengDel {

    fun init(context: Context) {
        // 在此处调用基础组件包提供的初始化函数 相应信息可在应用管理 -> 应用信息 中找到 http://message.umeng.com/list/apps
        // 参数一：当前上下文context；
        // 参数二：应用申请的Appkey（需替换）；
        // 参数三：渠道名称；
        // 参数四：设备类型，必须参数，传参数为UMConfigure.DEVICE_TYPE_PHONE则表示手机；传参数为UMConfigure.DEVICE_TYPE_BOX则表示盒子；默认为手机；
        // 参数五：Push推送业务的secret 填充Umeng Message Secret对应信息（需替换）
        UMConfigure.init(context, Const.channelConfig.umeng.appKey, Const.channelConfig.channelName,
                UMConfigure.DEVICE_TYPE_PHONE, Const.channelConfig.umeng.messageSecret)
        UMConfigure.setLogEnabled(Const.DEBUG)
        initUpush(context)
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.MANUAL)
    }

    fun initUpush(context: Context) {
        //获取消息推送代理示例
        val pushAgent = PushAgent.getInstance(context)

        //注册推送服务，每次调用register方法都会回调该接口
        pushAgent.register(object : IUmengRegisterCallback {

            override fun onSuccess(deviceToken: String) {
                //注册成功会返回deviceToken deviceToken是推送消息的唯一标志
                LogUtils.d("注册成功：deviceToken：-------->  $deviceToken")
            }

            override fun onFailure(s: String, s1: String) {
                LogUtils.d("注册失败：-------->  s:$s,s1:$s1")
            }
        })

        pushAgent.messageHandler = object : UmengMessageHandler() {
            override fun getNotification(context: Context?, msg: UMessage?): Notification {
                if (msg == null) return super.getNotification(context, msg)
                return NotificationDelegate.getUmengNotification(msg.title, msg.text)
            }
        }

        pushAgent.notificationClickHandler = object : UmengNotificationClickHandler() {
            override fun dealWithCustomAction(context: Context?, msg: UMessage?) {
                LogUtils.e("click")
            }
        }
        pushAgent.onAppStart()
    }
}
