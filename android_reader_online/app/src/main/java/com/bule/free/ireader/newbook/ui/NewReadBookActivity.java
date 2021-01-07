package com.bule.free.ireader.newbook.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextPaint;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bule.free.ireader.Const;
import com.bule.free.ireader.R;
import com.bule.free.ireader.api.Api;
import com.bule.free.ireader.api.consumer.ErrorConsumer;
import com.bule.free.ireader.api.consumer.SimpleCallback;
import com.bule.free.ireader.api.exception.ApiException;
import com.bule.free.ireader.common.download.BookDownloader;
import com.bule.free.ireader.common.download.OnDownloadListener;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.RxBus;
import com.bule.free.ireader.common.utils.RxUtils;
import com.bule.free.ireader.common.utils.SystemBarUtils;
import com.bule.free.ireader.common.utils.ToastUtils;
import com.bule.free.ireader.model.ApiConfig;
import com.bule.free.ireader.model.BookmarkBean;
import com.bule.free.ireader.model.DownloadMessage;
import com.bule.free.ireader.model.NewReadBookRefreshBookmarkEvent;
import com.bule.free.ireader.model.OffShelfEvent;
import com.bule.free.ireader.model.RefreshBookShelfEvent;
import com.bule.free.ireader.model.TodayReadTimeEvent;
import com.bule.free.ireader.model.User;
import com.bule.free.ireader.model.local.BookRepository;
import com.bule.free.ireader.model.objectbox.OB;
import com.bule.free.ireader.model.objectbox.OBKt;
import com.bule.free.ireader.model.objectbox.bean.BookBean;
import com.bule.free.ireader.model.bean.BookChapterBean;
import com.bule.free.ireader.model.objectbox.bean.BookChContentBean;
import com.bule.free.ireader.model.objectbox.bean.BookHistoryBean;
import com.bule.free.ireader.model.objectbox.bean.DownloadTaskBean;
import com.bule.free.ireader.model.objectbox.bean.ReadRecordBean;
import com.bule.free.ireader.module.login.LoginActivity;
import com.bule.free.ireader.newbook.ReadBookConfig;
import com.bule.free.ireader.newbook.adv.ReadPageAdvControllerKt;
import com.bule.free.ireader.newbook.contentswitchview.BookContentView;
import com.bule.free.ireader.newbook.contentswitchview.ContentSwitchView;
import com.bule.free.ireader.newbook.widget.ChapterListView;
import com.bule.free.ireader.ui.base.BaseReadActivity;
import com.monke.mprogressbar.MHorProgressBar;
import com.monke.mprogressbar.OnProgressListener;
import com.umeng.analytics.MobclickAgent;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import io.reactivex.Observable;
import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;
import me.grantland.widget.AutofitTextView;


public class NewReadBookActivity extends BaseReadActivity implements OnDownloadListener {

    @BindView(R.id.csv_book)
    ContentSwitchView csvBook;
    @BindView(R.id.fl_menu)
    FrameLayout flMenu;
    @BindView(R.id.ll_menu_top)
    LinearLayout llMenuTop;
    @BindView(R.id.ll_menu_bottom)
    LinearLayout llMenuBottom;
    @BindView(R.id.iv_return)
    ImageButton ivReturn;
    @BindView(R.id.atv_title)
    AutofitTextView atvTitle;
    @BindView(R.id.tv_pre)
    TextView tvPre;
    @BindView(R.id.tv_next)
    TextView tvNext;
    @BindView(R.id.hpb_read_progress)
    MHorProgressBar hpbReadProgress;
    @BindView(R.id.ll_catalog)
    LinearLayout llCatalog;
    @BindView(R.id.ll_setting)
    LinearLayout llSetting;
    @BindView(R.id.clp_chapterlist)
    ChapterListView chapterListView;
    @BindView(R.id.ll_menu_top_bg)
    LinearLayout llMenuTopBg;
    @BindView(R.id.ll_menu_bottom_bg)
    LinearLayout llMenuBottomBg;

    @BindView(R.id.iv_dn_mode)
    ImageView mIvDnMode;
    @BindView(R.id.tv_dn_mode)
    TextView mTvDnMode;
    @BindView(R.id.ll_dn_mode)
    LinearLayout mLlDnMode;
    @BindView(R.id.ll_bookmark)
    LinearLayout mLlBookmark;
    @BindView(R.id.iv_ic_catalog)
    ImageView mIvIcCatalog;
    @BindView(R.id.iv_ic_bookmark)
    ImageView mIvIcBookmark;
    @BindView(R.id.iv_ic_setting)
    ImageView mIvIcSetting;
    @BindView(R.id.iv_check_bookmark)
    ImageView mIvCheckBookmark;
    @BindView(R.id.fl_banner_ad_container)
    FrameLayout mFlBannerAdContainer;
    @BindView(R.id.btn_close_banner)
    ImageView mBtnCloseBanner;
    @BindView(R.id.layout_adv_container)
    FrameLayout mLayoutAdvContainer;

    //主菜单动画
    private Animation menuTopIn;
    private Animation menuTopOut;
    private Animation menuBottomIn;
    private Animation menuBottomOut;

    private long startReadTime = 0;

    int pageLineCount = 5;   //假设5行一页

    // activity是否调用了onStop
    volatile boolean isStopped = false;
    volatile boolean isCanSaveReadRecord = false;

