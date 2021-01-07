package com.bule.free.ireader.main.fragment

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.model.*
import com.bule.free.ireader.module.coin.MyCoinActivity
import com.bule.free.ireader.module.download.BookDownloadActivity
import com.bule.free.ireader.module.login.BindActivity
import com.bule.free.ireader.module.login.LoginActivity
import com.bule.free.ireader.module.setting.SettingActivity
import com.bule.free.ireader.ui.activity.ShareActivity
import com.bule.free.ireader.ui.base.BaseFragment2
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.module.setting.UserSettingActivity
import com.bule.free.ireader.module.pay.PayListActivity
import com.bule.free.ireader.module.pay.PayLogActivity
import com.bule.free.ireader.module.readhistory.ReadHistoryActivity
import com.bule.free.ireader.ui.activity.FeedBackActivity
import kotlinx.android.synthetic.main.fragment_person.*
import kotlinx.android.synthetic.main.layout_person_menu.*

/**
 * Created by suikajy on 2019/3/24
 */
class PersonFragment : BaseFragment2() {

    override fun getContentViewId() = R.layout.fragment_person

    override fun init(savedInstanceState: Bundle?) {
        refreshView()
    }

    override fun setListener() {
        btn_pay.setOnClickListener { PayListActivity.start(activity!!) }
        btn_pay_log.setOnClickListener { PayLogActivity.start(activity!!) }
        btn_setting.setOnClickListener { SettingActivity.start(activity!!) }
        btn_exchange_coin.setOnClickListener { MyCoinActivity.start(activity!!) }
        btn_bind_phone.setOnClickListener { if (User.phone.isEmpty() && !User.isBound) BindActivity.start(activity!!) }
        btn_feedback.setOnClickListener { if (User.checkLogin(activity!!)) FeedBackActivity.start(activity!!) }
        btn_login.setOnClickListener { if (!User.isLogin()) LoginActivity.start(activity!!) }
        iv_avatar.setOnClickListener { if (User.checkLogin(activity!!)) UserSettingActivity.start(activity!!) }
        btn_cache_list.setOnClickListener {
            if (Const.DEBUG) {
                BookDownloadActivity.start(activity!!)
            } else {
                if (User.checkLogin(activity!!)) BookDownloadActivity.start(activity!!)
            }
        }
        btn_invite_friends.onClick { ShareActivity.start(activity!!) }
        layout_user_coin.setOnClickListener { MyCoinActivity.start(activity!!) }
        btn_read_history.setOnClickListener { ReadHistoryActivity.start(activity!!) }
        subscribeEvent(LoginEvent::class.java) { refreshView() }
        subscribeEvent(LogoutEvent::class.java) { refreshView() }
        subscribeEvent(TodayReadTimeEvent::class.java) { refreshView() }
        subscribeEvent(UserInfoRefreshEvent::class.java) { refreshView() }
    }

    @SuppressLint("SetTextI18n")
    private fun refreshView() {
        if (User.isLogin()) {
            tv_user_name.text = if (User.nickName.isEmpty()) User.phone else User.nickName
            btn_login.visibility = View.GONE
        } else {
            tv_user_name.text = HttpHeader.getUUID().substring(0, 11)
            btn_login.visibility = View.VISIBLE
        }
        if (User.isBound) {
            tv_is_bound.text = "已绑定"
        } else {
            tv_is_bound.text = "未绑定"
        }
        if (User.isVip()) {
            tv_vip.visibility = View.VISIBLE
        } else {
            tv_vip.visibility = View.GONE
        }
        if (User.expire == 0L) {
            tv_expire.text = "普通用户"
        } else {
            tv_expire.text = "会员到期时间：${User.expire.toDateString("yyyy-MM-dd HH:mm")}"
        }
        if (User.inviteCode.isEmpty()) {
            tv_share_code.text = "推荐码获取失败"
        } else {
            tv_share_code.text = "推荐码：${User.inviteCode}"
        }
        if (User.avatarUrl.isNotEmpty()) {
//            iv_avatar.load(User.avatarUrl)
            iv_avatar.load(R.drawable.person_ic_avatar_def)
        } else {
            iv_avatar.load(R.drawable.person_ic_avatar_def)
        }
        tv_coin_count.text = User.coinCount.toString()
        tv_today_read_time.text = User.todayReadTime.toMinute().toString()
    }
}