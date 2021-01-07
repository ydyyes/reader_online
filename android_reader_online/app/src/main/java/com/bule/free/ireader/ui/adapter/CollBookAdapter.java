package com.bule.free.ireader.ui.adapter;

import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;

import com.bule.free.ireader.model.bean.BookCollItemBean;
import com.bule.free.ireader.model.objectbox.bean.BookBean;
import com.bule.free.ireader.ui.adapter.view.CollBookHolder;
import com.bule.free.ireader.ui.base.adapter.IViewHolder;
import com.bule.free.ireader.main.fragment.BookShelfFragment;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;

import java.util.List;

/**
 * Created by newbiechen on 17-5-8.
 */

public class CollBookAdapter extends WholeAdapter<BookBean> {
    // 当前书架上面的书数量, 包括添加到书架那个按钮
    public static int currentBookItemCount = 0;

    @Override
    protected IViewHolder<BookBean> createViewHolder(int viewType) {
        return new CollBookHolder();
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        RecyclerView.LayoutManager manager = recyclerView.getLayoutManager();
        if (manager instanceof GridLayoutManager) {
            final GridLayoutManager gridManager = ((GridLayoutManager) manager);
            gridManager.setSpanSizeLookup(new WholeGridSpanSizeLookUp(BookShelfFragment.SPAN_COUNT));
        }
    }

    @Override
    public void refreshItems(List<BookBean> list) {
        currentBookItemCount = list.size();
        super.refreshItems(list);
    }
}
