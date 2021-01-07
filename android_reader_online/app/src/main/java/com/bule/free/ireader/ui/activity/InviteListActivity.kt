package com.bule.free.ireader.ui.activity

import android.app.Activity
import android.content.Intent
import android.view.LayoutInflater
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.model.InviteFriItemBean
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.common.paging.Paging
import com.bule.free.ireader.common.paging.SwipePagingDel
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import kotlinx.android.synthetic.main.activity_invite_list.*

/**
 * Created by suikajy on 2019/4/9
 */
class InviteListActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, InviteListActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId = R.layout.activity_invite_list
    private val mAdapter by lazy { Adapter() }
    private val mPaging: Paging<InviteFriItemBean> by lazy {
        SwipePagingDel(mAdapter, swipe_recycler_view,
                { page -> Api.inviteFriendRecord(page).go({ beans -> mPaging.setNewData(beans) }, { mPaging.finishRefresh() }, false) },
                { page -> Api.inviteFriendRecord(page).go({ beans -> mPaging.loadMoreData(beans) }, { mPaging.finishLoadMore() }, false) })
    }

    override fun init() {
        val headerView = LayoutInflater.from(this).inflate(R.layout.header_invite_list, swipe_recycler_view, false)
        mAdapter.addHeaderView(headerView)
        mPaging.refresh()
    }

    override fun setListener() {

    }

    inner class Adapter : BaseQuickAdapter<InviteFriItemBean, BaseViewHolder>(R.layout.item_invite_list) {
        override fun convert(helper: BaseViewHolder, item: InviteFriItemBean) {
            helper.setText(R.id.tv_sequence_num, item.id)
            helper.setText(R.id.tv_invite_user, item.pa_mobile)
            helper.setText(R.id.tv_invite_time, item.create_time)
        }
    }
}