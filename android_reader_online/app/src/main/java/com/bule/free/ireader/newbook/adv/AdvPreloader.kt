package com.bule.free.ireader.newbook.adv

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.androidquery.AQuery
import com.bule.free.ireader.App
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.common.adv.ttad.config.TTAdManagerHolder
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.model.ApiConfig
import com.bule.free.ireader.model.Global
import com.bule.free.ireader.newbook.ui.NewReadBookActivity
import com.bytedance.sdk.openadsdk.*
import com.qq.e.ads.cfg.VideoOption
import com.qq.e.ads.nativ.ADSize
import com.qq.e.ads.nativ.NativeExpressAD
import com.qq.e.ads.nativ.NativeExpressADView
import com.qq.e.comm.util.AdError
import com.umeng.analytics.MobclickAgent
import io.reactivex.Single
import java.util.*

/**
 * Created by suikajy on 2019-05-14
 *
 * 章节尾部广告预加载机制封装
 */
interface AdvPreloader {

    companion object {
        fun isCanshowNativeAdv(): Boolean {
            LogUtils.e("attach")
            LogUtils.e("分享免广告，或者后台关闭广告" + ApiConfig.isNoAd())
            LogUtils.e("展示广告策略：" + Global.isCanShowNativeAd())
            LogUtils.e("后台是否开启广告：" + ApiConfig.strategy_ad_open)
            if (ApiConfig.isNoAd() || !Global.isCanShowNativeAd()) {
                return false
            }
            LogUtils.e("展示广告")
            LogUtils.e("attach end")
            return true
        }
    }

    // 加载广告
    fun loadAd()

    // 展示广告
    fun showAd(container: FrameLayout, callback: AdvDisplayCallback)

    // 销毁回调
    fun destroy()
}

open class AdvDisplayCallback {
    open fun onShow() {
    }

    open fun onFail() {
    }
}

// 腾讯广告预加载器
class GdtNativeAdvPreloader(val mActivity: NewReadBookActivity) : AdvPreloader {

    private var preLoadedADView: NativeExpressADView? = null
    private var nativeExpressAD: NativeExpressAD? = null
    private var currentLoadedAdView: NativeExpressADView? = null

    override fun loadAd() {
        nativeExpressAD = NativeExpressAD(mActivity, ADSize(ADSize.FULL_WIDTH, ADSize.AUTO_HEIGHT),
                Const.channelConfig.gdt.app_id, Const.channelConfig.gdt.native_pos_id,
                mAdvLoadListener) // 这里的Context必须为Activity
        nativeExpressAD?.setVideoOption(VideoOption.Builder()
                .setAutoPlayPolicy(VideoOption.AutoPlayPolicy.WIFI) // 设置什么网络环境下可以自动播放视频
                .setAutoPlayMuted(true) // 设置自动播放视频时，是否静音
                .build()) // setVideoOption是可选的，开发者可根据需要选择是否配置
        nativeExpressAD?.loadAD(1)
    }

    private val mAdvLoadListener = object : NativeExpressAD.NativeExpressADListener {
        override fun onADCloseOverlay(p0: NativeExpressADView?) {
        }

        override fun onADLoaded(list: MutableList<NativeExpressADView>?) {
            LogUtils.e("onNoAD : list size : " + list?.size)
            MobclickAgent.onEvent(mActivity, "adv_show", "gdt_native_adv")
            // 释放前一个展示的NativeExpressADView的资源
            preLoadedADView?.destroy()

            preLoadedADView = list?.get(0)
            // 广告可见才会产生曝光，否则将无法产生收益。
//            mFlAdvContainer.postDelayed(Runnable {
//                mFlAdvContainer.addView(preLoadedADView)
//                try {
//                    preLoadedADView.render()
//                } catch (e: Exception) {
//                }
//            }, 500)
            MobclickAgent.onEvent(mActivity, "gdt_native_adv_load_success")
            MobclickAgent.onEvent(mActivity, "gdt_native_adv_load")
        }

        override fun onADOpenOverlay(p0: NativeExpressADView?) {
        }

        override fun onRenderFail(p0: NativeExpressADView?) {
        }

        override fun onADExposure(p0: NativeExpressADView?) {
        }

        override fun onADClosed(p0: NativeExpressADView?) {
        }

        override fun onADLeftApplication(p0: NativeExpressADView?) {
        }

        override fun onNoAD(p0: AdError?) {
            MobclickAgent.onEvent(mActivity, "gdt_native_adv_load_fail")
            MobclickAgent.onEvent(mActivity, "gdt_native_adv_load")
        }

        override fun onADClicked(p0: NativeExpressADView?) {
            MobclickAgent.onEvent(mActivity, "gdt_native_adv_click")
        }

        override fun onRenderSuccess(p0: NativeExpressADView?) {
        }
    }

