package com.bule.free.ireader.presenter

import android.annotation.SuppressLint
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.ToastUtils
import com.bule.free.ireader.common.utils.async
import com.bule.free.ireader.common.utils.go
import com.bule.free.ireader.model.User
import com.bule.free.ireader.model.bean.BookCollItemBean
import com.bule.free.ireader.model.bean.BookDetailPageBean
import com.bule.free.ireader.model.local.BookRepository
import com.bule.free.ireader.model.local.DatabaseUtils
import com.bule.free.ireader.model.objectbox.OB
import com.bule.free.ireader.model.objectbox.bean.BookBean
import com.bule.free.ireader.presenter.contract.BookShelfContract
import com.bule.free.ireader.ui.adapter.view.CollBookHolder
import com.bule.free.ireader.ui.base.RxPresenter
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

/**
 * Created by suikajy on 2019/2/27
 */
class BookShelfPresenter : RxPresenter<BookShelfContract.View>(), BookShelfContract.Presenter {

    private var isRefreshed = false
    override fun refreshRemoteBooks() {
        Api.getRecommendList(User.gender.apiParam, 1, 6)
                .doOnSuccess {
                    OB.boxStore.boxFor(BookBean::class.java).put(it)
                }
                .go(this, {
                    //LogUtils.e("获取远程书籍$it")
                    mView.finishRemoteBooks(it)
                    mView.complete()
                }, {
                    mView.complete()
                })
    }

    override fun refreshLocalBooks() {
//        val orderby: String
        val sort = User.shelfSort
        val order: BookRepository.BookShelfOrder
        if (sort == 0) {//最近阅读
            order = BookRepository.BookShelfOrder.LAST_READ
            //= "lastRead desc"
        } else {
            order = BookRepository.BookShelfOrder.UPDATE
            //orderby = "updated desc"
        }

        BookRepository.getCollBookList(order)
                .async()
                .go(this, {
                    //LogUtils.e("获取本地书籍$it")
                    mView.finishLocalBooks(it)
                    mView.complete()
                }, {
                    mView.complete()
                    mView.finishLocalBooks(null)
                })
    }

    private var safeTime = 0L
    @SuppressLint("CheckResult")
    override fun updateLocalBooks(collBookBeans: MutableList<BookBean>) {
        if (isRefreshed) return
        isRefreshed = true
        val currentTimeMillis = System.currentTimeMillis()
        if (currentTimeMillis - safeTime < 30000) return
        val observables = ArrayList<Single<BookDetailPageBean>>(collBookBeans.size)
        for (bean in collBookBeans) {
            if (bean.id == CollBookHolder.ADD_BUTTON_ID) {
                continue
            }
            observables.add(Api.getBookDetail(bean.id))
        }

        collBookBeans.forEach {
            if (it.id == CollBookHolder.ADD_BUTTON_ID) return@forEach

        }

        val it = collBookBeans.iterator()
        //执行在上一个方法中的子线程中
        Single.concat<BookDetailPageBean>(observables)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        { book ->
                            if (book != null) {
                                val bean = it.next()
                                bean.over = book.detail.over
                                bean.title = book.detail.title
                                bean.cover = book.detail.cover
                                bean.lastChapter = book.detail.lastChapter

                                bean.isNewChapter = book.detail.updated > bean.updated

                                bean.updated = book.detail.updated
                                LogUtils.e("book notif")
                            }
                        },
                        { e ->
                            LogUtils.e(e)
                        }, {
                    mView?.finishUpdateBook()
                })
        safeTime = System.currentTimeMillis()
    }

    override fun delBookShelf(mBookDetailBean: BookBean) {
        BookRepository.delBookShelf(mBookDetailBean.id)
                .go(this, {
                    mView.finishDelBook()
                    mView.complete()
                }, {
                    ToastUtils.show("删除失败，请重试")
                    mView.complete()
                })
    }
}