package com.bule.free.ireader.newbook.contentswitchview;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.FragmentActivity;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.adv.ttad.del.TTAdVideoAdDel;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.utils.ToastUtils;
import com.bule.free.ireader.model.User;
import com.bule.free.ireader.newbook.adv.AdvDisplayCallback;
import com.bule.free.ireader.newbook.adv.ReadPageAdvControllerKt;
import com.bule.free.ireader.newbook.ui.NewReadBookActivity;
import com.bule.free.ireader.newbook.widget.MTextView;
import com.bule.free.ireader.newbook.ReadBookConfig;
import com.bule.free.ireader.common.adv.AdvController;
import com.bule.free.ireader.common.utils.ScreenUtils;
import com.bule.free.ireader.common.adv.ShowAdType;
import com.bule.free.ireader.common.adv.baiduad.BaiduBannerAdDel;
import com.bule.free.ireader.common.adv.gdt.GdtNativeAdvDel;
import com.bule.free.ireader.common.adv.ttad.del.TTAdFeedDel;
import com.bule.free.ireader.common.widget.BatteryView;

import java.util.List;

/**
 * 表示每一页的View
 */

public class BookContentView extends FrameLayout {
    public long qTag = System.currentTimeMillis();

    public static final int DURPAGEINDEXBEGIN = -1;
    public static final int DURPAGEINDEXEND = -2;

    private View view;
    private ImageView ivBg;
    private TextView tvTitle;
    private LinearLayout llContent;
    private MTextView tvContent;
    private View vBottom;
    private TextView tvPage;

    private TextView tvLoading;
    private LinearLayout llError;
    private TextView tvErrorInfo;
    private TextView tvLoadAgain;
    private FrameLayout flAdContent;
    private BatteryView mBatteryView;
    private TextView mBtnWatchVideo;

    private String title;
    private String content;
    private int durChapterIndex;
    private int chapterAll;
    private int durPageIndex;      //如果durPageIndex = -1 则是从头开始  -2则是从尾开始
    private int pageAll;

    public boolean showAd = false;
    public boolean loadError = false;

    private ContentSwitchView.LoadDataListener loadDataListener;

    private SetDataListener setDataListener;
    @Nullable
    private GdtNativeAdvDel mGdtNativeAdvDel;
    @Nullable
    private BaiduBannerAdDel mBaiduBannerAdvDel;

    public interface SetDataListener {
        public void setDataFinish(BookContentView bookContentView, int durChapterIndex, int chapterAll, int durPageIndex, int pageAll, int fromPageIndex);
    }

    public BookContentView(Context context) {
        this(context, null);
    }

    public BookContentView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public BookContentView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public BookContentView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    @SuppressLint("CheckResult")
    private void init() {
        view = LayoutInflater.from(getContext()).inflate(R.layout.adapter_content_switch_item, this, false);
        addView(view);
        ivBg = (ImageView) view.findViewById(R.id.iv_bg);
        tvTitle = (TextView) view.findViewById(R.id.tv_title);
        llContent = (LinearLayout) view.findViewById(R.id.ll_content);
        tvContent = (MTextView) view.findViewById(R.id.tv_content);
        vBottom = view.findViewById(R.id.v_bottom);
        tvPage = (TextView) view.findViewById(R.id.tv_page);
        tvLoading = (TextView) view.findViewById(R.id.tv_loading);
        llError = (LinearLayout) view.findViewById(R.id.ll_error);
        tvErrorInfo = (TextView) view.findViewById(R.id.tv_error_info);
        tvLoadAgain = (TextView) view.findViewById(R.id.tv_load_again);
        flAdContent = (FrameLayout) view.findViewById(R.id.fl_adcontent);
        mBatteryView = (BatteryView) view.findViewById(R.id.mBatteryView);
        mBtnWatchVideo = view.findViewById(R.id.btn_watch_video);
        mBtnWatchVideo.setTextSize(ReadBookConfig.INSTANCE.getTextSize());
        mBtnWatchVideo.setTextColor(ReadBookConfig.INSTANCE.getTextColor());
        tvLoadAgain.setOnClickListener(v -> {
            if (loadDataListener != null)
                loading();
        });
        mBtnWatchVideo.setOnClickListener(v -> {
            if (User.INSTANCE.getTodayChapterEndVideoShowTimes() > 2) {
                ToastUtils.show("今日视频免广告次数以用尽，快去福利中心做任务吧");
                return;
            }
            User.INSTANCE.setTodayChapterEndVideoShowTimes(User.INSTANCE.getTodayChapterEndVideoShowTimes() + 1);
            Context context = getContext();
            if (context instanceof NewReadBookActivity) {
                NewReadBookActivity activity = (NewReadBookActivity) context;
                new TTAdVideoAdDel().loadAd(activity, isSuccess -> {
                    if (isSuccess) {
                        ToastUtils.show("30分钟免广告已生效");
                        hideAdv();
                        activity.mNewReadBookViewDel.invalidateBannerAdv();
                        User.INSTANCE.setNoAdTimeByWatchVideo(System.currentTimeMillis() + 30 * 60 * 1000);
                    } else {
                        ToastUtils.show("服务器偷懒了");
                    }
                });
            }

        });
    }

