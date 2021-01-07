package com.bule.free.ireader.common.paging

import android.content.Context
import android.support.v4.widget.SwipeRefreshLayout
import android.support.v7.widget.RecyclerView
import android.util.AttributeSet

/**
 * Created by suikajy on 2019/3/18
 */
class SwipeRecyclerView(context: Context, attributeSet: AttributeSet? = null) : SwipeRefreshLayout(context, attributeSet) {

    constructor(context: Context) : this(context, null)

    private var recyclerView: RecyclerView = RecyclerView(context)

    init {
        val lp = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        addView(recyclerView, lp)
    }

    fun getRecyclerView() = recyclerView
}