package com.bule.free.ireader.module.bookcate

import android.os.Bundle
import android.support.v7.widget.GridLayoutManager
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.widget.adapter.WholeAdapter
import com.bule.free.ireader.model.OffShelfEvent
import com.bule.free.ireader.model.bean.BookCollItemBean
import com.bule.free.ireader.model.bean.BookMallItemBean
import com.bule.free.ireader.model.bean.CategoryBean
import com.bule.free.ireader.model.objectbox.bean.BookBean
import com.bule.free.ireader.ui.activity.BookDetailActivity
import com.bule.free.ireader.ui.adapter.BookMallRightAdapter
import com.bule.free.ireader.ui.base.BaseFragment2
import com.umeng.analytics.MobclickAgent
import kotlinx.android.synthetic.main.fragment_book_cate.*
import java.util.*

/**
 * Created by suikajy on 2019-05-21
 */
class BookCateFragment : BaseFragment2() {

    private var mPage = 1
    private var mLimit = 9
    private lateinit var mAdapter: BookMallRightAdapter
    private var mBookCateBean: CategoryBean? = null

    override fun getContentViewId() = R.layout.fragment_book_cate

    override fun init(savedInstanceState: Bundle?) {
        MobclickAgent.onEvent(activity, "book_mall_fragment", "book_mall")
        //添加Footer
        val manager = GridLayoutManager(context, 3)
        mAdapter = BookMallRightAdapter(context, WholeAdapter.Options())
        scroll_recycler_view.setLayoutManager(manager)
        scroll_recycler_view.setAdapter(mAdapter)
        refreshRightBooksList()
        subscribeEvent(OffShelfEvent::class.java) {
            scroll_recycler_view.startRefresh()
            mPage = 1
            refreshRightBooksList()
        }
    }

    override fun setListener() {
        scroll_recycler_view.setOnRefreshListener {
            mPage = 1
            refreshRightBooksList()
        }
        mAdapter.setOnLoadMoreListener {
            mPage++
            updateRightBooks()
        }
        mAdapter.setOnItemClickListener { _, pos ->
            val item = mAdapter.getItem(pos)
            BookDetailActivity.start(activity, item.id, false)
        }
    }

    fun setBookCates(bookCateBean: CategoryBean) {
        mBookCateBean = bookCateBean
    }

    private fun refreshRightBooksList() {
        if (mBookCateBean == null) {
            mAdapter.showLoadError()
            return
        }

        if ("-1" == mBookCateBean!!.id) {
            LogUtils.e("加载推荐")
            Api.getRecommendList(Const.Gender.NONE.apiParam, 1, mLimit)
                    .go({ bookBeanList ->
                        LogUtils.e("bookCollItemBeans: $bookBeanList")
                        val beans = ArrayList<BookMallItemBean>()
                        for (bookBean in bookBeanList) {
                            beans.add(BookMallItemBean.instanceOf(bookBean))
                        }
                        finishRefreshRight(beans)
                        scroll_recycler_view.finishRefresh()
                    }, { throwable ->
                        LogUtils.e(throwable.toString())
                        finishRefreshRight(null)
                        scroll_recycler_view.finishRefresh()
                    }, true)
            return
        }

        val cateId = mBookCateBean!!.id.toInt()
        LogUtils.e("加载分类，分类id：$cateId")
        Api.getBookMallItemList(cateId, "", mPage, mLimit)
                .go({ bookMallItemBeans ->
                    LogUtils.e("bookMallItemBeans: $bookMallItemBeans")
                    finishRefreshRight(bookMallItemBeans)
                    scroll_recycler_view.finishRefresh()
                }, { throwable ->
                    LogUtils.e(throwable.toString())
                    finishRefreshRight(null)
                    scroll_recycler_view.finishRefresh()
                }, true)
    }

    private fun updateRightBooks() {
        if (mBookCateBean == null) {
            mAdapter.showLoadError()
            return
        }
        if ("-1" == mBookCateBean!!.id) {
            addDisposable(Api.getRecommendList(Const.Gender.NONE.apiParam, mPage, mLimit)
                    .subscribe(object : SimpleCallback<List<BookBean>> {
                        override fun onSuccess(bookCollItemBeans: List<BookBean>) {
                            val beans = ArrayList<BookMallItemBean>()
                            for (collItemBean in bookCollItemBeans) {
                                beans.add(BookMallItemBean.instanceOf(collItemBean))
                            }
                            finishLoad(beans)
                            scroll_recycler_view.finishRefresh()
                        }

                        override fun onException(throwable: Throwable) {
                            LogUtils.e(throwable.toString())
                        }
                    }))
            return
        }
        val cateId = Integer.parseInt(mBookCateBean!!.id)
        Api.getBookMallItemList(cateId, "", mPage, mLimit)
                .go { bookMallItemBeans ->
                    finishLoad(bookMallItemBeans)
                    scroll_recycler_view.finishRefresh()
                }
    }

    private fun finishRefreshRight(beans: List<BookMallItemBean>?) {
        if (beans == null || beans.isEmpty()) {
            mAdapter.hideLoad()
            return
        }
        LogUtils.e("finishRefreshRight() beans：$beans")
        mAdapter.refreshItems(beans)

        if (beans.size < mLimit) {
            mAdapter.hideLoad()
        }
    }

    private fun finishLoad(beans: List<BookMallItemBean>?) {
        if (beans == null || beans.isEmpty()) {
            mAdapter.hideLoad()
            return
        }
        if (!mAdapter.items.containsAll(beans)) {
            mAdapter.addItems(beans)
        }

    }
}
