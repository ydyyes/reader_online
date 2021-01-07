package com.bule.free.ireader.ui.adapter;


import com.bule.free.ireader.ui.adapter.view.HotKeyHolder;
import com.bule.free.ireader.ui.base.adapter.IViewHolder;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;

/**
 * Created by newbiechen on 17-5-1.
 */

public class HotKeyAdapter extends WholeAdapter<String> {


    @Override
    protected IViewHolder<String> createViewHolder(int viewType) {
        return new HotKeyHolder();
    }
}
