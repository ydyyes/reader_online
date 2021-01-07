package com.bule.free.ireader.common.paging

import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder


/**
 * Created by suikajy on 2019/3/18
 */
abstract class BaseBrvahDelegate<T>(val adapter: BaseQuickAdapter<T, out BaseViewHolder>, recyclerView: RecyclerView) : Paging<T> {

    var mPage = 0
    var mTotalPage = Int.MAX_VALUE
    protected var mRefreshListener: ((Int) -> Unit)? = null
    protected var mLoadMoreListener: ((Int) -> Unit)? = null
    // 是否显示没有更多
    var isShowNoMoreDataView = true

    init {
        recyclerView.layoutManager = LinearLayoutManager(recyclerView.context)
        adapter.bindToRecyclerView(recyclerView)
        adapter.setOnLoadMoreListener(::loadMore, recyclerView)
    }

    override fun setOnLoadMoreListener(listener: ((Int) -> Unit)?) {
        if (listener == null) {
            adapter.setEnableLoadMore(false)
        }
        mLoadMoreListener = listener
    }

    override fun setOnRefreshListener(listener: ((Int) -> Unit)) {
        mRefreshListener = listener
    }

    override fun loadMore() {
        if (mLoadMoreListener == null) {
            return
        }
        if (mPage >= mTotalPage) {
            adapter.loadMoreEnd()
        } else {
            mPage++
            mLoadMoreListener?.invoke(mPage)
        }
    }

    override fun refresh() {
        mPage = 1
        mRefreshListener?.invoke(mPage)
    }

    override fun setNewData(newData: List<T>) {
        adapter.setNewData(newData)
        finishRefresh()
    }

    override fun loadMoreData(newData: List<T>) {
        if (!newData.isEmpty()) {
            adapter.addData(newData)
            finishLoadMore()
        } else {
            onNoMoreData()
        }
    }

    override fun finishLoadMore() {
        if (mPage == mTotalPage) {
            onNoMoreData()
        } else {
            adapter.loadMoreComplete()
        }
    }

    override fun finishRefresh() {
        if (mPage >= mTotalPage || adapter.data.size < Paging.limit) {
            adapter.disableLoadMoreIfNotFullPage()
            onNoMoreData()
        }
    }

    override fun onNoMoreData() = adapter.loadMoreEnd(!isShowNoMoreDataView)

    override fun isAlreadyLoaded() = adapter.data.isEmpty().not()

    override fun onError() {
        // todo : 先不实现，有需求再说
    }
}