    private static final String EXTRA_BOOK_ID = "extra_book_id";
    private static final String EXTRA_BOOK_TITLE = "extra_book_title";
    private static final String EXTRA_BOOK_COVER = "extra_book_cover";

    String mBookId;
    String mBookTitle;
    String mBookCover;

    int mCurrentChapterIndex = 0; // 章节索引
    int mCurrentPageIndex = 0; // 读到的页数记录

    List<BookChapterBean> mBookChapterList = new ArrayList<>(); // 章节列表
    List<BookmarkBean> mBookmarkList = new ArrayList<>(); // 书签列表
    @Nullable
    BookmarkBean mCurrentBookmark = null;
    NewReadBookPresenter mPresenter;
    public NewReadBookViewDel mNewReadBookViewDel;

    public static void startActivity(Context context, String bookId, String bookTitle, String bookCover) {
        Intent intent = new Intent(context, NewReadBookActivity.class);
        intent.putExtra(EXTRA_BOOK_ID, bookId);
        intent.putExtra(EXTRA_BOOK_TITLE, bookTitle);
        intent.putExtra(EXTRA_BOOK_COVER, bookCover);
        context.startActivity(intent);
    }

    public static void startActivityAndLog(Context context, @NonNull BookHistoryBean bean) {
        Intent intent = new Intent(context, NewReadBookActivity.class);
        intent.putExtra(EXTRA_BOOK_ID, bean.getBookId());
        intent.putExtra(EXTRA_BOOK_TITLE, bean.getTitle());
        intent.putExtra(EXTRA_BOOK_COVER, bean.getCover());
        OBKt.boxOf(BookHistoryBean.class).put(bean);
        context.startActivity(intent);
    }

    public static void startActivityForResult(Activity context, String bookId, String bookTitle, String bookCover) {
        Intent intent = new Intent(context, NewReadBookActivity.class);
        intent.putExtra(EXTRA_BOOK_ID, bookId);
        intent.putExtra(EXTRA_BOOK_TITLE, bookTitle);
        intent.putExtra(EXTRA_BOOK_COVER, bookCover);
        context.startActivityForResult(intent, 200);
    }

    @Override
    protected int getContentId() {
        return R.layout.activity_bookread;
    }

    @Override
    protected void initData(Bundle savedInstanceState) {
        super.initData(savedInstanceState);
        mBookId = getIntent().getStringExtra(EXTRA_BOOK_ID);
        mBookTitle = getIntent().getStringExtra(EXTRA_BOOK_TITLE);
        mBookCover = getIntent().getStringExtra(EXTRA_BOOK_COVER);
        mPresenter = new NewReadBookPresenter(this);
        mNewReadBookViewDel = new NewReadBookViewDel(this);
        NewReadBookViewDel.Companion.setLastShowInterstitialAdTime(System.currentTimeMillis());
    }

    @Override
    protected void initWidget() {
        super.initWidget();
        mNewReadBookViewDel.initView();
        initMenuAnim();
        flMenu.setVisibility(View.GONE);
        mNewReadBookViewDel.changeMode(ReadBookConfig.INSTANCE.getUiMode());
    }

    private void initMenuAnim() {
        if (menuTopIn != null) return;

        menuTopIn = AnimationUtils.loadAnimation(this, R.anim.anim_readbook_top_in);

        menuBottomIn = AnimationUtils.loadAnimation(this, R.anim.anim_readbook_bottom_in);

        menuTopOut = AnimationUtils.loadAnimation(this, R.anim.anim_readbook_top_out);

        menuBottomOut = AnimationUtils.loadAnimation(this, R.anim.anim_readbook_bottom_out);

        menuTopOut.setDuration(200);
        menuBottomOut.setDuration(200);
    }

    private void initChapterListData() {
        if (mBookChapterList == null) {
            return;
        }
        chapterListView.setData(mBookTitle, mBookChapterList, index -> {
            csvBook.setInitData(index, mBookChapterList.size(), BookContentView.DURPAGEINDEXBEGIN);
            chapterListView.dimissChapterList();
        });
    }

    //
    @Override
    protected void onResume() {
        super.onResume();
        hideSystemBar();
    }

