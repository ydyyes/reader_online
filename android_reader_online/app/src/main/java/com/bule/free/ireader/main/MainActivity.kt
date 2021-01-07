package com.bule.free.ireader.main

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentPagerAdapter
import android.support.v4.view.ViewPager
import android.util.Log
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import com.allenliu.versionchecklib.utils.FileHelper
import com.allenliu.versionchecklib.v2.AllenVersionChecker
import com.allenliu.versionchecklib.v2.builder.UIData
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.adv.yomi.YoMiDel
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.common.widget.adapter.IndicatorAdapter
import com.bule.free.ireader.main.fragment.*
import com.bule.free.ireader.model.*
import com.bule.free.ireader.module.readhistory.ReadHistoryActivity
import com.bule.free.ireader.module.search.SearchActivity
import com.bule.free.ireader.newbook.ReadBookConfig
import com.bule.free.ireader.presenter.SettingDelegate
import com.bule.free.ireader.ui.activity.FeedBackActivity
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.ui.dialog.OpeningDialog
import com.tbruyelle.rxpermissions2.RxPermissions
import com.umeng.analytics.MobclickAgent
import io.reactivex.functions.Consumer
import kotlinx.android.synthetic.main.activity_main.*
import org.jetbrains.anko.alert
import java.io.File

/**
 * Created by suikajy on 2019/3/22
 */
class MainActivity : BaseActivity2() {

    private val mFragmentList: List<Fragment> = listOf(BookShelfFragment(),
            BookMallFragment2(), WelfareFragment(), PersonFragment())
    private val mTitleList = Res.stringArray(R.array.nb_fragment_title)
    private var mTabIconList = listOf(R.drawable.selector_bookrack,
            R.drawable.selector_bookmarket, R.drawable.selector_ic_welfare, R.drawable.selector_person)
    private var mCurrentTab = 0
    private var isPrepareFinish = false
    private val mSettingDelegate by lazy { SettingDelegate(this) }
    private lateinit var mMenu: MainMenuPopupWindow

    override val layoutId = R.layout.activity_main