    public void loading() {
        loadError = false;
        llError.setVisibility(GONE);
        tvLoading.setVisibility(VISIBLE);
        llContent.setVisibility(INVISIBLE);
        qTag = System.currentTimeMillis();
        //LogUtils.e("loading!!!!!");
        //执行请求操作
        if (loadDataListener != null) {
            loadDataListener.loaddata(this, qTag, durChapterIndex, durPageIndex);
        }
    }

    public void finishLoading() {
        llError.setVisibility(GONE);
        llContent.setVisibility(VISIBLE);
        tvLoading.setVisibility(GONE);

    }

    //隐藏广告
    public void hideAdv() {
        //flAdContent.removeAllViews();
        flAdContent.setVisibility(GONE);
        mBtnWatchVideo.setVisibility(GONE);
        showAd = false;
    }

    private void showGdtEndAd(int contentLineSize) {
        LogUtils.e("准备展示腾讯章末广告！！！！");
        if (showAd) return;
        if (durPageIndex + 1 != pageAll) {
            return;
        }
        flAdContent.setVisibility(VISIBLE);
        int top = getContentHeight(contentLineSize);

        final Context context = getContext();
        int space = (int) (ScreenUtils.getScreenHeightSize() * 0.6);

        if (ScreenUtils.getScreenHeightSize() - top <= space) {
            showAd = false;
            return;
        } else {
            if (context instanceof NewReadBookActivity) {
                NewReadBookActivity activity = (NewReadBookActivity) context;
                showAd = true;
                activity.mNewReadBookViewDel.showChapterEndAdv(flAdContent, new AdvDisplayCallback() {
                    @Override
                    public void onShow() {
                        LogUtils.e("腾讯章末广告，展示成功");
                        mBtnWatchVideo.setVisibility(VISIBLE);
                    }

                    @Override
                    public void onFail() {
                        LogUtils.e("腾讯章末广告，展示失败");
                        new TTAdFeedDel(((FragmentActivity) context), flAdContent, isShowShare -> mBtnWatchVideo.setVisibility(isShowShare ? VISIBLE : GONE)).loadListAd();
                    }
                });
//                mGdtNativeAdvDel = GdtNativeAdvDel.attach(flAdContent, new GdtNativeAdvDel.GdtPageAdListener() {
//                    @Override
//                    public void onShow() {
//                    }
//
//                    @Override
//                    public void onFailure() {
//                    }
//
//                    @Override
//                    public void onAdClose() {
//                    }
//                });
            }
        }
    }

