package com.bule.free.ireader.ui.adapter.view;

import android.text.TextUtils;
import android.widget.ImageView;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.ui.base.adapter.ViewHolderImpl;
import com.bule.free.ireader.common.utils.Res;
import com.bule.free.ireader.common.library.glide.GlideExtKt;

/**
 * Created by newbiechen on 17-5-1.
 */

public class BookRandHolder extends ViewHolderImpl<BookDetailBean> {

    private ImageView mIvPortrait;
    private TextView mTvTitle;
    private TextView mTvAuthor;
    private TextView mTvMsg;

    @Override
    protected int getItemLayoutId() {
        return R.layout.item_book_rand;
    }

    @Override
    public void initView() {
        mIvPortrait = findById(R.id.book_brief_iv_portrait);
        mTvTitle = findById(R.id.book_brief_tv_title);
        mTvAuthor = findById(R.id.book_brief_tv_author);
        mTvMsg = findById(R.id.book_brief_tv_msg);
    }

    @Override
    public void onBind(BookDetailBean value, int pos) {

        GlideExtKt.load(mIvPortrait,value.getCover());
        //书单名
        mTvTitle.setText(value.getTitle());
        //作者
        if (!TextUtils.isEmpty(value.getMajorCate())) {
            mTvAuthor.setText(value.getAuthor() + " | " + value.getMajorCate());
        } else {
            mTvAuthor.setText(value.getAuthor());
        }

        String nb_book_message = Res.INSTANCE.string(R.string.book_message);
        //信息
        mTvMsg.setText(String.format(nb_book_message,
                value.getLatelyFollower(), value.getRetentionRatio()));
    }
}
