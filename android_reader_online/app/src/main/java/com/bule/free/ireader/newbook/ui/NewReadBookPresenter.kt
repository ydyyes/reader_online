package com.bule.free.ireader.newbook.ui

import com.bule.free.ireader.api.Api
import com.bule.free.ireader.model.local.BookRepository
import com.bule.free.ireader.common.library.java1_8.Consumer
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.BookmarkBean
import com.bule.free.ireader.model.bean.BookChapterBean
import org.jetbrains.anko.alert
import java.lang.Exception
import java.util.*

/**
 * Created by suikajy on 2019/4/10
 */
internal class NewReadBookPresenter(private val mView: NewReadBookActivity) {

    private val mBookChapterList: MutableList<BookChapterBean> get() = mView.mBookChapterList
    private val mBookmarkList: MutableList<BookmarkBean> get() = mView.mBookmarkList

    // 当退出读书页面，判断是否加入过书架，否则提示加入
    fun isBookInShelf(bookId: String, backAction: Runnable, addBookShelfAction: Consumer<String>) {
        BookRepository.checkCollBook(bookId)
                .async()
                .go(mView, {
                    if (it.isPresent) {
                        backAction.run()
                    } else {
                        mView.alert {
                            message = "是否加入到书架"
                            positiveButton("确认") {
                                addBookShelfAction.accept(bookId)
                                backAction.run()
                            }
                            negativeButton("取消") {
                                backAction.run()
                            }
                        }.show()
                    }
                }, { backAction.run() })
    }

    // 添加书签，书签并未添加缓存😏，只是一个成员变量
    fun addBookmark() {
        if (mView.mBookChapterList.isEmpty()) {
            ToastUtils.show("章节未加载成功，请稍后")
            return
        }
        val currentChapterBean = mView.mBookChapterList[mView.mCurrentChapterIndex]
        val percentage = getCurChapterPercentage()
        if (percentage != -1.0) {
            val percentageParam = String.format(Locale.CHINESE, "%.2f", percentage * 100)
            Api.addBookmark(mView.mBookId, currentChapterBean._label, percentageParam, currentChapterBean.title).go(mView) {
                ToastUtils.show("添加成功")
                mView.mIvCheckBookmark.isSelected = true
                val bookmarkBean = BookmarkBean(currentChapterBean._label, percentageParam, System.currentTimeMillis().toSecond().toString())
                mBookmarkList.add(bookmarkBean)
                mView.mCurrentBookmark = bookmarkBean
            }
        } else {
            ToastUtils.show("添加失败")
        }
    }

    // 删除书签
    fun deleteBookmark() {
        val bookmark = mView.mCurrentBookmark
        if (bookmark != null) {
            Api.deleteBookmark(mView.mBookId, listOf(bookmark)).go(mView) {
                mView.mIvCheckBookmark.isSelected = false
                mBookmarkList.remove(bookmark)
                ToastUtils.show("取消成功")
            }
        } else {
            ToastUtils.show("取消书签失败：无此书签")
        }
    }

    // 每当翻页，判断当前页是否有书签，有则返回书签，无则返回null
    fun getCurrentPageBookMark(): BookmarkBean? {
        if (mBookmarkList.isEmpty()) return null
        try {
            val currentChapterLabel = mBookChapterList[mView.mCurrentChapterIndex]._label
            val curChapterBookmarks = mBookmarkList.filter { it.label == currentChapterLabel }
            if (curChapterBookmarks.isEmpty()) return null
            for (bookmark in curChapterBookmarks) {
                if (isBookmarkInThisPage(bookmark)) {
                    return bookmark
                }
            }
        } catch (e: Exception) {
            return null
        }
        return null
    }

    // 获取当前章节当前页所占当前章节总页数的百分比，结果为0到1的double，-1代表获取失败
    private fun getCurChapterPercentage(): Double {
        val durContentView = mView.csvBook.durContentView
        val pageAll = durContentView.pageAll
        LogUtils.e("pageAll: $pageAll")
        return if (pageAll != 0) {
            val percentage = (mView.mCurrentPageIndex * 1.0f / pageAll).toDouble()
            if (percentage > 0 && percentage < 0.9995) {
                percentage + 0.0005
            } else if (percentage > 0.9995) {
                0.9999
            } else {
                0.0
            }
        } else {
            LogUtils.e(String.format("页数百分比计算错误：pageAll: %s", pageAll))
            LogUtils.e(String.format("页数百分比计算错误：mCurrentPageIndex: %s", mView.mCurrentPageIndex))
            -1.0
        }
    }

    // 判断书签bean的百分比是否在当前页
    private fun isBookmarkInThisPage(bookmark: BookmarkBean): Boolean {
        val percent = bookmark.percentage.toDouble() / 100
        val pageAll = mView.csvBook.durContentView.pageAll
//        LogUtils.e("pageAll: $pageAll")
//        LogUtils.e("percent: $percent")
        if (pageAll == 0) return false
        val currentPageIndex = mView.mCurrentPageIndex
//        LogUtils.e("currentPageIndex: $currentPageIndex")
        LogUtils.e("(percent * pageAll).toInt(): ${(percent * pageAll).toInt()}")
        return currentPageIndex == (percent * pageAll).toInt()
    }
}