package com.bule.free.ireader.main

import android.Manifest
import android.annotation.SuppressLint
import android.view.KeyEvent
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.common.adv.AdvController
import com.bule.free.ireader.common.adv.CachedAdvInfo
import com.bule.free.ireader.common.adv.ShowAdType
import com.bule.free.ireader.model.ApiConfig
import com.bule.free.ireader.model.Global
import com.bule.free.ireader.model.User
import com.bule.free.ireader.ui.activity.GenderSelActivity
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.common.adv.baiduad.BaiduSplashAdDel
import com.bule.free.ireader.common.download.BookDownloader
import com.bule.free.ireader.common.adv.gdt.GdtOpeningAdvDel
import com.bule.free.ireader.common.adv.ttad.del.TTAdSplashAdDel
import com.bule.free.ireader.model.local.BookRepository
import com.bule.free.ireader.model.objectbox.bean.DownloadTaskBean
import com.tbruyelle.rxpermissions2.RxPermissions
import kotlinx.android.synthetic.main.activity_splash.*

/**
 * Created by newbiechen on 17-4-14.
 */
abstract class BaseSplashActivity : BaseActivity2()

class SplashActivity : BaseSplashActivity() {

    companion object {
        // 如果不展示广告的基础等待时间
        const val BASE_WAIT_TIME = 2000L
    }

    private val mSkipAction = Runnable {
        synchronized(this) {
            if (!isSkip) {
                isSkip = true
                if (User.isFirstRun) {
                    GenderSelActivity.start(this)
                } else {
                    MainActivity.start(this)
                }
                finish()
            }
        }
    }
    private var isSkip = false
    private var mGdtOpeningAdvDel: GdtOpeningAdvDel? = null
    private var mTtAdSplashAdDel: TTAdSplashAdDel? = null
    private var mBaiduAdSplashDel: BaiduSplashAdDel? = null

    override val layoutId = R.layout.activity_splash

    override fun init() {
        if (!User.lastOpenAppTime.isToday()) {
            // 新的一天
            User.todayReadTime = 0
            User.todayDownloadTimes = 0
            User.todayShareCount = 0
            User.todayWatchVideoAdCount = 0
            User.todayIsSigned = false
            User.todayChapterEndVideoShowTimes = 0
            User.todayShowedOpeningDialog = false
        }
        iv_splash_bg.setImageResource(Const.channelConfig.bg_splash)
        User.lastOpenAppTime = System.currentTimeMillis()
        // 如果用户在下载时杀死应用，会导致状态异常，这里修正
        BookDownloader.downloadTaskList
                .filter { it.status == DownloadTaskBean.STATUS_LOADING }
                .forEach { it.status = DownloadTaskBean.STATUS_PAUSE }
        SystemBarUtils.hideStableStatusBar(this)
    }

    @SuppressLint("CheckResult")
    override fun setListener() {
        RxPermissions(this)
                .request(Manifest.permission.READ_PHONE_STATE,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.ACCESS_FINE_LOCATION)
                .subscribe({ granted ->
                    if (granted!!) {
                        runSplashLogic()
                    } else {
                        ToastUtils.show("未授予必要的权限，软件无法正常运行")
                        finish()
                    }
                }) {
                    LogUtils.e("$it")
                }
    }

