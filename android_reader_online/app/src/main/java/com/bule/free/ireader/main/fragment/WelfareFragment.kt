package com.bule.free.ireader.main.fragment

import android.annotation.SuppressLint
import android.os.Bundle
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.api.consumer.ErrorConsumer
import com.bule.free.ireader.api.exception.ApiException
import com.bule.free.ireader.common.adv.ttad.del.TTAdVideoAdDel
import com.bule.free.ireader.common.adv.yomi.YoMiDel
import com.bule.free.ireader.common.library.banner.GlideImageLoader
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.main.MainActivity
import com.bule.free.ireader.model.*
import com.bule.free.ireader.model.bean.BannerBean
import com.bule.free.ireader.module.coin.MyCoinActivity
import com.bule.free.ireader.module.login.BindActivity
import com.bule.free.ireader.module.pay.PayListActivity
import com.bule.free.ireader.ui.activity.BookDetailActivity
import com.bule.free.ireader.ui.activity.InviteListActivity
import com.bule.free.ireader.ui.activity.ShareActivity
import com.bule.free.ireader.ui.activity.WebViewActivity
import com.bule.free.ireader.ui.base.BaseFragment2
import com.bule.free.ireader.ui.dialog.InputDialog
import com.umeng.analytics.MobclickAgent
import com.youth.banner.BannerConfig
import kotlinx.android.synthetic.main.fragment_welfare.*
import kotlinx.android.synthetic.main.layout_sign_days.*

/**
 * Created by suikajy on 2019/3/13
 */
class WelfareFragment : BaseFragment2() {

    private val mSignIconViewList by lazy {
        listOf(tv_sign_1d, tv_sign_2d, tv_sign_3d, tv_sign_4d,
                tv_sign_5d, tv_sign_6d, tv_sign_7d)
    }

    private var mMaxSignReward = 0
    private val mBannerBeans: MutableList<BannerBean> = mutableListOf()
    private val mInputDialog by lazy { InputDialog(activity!!) { input -> et_invite_code.text = input } }

    override fun getContentViewId() = R.layout.fragment_welfare

    @SuppressLint("SetTextI18n")
    override fun init(savedInstanceState: Bundle?) {
        banner_view.setDelayTime(3000)
        banner_view.setIndicatorGravity(BannerConfig.CENTER)
        banner_view.setImageLoader(GlideImageLoader())
        refreshFullPage()
    }

    override fun setListener() {
        btn_sign.setOnClickListener { doSign() }
        btn_mission_bind.setOnClickListener {
            if (it.isSelected) return@setOnClickListener
            BindActivity.start(activity!!)
        }
        btn_mission_share_per_day.setOnClickListener {
            if (it.isSelected) return@setOnClickListener
            ShareActivity.start(activity!!)
        }
        btn_mission_video.setOnClickListener {
            if (it.isSelected) return@setOnClickListener
            TTAdVideoAdDel().loadAd(activity!!) { isSuccess ->
                if (isSuccess) {
                    User.todayWatchVideoAdCount++
                    Api.missionPost2(Const.MissionType.WATCH_VIDEO.serverValue.toString()).go { User.syncToServer() }
                } else {
                    ToastUtils.show("服务器偷懒了，请稍后再试")
                }
            }
        }
        banner_view.setOnBannerListener(this::onBannerClick)
        et_invite_code.setOnClickListener { if (!User.isInvited) mInputDialog.show() }
        btn_exchange_invite_code.setOnClickListener { view ->
            if (view.isSelected) {
                return@setOnClickListener
            }
            val inviteCode = et_invite_code.text.toString().trim()
            if (inviteCode.isNotEmpty()) {
                Api.missionPost2(task_type = Const.MissionType.INVITE_1_FRIEND.serverValue.toString(), invi_code = inviteCode).go({
                    if (it.res) {
                        ToastUtils.show("兑换成功")
                        view.postDelayed({ User.syncToServer() }, 2000)
                    } else {
                        ToastUtils.show("兑换失败")
                    }
                }, { throwable ->
                    if (throwable is ApiException) {
                        if (throwable.errorno == 400117) {
                            btn_exchange_invite_code.text = "已兑换"
                            btn_exchange_invite_code.isSelected = true
                            User.isInvited = true
                        } else {
                            ErrorConsumer.accept(throwable)
                        }
                    }
                }, false)
            } else {
                ToastUtils.show("请填写邀请码")
            }
        }
        btn_read_time_reward.onClick { view ->
            if (view.isSelected) return@onClick
            RxBus.post(MainActivityChangePageEvent(MainActivity.Page.BOOK_SHELF))
        }
        btn_invite_detial.onClick { InviteListActivity.start(activity!!) }
        btn_invite_1_friend.onClick { ShareActivity.start(activity!!) }
        btn_invite_3_friend.onClick { ShareActivity.start(activity!!) }
        btn_goto_coin_detail.onClick { MyCoinActivity.start(activity!!) }
        btn_download_get_coin.setOnClickListener { YoMiDel.showOffersWall() }
        subscribeEvent(UserInfoRefreshEvent::class.java) { refreshView() }
        subscribeEvent(LoginEvent::class.java) { refreshFullPage() }
        subscribeEvent(LogoutEvent::class.java) { refreshFullPage() }
        subscribeEvent(SignEvent::class.java) { doSign() }
        subscribeEvent(TodayReadTimeEvent::class.java) { refreshView() }
    }