    @Override
    protected void initClick() {
        mNewReadBookViewDel.initListener();

        chapterListView.setDownloadClickListener(this::clickDownloadView);

        hpbReadProgress.setProgressListener(new OnProgressListener() {
            @Override
            public void moveStartProgress(float dur) {
            }

            @Override
            public void durProgressChange(float dur) {
            }

            @Override
            public void moveStopProgress(float dur) {
                LogUtils.e("moveStopProgress " + dur + " " + hpbReadProgress.getMaxProgress());
                int realDur = (int) Math.ceil(dur);
                if (realDur < 1) {
                    realDur = 1;
                }
                if ((realDur - 1) != mCurrentChapterIndex) {
                    csvBook.setInitData(realDur - 1, mBookChapterList.size(), BookContentView.DURPAGEINDEXBEGIN);
                }
                if (hpbReadProgress.getDurProgress() != realDur)
                    hpbReadProgress.setDurProgress(realDur);
                if (dur == hpbReadProgress.getMaxProgress()) {
                    tvPre.setEnabled(true);
                    tvNext.setEnabled(false);
                }
            }

            @Override
            public void setDurProgress(float dur) {
                if (hpbReadProgress == null) return;
                //LogUtils.e("setDurProgress " + dur + " " + hpbReadProgress.getMaxProgress());
                if (hpbReadProgress.getMaxProgress() == 1) {
                    tvPre.setEnabled(false);
                    tvNext.setEnabled(false);
                } else {
                    if (dur == 1) {
                        tvPre.setEnabled(false);
                        tvNext.setEnabled(true);
                    } else if (dur == hpbReadProgress.getMaxProgress()) {
                        tvPre.setEnabled(true);
                        tvNext.setEnabled(false);
                    } else {
                        tvPre.setEnabled(true);
                        tvNext.setEnabled(true);
                    }
                }
            }
        });
        // 左上角菜单中的返回键
        ivReturn.setOnClickListener(v -> mPresenter.isBookInShelf(mBookId, this::finish, this::addToBookShelf));
        tvPre.setOnClickListener(v -> {
            csvBook.setInitData(mCurrentChapterIndex - 1, mBookChapterList.size(), BookContentView.DURPAGEINDEXBEGIN);
        });
        tvNext.setOnClickListener(v -> {
            csvBook.setInitData(mCurrentChapterIndex + 1, mBookChapterList.size(), BookContentView.DURPAGEINDEXBEGIN);
        });
        // 点击查看目录
        llCatalog.setOnClickListener(v -> { // 点击章节列表按钮
            toggleMenu(true);
            new Handler().postDelayed(() -> {
                if (chapterListView != null) {
                    chapterListView.show(mCurrentChapterIndex);
                    setDownloadText();
                }
            }, menuTopOut.getDuration());
        });
        // 点击切换夜间模式
        mLlDnMode.setOnClickListener(v -> {
            toggleMenu(true);
            if (ReadBookConfig.INSTANCE.getUiMode().isNight()) {
                ReadBookConfig.UIMode.DAY.changeMode();
            } else {
                ReadBookConfig.UIMode.NIGHT.changeMode();
            }
        });
        // 点击跳转书签列表
        mLlBookmark.setOnClickListener(v -> {
            if (mBookChapterList.isEmpty()) {
                ToastUtils.show("书籍未加载完毕，请稍后");
                return;
            }
            toggleMenu(false);
            BookmarkManageActivity.Companion.start(this, mBookId);
        });
        // 点击设置
        llSetting.setOnClickListener(v -> {
            toggleMenu(false);
            ReadSettingActivity.Companion.start(this);
        });
        // 点击添加书签
        mIvCheckBookmark.setOnClickListener(v -> {
            if (v.isSelected()) {
                mPresenter.deleteBookmark();
            } else {
                mPresenter.addBookmark();
            }
        });
        // 点击标题关闭菜单
        atvTitle.setOnClickListener(v -> toggleMenu(true));
        csvBook.setLoadDataListener(new ContentSwitchView.LoadDataListener() {
            @Override
            public void loaddata(BookContentView bookContentView, long qtag, int chapterIndex, int pageIndex) {
//                LogUtils.e("csvBook Listener loaddata mCurrentChapterIndex : " + chapterIndex);
//                LogUtils.e("csvBook Listener loaddata mCurrentPageIndex : " + pageIndex);
//                LogUtils.e("csvBook Listener loaddata qtag : " + qtag);
                int nextChapterIndex = chapterIndex + 1;
                if (!mBookChapterList.isEmpty() && nextChapterIndex < mBookChapterList.size()) {
                    csvBook.postDelayed(() -> {
                        if (nextChapterIndex < mBookChapterList.size())
                            preGetDatabaseContent(mBookChapterList.get(nextChapterIndex));
                    }, 200);
                }
                loadContent(bookContentView, qtag, chapterIndex, pageIndex);
            }

            @Override
            public void updateProgress(int chapterIndex, int pageIndex) {
                // LogUtils.e("csvBook Listener updateProgress mCurrentChapterIndex: " + chapterIndex);
                // LogUtils.e("csvBook Listener updateProgress mCurrentPageIndex: " + pageIndex);
                if (isDestroyed()) return;
                mCurrentChapterIndex = chapterIndex;
                mCurrentPageIndex = pageIndex;
                mNewReadBookViewDel.showInterstitialAdv();
                mNewReadBookViewDel.checkCurrentPageIsBookmark();

                if (atvTitle != null) {
                    atvTitle.setText(getChapterTitle(chapterIndex));
                }

                if (hpbReadProgress.getDurProgress() != chapterIndex + 1) {
                    hpbReadProgress.setDurProgress(chapterIndex + 1);
                }
                try {
                    mBookChapterList.get(chapterIndex - 3).setContentBean(null);
                    mBookChapterList.get(chapterIndex + 3).setContentBean(null);
                } catch (Exception e) {
                }
            }

            @Override
            public String getChapterTitle(int chapterIndex) {
//                LogUtils.d("csvBook Listener getTitle");

                if (mBookChapterList.size() == 0 || chapterIndex >= mBookChapterList.size() || chapterIndex < 0) {
                    return "无章节";
                } else
                    return mBookChapterList.get(chapterIndex).getTitle();
            }

            @Override
            public void initData(int lineCount) {

                pageLineCount = lineCount;

                LogUtils.d("csvBook Listener initData lineCount : " + lineCount);

                csvBook.setInitData(mCurrentChapterIndex, mBookChapterList.size(), mCurrentPageIndex);
            }

            @Override
            public void showMenu() {
                toggleMenu(true);
            }
        });

    }

