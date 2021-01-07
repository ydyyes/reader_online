package com.bule.free.ireader.presenter;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.api.Api;
import com.bule.free.ireader.api.consumer.SimpleCallback;
import com.bule.free.ireader.model.User;
import com.bule.free.ireader.model.bean.BookCollItemBean;
import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.model.CateMode;
import com.bule.free.ireader.model.objectbox.bean.BookBean;
import com.bule.free.ireader.presenter.contract.BookListContract;
import com.bule.free.ireader.ui.base.RxPresenter;
import com.bule.free.ireader.common.utils.LogUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;


/**
 * Created by newbiechen on 17-5-4.
 */

public class BookListPresenter extends RxPresenter<BookListContract.View>
        implements BookListContract.Presenter {

    @Override
    public void refreshBookList(CateMode mode, int start, int limit) {
        LogUtils.e(String.format(Locale.ENGLISH, "start: %d", start));
        if (mode == CateMode.GENTLEMAN || mode == CateMode.LADY) {
            addDisposable(Api.INSTANCE.getBookListByGender(mode.apiParam, 1, limit)
                    .subscribe(new SimpleCallback<List<BookMallItemBean>>() {
                        @Override
                        public void onSuccess(List<BookMallItemBean> bookMallItemBeans) {
                            mView.finishRefreshList(bookMallItemBeans);
                            mView.complete();
                        }

                        @Override
                        public void onException(Throwable throwable) {
                            LogUtils.e(throwable.toString());
                            mView.showError();
                        }
                    }));
        } else if (mode == CateMode.EDITOR_REC) {
            addDisposable(Api.INSTANCE.getRecommendList(User.INSTANCE.getGender().getApiParam(), 1, limit)
                    .subscribe(new SimpleCallback<List<BookBean>>() {
                        @Override
                        public void onSuccess(List<BookBean> bookCollItemBeans) {
                            List<BookMallItemBean> beans = new ArrayList<>();
                            for (BookBean bookCollItemBean : bookCollItemBeans) {
                                beans.add(BookMallItemBean.Companion.instanceOf(bookCollItemBean));
                            }
                            mView.finishRefreshList(beans);
                            mView.complete();
                        }

                        @Override
                        public void onException(Throwable throwable) {
                            LogUtils.e(throwable.toString());
                            mView.showError();
                        }
                    }));
        } else if (mode == CateMode.HOT_SEARCH || mode == CateMode.HOT_UPDATE) {
            addDisposable(Api.INSTANCE.getMoreBookList(mode.apiParam, start, limit).subscribe(new SimpleCallback<List<BookMallItemBean>>() {
                @Override
                public void onSuccess(List<BookMallItemBean> bookMallItemBeans) {
                    mView.finishRefreshList(bookMallItemBeans);
                    mView.complete();
                }

                @Override
                public void onException(Throwable throwable) {
                    LogUtils.e(throwable.toString());
                    mView.showError();
                }
            }));
        } else {
            addDisposable(Api.INSTANCE.getBookMallItemList(-1, mode.apiParam, start, limit)
                    .subscribe(new SimpleCallback<List<BookMallItemBean>>() {
                        @Override
                        public void onSuccess(List<BookMallItemBean> bookMallItemBeans) {
                            mView.finishRefreshList(bookMallItemBeans);
                            mView.complete();
                        }

                        @Override
                        public void onException(Throwable throwable) {
                            LogUtils.e(throwable.toString());
                            mView.showError();
                        }
                    }));
        }
    }

    @Override
    public void updateBookList(CateMode mode, int start, int limit) {
        LogUtils.e(String.format(Locale.ENGLISH, "start: %d", start));
        if (mode == CateMode.GENTLEMAN || mode == CateMode.LADY) {
            addDisposable(Api.INSTANCE.getBookListByGender(mode.apiParam, start, limit)
                    .subscribe(new SimpleCallback<List<BookMallItemBean>>() {
                        @Override
                        public void onSuccess(List<BookMallItemBean> bookMallItemBeans) {
                            mView.finishLoad(bookMallItemBeans);
                        }

                        @Override
                        public void onException(Throwable throwable) {
                            LogUtils.e(throwable.toString());
                            mView.showError();
                        }
                    }));
        } else if (mode == CateMode.EDITOR_REC) {
            addDisposable(Api.INSTANCE.getRecommendList(User.INSTANCE.getGender().getApiParam(), start, limit)
                    .subscribe(new SimpleCallback<List<BookBean>>() {
                        @Override
                        public void onSuccess(List<BookBean> bookCollItemBeans) {
                            List<BookMallItemBean> beans = new ArrayList<>();
                            for (BookBean bookCollItemBean : bookCollItemBeans) {
                                beans.add(BookMallItemBean.Companion.instanceOf(bookCollItemBean));
                            }
                            mView.finishLoad(beans);
                            //mView.complete();
                        }

                        @Override
                        public void onException(Throwable throwable) {
                            LogUtils.e(throwable.toString());
                            mView.showError();
                        }
                    }));
        } else if (mode == CateMode.HOT_SEARCH || mode == CateMode.HOT_UPDATE) {
            addDisposable(Api.INSTANCE.getMoreBookList(mode.apiParam, start, limit).subscribe(new SimpleCallback<List<BookMallItemBean>>() {
                @Override
                public void onSuccess(List<BookMallItemBean> bookMallItemBeans) {
                    mView.finishLoad(bookMallItemBeans);
                    //mView.complete();
                }

                @Override
                public void onException(Throwable throwable) {
                    LogUtils.e(throwable.toString());
                    mView.showError();
                }
            }));
        } else {
            addDisposable(Api.INSTANCE.getBookMallItemList(-1, mode.apiParam, start, limit)
                    .subscribe(new SimpleCallback<List<BookMallItemBean>>() {
                        @Override
                        public void onSuccess(List<BookMallItemBean> bookMallItemBeans) {
                            mView.finishLoad(bookMallItemBeans);
                            //mView.complete();
                        }

                        @Override
                        public void onException(Throwable throwable) {
                            LogUtils.e(throwable.toString());
                            mView.showError();
                        }
                    }));
        }
    }
}