    private void showTTad(int contentLineSize) {
//        LogUtils.e("准备展示穿山甲章末广告");
        if (showAd) return;
        if (durPageIndex + 1 != pageAll) {
            return;
        }
        flAdContent.setVisibility(VISIBLE);
        int top = getContentHeight(contentLineSize);

        final Context context = getContext();
        int space = (int) (ScreenUtils.getScreenHeightSize() * 0.6);

        if (ScreenUtils.getScreenHeightSize() - top <= space) {
            showAd = false;
            return;
        } else {

            if (context instanceof NewReadBookActivity) {
                showAd = true;
                new TTAdFeedDel(((FragmentActivity) context), flAdContent, isShowShare -> {
                    if (isShowShare) {
                        mBtnWatchVideo.setVisibility(VISIBLE);
                    } else {
                        ((NewReadBookActivity) context).mNewReadBookViewDel.showChapterEndAdv(flAdContent, new AdvDisplayCallback() {
                            @Override
                            public void onShow() {
                                //LogUtils.e("腾讯章末广告，展示成功");
                                mBtnWatchVideo.setVisibility(VISIBLE);
                            }

                            @Override
                            public void onFail() {
                                //LogUtils.e("腾讯章末广告，展示失败");
                                mBtnWatchVideo.setVisibility(GONE);
                            }
                        });
                    }
                }).loadListAd();
//                new TTAdNativeDel((Activity) context, flAdContent, isShowShare -> tvShare.setVisibility(isShowShare ? VISIBLE : GONE)).loadBannerAd();
            }
        }
    }

    private void showBaiduAd(int contentLineSize) {
        LogUtils.e("准备展示百度章末广告");
        if (showAd) return;
        if (durPageIndex + 1 != pageAll) {
            return;
        }
        flAdContent.setVisibility(VISIBLE);
        int top = getContentHeight(contentLineSize);

        final Context context = getContext();
        int space = (int) (ScreenUtils.getScreenHeightSize() * 0.6);

        if (ScreenUtils.getScreenHeightSize() - top <= space) {
            showAd = false;
            return;
        } else {

            if (context instanceof FragmentActivity) {
                showAd = true;

                mBaiduBannerAdvDel = new BaiduBannerAdDel(context, flAdContent, isShowShare -> mBtnWatchVideo.setVisibility(isShowShare ? VISIBLE : GONE));
                mBaiduBannerAdvDel.show();
            }
        }
    }

    // 展示末尾广告
    private void showPageEndAd(int contentLineSize, ShowAdType showAdType) {
        if (!ReadPageAdvControllerKt.isReadPageAdvShow()) return;

        if (showAdType == ShowAdType.GDT) {
            showGdtEndAd(contentLineSize);
            return;
        }

        if (showAdType == ShowAdType.TTAD) {
            showTTad(contentLineSize);
            return;
        }

        if (showAdType == ShowAdType.BDAD) {
            showBaiduAd(contentLineSize);
            return;
        }

        if (showAdType == ShowAdType.NONE) {
            return;
        }

//        String native_ad_info = AdsSetting.getInstance().getReadEndAdData();
//
//        if (TextUtils.isEmpty(native_ad_info)) {
//
//            flAdContent.removeAllViews();
//            showAd = false;
//            return;
//        }
//
//        if (contentLineSize >= 10) {
//
//            flAdContent.removeAllViews();
//            showAd = false;
//            return;
//        }
//
//        int top = getContentHeight(contentLineSize);
//
//        int space = (int) (ScreenUtils.getScreenHeightSize() * 0.6);
//
//        if (ScreenUtils.getScreenHeightSize() - top <= space) {
//
//            flAdContent.removeAllViews();
//            showAd = false;
//            return;
//        }
//
//        AdsInfo.AdsInfoItem adsInfoItem = null;
//
//        try {
//            adsInfoItem = new Gson().fromJson(native_ad_info, AdsInfo.AdsInfoItem.class);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        if (adsInfoItem == null) {
//            flAdContent.removeAllViews();
//            showAd = false;
//            return;
//        }
//
//        boolean isShowAd = AdsSetting.getInstance().checkAdshow(adsInfoItem.getAd_show_times_everyday(), adsInfoItem.getAd_show_intv(), 2);
//
//        if (!isShowAd) {
//            showAd = false;
//            flAdContent.removeAllViews();
//            return;
//        }
//
//        String imageUrl = adsInfoItem.getImg();
//
//        String webUrl = adsInfoItem.getLink();
//
//        if (TextUtils.isEmpty(imageUrl)) {
//            flAdContent.removeAllViews();
//            showAd = false;
//            return;
//        }
//
//
//        showAd = true;
//
//        ImageView img = new ImageView(getContext());
//        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
//        GlideExtKt.load(img, imageUrl);
//
//        img.setOnClickListener(v -> {
//
//            ViewParent parent = getParent();
//            if (parent instanceof ContentSwitchView) {
//                ContentSwitchView switchView = (ContentSwitchView) parent;
//
//                if (switchView.getDurContentView() == BookContentView.this) {
//                    WebAdsActivity.Companion.start(getContext(), webUrl);
//                }
//            }
//
//        });
//
////        img.setOnTouchListener(new OnTouchListener() {
////            boolean isCurrent = false;
////            @Override
////            public boolean onTouch(View v, MotionEvent event) {
////                LogUtils.d("onTouch : " + event.getAction());
////                ViewParent parent = BookContentView.this.getParent();
////                if(parent instanceof ContentSwitchView){
////                    ContentSwitchView switchView =  (ContentSwitchView) parent;
////
////                    if(switchView.getDurContentView() == BookContentView.this){
////                        isCurrent = true;
////                    }else{
////                        isCurrent = false;
////                    }
////
////                }
////
////                switch (event.getAction()){
////                    case MotionEvent.ACTION_MOVE:
////                        if(isCurrent){
////                            return false;
////                        }
////                        break;
////                    case MotionEvent.ACTION_DOWN:
////                        if(isCurrent){
////                            return true;
////                        }
////                        break;
////                    case MotionEvent.ACTION_UP:
////
////                        if(isCurrent){
////                            return true;
////                        }
////                        break;
////                }
////                return false;
////            }
////        });
//
//        int height = (int) (ScreenUtils.getScreenHeightSize() * 0.4f);
//
//        FrameLayout.LayoutParams flParams = (LayoutParams) flAdContent.getLayoutParams();
//        flParams.height = height;
//        flParams.setMargins(100, top, 100, 200);
//
//        flAdContent.addView(img, flParams);
//
//        int showTimes = AdsSetting.getInstance().getReadEndShowTimes() + 1;
//
//        AdsSetting.getInstance().setReadEndShowTimes(showTimes);
//        AdsSetting.getInstance().setReadEndAdLastShowDate(System.currentTimeMillis());

    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        super.onVisibilityChanged(changedView, visibility);
        if (visibility == GONE) hideAdv();
    }

