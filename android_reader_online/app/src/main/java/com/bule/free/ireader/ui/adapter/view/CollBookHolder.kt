package com.bule.free.ireader.ui.adapter.view

import android.support.constraint.ConstraintLayout
import android.text.TextUtils
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.model.bean.BookCollItemBean
import com.bule.free.ireader.ui.adapter.CollBookAdapter
import com.bule.free.ireader.ui.base.adapter.ViewHolderImpl
import com.bule.free.ireader.main.fragment.BookShelfFragment
import com.bule.free.ireader.common.utils.dp
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.model.objectbox.bean.BookBean

/**
 * Created by newbiechen on 17-5-8.
 * CollectionBookView
 */

class CollBookHolder : ViewHolderImpl<BookBean>() {

    companion object {
        const val ADD_BUTTON_ID = "add"
        const val ADV_BUTTON_ID = "adv"
    }

    private lateinit var mIvCover: ImageView
    private lateinit var mTvName: TextView
    private lateinit var mTvChapter: TextView
    private lateinit var ll_book_text: LinearLayout
    private lateinit var coll_book_red_rot: View
    private lateinit var iv_shelf_decorator: ImageView

    override fun getItemLayoutId() = R.layout.item_coll_book

    override fun initView() {
        mIvCover = findById(R.id.coll_book_iv_cover)
        mTvName = findById(R.id.coll_book_tv_name)
        mTvChapter = findById(R.id.coll_book_tv_lastchapter)
        ll_book_text = findById(R.id.ll_book_text)
        coll_book_red_rot = findById(R.id.coll_book_red_rot)
        iv_shelf_decorator = findById(R.id.iv_shelf_decorator)
    }

    override fun onBind(value: BookBean, pos: Int) {
        val coverLayoutParams = mIvCover.layoutParams as ConstraintLayout.LayoutParams
        val textLayoutParams = ll_book_text.layoutParams as ConstraintLayout.LayoutParams
        val decoratorLayoutParams = iv_shelf_decorator.layoutParams as ConstraintLayout.LayoutParams

        when {
            pos % BookShelfFragment.SPAN_COUNT == 0 -> {
                // 左
                coverLayoutParams.horizontalBias = 0.9f
                decoratorLayoutParams.rightMargin = dp(0)
                decoratorLayoutParams.leftMargin = dp(0)
                iv_shelf_decorator.setBackgroundResource(R.drawable.main_shelf_decorator_left)
            }
            pos % BookShelfFragment.SPAN_COUNT == BookShelfFragment.SPAN_COUNT - 1 -> {
                // 右
                coverLayoutParams.horizontalBias = 0.1f
                decoratorLayoutParams.rightMargin = dp(0)
                decoratorLayoutParams.leftMargin = dp(0)
                iv_shelf_decorator.setBackgroundResource(R.drawable.main_shelf_decorator_right)
            }
            else -> {
                // 中
                coverLayoutParams.horizontalBias = 0.5f
                decoratorLayoutParams.rightMargin = 0
                decoratorLayoutParams.leftMargin = 0
                iv_shelf_decorator.setBackgroundResource(R.drawable.main_shelf_decorator_middle)
            }
        }

        val mod = CollBookAdapter.currentBookItemCount % 3
        val lastRowViewCount = if (mod == 0) 3 else mod

        if (pos > CollBookAdapter.currentBookItemCount - lastRowViewCount - 1) {
            // 最后一行
            iv_shelf_decorator.visibility = View.GONE
        } else {
            iv_shelf_decorator.visibility = View.VISIBLE
        }

        mIvCover.layoutParams = coverLayoutParams
        ll_book_text.layoutParams = textLayoutParams
        iv_shelf_decorator.layoutParams = decoratorLayoutParams

        if (value.id == ADD_BUTTON_ID) {
            //iv_book_status.visibility = View.GONE
            coll_book_red_rot.visibility = View.GONE
            mIvCover.setImageResource(R.drawable.shelf_add)
            if (pos == 0) {
                mTvName.text = "书架空空如也"
                mTvChapter.text = ""
            } else {
                mTvName.text = ""
                mTvChapter.text = ""
            }

        } else if (value.id == ADV_BUTTON_ID) {
            mTvName.text = value.title
            mTvChapter.text = ""
            mIvCover.load(value.cover)
            coll_book_red_rot.visibility = View.GONE
        } else {
            mIvCover.load(value.cover)

            //书名
            mTvName.text = value.title

            if (!TextUtils.isEmpty(value.lastChapter) && value.lastChapter != "null") {
                mTvChapter.text = "更新至" + value.lastChapter + "章"
            } else {
                mTvChapter.text = "无更新"
            }
            if (value.isNewChapter) {
                coll_book_red_rot.visibility = View.VISIBLE
            } else {
                coll_book_red_rot.visibility = View.GONE
            }

//            when {
//                value.over == 0 -> {
//                    iv_book_status.visibility = View.VISIBLE
//                    iv_book_status.setImageResource(R.drawable.ic_book_status_conti)
//                }
//                value.over == 1 -> {
//                    iv_book_status.visibility = View.VISIBLE
//                    iv_book_status.setImageResource(R.drawable.ic_book_status_over)
//                }
//                else -> iv_book_status.visibility = View.GONE
//            }
        }
    }


}
