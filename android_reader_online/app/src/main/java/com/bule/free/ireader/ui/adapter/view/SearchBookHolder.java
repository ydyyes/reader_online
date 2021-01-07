package com.bule.free.ireader.ui.adapter.view;

import android.widget.ImageView;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.ui.base.adapter.ViewHolderImpl;
import com.bule.free.ireader.common.library.glide.GlideExtKt;

/**
 * Created by newbiechen on 17-6-2.
 */

public class SearchBookHolder extends ViewHolderImpl<BookDetailBean> {

    private ImageView mIvCover;
    private TextView mTvName;
    private TextView mTvBrief;

    @Override
    public void initView() {
        mIvCover = findById(R.id.search_book_iv_cover);
        mTvName = findById(R.id.search_book_tv_name);
        mTvBrief = findById(R.id.search_book_tv_brief);
    }

    @Override
    public void onBind(BookDetailBean data, int pos) {
        //显示图片
        GlideExtKt.load(mIvCover, data.getCover());

        mTvName.setText(data.getTitle());

        mTvBrief.setText(String.format("%s人在追 | %s读者留存 | %s著", data.getLatelyFollower(), data.getRetentionRatio() + "%", data.getAuthor()));
    }

    @Override
    protected int getItemLayoutId() {
        return R.layout.item_search_book;
    }
}
