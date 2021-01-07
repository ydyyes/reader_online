package com.bule.free.ireader.presenter.contract;

import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.ui.base.BaseContract;

import java.util.List;

/**
 * Created by newbiechen on 17-6-2.
 */

public interface SearchContract extends BaseContract {

    interface View extends BaseView {
        void finishHotWords(List<String> hotWords);

        void finishBooks(List<BookDetailBean> books);

        void finishLoadBooks(List<BookDetailBean> books);

        void errorBooks();
    }

    interface Presenter extends BasePresenter<View> {
        void searchHotWord();

        //搜索书籍
        void searchBook(String query, int page, int limit);

        void searchBookLoadMore(String query, int page, int limit);
    }
}
