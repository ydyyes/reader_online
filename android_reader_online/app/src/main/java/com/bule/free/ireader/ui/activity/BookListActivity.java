package com.bule.free.ireader.ui.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.adv.AdvController;
import com.bule.free.ireader.common.adv.baiduad.BaiduPageBottomBannerAdDel;
import com.bule.free.ireader.common.adv.gdt.GdtBannerAdvDel;
import com.bule.free.ireader.common.adv.ttad.del.TTAdBannerDel2;
import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.model.CateMode;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.presenter.BookListPresenter;
import com.bule.free.ireader.presenter.contract.BookListContract;
import com.bule.free.ireader.ui.adapter.BookListAdapter;
import com.bule.free.ireader.ui.base.BaseMVPActivity;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.Res;
import com.bule.free.ireader.common.widget.ToolBarView;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;
import com.bule.free.ireader.common.widget.refresh.ScrollRefreshRecyclerView;

import java.util.List;

import butterknife.BindView;

/**
 * Created by liumin on 2018/12/27.
 */

public class BookListActivity extends BaseMVPActivity<BookListContract.Presenter> implements BookListContract.View {
    @BindView(R.id.toolbar_view)
    ToolBarView toolbarView;

    @BindView(R.id.book_list_rv_content)
    ScrollRefreshRecyclerView mRvContent;

    private BookListAdapter mBookListAdapter;

    private CateMode mode;

    //private int mStart = 0;
    private int mPage = 1;
    private int mLimit = 8;

    private static final String CATEMODE = "catemode";

    @Nullable
    private TTAdBannerDel2 mTtAdBannerDel2;
    @Nullable
    private BaiduPageBottomBannerAdDel mBaiduPageBottomBannerAdDel;
    @Nullable
    private GdtBannerAdvDel mGdtBannerAdvDel;

    public static void start(Context context, CateMode mode) {
        Intent intent = new Intent(context, BookListActivity.class);
        Bundle bundle = new Bundle();
        bundle.putParcelable(CATEMODE, mode);
        intent.putExtras(bundle);
        context.startActivity(intent);

    }

    @Override
    protected int getContentId() {
        return R.layout.activity_booklist;
    }

    @Override
    protected void initData(Bundle savedInstanceState) {
        super.initData(savedInstanceState);
        mode = getIntent().getParcelableExtra(CATEMODE);

    }

    @Override
    protected void initClick() {
        super.initClick();

        mRvContent.setOnRefreshListener(() -> {
            mPage = 1;
            mPresenter.refreshBookList(mode, mPage, mLimit);
        });
    }

    @Override
    protected void initWidget() {
        super.initWidget();
        setUpAdapter();
    }

    public void setUpAdapter() {

        HeaderItem headerItem = new HeaderItem();
        mBookListAdapter = new BookListAdapter(this, new WholeAdapter.Options());
        mBookListAdapter.addHeaderView(headerItem);
        mBookListAdapter.setOnLoadMoreListener(() -> {
            LogUtils.e("setUpAdapter");
            mPage++;
            mPresenter.updateBookList(mode, mPage, mLimit);
        });

        mBookListAdapter.setOnItemClickListener((view, pos) -> {

            BookMallItemBean bookMallItemBean = mBookListAdapter.getItem(pos);
            BookDetailBean bookDetailBean = BookDetailBean.instanceOf(bookMallItemBean);

            BookDetailActivity.start(BookListActivity.this, bookDetailBean.getId(), false);
        });

        mRvContent.setLayoutManager(new LinearLayoutManager(this));
        mRvContent.setAdapter(mBookListAdapter);
    }

    @Override
    protected void processLogic() {
        super.processLogic();


        if (mode == null) {
            mode = CateMode.FINISHED;
        }

        switch (mode) {
            case FINISHED:
                toolbarView.setTitle(Res.INSTANCE.string(R.string.list_finished_book));
                break;
            case HOT:
                toolbarView.setTitle(Res.INSTANCE.string(R.string.list_hot));
                break;
            case NEW:
                toolbarView.setTitle(Res.INSTANCE.string(R.string.list_new_book));
                break;
            case HOT_SEARCH:
                toolbarView.setTitle("热门搜索");
                break;
            case HOT_UPDATE:
                toolbarView.setTitle("热门更新");
                break;
            case HIGH_QUALITY:
                toolbarView.setTitle(Res.INSTANCE.string(R.string.list_high_comment));
                break;
            case EDITOR_REC:
                toolbarView.setTitle("编辑推荐");
                break;
            case LADY:
                toolbarView.setTitle("女频榜");
                break;
            case GENTLEMAN:
                toolbarView.setTitle("男频榜");
                break;
        }
        mRvContent.startRefresh();
        mPresenter.refreshBookList(mode, mPage, mLimit);
    }

    @Override
    public void showError() {
        if (mRvContent.isRefreshing()) {
            mRvContent.finishRefresh();
        }
    }

    @Override
    public void complete() {
        if (mRvContent.isRefreshing()) {
            mRvContent.finishRefresh();
        }
    }

    @Override
    public void finishRefreshList(List<BookMallItemBean> bookDetailBeans) {
        if (bookDetailBeans == null || bookDetailBeans.size() == 0) {

            if (mBookListAdapter != null) {
                mBookListAdapter.hideLoad();
            }

            return;
        }

        //mStart = bookDetailBeans.size();
        mBookListAdapter.refreshItems(bookDetailBeans);

        if (mBookListAdapter.getItemCount() < mLimit) {
            if (mBookListAdapter != null) {
                mBookListAdapter.hideLoad();
            }
        }
    }

    @Override
    public void finishLoad(List<BookMallItemBean> bookDetailBeans) {
        LogUtils.e(bookDetailBeans.toString());
        if (bookDetailBeans == null || bookDetailBeans.size() == 0) {
            if (mBookListAdapter != null) {
                mBookListAdapter.hideLoad();
            }
            return;
        }

        if (mBookListAdapter != null) {
            mBookListAdapter.addItems(bookDetailBeans);
        }
    }

    @Override
    protected BookListContract.Presenter bindPresenter() {
        return new BookListPresenter();
    }

    class HeaderItem implements WholeAdapter.ItemView {

        @Override
        public View onCreateView(ViewGroup parent) {
            return getLayoutInflater().inflate(R.layout.header_banner_adv, parent, false);
        }

        @Override
        public void onBindView(View view) {
            if (view instanceof FrameLayout) {
                FrameLayout frameLayout = (FrameLayout) view;
                switch (AdvController.INSTANCE.getReadPageBottomAdType()) {
                    case GDT:
                        mGdtBannerAdvDel = new GdtBannerAdvDel(BookListActivity.this, frameLayout, () -> {

                        }, isSuccess -> {

                        });
                        mGdtBannerAdvDel.show();
                        break;
                    case BDAD:
                        mBaiduPageBottomBannerAdDel = new BaiduPageBottomBannerAdDel(BookListActivity.this, frameLayout, isSuccess -> {

                        });
                        mBaiduPageBottomBannerAdDel.show();
                        break;
                    case TTAD:
                        mTtAdBannerDel2 = new TTAdBannerDel2(BookListActivity.this, frameLayout, () -> {

                        });
                        mTtAdBannerDel2.show();
                        break;
                    default:
                }
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mBaiduPageBottomBannerAdDel != null) {
            mBaiduPageBottomBannerAdDel.onDestroy();
        }
        if (mTtAdBannerDel2 != null) {
            mTtAdBannerDel2.release();
        }
        if (mGdtBannerAdvDel != null) {
            mGdtBannerAdvDel.doCloseBanner();
        }
    }
}
