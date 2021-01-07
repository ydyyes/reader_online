package com.bule.free.ireader.newbook.ui

import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.adv.AdvController
import com.bule.free.ireader.common.adv.ShowAdType
import com.bule.free.ireader.common.adv.baiduad.BaiduPageBottomBannerAdDel
import com.bule.free.ireader.common.adv.gdt.GdtBannerAdvDel
import com.bule.free.ireader.common.adv.ttad.del.TTAdBannerDel2
import com.bule.free.ireader.common.library.java1_8.Consumer
import com.bule.free.ireader.common.library.qmui.QMUIStatusBarHelper
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.*
import com.bule.free.ireader.model.objectbox.bean.BookChContentBean
import com.bule.free.ireader.newbook.ReadBookConfig
import com.bule.free.ireader.newbook.adv.*
import com.bule.free.ireader.newbook.contentswitchview.BookContentView

/**
 * Created by suikajy on 2019/4/11
 *
 * 读书界面的一个委托类，用来专门处理界面的变化
 * 该类中的修改主要是第三版之后的新加的需求
 */
internal class NewReadBookViewDel(private val mActivity: NewReadBookActivity) : ReadBookConfig.ModeChangeable {

    companion object {
        const val DARK_TEXT_TINT = 0xFF7F7F7F.toInt()
        var lastShowInterstitialAdTime = System.currentTimeMillis()
    }

    private var mGdtBannerAdvDel: GdtBannerAdvDel? = null
    private var mTtAdBannerDel: TTAdBannerDel2? = null
    private var mBaiduBannerDel: BaiduPageBottomBannerAdDel? = null
    private val mGdtChapterEndAdvDel: AdvPreloader by lazy { GdtNativeAdvPreloader(mActivity) }
    private val mLayoutAdvContainer: FrameLayout? get() = mActivity.mLayoutAdvContainer
    private val mFlBannerAdContainer: FrameLayout? get() = mActivity.mFlBannerAdContainer
    private val mBtnCloseBanner: ImageView? get() = mActivity.mBtnCloseBanner
    private val mHandler: Handler = Handler(Looper.getMainLooper())

    // View初始化
    fun initView() {
        mGdtChapterEndAdvDel.loadAd()
        if (isReadPageAdvShow()) {
            showBannerAd()
            loopBannerAdv()
        }
    }

    fun initListener() {
        RxBus.toObservable(mActivity, ChangeNightModeEvent::class.java) { changeMode(it.uiMode) }
        RxBus.toObservable(mActivity, NewReadBookSetLightEvent::class.java) { e ->
            if (e.isFollowSys) {
                setScreenBrightness()
            } else {
                setScreenBrightness(e.light)
            }
        }
        RxBus.toObservable(mActivity, NewReadBookChangeReadBgEvent::class.java) {
            mActivity.csvBook.hideAdv()
            mActivity.csvBook.changeBg()
        }
        RxBus.toObservable(mActivity, NewReadBookChangeTextSizeEvent::class.java) {
            mActivity.csvBook.hideAdv()
            mActivity.csvBook.changeTextSize()
        }
        // 点击书签，跳转对应页
        RxBus.toObservable(mActivity, NewReadBookBookmarkClickEvent::class.java) { event ->
            LogUtils.e("NewReadBookBookmarkClickEvent")
            val label = event.bookmarkBean.label
            LogUtils.e("书签label: $label")
            // 获取对应章节
            val bookChapterBean = mActivity.mBookChapterList.find { it._label == label }
            LogUtils.e("对应章节label bean $bookChapterBean")
            // 对应章节索引
            val chapterIndex = mActivity.mBookChapterList.indexOf(bookChapterBean)
            if (bookChapterBean != null) {
                // 如果有对应章节
                val contentBean: BookChContentBean? = bookChapterBean.contentBean
                if (contentBean != null && TextUtils.isEmpty(contentBean.content).not()) {
                    // 如果章节有内容
                    LogUtils.e("书签点击：章节有内容")
                    val pageAll = contentBean.lineContent.size / mActivity.pageLineCount + 1
                    val percent = event.bookmarkBean.percentage.toDouble() / 100
                    val bookmarkPageIndex = (percent * pageAll).toInt()
                    mActivity.csvBook.setInitData(chapterIndex, mActivity.mBookChapterList.size, bookmarkPageIndex)
                } else {
                    // 无此章节不计算进度，直接跳转对应章节第一页
                    // todo : 这里添加标记，在实际加载对应章节的时候判断标记，在根据百分比计算应该跳转的页数索引(暂定)
                    if (contentBean == null) {
                        LogUtils.e("content bean is null")
                    }
                    LogUtils.e("书签点击：章节无内容")
                    mActivity.csvBook.setInitData(chapterIndex, mActivity.mBookChapterList.size, BookContentView.DURPAGEINDEXBEGIN)
                }
            } else {
                ToastUtils.show("无此章节")
            }
        }
        RxBus.toObservable(mActivity, NewReadBookRefreshBookmarkEvent::class.java) {
            Api.getBookmarkList(mActivity.mBookId).go(mActivity) {
                mActivity.mBookmarkList.clear()
                mActivity.mBookmarkList.addAll(it)
                checkCurrentPageIsBookmark()
            }
        }
        // 关闭底部banner广告
        mBtnCloseBanner?.setOnClickListener { invalidateBannerAdv() }
    }

