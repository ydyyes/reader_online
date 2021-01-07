package com.bule.free.ireader.presenter.contract;

import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.model.CateMode;
import com.bule.free.ireader.ui.base.BaseContract;

import java.util.List;


public interface BookListContract {
    interface View extends BaseContract.BaseView {
        void finishRefreshList(List<BookMallItemBean> BookDetailBeans);

        void finishLoad(List<BookMallItemBean> BookDetailBeans);
    }

    interface Presenter extends BaseContract.BasePresenter<View> {
        void refreshBookList(CateMode mode, int start, int limit);

        void updateBookList(CateMode mode, int start, int limit);
    }
}