    private fun doSign() {
        if (btn_sign.isSelected) return
        LogUtils.e("签到")
        Api.missionPost2(Const.MissionType.SIGN.serverValue.toString()).go { bean ->
            User.signedDaysCount = bean.num
            ToastUtils.show("签到成功")
            User.todayIsSigned = true
            User.syncToServer()
        }
    }

    private fun refreshFullPage() {
        Api.getSignGoldList().go {
            for (i in mSignIconViewList.indices) {
                mSignIconViewList[i].text = it[i].value.toString()
                mMaxSignReward += it[i].value
            }
            tv_sign_coin_count_max.text = "连续签到7天最高可得${mMaxSignReward}金币"
        }
        Api.getMissionInitData().go {
            User.todayIsSigned = it.NOW_USER_SIGN == 1
            User.signedDaysCount = it.SIGN_CURRNT_NUM
            User.todayShareCount = it.SHARE_TIMES_LIMIT_NUM
            User.todayWatchVideoAdCount = it.AD_BROWSE_LIMIT_NUM
            User.todayReadRewardCount = it.AD_REDARER_LIMIT_NUM
            refreshView()
        }
        Api.getBanner().go({ bannerBeans ->
            LogUtils.e("bannerBeans: $bannerBeans")
            mBannerBeans.clear()
            mBannerBeans.addAll(bannerBeans.filter { it.banner_local == "2" })
            LogUtils.e("mBannerBeans: $mBannerBeans")
            if (mBannerBeans.isNotEmpty()) {
                banner_view.setImages(mBannerBeans)
                banner_view.start()
            }
        }, {
            LogUtils.e(it.toString())
        }, true)
    }

