package com.bule.free.ireader.ui.dialog

import android.app.Activity
import android.app.Dialog
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.ViewGroup
import com.bule.free.ireader.R
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.common.utils.WebViewUtils
import com.bule.free.ireader.common.utils.onSafeClick
import com.bule.free.ireader.main.MainActivity
import com.bule.free.ireader.model.Info
import com.bule.free.ireader.model.MainActivityChangePageEvent
import com.bule.free.ireader.module.coin.MyCoinActivity
import com.bule.free.ireader.module.pay.PayListActivity
import com.bule.free.ireader.ui.activity.ShareActivity
import com.bule.free.ireader.ui.activity.WebViewActivity
import kotlinx.android.synthetic.main.dialog_openning.*

/**
 * Created by suikajy on 2019-06-03
 */
class OpeningDialog(private val mActivity: Activity, val info: Info) : Dialog(mActivity, R.style.OpeningDialog) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_openning)
        val window = window!!
        window.setGravity(Gravity.CENTER)
        //禁用弹出动画，直接显示
        window.setWindowAnimations(0)
        val attributes = window.attributes
        attributes.width = ViewGroup.LayoutParams.MATCH_PARENT
        attributes.height = ViewGroup.LayoutParams.MATCH_PARENT
        window.attributes = attributes
        setCanceledOnTouchOutside(true)
        setListener()
        iv_openning.load(info.cover)
    }

    private fun setListener() {
        iv_openning.onSafeClick {
            when (info.location) {
//                location：内部跳转 1 福利中心 2 兑换金币 3 邀请好友 4 充值页面
                "1" -> { // 跳转福利中心
                    RxBus.post(MainActivityChangePageEvent(MainActivity.Page.WELFARE))
                }
                "2" -> { // 跳转金币兑换
                    MyCoinActivity.start(mActivity)
                }
                "3" -> { // 跳转邀请好友
                    ShareActivity.start(mActivity)
                }
                "4" -> { // 跳转支付页面
                    PayListActivity.start(mActivity)
                }
                else -> {
                    if (info.link.isNotEmpty()) WebViewActivity.start(info.link)
                }
            }
            dismiss()
        }
        btn_close.setOnClickListener { dismiss() }
    }
}
