package com.bule.free.ireader.ui.adapter.view

import android.annotation.SuppressLint
import android.text.TextUtils
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.utils.bindView
import com.bule.free.ireader.model.bean.BookCollItemBean
import com.bule.free.ireader.model.objectbox.bean.BookBean
import com.bule.free.ireader.ui.base.adapter.ViewHolderImpl

/**
 * Created by suikajy on 2019-04-23
 */
class ListCollBookHolder : ViewHolderImpl<BookBean>() {
    private val mDivider: View by bindView(R.id.divider)
    private val mTvAddFavoriteBookHint: TextView by bindView(R.id.tv_add_favorite_book_hint)
    private val mIvBookCover: ImageView by bindView(R.id.iv_book_cover)
    //    private val mIvBookStatus: ImageView by bindView(R.id.iv_book_status)
    private val mCollBookRedRot: View by bindView(R.id.coll_book_red_rot)
    private val mTvBookTitle: TextView by bindView(R.id.tv_book_title)
    private val mTvBookAuthorAndType: TextView by bindView(R.id.tv_book_author_and_type)
    private val mTvLastUpdate: TextView by bindView(R.id.tv_last_update)

    override fun getItemLayoutId() = R.layout.item_book_shelf_list

    override fun initView() {}

    @SuppressLint("SetTextI18n")
    override fun onBind(data: BookBean, pos: Int) {
        when (data.id) {
            CollBookHolder.ADD_BUTTON_ID -> {
                mCollBookRedRot.visibility = View.GONE
                mIvBookCover.load(R.drawable.shelf_add)
                mTvBookTitle.text = ""
                mTvLastUpdate.text = ""
                mTvAddFavoriteBookHint.visibility = View.VISIBLE
                mDivider.visibility = View.GONE
                mTvBookAuthorAndType.text = ""
            }
            CollBookHolder.ADV_BUTTON_ID -> {
                mIvBookCover.load(data.cover)
                mTvBookTitle.text = ""
                mTvLastUpdate.text = ""
                mTvBookAuthorAndType.visibility = View.GONE
                mCollBookRedRot.visibility = View.GONE
                mTvAddFavoriteBookHint.visibility = View.VISIBLE
                mTvAddFavoriteBookHint.text = data.title
                mDivider.visibility = View.VISIBLE
            }
            else -> {
                mDivider.visibility = View.VISIBLE
                mTvAddFavoriteBookHint.visibility = View.GONE
                mIvBookCover.load(data.cover)
                mTvBookTitle.text = data.title
                if (!TextUtils.isEmpty(data.lastChapter) && data.lastChapter != "null") {
                    mTvLastUpdate.text = "更新至" + data.lastChapter + "章"
                } else {
                    mTvLastUpdate.text = "无更新"
                }
                if (data.isNewChapter) {
                    mCollBookRedRot.visibility = View.VISIBLE
                } else {
                    mCollBookRedRot.visibility = View.GONE
                }
            }
        }
    }
}