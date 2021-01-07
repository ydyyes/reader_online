package com.bule.free.ireader.module.setting

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.util.Log
import android.view.View
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.adv.AdvController
import com.bule.free.ireader.model.*
import com.bule.free.ireader.module.login.LoginActivity
import com.bule.free.ireader.newbook.ReadBookConfig
import com.bule.free.ireader.presenter.SettingDelegate
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.bookchapter.BookChapterManager
import com.bule.free.ireader.module.readhistory.ReadHistoryActivity
import com.bule.free.ireader.ui.activity.TestActivity
import com.bule.free.ireader.ui.activity.WebViewActivity
import io.reactivex.Observable
import io.reactivex.SingleObserver
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.activity_setting.*

/**
 * Created by suikajy on 2019/3/15
 */
class SettingActivity : BaseActivity2() {
    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, SettingActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private val mSettingDelegate by lazy { SettingDelegate(this) }

    override val layoutId: Int = R.layout.activity_setting

    override fun init() {
        initPageMode()
        val sort = User.shelfSort
        mTvSort.text = resources.getStringArray(R.array.setting_dialog_sort_choice)[sort]
        release {
            rl_test.visibility = View.GONE
            rl_test2.visibility = View.GONE
        }
        Observable.create<String> { e ->
            val cacheSize = mSettingDelegate.dbSize
            e.onNext(cacheSize)
            e.onComplete()
        }.subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .go(this) {
                    tv_cache_size.text = it
                }
        refreshView()
    }

    override fun setListener() {
        rl_test.setOnClickListener {
            LogUtils.e(ApiConfig.banner_ad_ratio)
            ToastUtils.show(AdvController.getReadPageBottomAdType().toString())
        }
        rl_test2.setOnClickListener {
            User.expire = Long.MIN_VALUE
            //TestBaiduBannerActivity.start(this)
        }
        btn_edit_user_info.onClick {
            if (User.checkLogin(this)) {
                UserSettingActivity.start(this)
            }
        }
//        rl_set_gender.setOnClickListener {
//            AlertDialog.Builder(this)
//                    .setSingleChoiceItems(Res.stringArray(R.array.setting_dialog_gender), User.gender.ordinal) { dialog, which ->
//                        val gender = Const.Gender.values()[which]
//                        tv_gender.text = gender.text
//                        User.gender = gender
//                    }.setPositiveButton("确定") { dialog, which ->
//                        dialog.dismiss()
//                    }.create().show()
//        }
        rl_clear_cache.setOnClickListener {
            mSettingDelegate.showClearCacheDialog(Consumer { cacheSize ->
                RxBus.post(RefreshBookShelfEvent)
                tv_cache_size.text = cacheSize
            })
        }
        bookshelfSort.setOnClickListener {
            mSettingDelegate.showSetBookOrderDialog(Consumer { which ->
                mTvSort!!.text = resources.getStringArray(R.array.setting_dialog_sort_choice)[which]
            })
        }
        rlFlipStyle.setOnClickListener {
            var mode = 0
            val anim = ReadBookConfig.turnAnim

            if (!anim) {
                mode = 1
            }
            AlertDialog.Builder(this)
                    .setTitle("阅读页翻页效果")
                    .setSingleChoiceItems(resources.getStringArray(R.array.setting_dialog_style_choice),
                            mode
                    ) { dialog, which ->
                        Log.d("corex", "click which : $which")
                        tvFlipStyle!!.text = resources.getStringArray(R.array.setting_dialog_style_choice)[which]
                        ReadBookConfig.turnAnim = which == 0
                        dialog.dismiss()
                    }
                    .create().show()
        }
        tv_signin_logout.setOnClickListener {
            if (User.isLogin()) {
                User.onLogout()
                RxBus.post(LogoutEvent)
            } else {
                LoginActivity.start(this)
            }
        }
        RxBus.toObservable(this, LoginEvent::class.java) { refreshView() }
        RxBus.toObservable(this, LogoutEvent::class.java) { refreshView() }
    }

    private fun refreshView() {
        if (User.isLogin()) {
            tv_signin_logout.text = "退出登录"
        } else {
            tv_signin_logout.text = "点击登录"
        }
    }

    private fun initPageMode() {
        var mode = 0
        val anim = ReadBookConfig.turnAnim
        if (!anim) {
            mode = 1
        }
        try {
            tvFlipStyle!!.text = resources.getStringArray(R.array.setting_dialog_style_choice)[mode]
        } catch (e: Exception) {
            e.printStackTrace()
        }

    }
}
