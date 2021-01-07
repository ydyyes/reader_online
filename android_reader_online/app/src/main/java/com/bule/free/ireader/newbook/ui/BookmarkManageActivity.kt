package com.bule.free.ireader.newbook.ui

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.paging.Paging
import com.bule.free.ireader.common.paging.SwipePagingDel
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.BookmarkBean
import com.bule.free.ireader.model.NewReadBookBookmarkClickEvent
import com.bule.free.ireader.model.NewReadBookRefreshBookmarkEvent
import com.bule.free.ireader.model.local.BookRepository
import com.bule.free.ireader.model.bean.BookChapterBean
import com.bule.free.ireader.ui.base.BaseActivity2
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import kotlinx.android.synthetic.main.activity_bookmark_manage.*

/**
 * Created by suikajy on 2019-04-24
 *
 * 书签管理页面
 */
class BookmarkManageActivity : BaseActivity2() {

    companion object {
        const val KEY_BOOK_ID = "key_book_id"
        fun start(activity: Activity, bookId: String) {
            val intent = Intent(activity, BookmarkManageActivity::class.java)
            intent.putExtra(KEY_BOOK_ID, bookId)
            activity.startActivity(intent)
        }
    }

    private var mManageMode = Mode.NORMAL
    private val mBookId: String by lazy { intent.getStringExtra(KEY_BOOK_ID) }
    private val mAdapter: Adapter by lazy { Adapter() }
    private val mBookmarkList = mutableListOf<BookmarkBeanWrapper>()
    private val mChapterList: MutableList<BookChapterBean> = mutableListOf()
    private val mPaging: Paging<BookmarkBeanWrapper> by lazy {
        SwipePagingDel(mAdapter, swipe_recycler_view, {
            Api.getBookmarkList(mBookId).go { bookmarkBeanList ->
                mBookmarkList.clear()
                bookmarkBeanList.forEach { bean ->
                    mBookmarkList.add(BookmarkBeanWrapper(bean, false))
                }
                mBookmarkList.sortByDescending { it.bookmarkBean.timestemp }
                mPaging.setNewData(mBookmarkList)
            }
        }, { mPaging.loadMoreData(emptyList()) }).apply { goneNoDataView() }
    }

    override val layoutId = R.layout.activity_bookmark_manage

    override fun init() {
        BookRepository.getChapterList(mBookId).go {
            mChapterList.clear()
            mChapterList.addAll(it)
        }
        refreshCheckView()
        changeMode(Mode.NORMAL)
        mPaging.refresh()
    }

    override fun setListener() {
        toolbar_view.setOnRightClickListener { changeMode(if (mManageMode == Mode.MANAGE) Mode.NORMAL else Mode.MANAGE) }
        btn_delete.onSafeClick { v ->
            val bookmarkBeanList = mBookmarkList.asSequence()
                    .filter { it.isChecked }
                    .map { it.bookmarkBean }
                    .toList()
            Api.deleteBookmark(mBookId, bookmarkBeanList).go {
                mBookmarkList.removeAll { it.isChecked }
                RxBus.post(NewReadBookRefreshBookmarkEvent)
                mAdapter.notifyDataSetChanged()
                if (mBookmarkList.isEmpty()) {
                    changeMode(Mode.NORMAL)
                }
                refreshCheckView()
            }
        }
        btn_check_all.setOnClickListener {
            if (mBookmarkList.isEmpty()) return@setOnClickListener
            if (isAllChecked()) {
                mBookmarkList.forEach { it.isChecked = false }
            } else {
                mBookmarkList.forEach { it.isChecked = true }
            }
            mAdapter.notifyDataSetChanged()
            refreshCheckView()
        }
    }

    private fun changeMode(mode: Mode) {
        when (mode) {
            Mode.NORMAL -> {
                toolbar_view.setRightText("管理")
                layout_manage.visibility = View.GONE
            }
            Mode.MANAGE -> {
                if (mBookmarkList.isEmpty()) return
                toolbar_view.setRightText("取消")
                layout_manage.visibility = View.VISIBLE
            }
        }
        mManageMode = mode
        mAdapter.notifyDataSetChanged()

    }

    private fun isAllChecked() = mBookmarkList.all { it.isChecked }

    private fun isNoneChecked() = mBookmarkList.all { it.isChecked.not() }

    @SuppressLint("SetTextI18n")
    private fun refreshCheckView() {
        if (mBookmarkList.isEmpty()) {
            btn_check_all.text = "全选"
            btn_delete.text = "删除"
            return
        }

        if (isAllChecked()) {
            btn_check_all.text = "取消全选"
        } else {
            btn_check_all.text = "全选"
        }

        if (isNoneChecked()) {
            btn_delete.text = "删除"
            btn_delete.isEnabled = false
        } else {
            btn_delete.text = "删除 (${mBookmarkList.count { it.isChecked }})"
            btn_delete.isEnabled = true
        }
    }


    inner class Adapter : BaseQuickAdapter<BookmarkBeanWrapper, ViewHolder>(R.layout.item_bookmark_manage) {

        @SuppressLint("SetTextI18n")
        override fun convert(helper: ViewHolder, item: BookmarkBeanWrapper) {
            if (mManageMode == Mode.MANAGE) {
                helper.mIvCheckBox.visibility = View.VISIBLE
            } else {
                helper.mIvCheckBox.visibility = View.GONE
            }
            helper.mIvCheckBox.setImageResource(if (item.isChecked) R.drawable.book_dl_ic_checked_p else R.drawable.book_dl_ic_checked_n)
            helper.mTvChapterTitle.text = item.bookmarkBean.title
            helper.mTvPercent.text = item.bookmarkBean.percentage + "%"
            helper.mTvBmAddTime.text = (item.bookmarkBean.timestemp.toLong() * 1000).toDateString()
            helper.itemView.setOnClickListener {
                if (mManageMode == Mode.MANAGE) {
                    if (item.isChecked) {
                        helper.mIvCheckBox.setImageResource(R.drawable.book_dl_ic_checked_n)
                        item.isChecked = false
                    } else {
                        helper.mIvCheckBox.setImageResource(R.drawable.book_dl_ic_checked_p)
                        item.isChecked = true
                    }
                    refreshCheckView()
                } else {
                    LogUtils.e("点击书签：${item.bookmarkBean}")
                    RxBus.post(NewReadBookBookmarkClickEvent(item.bookmarkBean))
                    finish()
                }
            }
        }
    }

    class ViewHolder(view: View) : BaseViewHolder(view) {
        val mIvCheckBox: ImageView by bindView(R.id.iv_check_box)
        val mTvChapterTitle: TextView by bindView(R.id.tv_chapter_title)
        val mTvBmAddTime: TextView by bindView(R.id.tv_bm_add_time)
        val mTvPercent: TextView by bindView(R.id.tv_percent)
    }

    private enum class Mode {
        NORMAL, MANAGE
    }

    data class BookmarkBeanWrapper(val bookmarkBean: BookmarkBean, var isChecked: Boolean)
}