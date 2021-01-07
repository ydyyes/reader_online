package com.bule.free.ireader.common.widget

import android.content.Context
import android.graphics.drawable.ColorDrawable
import android.support.annotation.IntRange
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.widget.LinearLayout
import com.bule.free.ireader.common.utils.dp
import de.hdodenhof.circleimageview.CircleImageView

/**
 * Created by suikajy on 2019/4/9
 *
 * 赶工，毫无复用性
 */

class StepView(context: Context, attributeSet: AttributeSet? = null, defStyleAttr: Int = 0) : LinearLayout(context, attributeSet, defStyleAttr) {

    private val stepCount = 3

    private val colorP = 0xFF2F94F9.toInt()
    private val colorN = 0xFFD5D5D5.toInt()
    private val drawableP = ColorDrawable(colorP)
    private val drawableN = ColorDrawable(colorN)

    constructor(context: Context) : this(context, null)

    constructor(context: Context, attributeSet: AttributeSet?) : this(context, attributeSet, 0)

    init {
        orientation = VERTICAL
        gravity = Gravity.CENTER
        addView(createSpotView())
        repeat(stepCount - 1) {
            addView(createLineView())
            addView(createSpotView())
        }
    }

    private fun createSpotView(): View {
        val view = CircleImageView(context)
        view.layoutParams = LinearLayout.LayoutParams(dp(11), dp(11))
        view.setImageDrawable(drawableN)
        return view
    }

    private fun createLineView(): View {
        val view = View(context)
        view.layoutParams = LinearLayout.LayoutParams(dp(1), dp(15))
        view.setBackgroundColor(colorN)
        return view
    }

    fun setCurrentStep(@IntRange(from = 0, to = 3) step: Int) {
        val selectedViewCount = step * 2 - 1
        for (i in 0 until childCount) {
            if (i % 2 == 0) {
                if (i < selectedViewCount) {
                    (getChildAt(i) as CircleImageView).setImageDrawable(drawableP)
                } else {
                    (getChildAt(i) as CircleImageView).setImageDrawable(drawableN)
                }
            } else {
                if (i < selectedViewCount) {
                    getChildAt(i).setBackgroundColor(colorP)
                } else {
                    getChildAt(i).setBackgroundColor(colorN)
                }
            }
        }
    }
}