    override fun showAd(container: FrameLayout, callback: AdvDisplayCallback) {
        if (AdvPreloader.isCanshowNativeAdv()) {
            if (preLoadedADView != null) {
                currentLoadedAdView = preLoadedADView
                preLoadedADView = null
                container.visibility = View.VISIBLE
                if (container.childCount > 0) {
                    container.removeAllViews()
                }
                container.addView(currentLoadedAdView)
                try {
                    currentLoadedAdView?.render()
                    MobclickAgent.onEvent(mActivity, "gdt_native_adv_show")
                    LogUtils.e("腾讯章末广告成功")
                    callback.onShow()
                } catch (e: Exception) {
                }
            } else {
                LogUtils.e("腾讯章末广告展示失败，原因：尚未加载")
                callback.onFail()
            }
            //todo ydy
           // loadAd()
        } else {
            LogUtils.e("腾讯章末广告展示失败，原因：关闭展示")
            container.removeAllViews()
            container.visibility = View.GONE
            callback.onFail()
        }
    }

    override fun destroy() {
        currentLoadedAdView?.destroy()
        preLoadedADView?.destroy()
    }

}

// 穿山甲章节尾部广告预加载器, 未正式启用
class TTAdNativeAdvPreloader(val mActivity: NewReadBookActivity) : AdvPreloader {

    private val mTTAdNative: TTAdNative
    private var mCurrentTTFeedAd: TTFeedAd? = null
    private var mPreloadedTTFeedAd: TTFeedAd? = null
    private var mCreativeButton: Button? = null
    private val mAQuery: AQuery = AQuery(mActivity)

    init {
        val ttAdManager = TTAdManagerHolder.get()
        mTTAdNative = ttAdManager.createAdNative(App.instance)
    }

    override fun loadAd() {
        val adSlot = AdSlot.Builder()
                .setCodeId(Const.channelConfig.ttad.feed_pos_id)
                .setSupportDeepLink(true)
                .setImageAcceptedSize(640, 320)
                .setAdCount(3)
                .build()
        mTTAdNative.loadFeedAd(adSlot, object : TTAdNative.FeedAdListener {
            override fun onError(code: Int, message: String) {
                LogUtils.e("onError")
                LogUtils.e(String.format(Locale.ENGLISH, "code: %d", code))
                LogUtils.e(String.format("message: %s", message))
            }

            override fun onFeedAdLoad(ads: List<TTFeedAd>?) {

                if (ads == null || ads.isEmpty()) {
                    LogUtils.e("on FeedAdLoaded: ad is null!")
                    return
                }
                mPreloadedTTFeedAd = ads[0]
            }
        })
    }

    override fun showAd(container: FrameLayout, callback: AdvDisplayCallback) {
        if (AdvPreloader.isCanshowNativeAdv()) {
            if (mPreloadedTTFeedAd != null) {
                mCurrentTTFeedAd = mPreloadedTTFeedAd
                mPreloadedTTFeedAd = null
                val bannerView = LayoutInflater.from(mActivity).inflate(R.layout.ttad_native_ad, container, false)
                if (bannerView == null) {
                    callback.onFail()
                    return
                }
                if (mCreativeButton != null) {
                    //防止内存泄漏
                    mCreativeButton = null
                }
                container.removeAllViews()
                container.addView(bannerView)

                callback.onShow()
                MobclickAgent.onEvent(mActivity, "ttad_feed_adv_show")
                //绑定原生广告的数据
                setAdData(bannerView, mCurrentTTFeedAd!!, container)
            } else {
                callback.onFail()
            }
            loadAd()
        } else {
            container.removeAllViews()
            container.visibility = View.GONE
            callback.onFail()
        }
    }

    override fun destroy() {
        mCurrentTTFeedAd = null
        mPreloadedTTFeedAd = null
        mCreativeButton = null
    }

