package com.bule.free.ireader.main.fragment;

import android.os.Bundle;
import android.support.v7.widget.GridLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.utils.RxBus;
import com.bule.free.ireader.common.utils.ScreenUtils;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;
import com.bule.free.ireader.common.widget.refresh.ScrollRefreshRecyclerView;
import com.bule.free.ireader.model.CateMode;
import com.bule.free.ireader.model.OffShelfEvent;
import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.model.bean.CategoryBean;
import com.bule.free.ireader.presenter.BookMallRightPresenter;
import com.bule.free.ireader.presenter.contract.BookMallRightContract;
import com.bule.free.ireader.ui.activity.BookDetailActivity;
import com.bule.free.ireader.ui.activity.BookListActivity;
import com.bule.free.ireader.ui.adapter.BookMallRightAdapter;
import com.bule.free.ireader.ui.base.BaseMVPFragment;

import java.util.List;

import butterknife.BindView;
import kotlin.Unit;

@Deprecated
public class BookMallByRightFragment extends BaseMVPFragment<BookMallRightContract.Presenter> implements BookMallRightContract.View {
    @BindView(R.id.book_shelf_rv_content)
    ScrollRefreshRecyclerView mRvContent;

    private BookMallRightAdapter mCollBookAdapter;

    private CategoryBean mBookCateBean;

    private HeaderItemView mHeaderItem;

    //private int mStart = 0;
    private int mLimit = 9;
    private int mPage = 1;

    public void setBookCates(CategoryBean mBookCateBean) {
        this.mBookCateBean = mBookCateBean;
    }

    @Override
    public void finishRefreshRight(List<BookMallItemBean> beans) {

        if (beans == null || beans.size() == 0) {

            if (mCollBookAdapter != null) {
                mCollBookAdapter.hideLoad();
            }

            return;
        }

//        mStart = beans.size();

        mCollBookAdapter.refreshItems(beans);

        if (beans.size() < mLimit) {
            if (mCollBookAdapter != null) {
                mCollBookAdapter.hideLoad();
            }
        }
    }

    @Override
    public void finishLoad(List<BookMallItemBean> beans) {
        if (beans == null || beans.size() == 0) {

            if (mCollBookAdapter != null) {
                mCollBookAdapter.hideLoad();
            }

            return;
        }
        if (mCollBookAdapter != null && !mCollBookAdapter.getItems().containsAll(beans)) {
            mCollBookAdapter.addItems(beans);
        }

    }

    @Override
    public void showErrorTip(String error) {
        mRvContent.setTip(error);
        mRvContent.showTip();
    }

    @Override
    protected void initWidget(Bundle savedInstanceState) {
        super.initWidget(savedInstanceState);
        setUpAdapter();
    }

    @Override
    protected BookMallRightContract.Presenter bindPresenter() {
        return new BookMallRightPresenter();
    }

    @Override
    protected void initClick() {
        super.initClick();
        mRvContent.setOnRefreshListener(() -> {
            mPage = 1;
            mPresenter.refreshRightBooksList(mBookCateBean, mPage, mLimit);
        });
    }

    @Override
    protected void processLogic() {
        super.processLogic();

        mPage = 1;
        mPresenter.refreshRightBooksList(mBookCateBean, mPage, mLimit);
        RxBus.INSTANCE.toObservable(this, OffShelfEvent.class, offShelfEvent -> {
            mRvContent.startRefresh();
            mPage = 1;
            mPresenter.refreshRightBooksList(mBookCateBean, mPage, mLimit);
            return Unit.INSTANCE;
        });
    }

