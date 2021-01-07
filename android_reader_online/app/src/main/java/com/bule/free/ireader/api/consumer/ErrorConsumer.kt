package com.bule.free.ireader.api.consumer

import android.app.AlertDialog
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.api.exception.ApiException
import com.bule.free.ireader.model.OffShelfEvent
import com.bule.free.ireader.model.User
import com.bule.free.ireader.module.login.LoginActivity
import com.bule.free.ireader.common.utils.CurrentActivityGetter
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.ToastUtils
import io.reactivex.functions.Consumer

/**
 * Created by suikajy on 2019/2/25
 *
 * 这个异常也是Rxjava全局的异常处理，
 */
object ErrorConsumer : Consumer<Throwable> {
    override fun accept(t: Throwable) {
        if (t is ApiException) {
            when (t.errorno) {
                // 服务器返回的json格式不对就会走这个分支
                ApiException.JSON_CAST_EXCEPTION -> ToastUtils.show("服务器异常")
                300108 -> { // token失效
                    User.onLogout()
                    val currentActivity = CurrentActivityGetter.getCurrentActivity()
                    if (currentActivity != null) {
                        AlertDialog.Builder(currentActivity)
                                .setMessage("您的登录已过期")
                                .setPositiveButton("重新登录") { _, _ ->
                                    LoginActivity.start(currentActivity)
                                }.create().show()
                    } else {
                        ToastUtils.show("您的登录已过期，请重新登录")
                    }
                }
                400105, 400104 -> { // 书籍下架
                    ToastUtils.show("该作品已下架")
                    RxBus.post(OffShelfEvent)
                }
                300107 -> {
                    ToastUtils.show("手机号已经被绑定，请直接登录或更换手机号")
                }
                300109 -> {
                    ToastUtils.show("账号不存在")
                }
                500101 -> {
                    ToastUtils.show("系统出现异常，请退出后重试")
                }
                300112 -> {
                    ToastUtils.show("账号不存在，请检查后重试")
                }
                else -> ToastUtils.show(t.message)
            }
        }
        LogUtils.e("$t")
//        ToastUtils.load("服务器异常")
    }
}