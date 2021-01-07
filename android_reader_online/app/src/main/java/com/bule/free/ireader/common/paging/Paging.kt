package com.bule.free.ireader.common.paging

/**
 * Created by suikajy on 2019/3/18
 */
interface Paging<T> {

    companion object {
        // 每页请求个数，如果有用到的话
        const val limit = 6
    }

    /**
     * 设置上拉加载监听
     *
     * @param listener 监听
     */
    fun setOnLoadMoreListener(listener: ((Int) -> Unit)?)

    /**
     * 设置刷新监听
     *
     * @param listener 刷新回调
     */
    fun setOnRefreshListener(listener: ((Int) -> Unit))

    /**
     * 当上拉加载时需要做的实现
     */
    fun loadMore()

    /**
     * 当刷新时需要作的实现
     */
    fun refresh()

    /**
     * 加载刷新数据列表
     *
     * @param newData 接口返回的数据列表
     */
    fun setNewData(newData: List<T>)

    /**
     * 上拉加载数据
     *
     * @param newData 接口返回的数据列表
     */
    fun loadMoreData(newData: List<T>)

    /**
     * 加载更多完成的处理
     */
    fun finishLoadMore()

    /**
     * 刷新完成的处理
     */
    fun finishRefresh()

    /**
     * 没有更多处理
     */
    fun onNoMoreData()

    fun isAlreadyLoaded(): Boolean

    fun onError()
}