    // 获取不到本地缓存的章节列表，加载服务器的
    private void loadServerBookChapters() {
        Disposable d = Api.INSTANCE.getChapterList(mBookId)
                .subscribe(
                        new SimpleCallback<List<BookChapterBean>>() {
                            @Override
                            public void onSuccess(List<BookChapterBean> it) {
                                LogUtils.e(String.format("it: %s", it));
                                if (it == null || it.isEmpty()) {
                                    ToastUtils.show("该作品已下架");
                                    NewReadBookActivity.this.finish();
                                    RxBus.INSTANCE.post(OffShelfEvent.INSTANCE);
                                }

                                mBookChapterList = it;

                                saveBookChapters();
                                NewReadBookActivity.this.loadCsvBook();

                            }

                            @Override
                            public void onException(Throwable throwable) {
                                LogUtils.e(String.format("throwable: %s", throwable));
                                if (!(throwable instanceof ApiException)) {
                                    LogUtils.e(throwable.toString());
                                    ToastUtils.show("章节列表加载出错");
                                }
                                finish();
                            }
                        }
                );
        addDisposable(d);
    }

    // 加载完本地章节后，还要再获取一次服务器章节来同步并覆盖缓存
    private void refreshBookChapters() {
        Disposable d = Api.INSTANCE.getChapterList(mBookId)
                .subscribe(
                        it -> {
                            if (it != null && it.size() > 0) {
                                mBookChapterList = it;
                                initChapterListData();
                                setHpbReadProgressMax(mBookChapterList.size());
                                saveBookChapters();
                            }
                        },
                        tr -> {
                        }
                );
        addDisposable(d);
    }

    private void saveBookChapters() {
        if (mBookChapterList == null) {
            return;
        }
        Disposable d = BookRepository.INSTANCE.putChapterList(mBookId, mBookChapterList)
                .compose(RxUtils::toSimpleSingle)
                .subscribe(it -> {
                }, tr -> {
                });

        addDisposable(d);
    }

    // 加载本地章节列表，加载成功则走网络刷新更新，加载失败则走网络获取
    private void loadCacheBookChapters() {
        LogUtils.e("start loadCsvBook by loadCacheBookChapters");
//        BookRepository.INSTANCE.getChapterList2(mBookId, it -> {
//            if (it != null && !it.isEmpty()) {
//                LogUtils.e("loadCacheBookChapters success");
//                mBookChapterList = it;
//                LogUtils.e("loadCsvBook by loadCacheBookChapters");
//                loadCsvBook();
//
//                refreshBookChapters();
//
//            } else {
//                LogUtils.e("loadCacheBookChapters fail 加载本地章节列表为空");
//                loadServerBookChapters();
//            }
//        }, throwable -> {
//            LogUtils.e("loadCacheBookChapters fail tr：" + throwable.toString());
//            loadServerBookChapters();
//        });
        LogUtils.e("loadCacheBookChapters");
        Disposable d = BookRepository.INSTANCE.getChapterList(mBookId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        it -> {
                            if (it != null && !it.isEmpty()) {
                                LogUtils.e("loadCacheBookChapters success");
                                mBookChapterList = it;
                                LogUtils.e("loadCsvBook by loadCacheBookChapters");
                                loadCsvBook();

                                refreshBookChapters();

                            } else {
                                LogUtils.e("loadCacheBookChapters fail 加载本地章节列表为空");
                                loadServerBookChapters();
                            }

                        },
                        tr -> {
                            LogUtils.e("loadCacheBookChapters fail tr：" + tr.toString());
                            loadServerBookChapters();
                        }
                );

        addDisposable(d);

    }

    // 加载阅读记录，阅读记录包括阅读位置
    private void loadReadRecord() {
        if (mBookId == null) {
            return;
        }
        LogUtils.e("start loadReadRecord " + System.currentTimeMillis());
//        BookRepository.INSTANCE.getBookRecord2(mBookId, bean -> {
//            if (bean != null) {
//                mCurrentChapterIndex = bean.getChapterIndex();
//                mCurrentPageIndex = bean.getPageIndex();
//            }
//            LogUtils.e("end loadReadRecord " + System.currentTimeMillis());
//            //mLlBookmark.postDelayed(this::loadCacheBookChapters,3000);
//            loadCacheBookChapters();
//        }, throwable -> {
//            //mLlBookmark.postDelayed(this::loadCacheBookChapters,3000);
//            loadCacheBookChapters();
//        });
        ReadRecordBean bookRecord = BookRepository.INSTANCE.getBookRecord(mBookId);
        if (bookRecord != null) {
            mCurrentChapterIndex = bookRecord.getChapterIndex();
            mCurrentPageIndex = bookRecord.getPageIndex();
        }
        isCanSaveReadRecord = true;
        loadCacheBookChapters();
    }

    private void saveReadRecord() {

        if (!isCanSaveReadRecord) return;
        ReadRecordBean mReadRecord = new ReadRecordBean();
        mReadRecord.setBookId(mBookId);
        mReadRecord.setChapterIndex(mCurrentChapterIndex);
        mReadRecord.setPageIndex(mCurrentPageIndex);
        BookRepository.INSTANCE.addBookRecord(mReadRecord);

        Disposable mdisposable = BookRepository.INSTANCE.checkCollBook(mBookId)
                .compose(RxUtils::toSimpleSingle)
                .subscribe(
                        (optional) -> {
                            if (optional.isPresent()) {
                                //书架的书本
                                optional.get().setLastRead(String.valueOf(System.currentTimeMillis()));
                                OB.INSTANCE.getBoxStore().boxFor(BookBean.class).put(optional.get());

                                RxBus.INSTANCE.post(RefreshBookShelfEvent.INSTANCE);

                            } else {
                                //不是书架书本

                                if (taskBean != null) {
                                    addToBookShelf(mBookId);
                                }
                            }
                        },
                        (e) -> {
                            LogUtils.e(e);
                            //不是书架书本
                            if (taskBean != null) {
                                addToBookShelf(mBookId);
                            }
                        }
                );
//        addDisposable(mdisposable);
    }

