package com.bule.free.ireader.presenter.contract;

import com.bule.free.ireader.model.bean.BookDetailPageBean;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.ui.base.BaseContract;

import java.util.List;

/**
 * Created by newbiechen on 17-5-4.
 */

public interface BookDetailContract {
    interface View extends BaseContract.BaseView {
        //
        void errorToBookShelf();

        void succeedAddToBookShelf();

        void succeedDelToBookShelf();

        void finishCheckBookShelf(boolean result);


        void  finishRandBooks(List<BookDetailBean> beans);

        void finishBookInfo(BookDetailPageBean bean);

        void errorBookInfo();
    }

    interface Presenter extends BaseContract.BasePresenter<View> {
        void addToBookShelf(BookDetailBean collBook);

        void delToBookShelf(BookDetailBean collBook);

        void checkBookShelf(BookDetailBean collBook);

        void loadBookInfo(String bookId,String hotSearch);
    }
}
