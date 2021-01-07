package com.bule.free.ireader.ui.adapter;

import android.content.Context;

import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.ui.adapter.view.BookRandHolder;
import com.bule.free.ireader.ui.base.adapter.IViewHolder;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;

/**
 * Created by newbiechen on 17-5-1.
 */

public class BookRandAdapter extends WholeAdapter<BookDetailBean> {
    public BookRandAdapter() {
    }

    public BookRandAdapter(Context context, Options options) {
        super(context, options);
    }

    @Override
    protected IViewHolder<BookDetailBean> createViewHolder(int viewType) {
        return new BookRandHolder();
    }
}
