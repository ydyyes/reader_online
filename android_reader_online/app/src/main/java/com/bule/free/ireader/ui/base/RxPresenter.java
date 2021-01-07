package com.bule.free.ireader.ui.base;

import com.bule.free.ireader.ui.base.action.DisposableHandler;

import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;

/**
 * Created by newbiechen on 17-4-26.
 */

public class RxPresenter<T extends BaseContract.BaseView> implements BaseContract.BasePresenter<T>, DisposableHandler {

    protected T mView;
    protected CompositeDisposable mDisposable;

    protected void unSubscribe() {
        if (mDisposable != null) {
            mDisposable.dispose();
        }
    }

    @Override
    public void addDisposable(Disposable subscription) {
        if (mDisposable == null) {
            mDisposable = new CompositeDisposable();
        }
        mDisposable.add(subscription);
    }

    @Override
    public void attachView(T view) {
        this.mView = view;
    }

    @Override
    public void detachView() {
        this.mView = null;
        unSubscribe();
    }
}