    public void setNoData(String contentLines) {
        this.content = contentLines;

        tvPage.setText((this.durPageIndex + 1) + "/" + this.pageAll);

        finishLoading();
    }

    /**
     * 更新这一页的界面
     *
     * @param tag
     * @param title           当前页标题
     * @param contentLines    当前页展示的字符串行
     * @param durChapterIndex 当前页章节索引
     * @param chapterAll      章节总数
     * @param durPageIndex    当前页的索引
     * @param durPageAll      当前章节总页数
     */
    public void updateData(long tag, String title, List<String> contentLines, int durChapterIndex, int chapterAll, int durPageIndex, int durPageAll) {
        if (tag == qTag) {
            if (setDataListener != null) {
                setDataListener.setDataFinish(this, durChapterIndex, chapterAll, durPageIndex, durPageAll, this.durPageIndex);
            }
            if (contentLines == null) {
                this.content = "";
            } else {
                StringBuilder s = new StringBuilder();
                for (int i = 0; i < contentLines.size(); i++) {
                    s.append(contentLines.get(i));
                }
                this.content = s.toString();
            }
            this.title = title;
            this.durChapterIndex = durChapterIndex;
            this.chapterAll = chapterAll;
            this.durPageIndex = durPageIndex;
            this.pageAll = durPageAll;

            tvTitle.setText(this.title);
            tvContent.setText(this.content);
            tvPage.setText((this.durPageIndex + 1) + "/" + this.pageAll);

            finishLoading();
            final int contentlineSize = contentLines.size();
//            postDelayed(() -> showPageEndAd(contentlineSize, AdvController.INSTANCE.invalidateChapterEndAdType()), 1500);


            showPageEndAd(contentlineSize, AdvController.INSTANCE.getSCurrentReadPageBottomAdType());
        }
    }


