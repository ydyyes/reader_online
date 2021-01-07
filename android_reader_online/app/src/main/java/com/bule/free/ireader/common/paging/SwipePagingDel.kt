package com.bule.free.ireader.common.paging

import android.view.LayoutInflater
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.LogUtils
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder

/**
 * Created by suikajy on 2019/3/18
 */
class SwipePagingDel<T>(adapter: BaseQuickAdapter<T, out BaseViewHolder>,
                        private val mRefreshLayout: SwipeRecyclerView,
                        refreshListener: ((Int) -> Unit),
                        loadMoreListener: ((Int) -> Unit)? = null)
    : BaseBrvahDelegate<T>(adapter, mRefreshLayout.getRecyclerView()) {

    init {
        mRefreshLayout.setOnRefreshListener(::refresh)
        setOnLoadMoreListener(loadMoreListener)
        setOnRefreshListener(refreshListener)
        val emptyView = LayoutInflater.from(mRefreshLayout.context).inflate(R.layout.view_empty, mRefreshLayout.getRecyclerView(), false)
        adapter.emptyView = emptyView
        emptyView.setOnClickListener {
            refresh()
        }
    }

    override fun refresh() {
        super.refresh()
        mRefreshLayout.isRefreshing = true
    }

    override fun finishRefresh() {
        super.finishRefresh()
        mRefreshLayout.post {
            mRefreshLayout.isRefreshing = false
        }
    }

    fun goneNoDataView() {
        isShowNoMoreDataView = false
    }
}