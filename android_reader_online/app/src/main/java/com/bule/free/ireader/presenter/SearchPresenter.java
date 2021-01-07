package com.bule.free.ireader.presenter;

import com.bule.free.ireader.api.Api;
import com.bule.free.ireader.api.consumer.SimpleCallback;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.presenter.contract.SearchContract;
import com.bule.free.ireader.ui.base.RxPresenter;
import com.bule.free.ireader.common.utils.LogUtils;

import java.util.List;


/**
 * Created by newbiechen on 17-6-2.
 */

public class SearchPresenter extends RxPresenter<SearchContract.View>
        implements SearchContract.Presenter {

    @Override
    public void searchHotWord() {
        addDisposable(Api.INSTANCE.getSearchHot()
                .subscribe(new SimpleCallback<List<String>>() {
                    @Override
                    public void onSuccess(List<String> strings) {
                        mView.finishHotWords(strings);
                    }

                    @Override
                    public void onException(Throwable throwable) {
                        LogUtils.e(throwable.toString());
                    }
                }));
    }


    @Override
    public void searchBook(String query, int page, int limit) {
        addDisposable(Api.INSTANCE.getSearchList(query, page, limit)
                .subscribe(new SimpleCallback<List<BookDetailBean>>() {
                    @Override
                    public void onSuccess(List<BookDetailBean> bookDetailBeans) {
                        mView.finishBooks(bookDetailBeans);
                        mView.complete();
                    }

                    @Override
                    public void onException(Throwable throwable) {
                        mView.errorBooks();
                        mView.finishBooks(null);
                        mView.complete();
                    }
                }));
//        LogUtils.d("searchBook : " + query);
//        Disposable disposable = RemoteRepository.getInstance()
//                .getBookList(0,50,0,query,0,0)
//                .compose(RxUtils::toSimpleSingle)
//                .subscribe(
//                        (bean) ->{
//                            mView.finishBooks(bean);
//                            mView.complete();
//                        }
//                        ,
//                        (e) -> {
//                            LogUtils.e(e);
//                            mView.errorBooks();
//                        }
//                );
//
//        addDisposable(disposable);
    }

    @Override
    public void searchBookLoadMore(String query, int page, int limit) {
        addDisposable(Api.INSTANCE.getSearchList(query, page, limit)
                .subscribe(new SimpleCallback<List<BookDetailBean>>() {
                    @Override
                    public void onSuccess(List<BookDetailBean> bookDetailBeans) {
                        mView.finishLoadBooks(bookDetailBeans);
                        mView.complete();
                    }

                    @Override
                    public void onException(Throwable throwable) {
                        mView.errorBooks();
                        mView.finishLoadBooks(null);
                        mView.complete();
                    }
                }));
    }
}
