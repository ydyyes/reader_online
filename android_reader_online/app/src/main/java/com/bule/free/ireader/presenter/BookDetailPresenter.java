package com.bule.free.ireader.presenter;

import com.bule.free.ireader.api.Api;
import com.bule.free.ireader.api.consumer.SimpleCallback;
import com.bule.free.ireader.model.bean.BookCollItemBean;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.model.bean.BookDetailPageBean;
import com.bule.free.ireader.model.local.BookRepository;
import com.bule.free.ireader.model.objectbox.bean.BookBean;
import com.bule.free.ireader.presenter.contract.BookDetailContract;
import com.bule.free.ireader.ui.base.RxPresenter;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.RxUtils;
import com.bule.free.ireader.common.utils.ToastUtils;

import io.reactivex.disposables.Disposable;

/**
 * Created by newbiechen on 17-5-4.
 */

public class BookDetailPresenter extends RxPresenter<BookDetailContract.View>
        implements BookDetailContract.Presenter {

    @Override
    public void addToBookShelf(BookDetailBean mBookDetailBean) {
        BookBean bookBean = new BookBean();
        bookBean.setId(mBookDetailBean.getId());
//        BookCollItemBean collItemBean = new BookCollItemBean();
        bookBean.setId(mBookDetailBean.getId());
        bookBean.setAuthor(mBookDetailBean.getAuthor());
        bookBean.setCover(mBookDetailBean.getCover());
        bookBean.setGender(mBookDetailBean.getGender());
        bookBean.setIsfree(mBookDetailBean.getIsfree());
        bookBean.setLatelyFollower(mBookDetailBean.getLatelyFollower());
        bookBean.setLongIntro(mBookDetailBean.getLongIntro());
        bookBean.setMajorCate(mBookDetailBean.getMajorCate());
        bookBean.setOver(mBookDetailBean.getOver());
        bookBean.setScore(mBookDetailBean.getScore());
        bookBean.setSerializeWordCount(mBookDetailBean.getSerializeWordCount());
        bookBean.setUpdated(mBookDetailBean.getUpdated());
        bookBean.setTitle(mBookDetailBean.getTitle());
        bookBean.setWordCount(mBookDetailBean.getWordCount() + "");
        bookBean.setLastChapter(mBookDetailBean.getLastChapter());
        bookBean.setLastRead(String.valueOf(System.currentTimeMillis()));
        bookBean.setUpdated(String.valueOf(System.currentTimeMillis() / 1000));
        Disposable disposable = BookRepository.INSTANCE
                .addBookShelf(bookBean)
                .compose(RxUtils::toSimpleSingle)
                .subscribe((bean) -> mView.succeedAddToBookShelf()
                        , (e) -> {
                            LogUtils.e(e);
                            mView.errorToBookShelf();
                        }
                );
        addDisposable(disposable);
    }

//    private void addRemoteBookShelf(String bookid) {
//        Disposable disposable = RemoteRepository.getInstance()
//                .addShelf(bookid)
//                .compose(RxUtils::toSimpleSingle)
//                .subscribe(
//                        (bean) -> {
//                            LogUtils.d("addRemoteBookShelf :" + bean);
//                        }
//                        ,
//                        (e) -> {
//                            LogUtils.e(e);
//                        }
//                );
//
//        addDisposable(disposable);
//    }

    @Override
    public void delToBookShelf(BookDetailBean mBookDetailBean) {
        Disposable disposable = BookRepository.INSTANCE
                .delBookShelf(mBookDetailBean.getId())
                .compose(RxUtils::toSimpleSingle)
                .subscribe(
                        (bean) -> {
                            mView.succeedDelToBookShelf();
                            mView.complete();
                        }
                        ,
                        (e) -> {
                            LogUtils.e(e);
                            ToastUtils.show("删除失败，请重试");
                            mView.complete();
                        }
                );

        addDisposable(disposable);
    }


    @Override
    public void checkBookShelf(BookDetailBean mBookDetailBean) {

        Disposable disposable = BookRepository.INSTANCE
                .checkCollBook(mBookDetailBean.getId())
                .compose(RxUtils::toSimpleSingle)
                .subscribe(
                        (optional) -> {
                            if (optional.isPresent()) {
                                mView.finishCheckBookShelf(true);
                            } else {
                                mView.finishCheckBookShelf(false);
                            }
                        }, (e) -> {
                            LogUtils.e(e);
                            mView.finishCheckBookShelf(false);
                        }
                );

        addDisposable(disposable);
    }


    @Override
    public void loadBookInfo(String bookId, String hotSearch) {
        LogUtils.e("loadBookInfo");
        addDisposable(Api.INSTANCE.getBookDetail(bookId, hotSearch)
                .subscribe(new SimpleCallback<BookDetailPageBean>() {
                    @Override
                    public void onSuccess(BookDetailPageBean bookDetailPageBean) {
                        mView.finishBookInfo(bookDetailPageBean);
                        mView.finishRandBooks(bookDetailPageBean.getRecommend());
                        mView.complete();
                    }

                    @Override
                    public void onException(Throwable throwable) {
                        LogUtils.e(throwable.toString());
                        mView.errorBookInfo();
                    }
                }));
    }


}
