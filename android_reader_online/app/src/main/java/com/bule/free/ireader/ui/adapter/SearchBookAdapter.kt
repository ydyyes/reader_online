package com.bule.free.ireader.ui.adapter

import android.content.Context
import com.bule.free.ireader.model.bean.BookDetailBean
import com.bule.free.ireader.ui.adapter.view.SearchBookHolder
import com.bule.free.ireader.common.widget.adapter.WholeAdapter

/**
 * Created by suikajy on 2019/3/2
 */
class SearchBookAdapter(context: Context) :
        WholeAdapter<BookDetailBean>(context, WholeAdapter.Options()) {
    override fun createViewHolder(viewType: Int) = SearchBookHolder()
}