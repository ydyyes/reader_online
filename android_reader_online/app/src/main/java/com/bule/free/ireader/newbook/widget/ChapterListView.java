package com.bule.free.ireader.newbook.widget;

import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.support.annotation.AttrRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StyleRes;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.Res;
import com.bule.free.ireader.model.bean.BookChapterBean2;
import com.bule.free.ireader.model.bean.BookChapterBean;
import com.bule.free.ireader.newbook.ReadBookConfig;
import com.bule.free.ireader.newbook.adapter.ChapterListAdapter;

import org.jetbrains.annotations.NotNull;

import java.util.List;


public class ChapterListView extends FrameLayout implements ReadBookConfig.ModeChangeable {
    private TextView tvName;
    private TextView tvListCount;
    private RecyclerView rvList;
    private RecyclerViewBar rvbSlider;
    private TextView btnSort;

    private FrameLayout flBg;
    private LinearLayout llContent;
    private LinearLayout llDownloadBook;
    private TextView tvDownText;

    private ChapterListAdapter chapterListAdapter;

    private Animation animIn;
    private Animation animOut;

    public ChapterListView(@NonNull Context context) {
        this(context, null);
    }

    public ChapterListView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ChapterListView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public ChapterListView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr, @StyleRes int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        setVisibility(INVISIBLE);
        LayoutInflater.from(getContext()).inflate(R.layout.view_chapterlist, this, true);
        initData();
        initView();
    }

    private void initData() {
        animIn = AnimationUtils.loadAnimation(getContext(), R.anim.anim_pop_chapterlist_in);
        animIn.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
                flBg.setOnClickListener(null);
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                flBg.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        dimissChapterList();
                    }
                });
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
        animOut = AnimationUtils.loadAnimation(getContext(), R.anim.anim_pop_chapterlist_out);
        animOut.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
                flBg.setOnClickListener(null);
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                llContent.setVisibility(INVISIBLE);
                setVisibility(INVISIBLE);
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
    }

    public void show(int durChapter) {

        int realDurChapter = durChapter;
        try {
            realDurChapter = chapterListAdapter.isAsc ? durChapter : chapterListAdapter.getItemCount() - 1 - durChapter;
            chapterListAdapter.setIndex(durChapter);
        } catch (Exception e) {
            e.printStackTrace();
        }

        ((LinearLayoutManager) rvList.getLayoutManager()).scrollToPositionWithOffset(realDurChapter, 0);
        if (getVisibility() != VISIBLE) {
            setVisibility(VISIBLE);
            animOut.cancel();
            animIn.cancel();
            llContent.setVisibility(VISIBLE);
            llContent.startAnimation(animIn);
        }
    }

    @Override
    public void changeMode(@NotNull ReadBookConfig.UIMode uiMode) {
        llContent.setBackgroundColor(uiMode.getMenuBarBgColor());

        if (uiMode == ReadBookConfig.UIMode.DAY) {
            llDownloadBook.setBackgroundColor(0xfffafafa);
        } else {
            llDownloadBook.setBackgroundColor(uiMode.getMenuBarBgColor());
        }
        if (chapterListAdapter != null) {
            chapterListAdapter.notifyDataSetChanged();
        }
    }

    public interface OnItemClickListener {
        void itemClick(int index);
    }

    public interface OnDownloadClickListener {
        void onClick();
    }

    private OnItemClickListener itemClickListener;

    public OnDownloadClickListener getDownloadClickListener() {
        return downloadClickListener;
    }

    public void setDownloadClickListener(OnDownloadClickListener downloadClickListener) {
        this.downloadClickListener = downloadClickListener;
    }

    private OnDownloadClickListener downloadClickListener;

    private void initView() {
        flBg = (FrameLayout) findViewById(R.id.fl_bg);
        llContent = (LinearLayout) findViewById(R.id.ll_content);
        tvName = (TextView) findViewById(R.id.tv_name);
        tvListCount = (TextView) findViewById(R.id.tv_listcount);
        rvList = (RecyclerView) findViewById(R.id.rv_list);
        rvList.setLayoutManager(new LinearLayoutManager(getContext()));
        rvList.setItemAnimator(null);
        rvbSlider = (RecyclerViewBar) findViewById(R.id.rvb_slider);
        btnSort = findViewById(R.id.btn_sort);
        llDownloadBook = (LinearLayout) findViewById(R.id.ll_download_book);
        tvDownText = (TextView) findViewById(R.id.tv_download_text);
        changeMode(ReadBookConfig.INSTANCE.getUiMode());
    }

    public void setData(String bookName, List<BookChapterBean> bookChapterBeans, OnItemClickListener clickListener) {
        this.itemClickListener = clickListener;
        tvName.setText(bookName);
        tvListCount.setText("共" + bookChapterBeans.size() + "章");
        chapterListAdapter = new ChapterListAdapter(bookChapterBeans, new OnItemClickListener() {
            @Override
            public void itemClick(int index) {
                if (itemClickListener != null) {
                    itemClickListener.itemClick(index);
                    LogUtils.e("click index is : " + index);
                    rvList.scrollToPosition(index);
                    //rvList.postDelayed(() -> chapterListAdapter.notifyItemChanged(index), 100);
                }
            }
        });
        rvList.setAdapter(chapterListAdapter);
        rvbSlider.setRecyclerView(rvList);

        btnSort.setCompoundDrawables(Res.INSTANCE.boundDrawable(R.drawable.read_ic_ch_sort_n), null, null, null);
        btnSort.setText("正序");
        btnSort.setOnClickListener(v -> {
            if (!chapterListAdapter.isAsc) {
                boolean reversed = chapterListAdapter.normalOrder();
                if (!reversed) {
                    btnSort.setCompoundDrawables(Res.INSTANCE.boundDrawable(R.drawable.read_ic_ch_sort_n), null, null, null);
                    btnSort.setText("正序");
                    ((LinearLayoutManager) rvList.getLayoutManager()).scrollToPositionWithOffset(chapterListAdapter.getIndex(), 0);
                }
            } else {
                boolean reversed = chapterListAdapter.reverseOrder();
                if (reversed) {
                    btnSort.setCompoundDrawables(Res.INSTANCE.boundDrawable(R.drawable.read_ic_ch_sort_r), null, null, null);
                    btnSort.setText("倒序");
                    ((LinearLayoutManager) rvList.getLayoutManager()).scrollToPositionWithOffset(chapterListAdapter.getItemCount() - 1 - chapterListAdapter.getIndex(), 0);
                }
            }
            LogUtils.e(String.format("chapterListAdapter.getIndex(): %s", chapterListAdapter.getIndex()));

        });

        llDownloadBook.setOnClickListener(v -> {
            if (downloadClickListener != null) {
                downloadClickListener.onClick();
            }
        });
    }

    public Boolean dimissChapterList() {
        if (getVisibility() != VISIBLE) {
            return false;
        } else {
            animOut.cancel();
            animIn.cancel();
            llContent.startAnimation(animOut);
            return true;
        }
    }

    public void refreshData(List<BookChapterBean2> bookChapterBeans) {
//        if(bookChapterBeans!=null){
//            tvListCount.setText("共"+bookChapterBeans.size()+"章");
//            chapterListAdapter.setBookChapterBeans(bookChapterBeans);
//        }
        chapterListAdapter.notifyDataSetChanged();
    }

    public void setDownloadText(String text) {
        tvDownText.setText(text);
    }

    // 是否正序
    public boolean isAsc() {
        return chapterListAdapter.isAsc;
    }
}