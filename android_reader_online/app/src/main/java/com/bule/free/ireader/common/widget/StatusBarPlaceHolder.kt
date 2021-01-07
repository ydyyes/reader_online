package com.bule.free.ireader.common.widget

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.widget.FrameLayout

/**
 * Created by suikajy on 2019/3/23
 *
 * 一个适配了状态栏高度的FrameLayout
 */
class StatusBarPlaceHolder(context: Context, attributeSet: AttributeSet? = null, defStyleAttr: Int = 0) : FrameLayout(context, attributeSet, defStyleAttr) {

    constructor(context: Context) : this(context, null)

    constructor(context: Context, attributeSet: AttributeSet?) : this(context, attributeSet, 0)

    init {
        val layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, getStatusHeight())
        val view = View(context)
        view.layoutParams = layoutParams
        addView(view)
    }

    private fun getStatusHeight(): Int {
        var statusBarHeight = 0
        val resourceId = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) {
            statusBarHeight = context.resources.getDimensionPixelSize(resourceId)
        }
        return statusBarHeight
    }
}