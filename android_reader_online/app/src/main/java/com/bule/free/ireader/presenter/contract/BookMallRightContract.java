package com.bule.free.ireader.presenter.contract;

import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.model.bean.CategoryBean;
import com.bule.free.ireader.ui.base.BaseContract;

import java.util.List;

/**
 * Created by newbiechen on 17-5-8.
 */

public interface BookMallRightContract {

    interface View extends BaseContract.BaseView {
        void finishRefreshRight(List<BookMallItemBean> BookDetailBeans);

        void finishLoad(List<BookMallItemBean> BookDetailBeans);

        void showErrorTip(String error);
    }

    interface Presenter extends BaseContract.BasePresenter<View> {

        void refreshRightBooksList(CategoryBean mBookCateBean, int page, int limit);

        void updateRightBooks(CategoryBean mBookCateBean, int page, int limit);
    }
}