    companion object {
        private const val CURRENT_TAB = "current_tab"
        private const val WAIT_INTERVAL = 2000

        fun start(activity: Activity) {
            val intent = Intent(activity, MainActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override fun init() {
        ScreenUtils.setStatusBar(status_bar)
        val adapter = TabFragmentPageAdapter(supportFragmentManager)
        tab_vp.adapter = adapter
        tab_vp.offscreenPageLimit = 4
        mMenu = MainMenuPopupWindow(this, btn_sign)
        tab_vp.addOnPageChangeListener(object : ViewPager.SimpleOnPageChangeListener() {
            override fun onPageSelected(position: Int) {
                mCurrentTab = position
                if (position == Page.BOOK_SHELF.ordinal) {
                    tv_toolbar_title.text = "书架"
                    btn_sign.setImageResource(R.drawable.selector_main_ic_setting)
                } else if (position == Page.BOOK_MALL.ordinal) {
                    tv_toolbar_title.text = "书城"
                    btn_sign.setImageResource(R.drawable.selector_main_ic_sign)
                }
                mMenu.dismiss()
                if (position == Page.WELFARE.ordinal) {
                    MobclickAgent.onEvent(this@MainActivity, "welfare_page_show")
                }
            }

            override fun onPageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {
                if (position > 1) {
                    layout_toolbar.visibility = View.GONE
                } else {
                    layout_toolbar.visibility = View.VISIBLE
                }
                if (position == 1 && positionOffset < 2) {
                    layout_toolbar.translationY = -((positionOffset) * layout_toolbar.height)
                } else if (position == 0) {
                    layout_toolbar.translationY = 0f
                }
            }
        })

        indicator.setViewPager(tab_vp, mCurrentTab)
        indicator.setIndicatorAdapter(object : IndicatorAdapter {
            @SuppressLint("InflateParams")
            override fun getTabView(context: Context, position: Int): View {
                val tabView = layoutInflater.inflate(R.layout.tab_bookrack, null)
                val tabIcon = tabView.findViewById<View>(R.id.tab_icon) as ImageView
                val tabTitle = tabView.findViewById<View>(R.id.tab_title) as TextView

                tabIcon.setBackgroundResource(mTabIconList[position])
                tabTitle.text = mTitleList[position]

                return tabView
            }

            override fun getTabCount(): Int {
                return mTitleList.size
            }

            override fun onTabChange(tabView: View, position: Int, selectPercent: Float) {}
        })

        indicator.setCurrentItem(mCurrentTab)

        checkUpdate()

        if (!NetworkUtils.isConnected()) {
            alert {
                isCancelable = false
                title = "没有网络，请检查手机网络连接"
                positiveButton("确定") {}
            }.show()
        }

        if (User.todayShowedOpeningDialog.not()) {
            Api.getOpeningWindow().go { bean ->
                if (bean.res_status) {
                    OpeningDialog(this, bean.info).show()
                    User.todayShowedOpeningDialog = true
                }
            }
        }
    }

    override fun setListener() {
        RxBus.toObservable(this, ToBookShelfEvent::class.java) {
            tab_vp.currentItem = Page.BOOK_MALL.ordinal
        }
        RxBus.toObservable(this, MainActivityChangePageEvent::class.java) {
            tab_vp.currentItem = it.page.ordinal
        }
        btn_search_bar.setOnClickListener { SearchActivity.start(this) }
        btn_sign.setOnClickListener {
            if (tab_vp.currentItem == Page.BOOK_SHELF.ordinal) {
                mMenu.show()
//                floatMenu.show()
            } else {
                tab_vp.currentItem = Page.WELFARE.ordinal
                RxBus.post(SignEvent)
            }
        }
        mMenu.setClearCacheClickListener {
            mSettingDelegate.showClearCacheDialog(Consumer { size ->
                ToastUtils.show("清除成功, 当前缓存大小为$size")
                RxBus.post(RefreshBookShelfEvent)
            })
            mMenu.dismiss()
        }
        mMenu.setFeedBackClickListener {
            if (User.checkLogin(this)) {
                FeedBackActivity.start(this)
            }
            mMenu.dismiss()
        }
        mMenu.setReadHistoryClickListener {
            ReadHistoryActivity.start(this)
            mMenu.dismiss()
        }
        mMenu.setShlefSortClickListener {
            mSettingDelegate.showSetBookOrderDialog()
            mMenu.dismiss()
        }
        mMenu.setSwitchNightModeClickListener {
            val currentUiMode = ReadBookConfig.uiMode
            if (currentUiMode.isNight()) {
                ReadBookConfig.UIMode.DAY.changeMode()
            } else {
                ReadBookConfig.UIMode.NIGHT.changeMode()
            }
            mMenu.dismiss()
        }
        mMenu.setShelfModeClickListener {
            Config.isShelfMode = Config.isShelfMode.not()
            mMenu.refreshView()
            RxBus.post(ChangeShelfModeEvent)
            mMenu.dismiss()
        }
    }


    override fun onSaveInstanceState(outState: Bundle?) {
        super.onSaveInstanceState(outState)
        outState?.putInt(CURRENT_TAB, mCurrentTab)
    }

    override fun onRestoreInstanceState(savedInstanceState: Bundle?) {
        super.onRestoreInstanceState(savedInstanceState)
        mCurrentTab = savedInstanceState?.getInt(CURRENT_TAB) ?: 0
    }

    private fun checkUpdate() {
        Api.getUpdate()
                .go(this, {
                    val isUpdate = it.update
                    if (isUpdate) {
                        val updateLog = it.update_log
                        val apkUrl = it.apk_url
                        val isForced = it.forced_updating == "1"
                        File(FileHelper.getDownloadApkCachePath()).deleteRecursively()
                        try{
                            RxPermissions(this)
                                    .request(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                                    .go({ granted ->
                                        if (granted) {
                                            LogUtils.e("apkUrl: $apkUrl")
                                            if (NetworkUtils.isWifiConnected(this@MainActivity)) {
                                                val downloadBuilder = AllenVersionChecker.getInstance().downloadOnly(UIData.create()
                                                        .setDownloadUrl(apkUrl)
                                                        .setTitle("版本更新")
                                                        .setContent(updateLog))
                                                if (isForced) {
                                                    downloadBuilder.setForceRedownload(true)
                                                            .setForceUpdateListener {
                                                                finish()
                                                            }
                                                }
                                                downloadBuilder.executeMission(this)
                                            } else {
//                                            LogUtils.e("没有WIFI，进行弹窗")
                                                val downloadBuilder = AllenVersionChecker.getInstance().downloadOnly(UIData.create()
                                                        .setDownloadUrl(apkUrl)
                                                        .setTitle("是否要在非Wifi环境进行更新？")
                                                        .setContent(updateLog))
                                                if (isForced) {
                                                    downloadBuilder.setForceRedownload(true)
                                                            .setForceUpdateListener {
                                                                finish()
                                                            }
                                                }
                                                downloadBuilder.executeMission(this)
//                                            alert {
//                                                message = ""
//                                                isCancelable = false
//                                                positiveButton("是") { dialogInterface->
//                                                    downloadBuilder.executeMission(this@MainActivity)
//                                                    dialogInterface.dismiss()
//                                                }
//                                                negativeButton("否") {
//                                                    finish()
//                                                }
//                                            }.show()
                                            }
                                        } else {
                                            ToastUtils.show("未授予读写权限，无法进行更新")
                                        }
                                    }, Consumer { t ->
                                        LogUtils.e("t: $t")
                                    })
                        } catch (e : IllegalStateException){
                            // do nothing
                        }
                    }
                }, {
                    LogUtils.e(it.message)
                })
    }

    override fun subscribeUiMode() {
        subscribeEvent(ChangeNightModeEvent::class.java) {
            setUIMode(it.uiMode)
            mMenu.refreshView()
        }
    }

    override fun onPause() {
        super.onPause()
        mMenu.dismiss()
    }

    override fun onDestroy() {
        YoMiDel.onAppExit()
        super.onDestroy()
    }

    override fun onBackPressed() {
        if (!isPrepareFinish) {
            tab_vp.postDelayed(
                    { isPrepareFinish = false }, WAIT_INTERVAL.toLong()
            )
            isPrepareFinish = true
            Toast.makeText(this, "再按一次退出", Toast.LENGTH_SHORT).show()
        } else {
            super.onBackPressed()
        }
    }

    private inner class TabFragmentPageAdapter(fm: FragmentManager) : FragmentPagerAdapter(fm) {
        override fun getItem(position: Int): Fragment {
            return mFragmentList[position]
        }

        override fun getCount(): Int {
            return mFragmentList.size
        }

        override fun getPageTitle(position: Int): CharSequence? {
            return mTitleList[position]
        }
    }

    enum class Page {
        BOOK_SHELF, BOOK_MALL, WELFARE, PERSON
    }
}