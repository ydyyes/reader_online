package com.bule.free.ireader.ui.activity

import android.app.Activity
import android.content.Intent
import android.view.KeyEvent
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.common.adv.AdvController
import com.bule.free.ireader.common.adv.ShowAdType
import com.bule.free.ireader.common.adv.baiduad.BaiduSplashAdDel
import com.bule.free.ireader.common.adv.gdt.GdtOpeningAdvDel
import com.bule.free.ireader.common.adv.ttad.del.TTAdSplashAdDel
import com.bule.free.ireader.main.BaseSplashActivity
import com.bule.free.ireader.main.SplashActivity
import kotlinx.android.synthetic.main.activity_splash.*

/**
 * Created by suikajy on 2019-05-14
 * 当app进入后台30秒之后重新进入前台（未被杀死的情况下）会开启这个Activity
 */
class SplashAdvActivity : BaseSplashActivity() {
    override val layoutId = R.layout.activity_splash

    private val mSkipAction = Runnable {
        synchronized(this) {
            if (!isSkip) {
                isSkip = true
                finish()
            }
        }
    }

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, SplashAdvActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private var isSkip = false
    private var mGdtOpeningAdvDel: GdtOpeningAdvDel? = null
    private var mTtAdSplashAdDel: TTAdSplashAdDel? = null
    private var mBaiduAdSplashDel: BaiduSplashAdDel? = null

    override fun init() {
        iv_splash_bg.setImageResource(Const.channelConfig.bg_splash)
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
                splash_tv_skip.postDelayed(mSkipAction, SplashActivity.BASE_WAIT_TIME)
            }
        }
    }

    override fun setListener() {
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