    // 下载书籍按钮的点击事件
    private void clickDownloadView() {
        if (!Const.DEBUG) {
            if (!User.INSTANCE.isLogin()) {
                ToastUtils.show("下载书籍需要先登录App");
                LoginActivity.Companion.start(this);
                return;
            }
        }
        if (mBookId == null) {

            return;
        }

        String taskId = mBookId + "_" + mBookTitle.hashCode();

        taskBean = BookDownloader.INSTANCE.getDownloadTask(taskId);

        if (taskBean == null) {

            createDownloadTask();

            return;
        }

        if (taskBean.getStatus() == DownloadTaskBean.STATUS_FINISH) {
            //下载完成
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_LOADING) {
            //下载中
            BookDownloader.INSTANCE.setDownloadStatus(taskId, DownloadTaskBean.STATUS_PAUSE);
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_WAIT) {
            //等待
            BookDownloader.INSTANCE.setDownloadStatus(taskId, DownloadTaskBean.STATUS_PAUSE);
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_PAUSE) {
            //暂停
            BookDownloader.INSTANCE.setDownloadStatus(taskId, DownloadTaskBean.STATUS_WAIT);
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_ERROR) {
            //出错
            BookDownloader.INSTANCE.setDownloadStatus(taskId, DownloadTaskBean.STATUS_WAIT);
        }
    }

    private void createDownloadTask() {
        if (!Const.DEBUG) {
            if (User.INSTANCE.getCoinCount() < ApiConfig.INSTANCE.getExchangeGoldNum()) {
                ToastUtils.show("金币不足" + ApiConfig.INSTANCE.getExchangeGoldNum() + "，无法继续下载");
                return;
            }
        }

        addDisposable(Api.INSTANCE.goldExchange("-1", mBookId)
                .subscribe(() -> {
                    String taskId = mBookId + "_" + mBookTitle.hashCode();
                    int lastChapter = 0;
                    if (mBookChapterList != null && mBookChapterList.size() > 0) {
                        lastChapter = mBookChapterList.size();
                    } else {
                        ToastUtils.show("下载任务创建异常，请重试");
                        return;
                    }
                    taskBean = new DownloadTaskBean(taskId, mBookId, 0, lastChapter, mBookTitle, mBookCover);
                    LogUtils.e("createDownloadTask : " + taskBean.toString());
                    RxBus.INSTANCE.post(taskBean);
                    User.INSTANCE.syncToServer();
                }, throwable -> {
                    ToastUtils.show("下载任务创建异常，请重试");
                }));
    }

    // 添加到书架
    private void addToBookShelf(String bookid) {
        LogUtils.d("download book addToBookShelf");

        Disposable d = Api.INSTANCE.getBookDetail(bookid, "")
                .subscribe(bookDetailPageBean -> {

                    if (bookDetailPageBean != null && bookDetailPageBean.getDetail() != null) {

                        BookBean collItemBean = new BookBean();

                        collItemBean.setId(bookDetailPageBean.getDetail().getId());
                        collItemBean.setAuthor(bookDetailPageBean.getDetail().getAuthor());
                        collItemBean.setCover(bookDetailPageBean.getDetail().getCover());
                        collItemBean.setGender(bookDetailPageBean.getDetail().getGender());
                        collItemBean.setIsfree(bookDetailPageBean.getDetail().getIsfree());
                        collItemBean.setLatelyFollower(bookDetailPageBean.getDetail().getLatelyFollower());
                        collItemBean.setLongIntro(bookDetailPageBean.getDetail().getLongIntro());
                        collItemBean.setMajorCate(bookDetailPageBean.getDetail().getMajorCate());
                        collItemBean.setOver(bookDetailPageBean.getDetail().getOver());
                        collItemBean.setScore(bookDetailPageBean.getDetail().getScore());
                        collItemBean.setSerializeWordCount(bookDetailPageBean.getDetail().getSerializeWordCount());
                        collItemBean.setUpdated(bookDetailPageBean.getDetail().getUpdated());
                        collItemBean.setTitle(bookDetailPageBean.getDetail().getTitle());
                        collItemBean.setWordCount(bookDetailPageBean.getDetail().getWordCount() + "");
                        collItemBean.setLastRead(String.valueOf(System.currentTimeMillis()));
                        collItemBean.setLastChapter(bookDetailPageBean.getDetail().getLastChapter());

                        BookRepository.INSTANCE
                                .addBookShelf(collItemBean)
                                .compose(RxUtils::toSimpleSingle)
                                .subscribe();
                    }
                }, ErrorConsumer.INSTANCE);
        //addDisposable(d);

    }

    private DownloadTaskBean taskBean;

