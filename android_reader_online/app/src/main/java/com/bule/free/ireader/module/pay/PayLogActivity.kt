package com.bule.free.ireader.module.pay

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.paging.Paging
import com.bule.free.ireader.common.paging.SwipePagingDel
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.model.GoldRecordBean
import com.bule.free.ireader.model.PayLogBean
import com.bule.free.ireader.ui.base.BaseActivity2
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import kotlinx.android.synthetic.main.activity_coin_record.*
import kotlinx.android.synthetic.main.activity_paylog.*
import kotlinx.android.synthetic.main.activity_paylog.swipe_recycler_view

class PayLogActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, PayLogActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId: Int = R.layout.activity_paylog

    private lateinit var paging: Paging<PayLogBean>

    override fun init() {


//        Api.getPayLog(0,10).go {
//            mAdapter.setNewData(it)
//            mAdapter.loadMoreEnd(true)
//        }

        paging = SwipePagingDel(mAdapter, swipe_recycler_view, { page ->
            LogUtils.e("$page")
            Api.getPayLog(page).go {
                LogUtils.e("pay log refresh it: $it")
                LogUtils.e("it.size: ${it.size}")
                paging.setNewData(it)
            }
        }) { page ->
            LogUtils.e("$page")
            Api.getPayLog(page).go {
                LogUtils.e("pay log load more it: $it")
                paging.loadMoreData(it)
            }
        }
        paging.refresh()

    }

    override fun setListener() {
    }

    private val mAdapter = Adapter()


    inner class Adapter : BaseQuickAdapter<PayLogBean, BaseViewHolder>(R.layout.item_pay_log) {
        override fun convert(helper: BaseViewHolder, item: PayLogBean) {
            helper.setText(R.id.tv_pay_title, item.name)
            helper.setText(R.id.tv_pay_time, item.create_time)
            helper.setText(R.id.tv_pay_price, "支付金额：￥" + item.pay_price)

            helper.getView<TextView>(R.id.tv_pay_status).setTextColor(Color.parseColor("#FFFF3636"))

            if (item.status != null && item.status == "0") {
                helper.setText(R.id.tv_pay_status, "待支付")
            } else if (item.status != null && item.status == "1") {
                helper.setText(R.id.tv_pay_status, "支付中")
            } else if (item.status != null && item.status == "2") {
                helper.setText(R.id.tv_pay_status, "支付成功")
                helper.getView<TextView>(R.id.tv_pay_status).setTextColor(Color.parseColor("#FF2F94F9"))
            } else if (item.status != null && item.status == "3") {
                helper.setText(R.id.tv_pay_status, "支付失败")
            } else if (item.status != null && item.status == "4") {
                helper.setText(R.id.tv_pay_status, "退款")
            } else if (item.status != null && item.status == "5") {
                helper.setText(R.id.tv_pay_status, "关闭")
            } else if (item.status != null && item.status == "6") {
                helper.setText(R.id.tv_pay_status, "撤销")
            } else if (item.status != null && item.status == "7") {
                helper.setText(R.id.tv_pay_status, "取消")
            } else if (item.status != null && item.status == "8") {
                helper.setText(R.id.tv_pay_status, "异常")
            } else {
                helper.setText(R.id.tv_pay_status, "其它")
            }

        }
    }
}