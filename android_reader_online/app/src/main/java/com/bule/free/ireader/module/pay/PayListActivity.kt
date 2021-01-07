package com.bule.free.ireader.module.pay

import android.app.Activity
import android.app.ProgressDialog
import android.content.Intent
import android.graphics.Paint
import android.net.Uri
import android.util.TypedValue
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.utils.AppUtils
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.ScreenUtils
import com.bule.free.ireader.model.ProductBean
import com.bule.free.ireader.ui.base.BaseActivity2
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import kotlinx.android.synthetic.main.activity_paylist.*

class PayListActivity : BaseActivity2() {

    var selBean: ProductBean? = null

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, PayListActivity::class.java)
            activity.startActivity(intent)
        }
    }


    override val layoutId: Int get() = R.layout.activity_paylist

    override fun init() {

        rv_pay_list.adapter = mAdapter
        mAdapter.setOnItemClickListener { adapter, view, position ->

            for (i in 0 until mAdapter.itemCount) {
                mAdapter.getItem(i)!!.selected = false
            }

            selBean = mAdapter.getItem(position)

            selBean!!.selected = true

            mAdapter.notifyDataSetChanged()

            tv_pay_price.text = selBean!!.discount_price
        }

        Api.getProductList().go({
            mAdapter.setNewData(it)
            mAdapter.loadMoreEnd(true)

            if (it.isNotEmpty()) {
                selBean = it[0]
                selBean!!.selected = true
                tv_pay_price.text = selBean!!.discount_price
            }

        }, {
            LogUtils.e(it)
        })
    }

    private var mProgressDialog: ProgressDialog? = null

    override fun setListener() {

        tv_to_pay.setOnClickListener {
            if (selBean == null) {
                return@setOnClickListener
            }
            if (mProgressDialog == null) {
                mProgressDialog = ProgressDialog(this)
                mProgressDialog!!.setTitle("数据加载中...")
                mProgressDialog!!.setCancelable(false)
            }
            mProgressDialog!!.show()

            Api.getPayOrder(selBean!!.id).go({
                mProgressDialog!!.dismiss()

//                LogUtils.e("sign:${it.sign}")
//
//                var maps = mutableMapOf<String,String>()
//                maps["code"]= it.code
//                maps["merchant_order_no"]= it.merchant_order_no
//                maps["pay_url"]= it.pay_url
//
//                var m_sign = AppUtils.md5SignByMapAndKey(maps,"dssa223ssd43")
//
//                LogUtils.e("m_sign:$m_sign")


                if (it?.pay_url != null) {
                    PayWebActivity.start(this, it.pay_url)
//                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(it.pay_url))
//                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
//                    start(intent)
                }
            }, {
                mProgressDialog!!.dismiss()
            })
        }
    }

    private val mAdapter = Adapter()

    inner class Adapter : BaseQuickAdapter<ProductBean, BaseViewHolder>(R.layout.item_pay_product) {
        override fun convert(helper: BaseViewHolder, item: ProductBean) {

            val fParams = FrameLayout.LayoutParams(ScreenUtils.getScreenWidthSize() / 3, FrameLayout.LayoutParams.WRAP_CONTENT)

            helper.itemView.layoutParams = fParams

            helper.setText(R.id.tv_product_title, item.product_name)

            helper.setText(R.id.tv_sale_price, "￥" + item.discount_price + "元")

            helper.setText(R.id.tv_normal_price, "￥" + item.price + "元")


            if(item.send_gold!=null && item.send_gold == "0"){
//                helper.getView<TextView>(R.id.tv_gift_coin).visibility = View.INVISIBLE
                helper.setText(R.id.tv_gift_coin, "无附送金币")

            }else{
                helper.setText(R.id.tv_gift_coin, "送" + item.send_gold + "金币")
            }

            if(item.price == null || item.price == "0" || item.price == "0.00"){
                helper.getView<TextView>(R.id.tv_normal_price).visibility = View.INVISIBLE
            }else{
                helper.getView<TextView>(R.id.tv_normal_price).visibility = View.VISIBLE
            }

            if(item.discount_price!=null && item.discount_price.length >= 6){
                helper.getView<TextView>(R.id.tv_sale_price).setTextSize(TypedValue.COMPLEX_UNIT_SP,18f)
            }else{
                helper.getView<TextView>(R.id.tv_sale_price).setTextSize(TypedValue.COMPLEX_UNIT_SP,21f)
            }

            helper.getView<TextView>(R.id.tv_normal_price).paint.flags = Paint.STRIKE_THRU_TEXT_FLAG

            if (item.selected) {
                helper.getView<LinearLayout>(R.id.ll_product_content).setBackgroundResource(R.drawable.pay_product_item_broad_sel)
            } else {
                helper.getView<LinearLayout>(R.id.ll_product_content).setBackgroundResource(R.drawable.pay_product_item_broad)
            }

        }
    }


}