    private fun setAdData(nativeView: View, ttFeedAd: TTFeedAd, container: FrameLayout) {
        (nativeView.findViewById<View>(R.id.tv_native_ad_title) as TextView).text = ttFeedAd.title
        (nativeView.findViewById<View>(R.id.tv_native_ad_desc) as TextView).text = ttFeedAd.description
        val imgDislike = nativeView.findViewById<ImageView>(R.id.img_native_dislike)
        bindDislikeAction(ttFeedAd, imgDislike, container)
        if (ttFeedAd.imageList != null && ttFeedAd.imageList.isNotEmpty()) {
            val image = ttFeedAd.imageList[0]
            if (image != null && image.isValid) {
                mAQuery.id(nativeView.findViewById<View>(R.id.iv_native_image)).image(image.imageUrl)
            }
        }
        mCreativeButton = nativeView.findViewById<View>(R.id.btn_native_creative) as Button
        //可根据广告类型，为交互区域设置不同提示信息
        when (ttFeedAd.interactionType) {
            TTAdConstant.INTERACTION_TYPE_DOWNLOAD -> {
                //如果初始化ttAdManager.createAdNative(getApplicationContext())没有传入activity 则需要在此传activity，否则影响使用Dislike逻辑
                ttFeedAd.setActivityForDownloadApp(mActivity)
                mCreativeButton?.visibility = View.VISIBLE
                ttFeedAd.setDownloadListener(mDownloadListener) // 注册下载监听器
            }
            TTAdConstant.INTERACTION_TYPE_DIAL -> {
                mCreativeButton?.visibility = View.VISIBLE
                mCreativeButton?.text = "立即拨打"
            }
            TTAdConstant.INTERACTION_TYPE_LANDING_PAGE, TTAdConstant.INTERACTION_TYPE_BROWSER -> {
                mCreativeButton?.visibility = View.VISIBLE
                mCreativeButton?.text = "查看详情"
            }
            else -> {
                mCreativeButton?.visibility = View.GONE
                LogUtils.e("交互类型异常")
            }
        }

        //可以被点击的view, 也可以把nativeView放进来意味整个广告区域可被点击
        val clickViewList = ArrayList<View>()
        clickViewList.add(nativeView)

        //触发创意广告的view（点击下载或拨打电话）
        val creativeViewList = ArrayList<View>()
        //如果需要点击图文区域也能进行下载或者拨打电话动作，请将图文区域的view传入
        creativeViewList.add(mCreativeButton!!)

        //重要! 这个涉及到广告计费，必须正确调用。convertView必须使用ViewGroup。
        ttFeedAd.registerViewForInteraction(nativeView as ViewGroup, clickViewList, creativeViewList, imgDislike, object : TTNativeAd.AdInteractionListener {
            override fun onAdClicked(view: View, ad: TTNativeAd?) {
                if (ad != null) {
                    LogUtils.e("广告" + ad.title + "被点击")
                }
            }

            override fun onAdCreativeClick(view: View, ad: TTNativeAd?) {
                if (ad != null) {
                    LogUtils.e("广告" + ad.title + "被创意按钮被点击")
                }
            }

            override fun onAdShow(ad: TTNativeAd?) {
                if (ad != null) {
                    LogUtils.e("广告" + ad.title + "展示")
                }
            }
        })

    }

    //接入网盟的dislike 逻辑，有助于提示广告精准投放度
    private fun bindDislikeAction(ad: TTNativeAd, dislikeView: View, container: FrameLayout?) {
        val ttAdDislike = ad.getDislikeDialog(mActivity)
        ttAdDislike?.setDislikeInteractionCallback(object : TTAdDislike.DislikeInteractionCallback {
            override fun onSelected(position: Int, value: String) {
                container?.removeAllViews()
            }

            override fun onCancel() {

            }
        })
        dislikeView.setOnClickListener { v -> ttAdDislike?.showDislikeDialog() }
    }

    private val mDownloadListener = object : TTAppDownloadListener {
        override fun onIdle() {
            mCreativeButton?.text = "开始下载"
        }

        @SuppressLint("SetTextI18n")
        override fun onDownloadActive(totalBytes: Long, currBytes: Long, fileName: String, appName: String) {
            if (totalBytes <= 0L) {
                mCreativeButton?.text = "下载中 percent: 0"
            } else {
                mCreativeButton?.text = "下载中 percent: " + currBytes * 100 / totalBytes
            }
        }

        @SuppressLint("SetTextI18n")
        override fun onDownloadPaused(totalBytes: Long, currBytes: Long, fileName: String, appName: String) {
            if (totalBytes == 0L){
                mCreativeButton?.text = "下载暂停 percent: 0"
            } else {
                mCreativeButton?.text = "下载暂停 percent: " + currBytes * 100 / totalBytes
            }
        }

        override fun onDownloadFailed(totalBytes: Long, currBytes: Long, fileName: String, appName: String) {
            mCreativeButton?.text = "重新下载"
        }

        override fun onInstalled(fileName: String, appName: String) {
            mCreativeButton?.text = "点击打开"
        }

        override fun onDownloadFinished(totalBytes: Long, fileName: String, appName: String) {
            mCreativeButton?.text = "点击安装"
        }
    }
}
