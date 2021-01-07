package com.bule.free.ireader.common.widget

import android.content.Context
import android.graphics.Color
import android.util.AttributeSet
import android.view.View

/**
 * Created by suikajy on 2019/3/15
 */
class ItemDivider(context: Context, attributeSet: AttributeSet? = null, defStyleAttr: Int = 0) : View(context, attributeSet, defStyleAttr) {

    constructor(context: Context, attributeSet: AttributeSet?) : this(context, attributeSet, 0)

    init {
        post {
            setBackgroundColor(Color.TRANSPARENT)
        }
    }
}