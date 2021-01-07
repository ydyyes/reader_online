package com.bule.free.ireader.module.search;

import android.content.Context;
import android.content.Intent;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.presenter.SearchPresenter;
import com.bule.free.ireader.presenter.contract.SearchContract;
import com.bule.free.ireader.ui.activity.BookDetailActivity;
import com.bule.free.ireader.ui.adapter.HotKeyAdapter;
import com.bule.free.ireader.ui.adapter.SearchBookAdapter;
import com.bule.free.ireader.ui.base.BaseMVPActivity;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.widget.refresh.ScrollRefreshRecyclerView;
import com.umeng.analytics.MobclickAgent;
import com.zhy.view.flowlayout.FlowLayout;
import com.zhy.view.flowlayout.TagAdapter;
import com.zhy.view.flowlayout.TagFlowLayout;

import java.util.List;

import butterknife.BindView;

/**
 * Created by newbiechen on 17-4-24.
 */

public class SearchActivity extends BaseMVPActivity<SearchContract.Presenter>
        implements SearchContract.View {

    @BindView(R.id.search_iv_back)
    ImageView mIvBack;
    @BindView(R.id.search_et_input)
    EditText mEtInput;
    @BindView(R.id.search_iv_delete)
    ImageView mIvDelete;
    @BindView(R.id.search_iv_search)
    ImageView mIvSearch;
    @BindView(R.id.search_rv_hot)
    RecyclerView mRvHot;
    @BindView(R.id.refresh_rv_content)
    ScrollRefreshRecyclerView mRvSearch;
    @BindView(R.id.tv_temp1)
    TextView mTvTemp1;
    @BindView(R.id.btn_clear)
    TextView mBtnClear;
    @BindView(R.id.tfl_history)
    TagFlowLayout mTflHistory;
    @BindView(R.id.layout_search_history)
    ConstraintLayout mLayoutSearchHistory;
    @BindView(R.id.layout_inner)
    LinearLayout mLayoutInner;

    private SearchBookAdapter mSearchAdapter;
    private HotKeyAdapter mHotKeyAdapter;
    private final int mLimit = 9;
    private int mPage = 1;
    private String tempQueryKey = "";

    public static void start(Context context) {
        Intent intent = new Intent(context, SearchActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected int getContentId() {
        return R.layout.activity_search;
    }

    @Override
    protected SearchContract.Presenter bindPresenter() {
        return new SearchPresenter();
    }

    @Override
    protected void initWidget() {
        super.initWidget();
        setStatusBarColor(R.color.colorPrimary);
        setUpAdapter();
    }

    private void setUpAdapter() {
        mSearchAdapter = new SearchBookAdapter(this);

        mRvSearch.setLayoutManager(new LinearLayoutManager(this));

        mSearchAdapter.setOnLoadMoreListener(() -> {
            if (tempQueryKey.length() == 0) finishLoadBooks(null);
            mPage++;
            LogUtils.e("load more search" + mPage + " query: " + tempQueryKey);
            mPresenter.searchBookLoadMore(tempQueryKey, mPage, mLimit);
        });
        mSearchAdapter.hideLoad();

        mRvSearch.setAdapter(mSearchAdapter);

        mHotKeyAdapter = new HotKeyAdapter();
        mRvHot.setLayoutManager(new GridLayoutManager(this, 2));
        mRvHot.setAdapter(mHotKeyAdapter);
        refreshSearchHistory();
    }

    @Override
    protected void initClick() {
        super.initClick();

        //退出
        mIvBack.setOnClickListener(
                (v) -> onBackPressed()
        );
        mBtnClear.setOnClickListener(v -> {
            SearchHistory.INSTANCE.clear();
            refreshSearchHistory();
        });
        //输入框
        mEtInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.toString().trim().equals("")) {
                    //隐藏delete按钮和关键字显示内容
                    if (mIvDelete.getVisibility() == View.VISIBLE) {
                        mIvDelete.setVisibility(View.INVISIBLE);
                        hideSearchList();
                        mRvHot.setVisibility(View.VISIBLE);
                        //删除全部视图
                        mSearchAdapter.clear();
                        //mRvSearch.removeAllViews();
                    }
                    return;
                }
                //显示delete按钮
                if (mIvDelete.getVisibility() == View.INVISIBLE) {
                    mIvDelete.setVisibility(View.VISIBLE);
                    showSearchList();
                    mRvHot.setVisibility(View.GONE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        //键盘的搜索
        mEtInput.setOnKeyListener((v, keyCode, event) -> {
            //修改回车键功能
            if (keyCode == KeyEvent.KEYCODE_ENTER) {
                refreshSearchBook();
                return true;
            }
            return false;
        });

        //进行搜索
        mIvSearch.setOnClickListener(
                (v) -> refreshSearchBook()
        );

        //删除字
        mIvDelete.setOnClickListener(
                (v) -> {
                    mEtInput.setText("");
                    toggleKeyboard();
                }
        );

        mHotKeyAdapter.setOnItemClickListener((view, pos) -> {
            try{
                mEtInput.setText(mHotKeyAdapter.getItem(pos));
                refreshSearchBook();
            }catch (IndexOutOfBoundsException e){
                // do nothing
            }
        });

        //书本的点击事件
        mSearchAdapter.setOnItemClickListener(
                (view, pos) -> {
                    try{
                        BookDetailBean mBookDetailBean = mSearchAdapter.getItem(pos);
                        BookDetailActivity.start(this, mBookDetailBean.getId(), true);
                    }catch (IndexOutOfBoundsException e){
                        // do nothing
                    }
                }
        );
        mRvSearch.setOnRefreshListener(this::refreshSearchBook);
    }

    private void refreshSearchBook() {
        String query = mEtInput.getText().toString().trim();
        if (!query.equals("")) {
            MobclickAgent.onEvent(this, "book_search", query);
            tempQueryKey = query;
            showSearchList();
            mRvSearch.startRefresh();
            mPage = 1;
            mPresenter.searchBook(query, mPage, mLimit);
            toggleKeyboard();
        }
    }

    private String getCurrentQueryKey() {
        String query = mEtInput.getText().toString().trim();
        if (TextUtils.isEmpty(query)) {
            return "";
        } else {
            return query;
        }
    }

    private void toggleKeyboard() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
    }

    @Override
    protected void processLogic() {
        super.processLogic();
        //默认隐藏
        hideSearchList();
        //获取热词
        mPresenter.searchHotWord();
        MobclickAgent.onEvent(this, "search_activity", "search");
    }

    @Override
    public void showError() {
    }

    @Override
    public void complete() {
        mRvSearch.finishRefresh();
    }

    @Override
    public void finishHotWords(List<String> hotWords) {
        if (hotWords != null) {
            if (hotWords.size() % 2 != 0) {
                hotWords.add("");
            }
            List<String> finalHotList = hotWords.size() > 10 ? hotWords.subList(0, 10) : hotWords;
            mHotKeyAdapter.refreshItems(finalHotList);
        }

    }

    @Override
    public void finishBooks(List<BookDetailBean> books) {
        LogUtils.d("finishBooks");

        if (books == null || books.size() == 0) {

            if (mSearchAdapter != null) {
                mSearchAdapter.hideLoad();
            }

            mSearchAdapter.refreshItems(books);

            return;
        }

        mPage = 1;
        showSearchList();
        mSearchAdapter.refreshItems(books);
        mRvSearch.finishRefresh();

        SearchHistory.INSTANCE.addHistory(getCurrentQueryKey());
        refreshSearchHistory();
    }

    @Override
    public void finishLoadBooks(List<BookDetailBean> books) {
        if (books == null || books.isEmpty()) {
            if (mSearchAdapter != null) {
                mSearchAdapter.hideLoad();
            }
            return;
        }

        if (mSearchAdapter != null) {
            mSearchAdapter.addItems(books);
        }
    }

    @Override
    public void errorBooks() {

    }

    private void showSearchList() {
        mRvSearch.setVisibility(View.VISIBLE);
        mLayoutInner.setVisibility(View.GONE);
    }

    private void hideSearchList() {
        mRvSearch.setVisibility(View.GONE);
        mLayoutInner.setVisibility(View.VISIBLE);
    }

    private void refreshSearchHistory() {
        List<String> historyList = SearchHistory.INSTANCE.getHistory();
        if (historyList.isEmpty()) {
            mLayoutSearchHistory.setVisibility(View.GONE);
        } else {
            mLayoutSearchHistory.setVisibility(View.VISIBLE);
            mTflHistory.setAdapter(new TagAdapter<String>(historyList) {
                @Override
                public View getView(FlowLayout parent, int position, String keyword) {
                    View tagView = LayoutInflater.from(SearchActivity.this).inflate(R.layout.item_search_history, null);
                    TextView tvTag = tagView.findViewById(R.id.tv_history_element);
                    tvTag.setText(keyword);
                    tvTag.setOnClickListener(v -> {
                        mEtInput.setText(keyword);
                        refreshSearchBook();
                    });
                    return tagView;
                }
            });
        }
    }

    @Override
    public void onBackPressed() {
        if (mRvSearch.getVisibility() == View.VISIBLE) {
            mEtInput.setText("");
        } else {
            super.onBackPressed();
        }
    }
}