    private fun runSplashLogic() {
//        if (Const.DEBUG) {
//            Handler(Looper.getMainLooper()).postDelayed(mSkipAction, 400)
//        } else {
        BookRepository.migrateOldBookShelf()
        BookRepository.migrateOldDownloadTask()
        BookRepository.migrateOldReadRecord()
        when (AdvController.getSplashAdType()) {
            ShowAdType.GDT -> {
                mGdtOpeningAdvDel = GdtOpeningAdvDel(this, splash_tv_skip, fl_adv_container, mSkipAction)
                mGdtOpeningAdvDel?.init()
            }
            ShowAdType.TTAD -> {
                mTtAdSplashAdDel = TTAdSplashAdDel(this, fl_adv_container, mSkipAction)
                mTtAdSplashAdDel?.onCreate()
            }
            ShowAdType.BDAD -> {
                mBaiduAdSplashDel = BaiduSplashAdDel(this, fl_adv_container, mSkipAction)
                mBaiduAdSplashDel?.show()
            }
            ShowAdType.NONE -> {
                splash_tv_skip.postDelayed(mSkipAction, BASE_WAIT_TIME)
            }
        }
//        }
        Api.reqServerTime {
            Api.getAdvStrategy()
                    .subscribe(SimpleCallback { advStrategyBean ->
                        LogUtils.e("advStrategyBean.toString(): $advStrategyBean")
                        ApiConfig.strategy_ad_open = "1" == advStrategyBean.STRATEGY_AD_OPEN
                        ApiConfig.strategyAdChapterEndIntv = advStrategyBean.STRATEGY_AD_CHAPTER_END_INTV.toLong() * 1000
                        ApiConfig.exchangeGoldNum = advStrategyBean.EXCHANGE_GOLD_NUM
                        ApiConfig.shareTimesLimit = advStrategyBean.SHARE_TIMES_LIMIT.toInt()
                        ApiConfig.adBrowseLimit = advStrategyBean.AD_BROWSE_LIMIT.toInt()
                        ApiConfig.strategy_chapter_end_ratio = advStrategyBean.STRATEGY_CHAPTER_END_RATIO
                        ApiConfig.strategy_start_ratio = advStrategyBean.STRATEGY_START_RATIO
                        ApiConfig.strategy_red_packet = advStrategyBean.STRATEGY_RED_PACKET
                        ApiConfig.banner_ad_limit = advStrategyBean.BANNER_AD_LIMIT
                        ApiConfig.banner_ad_ratio = advStrategyBean.BANNER_AD_RATIO
                        ApiConfig.banner_ad_switch = advStrategyBean.BANNER_AD_SWITCH
                        ApiConfig.contact_us = advStrategyBean.CONTACT_US
                        ApiConfig.strategy_screen_limit = advStrategyBean.STRATEGY_SCREEN_LIMIT.toLong() * 1000
                        ApiConfig.strategy_screen_ratio = advStrategyBean.STRATEGY_SCREEN_RATIO
                        ApiConfig.strategy_screen_switch = advStrategyBean.STRATEGY_SCREEN_SWITCH == "1"
                        ApiConfig.strategy_start_load = advStrategyBean.STRATEGY_START_LOAD.toLong() * 1000
                        ApiConfig.banner_ad_load = advStrategyBean.BANNER_AD_LOAD.toLong() * 1000
                    })
            User.syncToServer()
            Api.getMissionList2().subscribe(SimpleCallback { Global.missionList = it })
            Api.getAdvList().subscribe(SimpleCallback { adList ->
                LogUtils.e("adList: $adList")
                CachedAdvInfo.sAdvInfoList.clear()
                CachedAdvInfo.sAdvInfoList.addAll(adList)
            })
        }
    }

    override fun isFullScreen() = true

    override fun onDestroy() {
        super.onDestroy()
        isSkip = true
        mGdtOpeningAdvDel?.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        mGdtOpeningAdvDel?.onResume()
        mTtAdSplashAdDel?.onResume()
        mBaiduAdSplashDel?.onResume()
    }

    override fun onPause() {
        super.onPause()
        mGdtOpeningAdvDel?.onPause()
        mBaiduAdSplashDel?.onPause()
    }

    override fun onStop() {
        super.onStop()
        mTtAdSplashAdDel?.onStop()
    }

    /**
     * 开屏页一定要禁止用户对返回按钮的控制，否则将可能导致用户手动退出了App而广告无法正常曝光和计费
     */
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        return if (keyCode == KeyEvent.KEYCODE_BACK || keyCode == KeyEvent.KEYCODE_HOME) {
            true
        } else super.onKeyDown(keyCode, event)
    }
}
