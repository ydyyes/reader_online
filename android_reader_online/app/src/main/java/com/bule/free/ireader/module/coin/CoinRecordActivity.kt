package com.bule.free.ireader.module.coin

import android.app.Activity
import android.content.Intent
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.model.GoldRecordBean
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.paging.Paging
import com.bule.free.ireader.common.paging.SwipePagingDel
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import kotlinx.android.synthetic.main.activity_coin_record.*

/**
 * Created by suikajy on 2019/3/15
 */
class CoinRecordActivity : BaseActivity2() {
    private val adapter = Adapter()

    private lateinit var paging: Paging<GoldRecordBean>

    companion object {

        fun start(activity: Activity) {
            val intent = Intent(activity, CoinRecordActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId = R.layout.activity_coin_record

    override fun init() {
        paging = SwipePagingDel(adapter, swipe_recycler_view, { page ->
            LogUtils.e("$page")
            Api.getGoldExchangeRecord(page).go { paging.setNewData(it) }
        }) { page ->
            LogUtils.e("$page")
            Api.getGoldExchangeRecord(page).go {
                LogUtils.e("$it")
                paging.loadMoreData(it)
            }
        }
        paging.refresh()
    }

    override fun setListener() {

    }

    inner class Adapter : BaseQuickAdapter<GoldRecordBean, BaseViewHolder>(R.layout.item_coin_record) {
        override fun convert(helper: BaseViewHolder, item: GoldRecordBean) {
            helper.setText(R.id.tv_mission_time, item.create_time)
            helper.setText(R.id.tv_mission_content, item.describe)
            helper.setTextColor(R.id.tv_mission_reward,
                    if (item.num.toInt() < 0) Const.Color.COMMON_AOI
                    else Const.Color.COIN_RED)
            helper.setText(R.id.tv_mission_reward, item.num)
            helper.setText(R.id.tv_mission_title, item.name)
        }
    }
}