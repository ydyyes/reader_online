package com.bule.free.ireader.ui.activity

import android.app.Activity
import android.app.ProgressDialog
import android.content.Intent
import android.text.TextUtils
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.api.exception.ApiException
import com.bule.free.ireader.common.utils.SharedPreUtils
import com.bule.free.ireader.common.utils.ToastUtils
import com.bule.free.ireader.ui.base.BaseActivity2
import com.umeng.analytics.MobclickAgent
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_feed_back.*

/**
 * Created by suikajy on 2019-05-17
 */
class FeedBackActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, FeedBackActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            activity.startActivity(intent)
        }
    }

    private val mEmail get() = edit_feed_email.text.toString().trim()
    private var mProgressDialog: ProgressDialog? = null
    override val layoutId = R.layout.activity_feed_back

    override fun init() {
        MobclickAgent.onEvent(this, "feedback_activity", "feedback")
    }

    override fun setListener() {
        btn_feed.setOnClickListener {
            val feedText = edit_feed_text.text.toString()

            if (!TextUtils.isEmpty(feedText) && feedText.length < 200 && feedText.length > 10) {
                //内容ok
                sendFeedToService(feedText)
            } else if (!TextUtils.isEmpty(feedText) && feedText.length >= 200) {
                //内容ok
                ToastUtils.show("反馈内容过长")
            } else if (!TextUtils.isEmpty(feedText) && feedText.length <= 10) {
                //内容ok
                ToastUtils.show("反馈内容过短")

            } else if (TextUtils.isEmpty(feedText)) {
                //请输入反馈内容
                ToastUtils.show("请输入反馈内容")
            }
        }
    }

    private fun sendFeedToService(content: String) {
        val lastfeed = SharedPreUtils.getInstance().getLong("lastfeed", -1)
        if (System.currentTimeMillis() - lastfeed <= 1000 * 60 * 5) {
            ToastUtils.show("您反馈的太频繁了，请稍后再试!")
            return
        }

        if (mProgressDialog == null) {
            mProgressDialog = ProgressDialog(this)
            mProgressDialog?.setTitle("数据上传中...")
            mProgressDialog?.setCancelable(false)
        }
        mProgressDialog?.show()


        val mDisposable = Api.feedBack(content, mEmail)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(object : SimpleCallback<List<Unit>> {
                    override fun onSuccess(units: List<Unit>) {
                        mProgressDialog?.dismiss()
                        ToastUtils.show("反馈成功")
                        SharedPreUtils.getInstance().putLong("lastfeed", System.currentTimeMillis())
                        finish()
                    }

                    override fun onException(throwable: Throwable) {
                        if (mProgressDialog != null) {
                            mProgressDialog?.dismiss()
                        }
                        if (throwable is ApiException) {
                            val errno = throwable.errorno
                            ToastUtils.show("反馈失败,其它错误 :$errno")
                        } else {
                            ToastUtils.show("反馈失败 ")
                        }
                    }
                })
        addDisposable(mDisposable)
    }
}