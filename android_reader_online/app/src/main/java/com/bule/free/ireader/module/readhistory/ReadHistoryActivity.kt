package com.bule.free.ireader.module.readhistory

import android.annotation.SuppressLint
import android.app.Activity
import android.content.DialogInterface
import android.content.Intent
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.paging.Paging
import com.bule.free.ireader.common.paging.SwipePagingDel
import com.bule.free.ireader.common.utils.bindView
import com.bule.free.ireader.model.objectbox.bean.BookHistoryBean
import com.bule.free.ireader.model.objectbox.bean.BookHistoryBean_
import com.bule.free.ireader.model.objectbox.boxOf
import com.bule.free.ireader.newbook.ui.NewReadBookActivity
import com.bule.free.ireader.ui.base.BaseActivity2
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import io.objectbox.query.QueryBuilder
import kotlinx.android.synthetic.main.activity_read_history.*
import org.jetbrains.anko.alert

/**
 * Created by suikajy on 2019-05-20
 */
class ReadHistoryActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, ReadHistoryActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private val mHistoryBox by lazy { boxOf(BookHistoryBean::class.java) }
    private val mAdapter by lazy { Adapter() }
    private val mPaging: Paging<BookHistoryBean> by lazy {
        SwipePagingDel(mAdapter, swipe_recycler_view, { page ->
            val beanList = mHistoryBox.query().order(BookHistoryBean_.addTime, QueryBuilder.DESCENDING).build().find()
            mPaging.setNewData(beanList)
        }, { page -> mPaging.loadMoreData(emptyList()) }).apply { goneNoDataView() }
    }

    override val layoutId = R.layout.activity_read_history

    override fun init() {
        mPaging.refresh()
    }

    override fun setListener() {
        toolbar_view.setOnRightClickListener {
            if (mHistoryBox.isEmpty) return@setOnRightClickListener
            alert {
                message = "确认清空全部记录？"
                positiveButton("是") {
                    mHistoryBox.removeAll()
                    mPaging.refresh()
                    it.dismiss()
                }
                negativeButton("否", DialogInterface::dismiss)
            }.show()
        }
    }

    private inner class Adapter : BaseQuickAdapter<BookHistoryBean, ViewHolder>(R.layout.item_read_history) {

        @SuppressLint("SetTextI18n")
        override fun convert(helper: ViewHolder, item: BookHistoryBean) {
            helper.mIvBookCover.load(item.cover)
            helper.mTvBookTitle.text = item.title
            helper.mTvLongIntro.text = item.longIntro
            helper.mTvBookAuthorAndType.text = "${item.author} | ${item.cates}"
            helper.itemView.setOnClickListener {
                item.addTime = System.currentTimeMillis()
                NewReadBookActivity.startActivityAndLog(this@ReadHistoryActivity, item)
            }
        }
    }

    private class ViewHolder(view: View) : BaseViewHolder(view) {
        val mIvBookCover: ImageView by bindView(R.id.iv_book_cover)
        val mTvBookTitle: TextView by bindView(R.id.tv_book_title)
        val mTvBookAuthorAndType: TextView by bindView(R.id.tv_book_author_and_type)
        val mTvLongIntro: TextView by bindView(R.id.tv_long_intro)
    }
}