    // 切换夜间模式和白天模式
    override fun changeMode(uiMode: ReadBookConfig.UIMode) {
        if (!uiMode.isNight()) { // 切换为日间模式
            QMUIStatusBarHelper.setStatusBarLightMode(mActivity)
            mActivity.tvPre.setTextColor(Res.colorStateList(R.color.selector_tv_black))
            mActivity.tvNext.setTextColor(Res.colorStateList(R.color.selector_tv_black))
            mActivity.mIvDnMode.colorFilter = null
            mActivity.mIvIcSetting.colorFilter = null
            mActivity.mIvIcCatalog.colorFilter = null
            mActivity.mIvIcBookmark.colorFilter = null
            mActivity.mIvCheckBookmark.colorFilter = null
            mActivity.mIvDnMode.setImageResource(R.drawable.read_ic_night_mode)
            mActivity.mTvDnMode.text = "夜间模式"
        } else {// 切换为夜间模式
            QMUIStatusBarHelper.setStatusBarDarkMode(mActivity)
            mActivity.tvPre.setTextColor(DARK_TEXT_TINT)
            mActivity.tvNext.setTextColor(DARK_TEXT_TINT)
            mActivity.mIvDnMode.setColorFilter(DARK_TEXT_TINT)
            mActivity.mIvIcBookmark.setColorFilter(DARK_TEXT_TINT)
            mActivity.mIvIcCatalog.setColorFilter(DARK_TEXT_TINT)
            mActivity.mIvIcSetting.setColorFilter(DARK_TEXT_TINT)
            mActivity.mIvCheckBookmark.setColorFilter(DARK_TEXT_TINT)
            mActivity.mIvDnMode.setImageResource(R.drawable.read_ic_day_mode)
            mActivity.mTvDnMode.text = "白天模式"
        }
        mActivity.setUIMode(uiMode)
        mActivity.llMenuBottomBg?.setBackgroundColor(uiMode.menuBarBgColor)
        mActivity.llMenuTopBg?.setBackgroundColor(uiMode.menuBarBgColor)
//        mActivity.fontPop?.changeMode(uiMode)
//        mActivity.moreSettingPop?.changeMode(uiMode)
//        mActivity.windowLightPop?.changeMode(uiMode)
        mActivity.chapterListView.changeMode(uiMode)
        mActivity.csvBook.hideAdv()
        mActivity.csvBook.changeBg()
    }

    // 判断当前页是否是书签，改变添加书签按钮样式
    fun checkCurrentPageIsBookmark() {
        if (mActivity.isDestroyed) return
        mActivity.mCurrentBookmark = mActivity.mPresenter.getCurrentPageBookMark()
        mActivity.mIvCheckBookmark.isSelected = mActivity.mCurrentBookmark != null
    }

    // 设置屏幕亮度
    private fun setScreenBrightness(value: Int) {
        val realValue = if (ReadBookConfig.uiMode.isNight()) {
            value / 2
        } else {
            value
        }
        val params = mActivity.window.attributes
        params.screenBrightness = realValue * 1.0f / 255f
        mActivity.window.attributes = params
    }

    // 屏幕亮度跟随系统
    private fun setScreenBrightness() {
        if (ReadBookConfig.uiMode.isNight()) return
        val params = mActivity.window.attributes
        params.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        mActivity.window.attributes = params
    }

