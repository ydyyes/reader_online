package com.bule.free.ireader.presenter.contract;

import com.bule.free.ireader.model.bean.BannerBean;
import com.bule.free.ireader.model.bean.BookCollItemBean;
import com.bule.free.ireader.model.objectbox.bean.BookBean;
import com.bule.free.ireader.ui.base.BaseContract;

import java.util.List;

/**
 * Created by newbiechen on 17-5-8.
 */

public interface BookShelfContract {

    interface View extends BaseContract.BaseView {
        void finishRemoteBooks(List<BookBean> collBookBeans);

        void finishLocalBooks(List<BookBean> collBookBeans);

        void finishUpdateBook();

        void showErrorTip(String error);

        void finishDelBook();
    }

    interface Presenter extends BaseContract.BasePresenter<View> {
        void refreshRemoteBooks();

        void refreshLocalBooks();

        void updateLocalBooks(List<BookBean> collBookBeans);

        void delBookShelf(BookBean mBookDetailBean);
    }
}
