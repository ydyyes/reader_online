package com.bule.free.ireader.ui.adapter;

import android.content.Context;

import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.ui.adapter.view.MallRightBookHolder;
import com.bule.free.ireader.ui.base.adapter.IViewHolder;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;

/**
 * Created by newbiechen on 17-5-8.
 */

public class BookMallRightAdapter extends WholeAdapter<BookMallItemBean> {

    public BookMallRightAdapter(Context context, Options options) {
        super(context, options);
    }

    @Override
    protected IViewHolder<BookMallItemBean> createViewHolder(int viewType) {
        return new MallRightBookHolder();
    }

}
