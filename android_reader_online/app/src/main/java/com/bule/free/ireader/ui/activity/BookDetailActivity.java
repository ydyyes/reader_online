package com.bule.free.ireader.ui.activity;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.adv.AdvController;
import com.bule.free.ireader.common.adv.baiduad.BaiduPageBottomBannerAdDel;
import com.bule.free.ireader.common.adv.gdt.GdtBannerAdvDel;
import com.bule.free.ireader.common.adv.ttad.del.TTAdBannerDel2;
import com.bule.free.ireader.model.AddBookToShelfEvent;
import com.bule.free.ireader.model.RefreshBookShelfEvent;
import com.bule.free.ireader.model.bean.BookDetailBean;
import com.bule.free.ireader.model.bean.BookDetailPageBean;
import com.bule.free.ireader.model.local.BookRepository;
import com.bule.free.ireader.model.objectbox.OBKt;
import com.bule.free.ireader.model.objectbox.bean.BookHistoryBean;
import com.bule.free.ireader.model.objectbox.bean.BookHistoryBean_;
import com.bule.free.ireader.newbook.ui.NewReadBookActivity;
import com.bule.free.ireader.presenter.BookDetailPresenter;
import com.bule.free.ireader.presenter.contract.BookDetailContract;
import com.bule.free.ireader.ui.adapter.BookRandAdapter;
import com.bule.free.ireader.ui.base.BaseMVPActivity;
import com.bule.free.ireader.common.utils.RxBus;
import com.bule.free.ireader.common.utils.RxUtils;
import com.bule.free.ireader.common.utils.ToastUtils;
import com.bule.free.ireader.common.library.glide.GlideExtKt;
import com.bule.free.ireader.common.widget.BookCoverPop;
import com.bule.free.ireader.common.widget.EasyRatingBar;
import com.bule.free.ireader.common.widget.TagsTextView;
import com.bule.free.ireader.common.widget.itemdecoration.DividerItemDecoration;
import com.umeng.analytics.MobclickAgent;

import java.util.Arrays;
import java.util.List;

import butterknife.BindView;
import butterknife.OnClick;
import io.reactivex.disposables.Disposable;
import kotlin.Unit;

/**
 * Created by newbiechen on 17-5-4.
 * <p>
 * 书籍详情页
 */

