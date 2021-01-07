package com.bule.free.ireader.ui.adapter;

import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.ui.adapter.view.SearchBookHolder;
import com.bule.free.ireader.ui.base.adapter.BaseListAdapter;
import com.bule.free.ireader.ui.base.adapter.IViewHolder;

/**
 * Created by newbiechen on 17-6-2.
 */
@Deprecated
public class SearchBookAdapterOld extends BaseListAdapter<BookDetailBean> {
    @Override
    protected IViewHolder<BookDetailBean> createViewHolder(int viewType) {
        return new SearchBookHolder();
    }
}
