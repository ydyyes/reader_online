package com.bule.free.ireader.ui.adapter;

import com.bule.free.ireader.common.widget.adapter.WholeAdapter;
import com.bule.free.ireader.model.bean.BookCollItemBean;
import com.bule.free.ireader.model.objectbox.bean.BookBean;
import com.bule.free.ireader.ui.adapter.view.ListCollBookHolder;
import com.bule.free.ireader.ui.base.adapter.IViewHolder;

import java.util.List;

/**
 * Created by suikajy on 2019-04-23
 */
public class ListCollBookAdapter extends WholeAdapter<BookBean> {
    // 当前书架上面的书数量, 包括添加到书架那个按钮
    public static int currentBookItemCount = 0;

    @Override
    protected IViewHolder<BookBean> createViewHolder(int viewType) {
        return new ListCollBookHolder();
    }

    @Override
    public void refreshItems(List<BookBean> list) {
        currentBookItemCount = list.size();
        super.refreshItems(list);
    }
}