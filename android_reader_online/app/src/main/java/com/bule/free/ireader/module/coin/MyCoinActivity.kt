package com.bule.free.ireader.module.coin

import android.app.Activity
import android.content.Intent
import android.widget.ImageView
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.model.GoldExchangeItemBean
import com.bule.free.ireader.model.MainActivityChangePageEvent
import com.bule.free.ireader.model.User
import com.bule.free.ireader.model.UserInfoRefreshEvent
import com.bule.free.ireader.main.MainActivity
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.common.utils.ToastUtils
import com.bule.free.ireader.common.utils.onClick
import com.bule.free.ireader.common.utils.onSafeClick
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import kotlinx.android.synthetic.main.activity_my_coin.*

/**
 * Created by suikajy on 2019/3/21
 */
class MyCoinActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, MyCoinActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private val mAdapter = Adapter()

    override val layoutId: Int = R.layout.activity_my_coin

    override fun init() {
        rv_exchange_list.adapter = mAdapter
        Api.getGoldExchangeList().go {
            mAdapter.setNewData(it)
            mAdapter.loadMoreEnd(true)
        }
        refreshView()
        btn_coin_record.post { User.syncToServer() }
    }

    override fun setListener() {
        btn_coin_record.onClick { CoinRecordActivity.start(this) }
        RxBus.toObservable(this, UserInfoRefreshEvent::class.java) { refreshView() }
        btn_earn_coin.onClick {
            RxBus.post(MainActivityChangePageEvent(MainActivity.Page.WELFARE))
            finish()
        }
        toolbar.setOnRightClickListener { CoinIntroActivity.start(this) }
    }

    private fun refreshView() {
        tv_temp1.text = User.coinCount.toString()
    }

    inner class Adapter : BaseQuickAdapter<GoldExchangeItemBean, BaseViewHolder>(R.layout.item_coin_exchange) {
        override fun convert(helper: BaseViewHolder, item: GoldExchangeItemBean) {
            helper.setText(R.id.tv_exchange_name, item.name)
            helper.setGone(R.id.tv_header, helper.adapterPosition == 0)
            when (item.num) {
                "1" -> helper.setImageResource(R.id.iv_thumb, R.drawable.coin_ic_1h_mission)
                "24" -> helper.setImageResource(R.id.iv_thumb, R.drawable.coin_ic_1d_mission)
                (7 * 24).toString() -> helper.setImageResource(R.id.iv_thumb, R.drawable.coin_ic_7d_mission)
            }
            helper.getView<ImageView>(R.id.iv_thumb).load(item.cover)
            helper.setText(R.id.tv_cost, "${item.cost_gold}金币")
            helper.getView<TextView>(R.id.btn_exchange).onSafeClick {
                if (User.coinCount < item.cost_gold.toInt()) {
                    ToastUtils.show("金币不足")
                } else {
                    Api.goldExchange(item.id).go {
                        ToastUtils.show("兑换成功")
                        User.syncToServer()
                    }
                }
            }
        }
    }
}