    private void setUpAdapter() {
        //添加Footer
        mCollBookAdapter = new BookMallRightAdapter(getContext(), new WholeAdapter.Options());
        GridLayoutManager manager = new GridLayoutManager(getContext(), 3);
        manager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                if (position == 0) return 3;
                else return 1;
            }
        });

        mRvContent.setLayoutManager(manager);
        mRvContent.setAdapter(mCollBookAdapter);

        mCollBookAdapter.setOnLoadMoreListener(() -> {
            mPage++;
            mPresenter.updateRightBooks(mBookCateBean, mPage, mLimit);
        });

        mCollBookAdapter.setOnItemClickListener((view, pos) -> {

            BookMallItemBean item = mCollBookAdapter.getItem(pos);
            BookDetailActivity.start(getActivity(), item.getId(),false);
        });

        if (mHeaderItem == null) {
            mHeaderItem = new HeaderItemView();
            mCollBookAdapter.addHeaderView(mHeaderItem);
        }

    }

    @Override
    public void showError() {
        if (mCollBookAdapter != null) {
            mCollBookAdapter.showLoadError();
        }
    }

    @Override
    public void complete() {
        if (mRvContent.isRefreshing()) {
            mRvContent.finishRefresh();
        }
    }

    @Override
    protected int getContentId() {
        return R.layout.fragment_bookmall_right;
    }

    class HeaderItemView implements WholeAdapter.ItemView, View.OnClickListener {

        @Override
        public View onCreateView(ViewGroup parent) {

            View view = LayoutInflater.from(getContext())
                    .inflate(R.layout.header_book_market, parent, false);

            Button btnRecom = view.findViewById(R.id.btn_header_bookmark_finished);
            Button btnPay = view.findViewById(R.id.btn_header_bookmark_new);
            Button btnHot = view.findViewById(R.id.btn_header_bookmark_hot);
            Button btnFav = view.findViewById(R.id.btn_header_bookmark_high_comment);

            int width = (int) (ScreenUtils.getScreenWidthSize() * 0.75 / 2 - ScreenUtils.dpToPx(18));
            int height = (int) (width * 0.36);

            LinearLayout.LayoutParams lparamsRecom = (LinearLayout.LayoutParams) btnRecom.getLayoutParams();
            lparamsRecom.width = width;
            lparamsRecom.height = height;
            lparamsRecom.leftMargin = ScreenUtils.dpToPx(6);
            btnRecom.setLayoutParams(lparamsRecom);

            LinearLayout.LayoutParams lparamsPay = (LinearLayout.LayoutParams) btnPay.getLayoutParams();
            lparamsPay.width = width;
            lparamsPay.height = height;
            lparamsPay.leftMargin = ScreenUtils.dpToPx(6);
            btnPay.setLayoutParams(lparamsPay);

            LinearLayout.LayoutParams lparamsHot = (LinearLayout.LayoutParams) btnHot.getLayoutParams();
            lparamsHot.width = width;
            lparamsHot.height = height;
            lparamsHot.rightMargin = ScreenUtils.dpToPx(6);
            btnHot.setLayoutParams(lparamsHot);

            LinearLayout.LayoutParams lparamsFav = (LinearLayout.LayoutParams) btnFav.getLayoutParams();
            lparamsFav.width = width;
            lparamsFav.height = height;
            lparamsFav.rightMargin = ScreenUtils.dpToPx(6);
            btnFav.setLayoutParams(lparamsFav);

            btnRecom.setOnClickListener(this);
            btnPay.setOnClickListener(this);
            btnHot.setOnClickListener(this);
            btnFav.setOnClickListener(this);

            return view;
        }

        @Override
        public void onBindView(View view) {
        }

        @Override
        public void onClick(View v) {
            switch (v.getId()) {
                case R.id.btn_header_bookmark_finished:
                    BookListActivity.start(getContext(), CateMode.FINISHED);
                    break;
                case R.id.btn_header_bookmark_hot:
                    BookListActivity.start(getContext(), CateMode.HOT);
                    break;
                case R.id.btn_header_bookmark_new:
                    BookListActivity.start(getContext(), CateMode.NEW);
                    break;
                case R.id.btn_header_bookmark_high_comment:
                    BookListActivity.start(getContext(), CateMode.HIGH_QUALITY);
                    break;
            }
        }
    }

}
