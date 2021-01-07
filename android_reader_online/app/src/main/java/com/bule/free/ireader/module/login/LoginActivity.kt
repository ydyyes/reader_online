package com.bule.free.ireader.module.login

import android.app.Activity
import android.content.Intent
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.LoginEvent
import com.bule.free.ireader.model.User
import com.bule.free.ireader.model.UserInfoRefreshEvent
import com.bule.free.ireader.ui.base.BaseActivity2
import com.umeng.analytics.MobclickAgent
import io.reactivex.Observable
import kotlinx.android.synthetic.main.activity_login.*
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern

/**
 * Created by suikajy on 2019/3/24
 */
class LoginActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, LoginActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private val mCode
        get() = edit_phone_code.text.toString().trim()
    private val mMobileNum
        get() = edit_phone_number.text.toString().trim()

    override val layoutId = R.layout.activity_login

    override fun init() {

    }

    override fun setListener() {
        btn_login.setOnClickListener {
            if (mMobileNum.isEmpty()) {
                ToastUtils.show("请输入手机号码")
                return@setOnClickListener
            }

            if (mCode.isEmpty()) {
                ToastUtils.show("请输入验证码")
                return@setOnClickListener
            }

            if (!isNumeric(mMobileNum)) {
                ToastUtils.show("请输入正确的手机号码")
                return@setOnClickListener
            }

            if (!isNumeric(mCode)) {
                ToastUtils.show("请输入正确的验证码")
                return@setOnClickListener
            }

            doLogin(mMobileNum, mCode)
        }
        tv_get_phone_code.onSafeClick {
            if (mMobileNum.isEmpty()) {
                ToastUtils.show("请输入手机号码")
                return@onSafeClick
            }

            if (!isNumeric(mMobileNum)) {
                ToastUtils.show("请输入正确的手机号码")
                return@onSafeClick
            }
            Api.sendSmsCode(mMobileNum).go { postDelayReqPhoneCode() }
        }
    }

    private fun doLogin(mobile: String, code: String) =
            Api.loginReg(mobile, code)
                    .go {
                        ToastUtils.show("登录成功")
                        User.onLogin(it, mobile)
                        MobclickAgent.onEvent(this, "login", mobile)
                        finish()
                    }

    private fun postDelayReqPhoneCode() {
        ToastUtils.show("验证码已发送")
        val disposable = Observable.intervalRange(0L, 60L, 0L, 1, TimeUnit.SECONDS)
                .async()
                .doOnComplete {
                    LogUtils.e("do on complete")
                    tv_get_phone_code.text = "获取验证码"
                    tv_get_phone_code.isClickable = true
                }.doOnNext {
                    val remainTime = 60 - it
                    tv_get_phone_code.text = "${remainTime}s 后重试"
                    tv_get_phone_code.isClickable = false
                }.subscribe()
        addDisposable(disposable)
    }

    private fun isNumeric(str: String): Boolean {
        val pattern = Pattern.compile("[0-9]*")
        val isNum = pattern.matcher(str)
        return isNum.matches()
    }
}