    public void loadData(String title, int durChapterIndex, int chapterAll, int durPageIndex) {
        this.title = title;
        this.durChapterIndex = durChapterIndex;
        this.chapterAll = chapterAll;
        this.durPageIndex = durPageIndex;
        tvTitle.setText(title);
        tvPage.setText("");

        loading();
    }

    public ContentSwitchView.LoadDataListener getLoadDataListener() {
        return loadDataListener;
    }

    public void setLoadDataListener(ContentSwitchView.LoadDataListener loadDataListener, SetDataListener setDataListener) {
        this.loadDataListener = loadDataListener;
        this.setDataListener = setDataListener;
    }

    public void setLoadDataListener(ContentSwitchView.LoadDataListener loadDataListener) {
        this.loadDataListener = loadDataListener;
    }

    public void loadError() {
        loadError = true;
        llError.setVisibility(VISIBLE);
        tvLoading.setVisibility(GONE);
        llContent.setVisibility(INVISIBLE);

        tvErrorInfo.setText("数据加载异常，请稍后重试");

    }


    public void loadPay() {
        loadError = true;
        llError.setVisibility(VISIBLE);
        tvLoading.setVisibility(GONE);
        llContent.setVisibility(INVISIBLE);
        tvErrorInfo.setText("当前为收费章节，请充值成为会员后观看");
    }

    public int getPageAll() {
        return pageAll;
    }

    public void setPageAll(int pageAll) {
        this.pageAll = pageAll;
    }

    public int getDurPageIndex() {
        return durPageIndex;
    }

    public void setDurPageIndex(int durPageIndex) {
        this.durPageIndex = durPageIndex;
    }

    public int getDurChapterIndex() {
        return durChapterIndex;
    }

    public void setDurChapterIndex(int durChapterIndex) {
        this.durChapterIndex = durChapterIndex;
    }

    public int getChapterAll() {
        return chapterAll;
    }

    public void setChapterAll(int chapterAll) {
        this.chapterAll = chapterAll;
    }

    public SetDataListener getSetDataListener() {
        return setDataListener;
    }

    public void setSetDataListener(SetDataListener setDataListener) {
        this.setDataListener = setDataListener;
    }

    public long getqTag() {
        return qTag;
    }

    public void setqTag(long qTag) {
        this.qTag = qTag;
    }

    public TextView getTvContent() {
        return tvContent;
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    public int getLineCount(int height) {
        float ascent = tvContent.getPaint().ascent();
        float descent = tvContent.getPaint().descent();
        float textHeight = descent - ascent;
        return (int) ((height * 1.0f - tvContent.getLineSpacingExtra()) / (textHeight + tvContent.getLineSpacingExtra()));
    }

    public int getContentHeight(int line) {
        float ascent = tvContent.getPaint().ascent();
        float descent = tvContent.getPaint().descent();
        float textHeight = descent - ascent;

        return line * (int) (textHeight + tvContent.getLineSpacingExtra());
    }

    public void setReadBookControl() {
        setTextKind();
        setBg();
    }

    public void setBg() {
        ivBg.setImageResource(ReadBookConfig.INSTANCE.getTextBackground());
        tvTitle.setTextColor(ReadBookConfig.INSTANCE.getTextColor());
        tvContent.setTextColor(ReadBookConfig.INSTANCE.getTextColor());
        tvPage.setTextColor(ReadBookConfig.INSTANCE.getTextColor());
        vBottom.setBackgroundColor(ReadBookConfig.INSTANCE.getTextColor());
        tvLoading.setTextColor(ReadBookConfig.INSTANCE.getTextColor());
        tvErrorInfo.setTextColor(ReadBookConfig.INSTANCE.getTextColor());
        mBatteryView.setBatteryColor(ReadBookConfig.INSTANCE.getTextColor());
    }

    public void setTextKind() {
        tvContent.setTextSize(ReadBookConfig.INSTANCE.getTextSize());
        tvContent.setLineSpacing(ReadBookConfig.INSTANCE.getTextExtra(), 1);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (mGdtNativeAdvDel != null) {
            mGdtNativeAdvDel.destroy();
        }
        if (mBaiduBannerAdvDel != null) {
            mBaiduBannerAdvDel.onDestroy();
        }
    }
}
