package com.bule.free.ireader.presenter

import com.bule.free.ireader.Const
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.model.bean.BookCollItemBean
import com.bule.free.ireader.model.bean.BookMallItemBean
import com.bule.free.ireader.model.bean.CategoryBean
import com.bule.free.ireader.presenter.contract.BookMallRightContract
import com.bule.free.ireader.ui.base.RxPresenter
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.model.objectbox.bean.BookBean
import java.util.*

class BookMallRightPresenter : RxPresenter<BookMallRightContract.View>(), BookMallRightContract.Presenter {

    override fun refreshRightBooksList(mBookCateBean: CategoryBean?, page: Int, limit: Int) {
        if (mBookCateBean == null) {
            mView.showError()
            return
        }

        if ("-1" == mBookCateBean.id) {
            addDisposable(Api.getRecommendList(Const.Gender.NONE.apiParam, 1, limit)
                    .subscribe(object : SimpleCallback<List<BookBean>> {
                        override fun onSuccess(bookCollItemBeans: List<BookBean>) {
                            val beans = ArrayList<BookMallItemBean>()
                            for (collItemBean in bookCollItemBeans) {
                                beans.add(BookMallItemBean.instanceOf(collItemBean))
                            }
                            mView.finishRefreshRight(beans)
                            mView.complete()
                        }

                        override fun onException(throwable: Throwable) {
                            LogUtils.e(throwable.toString())
                            mView.finishRefreshRight(null)
                            mView.complete()
                        }
                    }))
            return
        }

        val cateId = mBookCateBean.id.toInt()

        val disposable = Api.getBookMallItemList(cateId, "", page, limit)
                .subscribe({ bookMallItemBeans ->

                    mView.finishRefreshRight(bookMallItemBeans)
                    mView.complete()
                }, { throwable ->
                    LogUtils.e(throwable.toString())
                    mView.finishRefreshRight(null)
                    mView.complete()
                })

        addDisposable(disposable)
    }

    override fun updateRightBooks(mBookCateBean: CategoryBean, page: Int, limit: Int) {
        if ("-1" == mBookCateBean.id) {
            addDisposable(Api.getRecommendList(Const.Gender.NONE.apiParam, page, limit)
                    .subscribe(object : SimpleCallback<List<BookBean>> {
                        override fun onSuccess(bookCollItemBeans: List<BookBean>) {
                            val beans = ArrayList<BookMallItemBean>()
                            for (collItemBean in bookCollItemBeans) {
                                beans.add(BookMallItemBean.instanceOf(collItemBean))
                            }
                            mView.finishLoad(beans)
                            mView.complete()
                        }

                        override fun onException(throwable: Throwable) {
                            LogUtils.e(throwable.toString())
                        }
                    }))
            return
        }
        val cateId = Integer.parseInt(mBookCateBean.id)
        val disposable = Api.getBookMallItemList(cateId, "", page, limit)
                .subscribe({ bookMallItemBeans ->
                    mView.finishLoad(bookMallItemBeans)
                    mView.complete()
                }, { throwable -> LogUtils.e(throwable.toString()) })

        addDisposable(disposable)
    }

}