    // 展示底部banner广告
    private fun showBannerAd() {
        if (ApiConfig.isNoAd()) {
            LogUtils.e("用户为vip，无需展示广告")
            mLayoutAdvContainer?.visibility = View.GONE
            return
        }
        if (isReadPageAdvShow().not()) {
            LogUtils.e("用户看视频了，免30分钟广告")
            mLayoutAdvContainer?.visibility = View.GONE
            return
        }
        var readPageBottomAdType = AdvController.getReadPageBottomAdType()
        when (readPageBottomAdType) {
            ShowAdType.GDT -> {
                LogUtils.e("底部展示广点通banner")
                mLayoutAdvContainer?.visibility = View.VISIBLE
                mBtnCloseBanner?.visibility = View.GONE
                mGdtBannerAdvDel = GdtBannerAdvDel(mActivity, mFlBannerAdContainer, Runnable { invalidateBannerAdv() }, Consumer { successLoad ->
                    if (successLoad) {
                        LogUtils.e("腾讯广告展示成功")
                        mBtnCloseBanner?.visibility = View.GONE
                        mLayoutAdvContainer?.visibility = View.VISIBLE
                    } else {
                        LogUtils.e("腾讯广告展示失败")
                        invalidateBannerAdv()
                    }
                })
                mGdtBannerAdvDel?.showInRead()
            }
            ShowAdType.TTAD -> {
                LogUtils.e("底部展示穿山甲")
                mLayoutAdvContainer?.visibility = View.VISIBLE
                mBtnCloseBanner?.visibility = View.GONE
                mTtAdBannerDel = TTAdBannerDel2(mActivity, mFlBannerAdContainer) { invalidateBannerAdv() }
                mTtAdBannerDel?.showInRead()
            }
            ShowAdType.BDAD -> {
                LogUtils.e("底部展示百度")

                mBaiduBannerDel = BaiduPageBottomBannerAdDel(mActivity, mFlBannerAdContainer, Consumer { successLoad ->
                    if (successLoad) {
                        LogUtils.e("百度展示成功")
                    } else {
                        LogUtils.e("百度展示失败")
                        invalidateBannerAdv()
                    }
                })
                mBaiduBannerDel?.show()
            }
            else -> LogUtils.e("底部不展示广告，无类型")
        }
    }

    // 当底部banner广告关闭或者加载失败时进行的处理，这里也用来5分钟重新拉取banner
    fun invalidateBannerAdv() {
        mLayoutAdvContainer?.visibility = View.GONE
        mBtnCloseBanner?.visibility = View.VISIBLE
        mGdtBannerAdvDel?.doCloseBanner()
        mTtAdBannerDel?.release()
        mBaiduBannerDel?.onDestroy()
        //LogUtils.e("ApiConfig.banner_ad_limit: ${ApiConfig.banner_ad_limit}")
        if (ApiConfig.banner_ad_limit.isEmpty().not()) {
            //LogUtils.e("ApiConfig.banner_ad_limit: ${ApiConfig.banner_ad_limit}")
            mBtnCloseBanner?.postDelayed({
                LogUtils.e("重新展示新的Banner")
                showBannerAd()
            }, ApiConfig.banner_ad_limit.toLong() * 1000)
        }
    }

    // 5分钟重新拉取新的banner
    private val mReloadBannerAction = object : Runnable {
        override fun run() {
            LogUtils.e("3分钟重新获取banner广告")
//            if (mActivity.isStopped.not()) {
            LogUtils.e("3分钟重新获取banner广告,刷新广告")
            invalidateBannerAdv()
//            }
            mHandler.postDelayed(this, ApiConfig.banner_ad_load)
        }
    }

    private fun loopBannerAdv() {
        mHandler.postDelayed(mReloadBannerAction, ApiConfig.banner_ad_load)
    }

    // todo: 这个方法设计的本意是想在此方法处计算展示广告的概率，然后随机展示广告，现版本只有腾讯广告的预加载比较稳定，所以固定加载腾讯的了
    fun showChapterEndAdv(container: FrameLayout, callback: AdvDisplayCallback) {
        mGdtChapterEndAdvDel.showAd(container, callback)
    }


    fun loadChapterEndAdv() {
        if (AdvController.sCurrentReadPageBottomAdType == ShowAdType.GDT) {
            mGdtChapterEndAdvDel.loadAd()
        }
    }

    // 展示插屏广告
    fun showInterstitialAdv() {
//        debug {
//            LogUtils.e("ApiConfig.strategy_screen_switch: ${ApiConfig.strategy_screen_switch}")
//            LogUtils.e("ApiConfig.strategy_screen_limit: ${ApiConfig.strategy_screen_limit}")
//            ReadFullAdFragment.getInstance(false).show(mActivity.supportFragmentManager, "ad")
//        }
//        if (isReadPageAdvShow().not()) {
//            LogUtils.e("用户看视频了，免30分钟广告")
//            return
//        }
//        val currentTime = System.currentTimeMillis()
//        if (currentTime - lastShowInterstitialAdTime > ApiConfig.strategy_screen_limit) {
//            lastShowInterstitialAdTime = currentTime
//            if (ApiConfig.isNoAd().not() and ApiConfig.strategy_screen_switch and Global.isCanShowNativeAd()) {
//                try{
//                    ReadFullAdFragment.getInstance(false).show(mActivity.supportFragmentManager, "ad")
//                }catch (e: IllegalStateException){
//                    // do nothing!
//                }
//            }
//        }
    }

    fun onDestroy() {
        mHandler.removeCallbacks(mReloadBannerAction)
        mGdtChapterEndAdvDel.destroy()
    }
}

