package com.bule.free.ireader.common.adv.tuia

import android.view.View
import com.bule.free.ireader.Const
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.model.ApiConfig
import com.check.ox.sdk.LionListener
import com.check.ox.sdk.LionWallView
import com.umeng.analytics.MobclickAgent

/**
 * Created by suikajy on 2019/4/12
 */
class TuiaDobberAdvDel(private val adView: LionWallView) {

    var isLoadSuccess: Boolean = false
    var isHide: Boolean = false

    fun load() {
        if (ApiConfig.isNoAd() || ApiConfig.strategy_red_packet == "0") return
        MobclickAgent.onEvent(adView.context, "tuia_adv_load")
        adView.setAdListener(object : LionListener {
            override fun onReceiveAd() {
                isLoadSuccess = true
                //LogUtils.e("onReceiveAd")
            }

            override fun onFailedToReceiveAd() {
                isLoadSuccess = false
                //LogUtils.e("onFailedToReceiveAd")
            }

            override fun onLoadFailed() {
                isLoadSuccess = false
                //LogUtils.e("onLoadFailed")
            }

            override fun onCloseClick() {
               // LogUtils.e("onCloseClick")
            }

            override fun onAdClick() {
                MobclickAgent.onEvent(adView.context, "tuia_adv_click")
               // LogUtils.e("onAdClick")
            }

            override fun onAdExposure() {
                isLoadSuccess = true
                MobclickAgent.onEvent(adView.context, "tuia_adv_exposure")
                //LogUtils.e("onAdExposure")
            }
        })
        adView.loadAd(Const.channelConfig.tuia.dobber_pos_id)
    }

    fun show() {
//        LogUtils.e("show isLoadSuccess: $isLoadSuccess")
        if (isLoadSuccess && isHide) {
            adView.visibility = View.VISIBLE
            isHide = false
        }
    }

    fun hide() {
//        LogUtils.e("hide isLoadSuccess: $isLoadSuccess")
        if (!isHide) {
            adView.visibility = View.GONE
            isHide = true
        }
    }

}