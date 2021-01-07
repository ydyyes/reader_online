package com.bule.free.ireader.ui.adapter;

import android.content.Context;

import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.ui.adapter.view.BookListHolder;
import com.bule.free.ireader.ui.base.adapter.IViewHolder;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;

/**
 * Created by newbiechen on 17-5-1.
 */

public class BookListAdapter extends WholeAdapter<BookMallItemBean> {

    public BookListAdapter(Context context, Options options) {
        super(context, options);
    }

    @Override
    protected IViewHolder<BookMallItemBean> createViewHolder(int viewType) {
        return new BookListHolder();
    }
}
