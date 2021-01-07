package com.bule.free.ireader.common.widget

import android.app.Activity
import android.content.Context
import android.os.Build
import android.support.annotation.DrawableRes
import android.support.v4.content.ContextCompat
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewManager
import android.widget.LinearLayout
import com.bule.free.ireader.R
import kotlinx.android.synthetic.main.view_toolbar.view.*
import org.jetbrains.anko.custom.ankoView
import org.jetbrains.anko.dip

/**
 * Created by suikajy on 2019/3/13
 */
inline fun ViewManager.toolBarView(init: ToolBarView.() -> Unit = {}): ToolBarView {
    return ankoView({ ToolBarView(it) }, theme = 0, init = init)
}

class ToolBarView(context: Context, attributeSet: AttributeSet? = null, defStyleAttr: Int = 0) : LinearLayout(context, attributeSet, defStyleAttr) {

    private var isImg = false
    private var isShadow = false
    private var mRightText = ""
    private var mTitle = ""

    constructor(context: Context) : this(context, null)

    constructor(context: Context, attributeSet: AttributeSet?) : this(context, attributeSet, 0)

    init {
        orientation = VERTICAL

        val childView = LayoutInflater.from(context).inflate(R.layout.view_toolbar, this, false)
        addView(childView)
        val typedArray = context.obtainStyledAttributes(attributeSet, R.styleable.ToolBarView)
        isImg = typedArray.getBoolean(R.styleable.ToolBarView_tb_is_img, false)
        isShadow = typedArray.getBoolean(R.styleable.ToolBarView_tb_is_shadow, false)
        val backGroundId = typedArray.getResourceId(R.styleable.ToolBarView_tb_background, -1)
        mRightText = typedArray.getString(R.styleable.ToolBarView_tb_right_text) ?: ""
        mTitle = typedArray.getString(R.styleable.ToolBarView_tb_title) ?: ""
        val mImgRight = typedArray.getResourceId(R.styleable.ToolBarView_tb_img_right, 0)
        val icBtnBack = typedArray.getResourceId(R.styleable.ToolBarView_tb_back_button_icon, 0)
        val statusBarColor = typedArray.getColor(R.styleable.ToolBarView_tb_status_bar_color, 0)
        val isShowDivider = typedArray.getBoolean(R.styleable.ToolBarView_tb_is_show_divider, true)

        if (!isShowDivider) {
            toolbar_divider.visibility = GONE
        }

        if (statusBarColor != 0) {
            status_bar.setBackgroundColor(statusBarColor)
        }

        if (backGroundId != -1) {
            setBackgroundResource(backGroundId)
        } else {
            setBackgroundColor(ContextCompat.getColor(context, R.color.colorPrimary))
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && isShadow) {
            elevation = dip(4).toFloat()
        }

        adjustStatusBar(status_bar)

        if (icBtnBack != 0) {
            btn_back.setImageResource(icBtnBack)
        }

        btn_back.setOnClickListener { (context as? Activity)?.finish() }

        if (isImg) {
            btn_right_text.visibility = View.GONE
            btn_right_img.visibility = View.VISIBLE
            if (mImgRight != 0) {
                btn_right_img.setImageResource(mImgRight)
            }
        } else {
            btn_right_text.visibility = View.VISIBLE
            btn_right_img.visibility = View.GONE
            if (!TextUtils.isEmpty(mRightText)) {
                btn_right_text.text = mRightText
            }
        }
        tv_title.text = if (TextUtils.isEmpty(mTitle)) "" else mTitle
        typedArray.recycle()

    }

    fun setOnRightClickListener(listener: (View) -> Unit) {
        if (isImg) {
            btn_right_img.setOnClickListener(listener)
        } else {
            btn_right_text.setOnClickListener(listener)
        }
    }

    fun setTitle(title: String) {
        mTitle = title
        tv_title.text = mTitle
    }

    /**
     * 将右侧控件设置为TextView，如果rightText为空字符串，则会将右侧控件设置为GONE
     */
    fun setRightText(rightText: String) {
        isImg = false
        mRightText = rightText
        btn_right_text.text = mRightText
        btn_right_img.visibility = GONE
        if (rightText.isEmpty()) {
            btn_right_text.visibility = GONE
        } else {
            btn_right_text.visibility = VISIBLE
        }
    }

    fun setRightIcon(@DrawableRes resId: Int) {
        isImg = true
        btn_right_text.visibility = View.GONE
        btn_right_img.visibility = View.VISIBLE
        btn_right_img.setImageResource(resId)
    }

    private fun adjustStatusBar(layout: LinearLayout) {
        val statusBarHeight = getStatusHeight()
        val linearParams = layout.layoutParams as LinearLayout.LayoutParams
        linearParams.height = statusBarHeight
        layout.layoutParams = linearParams
    }

    private fun getStatusHeight(): Int {
        var statusBarHeight = 0
        val resourceId = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) {
            statusBarHeight = context.resources.getDimensionPixelSize(resourceId)
        }
        return statusBarHeight
    }

    fun getBtnRight(): View {
        return if (isImg) {
            btn_right_img
        } else {
            btn_right_text
        }
    }
}