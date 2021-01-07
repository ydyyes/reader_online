package com.bule.free.ireader.main

import android.app.Activity
import android.content.Context
import android.graphics.Point
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.view.*
import android.widget.FrameLayout
import android.widget.PopupWindow
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.Res
import com.bule.free.ireader.common.utils.dp
import com.bule.free.ireader.model.Config
import com.bule.free.ireader.newbook.ReadBookConfig

/**
 * Created by suikajy on 2019-05-15
 */

class MainMenuPopupWindow(private val mActivity: Activity,
                          private val mAnchorView: View) {
    private val ANCHORED_GRAVITY = Gravity.TOP or Gravity.START
    private val VERTICAL_OFFSET = dp(10)
    private val mScreenSize = getScreenMetrics(mActivity)

    private val mBtnShelfSort: TextView
    private val mBtnClearCache: TextView
    private val mBtnShelfMode: TextView
    private val mBtnFeedback: TextView
    private val mBtnReadHistory: TextView
    private val mBtnSwitchNightMode: TextView
    private val mMenuWindow: PopupWindow

    private var clickX = 0
    private var clickY = 0
    private var mMeasuredWidth = 0
    private var mMeasuredHeight = 0

    init {
        val contentView = FrameLayout(mActivity)
        val menuView = LayoutInflater.from(mActivity).inflate(R.layout.popup_main_menu, null)
        contentView.addView(menuView)
        val width = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        val height = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        contentView.measure(width, height)
        mMeasuredWidth = contentView.measuredWidth
        mMeasuredHeight = contentView.measuredHeight
        mBtnShelfSort = menuView.findViewById(R.id.btn_shelf_sort)
        mBtnClearCache = menuView.findViewById(R.id.btn_clear_cache)
        mBtnShelfMode = menuView.findViewById(R.id.btn_shelf_mode)
        mBtnFeedback = menuView.findViewById(R.id.btn_feedback)
        mBtnReadHistory = menuView.findViewById(R.id.btn_read_history)
        mBtnSwitchNightMode = menuView.findViewById(R.id.btn_switch_night_mode)
        mAnchorView.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_DOWN) {
                clickX = event.rawX.toInt()
                clickY = event.rawY.toInt()
            }
            false
        }
        mMenuWindow = PopupWindow(contentView, mMeasuredWidth, mMeasuredHeight)

    }

    fun show() {
        if (mMenuWindow.isShowing) {
            mMenuWindow.dismiss()
            return
        }
        LogUtils.e("show")
        //it is must ,other wise 'setOutsideTouchable' will not work under Android5.0
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            mMenuWindow.setBackgroundDrawable(BitmapDrawable())
        }

        if (clickX <= mScreenSize.x / 2) {
            if (clickY + mMeasuredHeight < mScreenSize.y) {
                mMenuWindow.animationStyle = R.style.Animation_top_left
                mMenuWindow.showAtLocation(mAnchorView, ANCHORED_GRAVITY, clickX, clickY + VERTICAL_OFFSET)
            } else {
                mMenuWindow.animationStyle = R.style.Animation_bottom_left
                mMenuWindow.showAtLocation(mAnchorView, ANCHORED_GRAVITY, clickX, clickY - mMeasuredHeight - VERTICAL_OFFSET)
            }
        } else {
            if (clickY + mMeasuredHeight < mScreenSize.y) {
                mMenuWindow.animationStyle = R.style.Animation_top_right
                mMenuWindow.showAtLocation(mAnchorView, ANCHORED_GRAVITY, clickX - mMeasuredWidth, clickY + VERTICAL_OFFSET)
            } else {
                mMenuWindow.animationStyle = R.style.Animation_bottom_right
                mMenuWindow.showAtLocation(mAnchorView, ANCHORED_GRAVITY, clickX - mMeasuredWidth, clickY - mMeasuredHeight - VERTICAL_OFFSET)
            }
        }
    }

    fun dismiss() {
        mMenuWindow.dismiss()
    }

    private fun getScreenMetrics(context: Context): Point {
        val dm = context.resources.displayMetrics
        val w_screen = dm.widthPixels
        val h_screen = dm.heightPixels
        return Point(w_screen, h_screen)
    }

    // 书架排序
    fun setShlefSortClickListener(block: (View) -> Unit) {
        mBtnShelfSort.setOnClickListener { block(it) }
    }

    // 清除缓存
    fun setClearCacheClickListener(block: (View) -> Unit) {
        mBtnClearCache.setOnClickListener { block(it) }
    }

    // 书架模式
    fun setShelfModeClickListener(block: (View) -> Unit) {
        mBtnShelfMode.setOnClickListener { block(it) }
    }

    // 意见反馈
    fun setFeedBackClickListener(block: (View) -> Unit) {
        mBtnFeedback.setOnClickListener { block(it) }
    }

    // 阅读历史
    fun setReadHistoryClickListener(block: (View) -> Unit) {
        mBtnReadHistory.setOnClickListener { block(it) }
    }

    // 夜间模式
    fun setSwitchNightModeClickListener(block: (View) -> Unit) {
        mBtnSwitchNightMode.setOnClickListener { block(it) }
    }

    fun refreshView() {
        mBtnShelfMode.text = if (Config.isShelfMode) "列表模式" else "图墙模式"
        mBtnSwitchNightMode.text = if (ReadBookConfig.uiMode.isNight()) "日间模式" else "夜间模式"
        if (ReadBookConfig.uiMode.isNight()) {
            mBtnSwitchNightMode.text = "日间模式"
            mBtnSwitchNightMode.setCompoundDrawables(Res.boundDrawable(R.drawable.main_ic_day_mode), null, null, null)
        } else {
            mBtnSwitchNightMode.text = "夜间模式"
            mBtnSwitchNightMode.setCompoundDrawables(Res.boundDrawable(R.drawable.main_ic_night_mode), null, null, null)
        }
    }
}