    @Override
    protected void processLogic() {
        super.processLogic();

        initCsvBook();

        BookDownloader.INSTANCE.register(this);

        MobclickAgent.onEvent(this, "book_read_activity", mBookId);
        MobclickAgent.onEvent(this, "book_read_count", mBookTitle);

        Disposable donwloadDisp = RxBus.INSTANCE
                .toObservable(DownloadMessage.class)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        event -> {
                            //使用Toast提示
                            ToastUtils.show(event.getMessage());
                        }
                );
        addDisposable(donwloadDisp);
        RxBus.INSTANCE.post(NewReadBookRefreshBookmarkEvent.INSTANCE);
    }

    private void setDownloadText() {
        if (mBookId == null) {
            return;
        }

        String taskId = mBookId + "_" + mBookTitle.hashCode();

        taskBean = BookDownloader.INSTANCE.getDownloadTask(taskId);

        if (taskBean == null) {
            chapterListView.setDownloadText("下载整本（消耗" + ApiConfig.INSTANCE.getExchangeGoldNum() + "金币）");
            return;
        }

        if (taskBean.getStatus() == DownloadTaskBean.STATUS_FINISH) {
            //下载完成
            chapterListView.setDownloadText("下载完成");
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_LOADING) {
            //下载中
            chapterListView.setDownloadText("正在下载（" + taskBean.getCurrentChapter() + "/" + taskBean.getLastChapter() + "）");
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_WAIT) {
            //等待
            chapterListView.setDownloadText("等待其它小说下载完成");
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_PAUSE) {
            //暂停
            chapterListView.setDownloadText("暂停中，点击继续下载");
        } else if (taskBean.getStatus() == DownloadTaskBean.STATUS_ERROR) {
            //出错
            chapterListView.setDownloadText("出错，点击重新下载");
        }
    }

    private void initCsvBook() {
        csvBook.bookReadInit(() -> {
            LogUtils.d("csvBook init success");
            loadReadRecord();
        });
    }

    private void loadCsvBook() {
        initChapterListData();

        setHpbReadProgressMax(mBookChapterList.size());

        startLoadingBook();
    }

    public void setHpbReadProgressMax(int count) {
        hpbReadProgress.setMaxProgress(count);
    }

    public void startLoadingBook() {
        csvBook.startLoading();
    }

    public void loadContent(final BookContentView bookContentView, final long bookTag, final int chapterIndex, int pageIndex) {
        //LogUtils.e("loadContent(chapter index: " + chapterIndex + ")");
        if (mBookChapterList.size() == 0 || mBookChapterList.size() <= chapterIndex) {

            if (bookContentView != null && bookTag == bookContentView.getqTag())
                bookContentView.loadError();

            return;
        }


        final BookChapterBean mBookChapterBean = mBookChapterList.get(chapterIndex);

        if (null != mBookChapterBean && mBookChapterBean.getContentBean() != null && !TextUtils.isEmpty(mBookChapterBean.getContentBean().getContent())) {

            if (mBookChapterBean.getContentBean().getLineSize() == getPaint().getTextSize() && mBookChapterBean.getContentBean().getLineContent().size() > 0) {
                //已有数据
                int tempCount = (int) Math.ceil(mBookChapterBean.getContentBean().getLineContent().size() * 1.0 / pageLineCount) - 1;

                if (pageIndex == BookContentView.DURPAGEINDEXBEGIN) {
                    pageIndex = 0;
                } else if (pageIndex == BookContentView.DURPAGEINDEXEND) {
                    pageIndex = tempCount;
                } else {
                    if (pageIndex >= tempCount) {
                        pageIndex = tempCount;
                    }
                }

                int start = pageIndex * pageLineCount;
                int end = pageIndex == tempCount ? mBookChapterBean.getContentBean().getLineContent().size() : start + pageLineCount;
                if (bookContentView != null && bookTag == bookContentView.getqTag()) {
                    bookContentView.updateData(bookTag, mBookChapterList.get(chapterIndex).getTitle()
                            , mBookChapterBean.getContentBean().getLineContent().subList(start, end)
                            , chapterIndex
                            , mBookChapterList.size()
                            , pageIndex
                            , tempCount + 1);
                }
            } else {
                //有元数据  重新分行
                mBookChapterBean.getContentBean().setLineSize(getPaint().getTextSize());

                final int finalPageIndex = pageIndex;

                SeparateParagraphtoLines(mBookChapterBean.getContentBean().getContent())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribeOn(Schedulers.io())
                        .subscribe(new Observer<List<String>>() {
                            @Override
                            public void onSubscribe(Disposable d) {

                            }

                            @Override
                            public void onNext(List<String> value) {
                                try {
                                    mBookChapterBean.getContentBean().getLineContent().clear();
                                    mBookChapterBean.getContentBean().getLineContent().addAll(value);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                                loadContent(bookContentView, bookTag, chapterIndex, finalPageIndex);
                            }

                            @Override
                            public void onError(Throwable e) {
                                if (bookContentView != null && bookTag == bookContentView.getqTag())
                                    bookContentView.loadError();
                            }

                            @Override
                            public void onComplete() {
                                if (!ApiConfig.INSTANCE.isNoAd() && ReadPageAdvControllerKt.isReadPageAdvShow())
                                    mBookChapterBean.getContentBean().needAddLineContent(pageLineCount);
                            }
                        });
            }
        } else {

            final int finalPageIndex = pageIndex;

            showCacheContent(bookContentView, mBookChapterBean, chapterIndex, finalPageIndex, bookTag);

        }
        // 这里重复添加书签检查，为了一个小bug
        mNewReadBookViewDel.checkCurrentPageIsBookmark();
    }

    private void showCacheContent(final BookContentView bookContentView, BookChapterBean mBookChapterBean, int chapterIndex, int finalPageIndex, long bookTag) {
        LogUtils.e("showCacheContent chapterIndex: " + chapterIndex);
        Disposable disposable = BookRepository.INSTANCE.getBookContent(mBookId, mBookChapterBean.get_label())
                .compose(RxUtils::toSimpleSingle)
                .subscribe(
                        it -> {
                            if (it != null && !TextUtils.isEmpty(it.getContent())) {
                                BookChContentBean contentBean = new BookChContentBean();
                                contentBean.setContent(it.getContent());
                                contentBean.setId(it.getId());
                                contentBean.setBookId(mBookId);
                                mBookChapterBean.setContentBean(contentBean);
                                if (bookTag == bookContentView.getqTag()) {
                                    LogUtils.e("加载缓存章节内容成功，chapterIndex: " + chapterIndex);
                                    loadContent(bookContentView, bookTag, chapterIndex, finalPageIndex);
                                } else {
                                    LogUtils.e("加载缓存章节内容失败，chapterIndex: " + chapterIndex);
                                    if (bookContentView != null && bookTag == bookContentView.getqTag()) {
                                        bookContentView.loadError();
                                    }
                                }
                            } else {
                                LogUtils.e("加载缓存章节内容失败，开始展示服务器内容，chapterIndex: " + chapterIndex);
                                showServerContent(bookContentView, mBookChapterBean, chapterIndex, finalPageIndex, bookTag);
                            }
                        },
                        tr -> {
                            showServerContent(bookContentView, mBookChapterBean, chapterIndex, finalPageIndex, bookTag);
                        }
                );
        addDisposable(disposable);
    }

    private void showServerContent(final BookContentView bookContentView, BookChapterBean mBookChapterBean, int chapterIndex, int finalPageIndex, long bookTag) {
        LogUtils.e("showServerContent");
        Disposable disposable = Api.INSTANCE.getChapterContent(mBookId, mBookChapterBean.get_label())
                .subscribe(chapterContentBean -> {

                    if (chapterContentBean != null && !TextUtils.isEmpty(chapterContentBean.getUrl())) {
                        Api.INSTANCE.get2(chapterContentBean.getUrl(), new Api.ApiCallBack() {
                            @Override
                            public void onSuccess(@NotNull String content) {
                                BookChContentBean contentBean = new BookChContentBean();
                                contentBean.setContent(content);
                                contentBean.setId(mBookId + "_" + mBookChapterBean.get_label());
                                contentBean.setBookId(mBookId);
                                mBookChapterBean.setContentBean(contentBean);

                                if (!TextUtils.isEmpty(content)) {
                                    BookRepository.INSTANCE.putBookContent(contentBean);
                                }

                                if (!TextUtils.isEmpty(content) && bookContentView != null && bookTag == bookContentView.getqTag()) {
                                    loadContent(bookContentView, bookTag, chapterIndex, finalPageIndex);
                                } else {
                                    if (bookContentView != null && bookTag == bookContentView.getqTag()) {
                                        bookContentView.loadError();
                                    }
                                }
                            }

                            @Override
                            public void onFail(@NotNull Throwable e) {
                                if (bookContentView != null && bookTag == bookContentView.getqTag()) {
                                    bookContentView.loadError();
                                }
                            }
                        });
                    } else {
                        if (bookContentView != null && bookTag == bookContentView.getqTag()) {
                            bookContentView.loadError();
                        }
                    }

                }, throwable -> {
                    LogUtils.e(throwable.toString());
                    if (bookContentView != null && bookTag == bookContentView.getqTag()) {
                        bookContentView.loadError();
                    }
                });
        addDisposable(disposable);
    }

    // 预加载下一章的内容
    private void preGetDatabaseContent(BookChapterBean bookChapterBean) {
        Runnable preGetServerContent = () -> {
            Disposable disposable = Api.INSTANCE.getChapterContent(mBookId, bookChapterBean.get_label())
                    .subscribe(chapterContentBean -> {
                        LogUtils.e("预加载下一章 label is: " + bookChapterBean.get_label());
                        if (chapterContentBean != null && !TextUtils.isEmpty(chapterContentBean.getUrl())) {
                            Api.INSTANCE.get2(chapterContentBean.getUrl(), new Api.ApiCallBack() {
                                @Override
                                public void onSuccess(@NotNull String content) {
                                    BookChContentBean contentBean = new BookChContentBean();
                                    contentBean.setContent(content);
                                    contentBean.setId(mBookId + "_" + bookChapterBean.get_label());
                                    contentBean.setBookId(mBookId);
                                    bookChapterBean.setContentBean(contentBean);

                                    if (!TextUtils.isEmpty(content)) {
                                        BookRepository.INSTANCE.putBookContent(contentBean);
                                    }
                                }

                                @Override
                                public void onFail(@NotNull Throwable e) {
                                    LogUtils.e(String.format("e.toString(): %s", e.toString()));
                                }
                            });
                        }
                    }, t -> {
                    });
            addDisposable(disposable);
        };
        Disposable disposable = BookRepository.INSTANCE.getBookContent(mBookId, bookChapterBean.get_label())
                .compose(RxUtils::toSimpleSingle)
                .subscribe(it -> {
                            if (it == null || TextUtils.isEmpty(it.getContent())) {
                                preGetServerContent.run();
                            }
                        }, tr -> preGetServerContent.run()
                );
        addDisposable(disposable);
    }

    Observable<List<String>> SeparateParagraphtoLines(final String paragraphstr) {
        // 在每行初始添加缩紧
        final String indentParagraphStr = paragraphstr.replace("\n", "\n        ");
        return Observable.create(e -> {
            TextPaint mPaint = (TextPaint) getPaint();
            mPaint.setSubpixelText(true);
            Layout tempLayout = new StaticLayout(indentParagraphStr, mPaint, getContentWidth(), Layout.Alignment.ALIGN_NORMAL, 0, 0, false);
            List<String> linesdata = new ArrayList<String>();
            for (int i = 0; i < tempLayout.getLineCount(); i++) {
                linesdata.add(indentParagraphStr.substring(tempLayout.getLineStart(i), tempLayout.getLineEnd(i)));
            }
            e.onNext(linesdata);
            e.onComplete();
        });
    }

    public Paint getPaint() {
        if (csvBook == null) {
            return new Paint();
        }
        return csvBook.getTextPaint();
    }

    public int getContentWidth() {
        return csvBook.getContentWidth();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        Boolean temp = csvBook.onKeyDown(keyCode, event);
        if (temp) {
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        Boolean temp = csvBook.onKeyUp(keyCode, event);
        if (temp)
            return true;
        return super.onKeyUp(keyCode, event);
    }

    @Override
    protected void onPause() {
        super.onPause();
        saveReadRecord();
        BookDownloader.INSTANCE.saveData();
    }


    @Override
    protected void onStart() {
        super.onStart();
        isStopped = false;
        hideSystemBar();
        startReadTime = System.currentTimeMillis();
    }

    @Override
    protected void onStop() {
        super.onStop();
        isStopped = true;
        long todayReadTime = User.INSTANCE.getTodayReadTime();
        if (Const.DEBUG) {
            todayReadTime += (System.currentTimeMillis() - startReadTime) * 10;
        } else {
            todayReadTime += System.currentTimeMillis() - startReadTime;
        }
        //LogUtils.e("存储时长为" + todayReadTime);
        User.INSTANCE.setTodayReadTime(todayReadTime);
        RxBus.INSTANCE.post(TodayReadTimeEvent.INSTANCE);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mNewReadBookViewDel.onDestroy();
        BookDownloader.INSTANCE.unregister(this);
    }

    @Override
    public void onBackPressed() {
        mPresenter.isBookInShelf(mBookId, super::onBackPressed, this::addToBookShelf);
    }

    private void showSystemBar() {
        //显示
        if (flMenu.getVisibility() == View.VISIBLE) {
            SystemBarUtils.showUnStableStatusBar(this);
        }
    }

    private void hideSystemBar() {
        SystemBarUtils.hideStableStatusBar(this);
        SystemBarUtils.hideStableNavBar(this);
    }

    /**
     * 切换菜单栏的可视状态
     * 默认是隐藏的
     */
    private void toggleMenu(boolean hideStatusBar) {
        initMenuAnim();

        if (flMenu.getVisibility() == View.VISIBLE) {
            //关闭

            llMenuTop.startAnimation(menuTopOut);
            llMenuBottom.startAnimation(menuBottomOut);

            flMenu.setVisibility(View.INVISIBLE);
            if (hideStatusBar) {
                hideSystemBar();
            }

        } else {
            llMenuTop.startAnimation(menuTopIn);
            llMenuBottom.startAnimation(menuBottomIn);

            flMenu.setVisibility(View.VISIBLE);
            showSystemBar();
        }
    }

    @Override
    public void onDownloadChange(int pos, int status, String msg) {
        LogUtils.d("onDownloadChange : " + status);
    }

    @Override
    public void onDownloadResponse(int pos, int status) {
        LogUtils.d("onDownloadResponse : " + status);
        if (status == DownloadTaskBean.STATUS_PAUSE) {
            chapterListView.setDownloadText("暂停中，点击继续下载");
        } else if (status == DownloadTaskBean.STATUS_WAIT) {
            chapterListView.setDownloadText("等待其它小说下载完成");
        }
    }

    @Override
    public void onDownloadChange(DownloadTaskBean task) {
        LogUtils.d("onDownloadChange task: " + task);
        LogUtils.d("onDownloadChange taskBean: " + taskBean);
        if (chapterListView != null && taskBean != null && task != null && taskBean.get_id().equals(task.get_id())) {
            if (task.getStatus() == DownloadTaskBean.STATUS_FINISH) {
                chapterListView.setDownloadText("下载完成");
            } else if (task.getStatus() == DownloadTaskBean.STATUS_ERROR) {
                chapterListView.setDownloadText("出错，点击重新下载");
            } else if (task.getStatus() == DownloadTaskBean.STATUS_PAUSE) {
                chapterListView.setDownloadText("暂停中，点击继续下载");
            } else if (task.getStatus() == DownloadTaskBean.STATUS_WAIT) {
                chapterListView.setDownloadText("等待其它小说下载完成");
            } else if (task.getStatus() == DownloadTaskBean.STATUS_LOADING) {
                chapterListView.setDownloadText("正在下载（" + task.getCurrentChapter() + "/" + task.getLastChapter() + "）");
            }

        }
    }
}