    @SuppressLint("SetTextI18n")
    private fun refreshView() {

        for (i in mSignIconViewList.indices) {
            mSignIconViewList[i].isSelected = i < User.signedDaysCount
        }
        if (User.isLogin() || User.isBound) {
            btn_mission_bind.isSelected = true
            btn_mission_bind.text = "已完成"
        } else {
            btn_mission_bind.isSelected = false
            btn_mission_bind.text = "点我"
        }
        if (User.todayShareCount == ApiConfig.shareTimesLimit) {
            btn_mission_share_per_day.isSelected = true
            btn_mission_share_per_day.text = "已完成"
            tv_share_times.text = "${ApiConfig.shareTimesLimit}/${ApiConfig.shareTimesLimit}"
        } else {
            btn_mission_share_per_day.isSelected = false
            btn_mission_share_per_day.text = "点我"
            tv_share_times.text = "${User.todayShareCount}/${ApiConfig.shareTimesLimit}"
        }
        if (User.todayWatchVideoAdCount == ApiConfig.adBrowseLimit) {
            btn_mission_video.isSelected = true
            btn_mission_video.text = "已完成"
            tv_video_ad_times.text = "${ApiConfig.adBrowseLimit}/${ApiConfig.adBrowseLimit}"
        } else {
            btn_mission_video.isSelected = false
            btn_mission_video.text = "点我"
            tv_video_ad_times.text = "${User.todayWatchVideoAdCount}/${ApiConfig.adBrowseLimit}"
        }
        if (User.todayIsSigned) {
            btn_sign.isSelected = true
            btn_sign.text = "已签到"
        } else {
            btn_sign.isSelected = false
            btn_sign.text = "签到"
        }
        when {
            User.todayReadTime.toMinute() > 120 -> {
                btn_read_time_reward.isSelected = true
                btn_read_time_reward.text = "已完成"
                sv_read_time.setCurrentStep(3)
                // todo : 添加阅读时长接口
                Api.missionPost2(Const.MissionType.READ_120MIN.serverValue.toString(), User.todayReadTime.toSecond()).go({ User.syncToServer() }, {}, false)
            }
            User.todayReadTime.toMinute() > 60 -> {
                btn_read_time_reward.isSelected = false
                btn_read_time_reward.text = "点我"
                sv_read_time.setCurrentStep(2)
                Api.missionPost2(Const.MissionType.READ_120MIN.serverValue.toString(), User.todayReadTime.toSecond()).go({ User.syncToServer() }, {}, false)
            }
            User.todayReadTime.toMinute() > 30 -> {
                btn_read_time_reward.isSelected = false
                btn_read_time_reward.text = "点我"
                sv_read_time.setCurrentStep(1)
                Api.missionPost2(Const.MissionType.READ_120MIN.serverValue.toString(), User.todayReadTime.toSecond()).go({ User.syncToServer() }, {}, false)
            }
            else -> {
                btn_read_time_reward.isSelected = false
                btn_read_time_reward.text = "点我"
                sv_read_time.setCurrentStep(0)
            }
        }
        if (User.isInvited) {
            btn_exchange_invite_code.isSelected = true
            btn_exchange_invite_code.text = "已兑换"
        } else {
            btn_exchange_invite_code.isSelected = false
            btn_exchange_invite_code.text = "兑换"
        }
        tv_share_earn_coin.text = "奖励" + Const.MissionType.SHARE.getEarnCoinCount().toString() + "金币"
        tv_video_ad_earn_coin.text = "奖励" + Const.MissionType.WATCH_VIDEO.getEarnCoinCount().toString() + "金币"
        tv_bind_earn_hour.text = "奖励" + Const.MissionType.BIND_PHONE.getEarnCoinCount().toString() + "金币"
        tv_invite_1_friend_reward.text = "奖励" + Const.MissionType.INVITE_1_FRIEND.getEarnCoinCount().toString() + "金币"
        tv_invite_3_friend_reward.text = "奖励" + Const.MissionType.INVITE_3_FRIEND.getEarnCoinCount().toString() + "金币"
        tv_read_30min_reward.text = Const.MissionType.READ_30MIN.getEarnCoinCount().toString() + "金币"
        tv_read_60min_reward.text = Const.MissionType.READ_60MIN.getEarnCoinCount().toString() + "金币"
        tv_read_120min_reward.text = Const.MissionType.READ_120MIN.getEarnCoinCount().toString() + "金币"
    }

    // banner点击判断
    private fun onBannerClick(position: Int) {
        if (position >= mBannerBeans.size) return
        try {
            val bean = mBannerBeans[position]
            val type = bean.type
            if (type.isEmpty()) {
                return
            }
            MobclickAgent.onEvent(context, "banner_click", bean.id)
            when (bean.inner) {
                "1" -> { // 跳转福利中心
                    RxBus.post(MainActivityChangePageEvent(MainActivity.Page.WELFARE))
                }
                "2" -> { // 跳转金币兑换
                    MyCoinActivity.start(activity!!)
                }
                "3" -> { // 跳转邀请好友
                    ShareActivity.start(activity!!)
                }
                "4" -> { // 跳转支付页面
                    PayListActivity.start(activity!!)
                }
                else -> {
                    if (type == "ad") {
                        val link = bean.link
                        if (link.isEmpty().not()) WebViewUtils.startBrowser(activity,link)
                    } else if (type == "book") {
                        val bookId = bean.id
                        BookDetailActivity.start(context, bookId, false)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}