package com.bule.free.ireader.ui.adapter.view;

import android.text.TextUtils;
import android.widget.ImageView;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.ui.base.adapter.ViewHolderImpl;
import com.bule.free.ireader.common.library.glide.GlideExtKt;

/**
 * Created by newbiechen on 17-5-1.
 */

public class BookListHolder extends ViewHolderImpl<BookMallItemBean> {

    private ImageView mIvPortrait;
    private TextView mTvTitle;
    private TextView mTvAuthor;
    private TextView mTvMsg;
    private ImageView mIvLevel;

    @Override
    protected int getItemLayoutId() {
        return R.layout.item_book_list;
    }

    @Override
    public void initView() {
        mIvPortrait = findById(R.id.book_brief_iv_portrait);
        mTvTitle = findById(R.id.book_brief_tv_title);
        mTvAuthor = findById(R.id.book_brief_tv_author);
        mTvMsg = findById(R.id.book_brief_tv_msg);
        mIvLevel = findById(R.id.book_brief_iv_level);
    }

    @Override
    public void onBind(BookMallItemBean value, int pos) {

        GlideExtKt.load(mIvPortrait, value.getCover());
        //书单名
        mTvTitle.setText(value.getTitle());
        //作者
        if (!TextUtils.isEmpty(value.getMajorCate())) {
            mTvAuthor.setText(value.getAuthor() + " | " + value.getMajorCate());
        } else {
            mTvAuthor.setText(value.getAuthor());
        }

        //信息
        mTvMsg.setText(value.getLongIntro());


        if (pos == 0) {
            mIvLevel.setImageResource(R.drawable.ic_level_1);
        } else if (pos == 1) {
            mIvLevel.setImageResource(R.drawable.ic_level_2);
        } else if (pos == 2) {
            mIvLevel.setImageResource(R.drawable.ic_level_3);
        } else {
            mIvLevel.setImageDrawable(null);
        }
    }
}