public class BookDetailActivity extends BaseMVPActivity<BookDetailContract.Presenter>
        implements BookDetailContract.View {

    private static final String EXTRA_BOOK_ID = "extra_book_id";
    private static final String EXTRA_IS_START_BY_SEARCH = "EXTRA_IS_START_BY_SEARCH";
    private static final String EXTRA_BOOK_BEAN = "extra_book_bean";

    @BindView(R.id.book_detail_iv_cover)
    ImageView mIvCover;
    @BindView(R.id.book_detail_tv_title)
    TextView mTvTitle;
    @BindView(R.id.book_detail_tv_author)
    TextView mTvAuthor;
    @BindView(R.id.book_detail_tv_type)
    TextView mTvType;
    @BindView(R.id.book_detail_tv_word_count)
    TextView mTvWordCount;
    //    @BindView(R.id.book_detail_tv_lately_update)
//    TextView mTvLatelyUpdate;
    @BindView(R.id.book_list_tv_chase)
    TextView mTvChase;
    @BindView(R.id.book_detail_tv_read)
    TextView mTvRead;
    @BindView(R.id.book_detail_tv_follower_count)
    TextView mTvFollowerCount;
    @BindView(R.id.book_detail_tv_retention)
    TextView mTvRetention;
    @BindView(R.id.book_detail_tv_day_word_count)
    TextView mTvDayWordCount;
    @BindView(R.id.book_detail_tv_brief)
    TextView mTvBrief;
    @BindView(R.id.book_list_tv_recommend_book_list)
    TextView mTvRecommendBookList;
    @BindView(R.id.book_detail_rv_recommend_book_list)
    RecyclerView mRvRecommendBookList;

    @BindView(R.id.hot_comment_erb_rate)
    EasyRatingBar hot_comment_erb_rate;

    @BindView(R.id.toolbar_title)
    TextView toolbar_title;
    @BindView(R.id.fl_adv_container)
    FrameLayout mFlAdvContainer;

//    @BindView(R.id.iv_book_status)
//    ImageView iv_book_status;

    /************************************/
    private BookRandAdapter mBookListAdapter;
    private ProgressDialog mProgressDialog;
    /*******************************************/
    private boolean isBriefOpen = false;
    private boolean isCollected = false;

    private BookDetailBean mBookDetailBean;

    private String bookId;

    @BindView(R.id.book_detail_layout_tag)
    LinearLayout layoutTags;


    @BindView(R.id.fl_top_book_content)
    FrameLayout fl_top_book_content;

    private BookCoverPop bookCoverPop;
    private boolean isStartBySearch = false;
    @Nullable
    private TTAdBannerDel2 mTtAdBannerDel2;
    @Nullable
    private BaiduPageBottomBannerAdDel mBaiduPageBottomBannerAdDel;
    @Nullable
    private GdtBannerAdvDel mGdtBannerAdvDel;

    public static void start(Context context, String bookid, boolean isStartBySearch) {
        Intent intent = new Intent(context, BookDetailActivity.class);
        if (TextUtils.isEmpty(bookid)) {
            ToastUtils.show("无效的书籍id");
            return;
        }
        intent.putExtra(EXTRA_BOOK_ID, bookid);
        intent.putExtra(EXTRA_IS_START_BY_SEARCH, isStartBySearch);
        context.startActivity(intent);
    }

    @Override
    protected int getContentId() {
        return R.layout.activity_book_detail;
    }

    @Override
    protected BookDetailContract.Presenter bindPresenter() {
        return new BookDetailPresenter();
    }

    @Override
    protected void initData(Bundle savedInstanceState) {
        super.initData(savedInstanceState);

//        mBookDetailBean = (BookDetailBean) getIntent().getSerializableExtra(EXTRA_BOOK_BEAN);

        bookId = getIntent().getStringExtra(EXTRA_BOOK_ID);
        isStartBySearch = getIntent().getBooleanExtra(EXTRA_IS_START_BY_SEARCH, false);
    }

    @Override
    protected void setUpToolbar(Toolbar toolbar) {
        super.setUpToolbar(toolbar);
        toolbar_title.setText("书籍详情");
    }

    @Override
    protected void initClick() {
        super.initClick();

        //可伸缩的TextView
        mTvBrief.setOnClickListener(
                (view) -> {
                    if (isBriefOpen) {
                        mTvBrief.setMaxLines(4);
                        isBriefOpen = false;
                    } else {
                        mTvBrief.setMaxLines(8);
                        isBriefOpen = true;
                    }
                }
        );

        bookCoverPop = new BookCoverPop(this);

        mIvCover.setOnClickListener(v -> {
//                if (mBookDetailBean != null) {
//                    bookCoverPop.loadImg(mIvCover.getDrawable());
//                    bookCoverPop.showAtLocation(fl_top_book_content, Gravity.TOP, 0, 0);
//                }
            startRead();
        });

        RxBus.INSTANCE.toObservable(this, AddBookToShelfEvent.class, addBookShelfEvent -> {
            Disposable disposable = BookRepository.INSTANCE.checkCollBook(mBookDetailBean.getId())
                    .compose(RxUtils::toSimpleSingle)
                    .subscribe(optional -> {
                        if (optional.isPresent()) {
                            mTvChase.setText(getResources().getString(R.string.book_detail_give_up));
                            isCollected = true;
                        } else {
                            mTvChase.setText(getResources().getString(R.string.book_detail_chase_update));
                            isCollected = false;
                        }
                    }, throwable -> {
                    });
            addDisposable(disposable);
            return Unit.INSTANCE;
        });
    }


    @Override
    protected void processLogic() {
        super.processLogic();
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog(this);
            mProgressDialog.setTitle("数据加载中");
            mProgressDialog.setCancelable(false);
        }
        mProgressDialog.show();

        if (mBookDetailBean != null) {

            setViewData();

            mPresenter.checkBookShelf(mBookDetailBean);

        } else {

            if (TextUtils.isEmpty(bookId)) {
                ToastUtils.show("书本id获取错误");
                finish();
            }

            mPresenter.loadBookInfo(bookId, isStartBySearch ? "1" : "");
        }
    }


    private void setViewData() {
//        GlideApp.with(this)
//                .setDefaultRequestOptions(G.INSTANCE.getSDefaultOptions())
//                .asBitmap()
//                .load(mBookDetailBean.getCover())
//                .placeholder(R.drawable.common_bg_book_placeholder)
//                .transforms(new BlurTransformation(this, 300, 5),
//                        new CropTransformation(this, ScreenUtils.getScreenWidthSize(), (int) (ScreenUtils.getScreenWidthSize() / 1.32), CropTransformation.CropType.TOP))
//                .into(new SimpleTarget<Bitmap>() {
//                    @Override
//                    public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
//                        fl_top_book_content.setBackground(new BitmapDrawable(resource));
//                    }
//                });
        GlideExtKt.load(mIvCover, mBookDetailBean.getCover());

        //书名
        mTvTitle.setText(mBookDetailBean.getTitle());
        //作者
        mTvAuthor.setText(mBookDetailBean.getAuthor());
        //类型
        if (!TextUtils.isEmpty(mBookDetailBean.getMajorCate())) {
            mTvType.setText(mBookDetailBean.getMajorCate() + " | ");
        }

        //总字数
        mTvWordCount.setText(getResources().getString(R.string.book_word, mBookDetailBean.getWordCount() / 10000));

        //更新时间
//        mTvLatelyUpdate.setText(StringUtils.dateConvert(bean.getUpdated(), Constant.FORMAT_BOOK_DATE));

        //追书人数
        mTvFollowerCount.setText(mBookDetailBean.getLatelyFollower() + "");

        //存留率
        mTvRetention.setText(mBookDetailBean.getRetentionRatio() + "%");

        //日更字数
        if (Integer.parseInt(mBookDetailBean.getSerializeWordCount()) < 0) {
            mTvDayWordCount.setText(0 + "");
        } else {
            mTvDayWordCount.setText(mBookDetailBean.getSerializeWordCount());
        }

        //简介
        mTvBrief.setText(mBookDetailBean.getLongIntro());


        String score = mBookDetailBean.getScore();

        int icore = 3;

        try {
            icore = (int) Double.parseDouble(score) / 2;
        } catch (Exception e) {
        }


        hot_comment_erb_rate.setRateCount(5);
        if (icore < 2) icore = 2;
        hot_comment_erb_rate.setRating(icore);

//        if (mBookDetailBean.getOver() == 0) {
//            iv_book_status.setVisibility(View.VISIBLE);
//            iv_book_status.setImageResource(R.drawable.ic_book_status_conti);
//        } else if (mBookDetailBean.getOver() == 1) {
//            iv_book_status.setVisibility(View.VISIBLE);
//            iv_book_status.setImageResource(R.drawable.ic_book_status_over);
//        } else {
//            iv_book_status.setVisibility(View.GONE);
//        }


        List<String> bookTags = Arrays.asList(mBookDetailBean.getTags().split(","));
        if (!bookTags.isEmpty() && !bookTags.contains("")) {
            layoutTags.setVisibility(View.VISIBLE);
            int i = 0;
            for (String tag : bookTags) {
                i++;
                if (i <= 3) {
                    TagsTextView tagsTextView = new TagsTextView(this);
                    tagsTextView.setText(tag);

                    int color = Color.parseColor("#e33f40");
                    if (i % 2 == 0) {
                        color = Color.parseColor("#2998bc");
                    }
                    tagsTextView.setBackgroundShapeColor(color);
                    tagsTextView.setTextColor(color);

                    layoutTags.addView(tagsTextView);
                }

            }
        } else {
            layoutTags.removeAllViews();
            layoutTags.setVisibility(View.GONE);
        }

    }

    @OnClick(R.id.book_detail_tv_read)
    public void onClickBookRead() {
        startRead();
    }

    private void startRead() {
        if (mBookDetailBean != null) {
            BookHistoryBean bookHistoryBean = OBKt.boxOf(BookHistoryBean.class).query().equal(BookHistoryBean_.bookId, mBookDetailBean.getId()).build().findUnique();
            if (bookHistoryBean == null) {
                bookHistoryBean = new BookHistoryBean(mBookDetailBean.getId(), mBookDetailBean.getCover(), mBookDetailBean.getAuthor(),
                        mBookDetailBean.getMajorCate(), mBookDetailBean.getLongIntro(), System.currentTimeMillis(), mBookDetailBean.getTitle());
            } else {
                bookHistoryBean.setAddTime(System.currentTimeMillis());
            }
            NewReadBookActivity.startActivityAndLog(this, bookHistoryBean);
            finish();
        }
    }

    @OnClick(R.id.book_list_tv_chase)
    public void onClickAddBookShelf() {

        if (isCollected) {
            //放弃点击
            mPresenter.delToBookShelf(mBookDetailBean);

        } else {

            if (mProgressDialog == null) {
                mProgressDialog = new ProgressDialog(this);
                mProgressDialog.setTitle("正在添加到书架中");
                mProgressDialog.show();
            }

            mPresenter.addToBookShelf(mBookDetailBean);

        }
    }


    @Override
    public void errorToBookShelf() {
        if (mProgressDialog != null) {
            mProgressDialog.dismiss();
        }
        ToastUtils.show("加入书架失败，请重试");
    }

    @Override
    public void succeedAddToBookShelf() {
        if (mProgressDialog != null) {
            mProgressDialog.dismiss();
        }

        mTvChase.setText(getResources().getString(R.string.book_detail_give_up));

        isCollected = true;

        RxBus.INSTANCE.post(RefreshBookShelfEvent.INSTANCE);

        ToastUtils.show("加入书架成功");
    }

    @Override
    public void succeedDelToBookShelf() {
        mTvChase.setText(getResources().getString(R.string.book_detail_chase_update));

        isCollected = false;

        RxBus.INSTANCE.post(RefreshBookShelfEvent.INSTANCE);

        ToastUtils.show("从书架移除成功");
    }

    @Override
    public void finishCheckBookShelf(boolean result) {
        if (result) {
            isCollected = true;
            mTvChase.setText(getResources().getString(R.string.book_detail_give_up));
            mTvRead.setText("继续阅读");
        }
    }

    @Override
    public void showError() {
        if (mProgressDialog != null) {
            mProgressDialog.dismiss();
        }

//        ToastUtils.load("数据加载失败，请重试");
//        finish();
    }

    @Override
    public void complete() {
        if (mProgressDialog != null) {
            mProgressDialog.dismiss();
        }
    }


    @Override
    public void finishRandBooks(List<BookDetailBean> beans) {
        if (beans == null || beans.isEmpty()) {
            mTvRecommendBookList.setVisibility(View.GONE);
            return;
        }
        //推荐书单列表
        mBookListAdapter = new BookRandAdapter();
        mRvRecommendBookList.setLayoutManager(new LinearLayoutManager(this) {
            @Override
            public boolean canScrollVertically() {
                //与外部ScrollView滑动冲突
                return false;
            }
        });
        mRvRecommendBookList.addItemDecoration(new DividerItemDecoration(this));
        mRvRecommendBookList.setAdapter(mBookListAdapter);
        mBookListAdapter.refreshItems(beans);
        mBookListAdapter.setOnItemClickListener((view, pos) -> {
            BookDetailBean mBookDetailBean = mBookListAdapter.getItem(pos);
            MobclickAgent.onEvent(BookDetailActivity.this, "book_detail_click_recommend", mBookDetailBean.getId());
            start(BookDetailActivity.this, mBookDetailBean.getId(), false);
            finish();
        });

    }

    @Override
    public void finishBookInfo(BookDetailPageBean bean) {

        if (bean != null) {

            mBookDetailBean = bean.getDetail();

            setViewData();

            mPresenter.checkBookShelf(mBookDetailBean);

            switch (AdvController.INSTANCE.getReadPageBottomAdType()) {
                case GDT:
                    mGdtBannerAdvDel = new GdtBannerAdvDel(this, mFlAdvContainer, () -> {

                    }, isSuccess -> {

                    });
                    mGdtBannerAdvDel.show();
                    break;
                case BDAD:
                    mBaiduPageBottomBannerAdDel = new BaiduPageBottomBannerAdDel(this, mFlAdvContainer, isSuccess -> {

                    });
                    mBaiduPageBottomBannerAdDel.show();
                    break;
                case TTAD:
                    mTtAdBannerDel2 = new TTAdBannerDel2(this, mFlAdvContainer, () -> {

                    });
                    mTtAdBannerDel2.show();
                    break;
                default:
            }
        } else {
            ToastUtils.show("书本详情获取失败");
            finish();
        }


    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mProgressDialog != null && mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
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

    @Override
    public void errorBookInfo() {
//        ToastUtils.load("书本详情获取失败");
        finish();
    }
}
