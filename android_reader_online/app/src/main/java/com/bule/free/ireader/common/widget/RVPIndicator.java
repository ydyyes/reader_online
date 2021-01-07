package com.bule.free.ireader.common.widget;

/**
 * Created by liumin on 2018/12/11.
 */


import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.NinePatchDrawable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;


import com.bule.free.ireader.R;
import com.bule.free.ireader.common.widget.adapter.IndicatorAdapter;

import java.util.List;


/**
 * Created by Administrator on 2016/8/4.
 */
public class RVPIndicator extends LinearLayout {

    // 指示器风格-图标
    private static final int STYLE_BITMAP = 0;
    // 指示器风格-下划线
    private static final int STYLE_LINE = 1;
    // 指示器风格-方形背景
    private static final int STYLE_SQUARE = 2;
    // 指示器风格-三角形
    private static final int STYLE_TRIANGLE = 3;

    /*
     * 系统默认:Tab数量
     */
    private static final int D_TAB_COUNT = 3;

    /*
     * 系统默认:文字正常时颜色
     */
    private static final int D_TEXT_COLOR_NORMAL = Color.parseColor("#000000");

    /*
     * 系统默认:文字选中时颜色
     */
    private static final int D_TEXT_COLOR_HIGHLIGHT = Color
            .parseColor("#FF0000");

    /*
     * 系统默认:指示器颜色
     */
    private static final int D_INDICATOR_COLOR = Color.parseColor("#f29b76");

    /**
     * tab上的内容
     */
    private List<Tab> mTabTitles;

    /**
     * 可见tab数量
     */
    private int mTabVisibleCount = D_TAB_COUNT;

    /**
     * 与之绑定的ViewPager
     */
    public ViewPager mViewPager;

    /**
     * 文字大小
     */
    private int mTextSize = 16;

    /**
     * 文字正常时的颜色
     */
    private int mTextColorNormal = D_TEXT_COLOR_NORMAL;

    /**
     * 文字选中时的颜色
     */
    private int mTextColorHighlight = D_TEXT_COLOR_HIGHLIGHT;

    /**
     * 指示器正常时的颜色
     */
    private int mIndicatorColor = D_INDICATOR_COLOR;

    /**
     * 画笔
     */
    private Paint mPaint;

    /**
     * 矩形
     */
    private Rect mRectF;

    /**
     * bitmap
     */
    private Bitmap mBitmap;

    /**
     * 指示器高
     */
    private int mIndicatorHeight = 5;

    /**
     * 指示器宽
     */
    private int mIndicatorWidth = getWidth() / mTabVisibleCount;

    /**
     * 三角形的宽度为单个Tab的1/6
     */
    private static final float RADIO_TRIANGEL = 1.0f / 6;

    /**
     * 手指滑动时的偏移量
     */
    private float mTranslationX;

    /**
     * 指示器风格
     */
    private int mIndicatorStyle = STYLE_LINE;

    /**
     * 曲线path
     */
    private Path mPath;

    /**
     * viewPage初始下标
     */
    private int mPosition = 0;

    public RVPIndicator(Context context) {
        this(context, null);
    }

    public RVPIndicator(Context context, AttributeSet attrs) {
        super(context, attrs);
        // 获得自定义属性
        TypedArray a = context.obtainStyledAttributes(attrs,
                R.styleable.RVPIndicator);

        mTabVisibleCount = a.getInt(R.styleable.RVPIndicator_item_count,
                D_TAB_COUNT);
        mTextColorNormal = a
                .getColor(R.styleable.RVPIndicator_text_color_normal,
                        D_TEXT_COLOR_NORMAL);
        mTextColorHighlight = a.getColor(
                R.styleable.RVPIndicator_text_color_hightlight,
                D_TEXT_COLOR_HIGHLIGHT);
        mTextSize = a.getDimensionPixelSize(R.styleable.RVPIndicator_text_size,
                16);
        mIndicatorColor = a.getColor(R.styleable.RVPIndicator_indicator_color,
                D_INDICATOR_COLOR);
        mIndicatorStyle = a.getInt(R.styleable.RVPIndicator_indicator_style,
                STYLE_LINE);

        Drawable drawable = a
                .getDrawable(R.styleable.RVPIndicator_indicator_src);

        if (drawable != null) {
            if (drawable instanceof BitmapDrawable) {
                mBitmap = ((BitmapDrawable) drawable).getBitmap();
            } else if (drawable instanceof NinePatchDrawable) {
                // .9图处理
                Bitmap bitmap = Bitmap.createBitmap(
                        drawable.getIntrinsicWidth(),
                        drawable.getIntrinsicHeight(), Config.ARGB_8888);
                Canvas canvas = new Canvas(bitmap);
                drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
                drawable.draw(canvas);
                mBitmap = bitmap;

            }
        } else {
//            mBitmap = BitmapFactory.decodeResource(getResources(),
//                    R.drawable.heart_love);
        }

        a.recycle();

        /**
         * 设置画笔
         */
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setColor(mIndicatorColor);
        mPaint.setStyle(Style.FILL);

    }

    /**
     * 初始化指示器
     */
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        switch (mIndicatorStyle) {

            case STYLE_LINE:

			/*
			 * 下划线指示器:宽与item相等,高是item的1/10
			 */
                mIndicatorWidth = w / mTabVisibleCount;
                mIndicatorHeight = h / 10;
                mTranslationX = 0;
                mRectF = new Rect(0, 0, mIndicatorWidth, mIndicatorHeight);

                break;
            case STYLE_SQUARE:
            case STYLE_BITMAP:

			/*
			 * 方形/图标指示器:宽,高与item相等
			 */
                mIndicatorWidth = w / mTabVisibleCount;
                mIndicatorHeight = h;
                mTranslationX = 0;
                mRectF = new Rect(0, 0, mIndicatorWidth, mIndicatorHeight);

                break;
            case STYLE_TRIANGLE:

			/*
			 * 三角形指示器:宽与item(1/4)相等,高是item的1/4
			 */
                //mIndicatorWidth = w / mTabVisibleCount / 4;
                // mIndicatorHeight = h / 4;
                mIndicatorWidth = (int) (w / mTabVisibleCount * RADIO_TRIANGEL);// 1/6 of  width  ;
                mIndicatorHeight = (int) (mIndicatorWidth / 2 / Math.sqrt(2));
                mTranslationX = 0;

                break;
        }
        // 初始化tabItem
        initTabItem();

        // 高亮
        setHighLightTextView(mPosition);
    }

    /**
     * 绘制指示器(子view)
     */
    @Override
    protected void dispatchDraw(Canvas canvas) {
        super.dispatchDraw(canvas);
    }

    /**
     * 设置tab上的内容
     *
     * @param datas
     */
    public void setTabItemTitles(List<Tab> datas) {
        this.mTabTitles = datas;
    }

    /**
     * 设置关联viewPager
     *
     * @param viewPager
     * @param pos
     */
    @SuppressWarnings("deprecation")
    public void setViewPager(ViewPager viewPager, int pos) {
        this.mViewPager = viewPager;

        mViewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {

            @Override
            public void onPageSelected(int position) {
                // 设置文本高亮
                setHighLightTextView(position);

                // 回调
                if (onPageChangeListener != null) {
                    onPageChangeListener.onPageSelected(position);
                }
            }

            @Override
            public void onPageScrolled(int position, float positionOffset,
                                       int positionOffsetPixels) {

                // scoll
                onScoll(position, positionOffset);

                // 回调
                if (onPageChangeListener != null) {
                    onPageChangeListener.onPageScrolled(position,
                            positionOffset, positionOffsetPixels);
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {
                // 回调
                if (onPageChangeListener != null) {
                    onPageChangeListener.onPageScrollStateChanged(state);
                }
            }
        });

        // 设置当前页
    }

    public void setCurrentItem(int pos) {
        mPosition = pos;
        mViewPager.setCurrentItem(pos);
        if(mViewPager.getCurrentItem() == pos) {
            setHighLightTextView(pos);
        }
    }

    /**
     *
     * 初始化tabItem
     *
     * @author Ruffian
     */
    private void initTabItem() {

        if (mTabTitles != null && mTabTitles.size() > 0) {
            if (this.getChildCount() != 0) {
                this.removeAllViews();
            }

            // 设置点击事件
            setItemClickEvent();
        }

    }

    /**
     * 设置点击事件
     */
    private void setItemClickEvent() {
        int cCount = getChildCount();
        for (int i = 0; i < cCount; i++) {
            final int j = i;
            View view = getChildAt(i);
            view.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    mViewPager.setCurrentItem(j);
                }
            });
        }
    }



    /**
     * 设置文本高亮
     *
     * @param position
     */
    private void setHighLightTextView(int position) {

        for (int i = 0; i < getChildCount(); i++) {
            View view = getChildAt(i);
            View tabIcon = view.findViewById(R.id.tab_icon);
            View tabTitle = view.findViewById(R.id.tab_title);
            if(i == position) {
                if(tabIcon != null && tabIcon.getVisibility() == View.VISIBLE) {
                    tabIcon.setSelected(true);
                }
                if(tabTitle != null) {
                    tabTitle.setSelected(true);
                }
            } else {
                if(tabIcon != null && tabIcon.getVisibility() == View.VISIBLE) {
                    tabIcon.setSelected(false);
                }
                if(tabTitle != null) {
                    tabTitle.setSelected(false);
                }
            }
        }
    }

    /**
     * 滚动
     *
     * @param position
     * @param offset
     */
    private void onScoll(int position, float offset) {

        // 不断改变偏移量，invalidate
        mTranslationX = getWidth() / mTabVisibleCount * (position + offset);

        int tabWidth = getWidth() / mTabVisibleCount;

        // 容器滚动，当移动到倒数第二个的时候，开始滚动
        if (offset > 0 && position >= (mTabVisibleCount - 2)
                && getChildCount() > mTabVisibleCount
                && position < (getChildCount() - 2)) {
            if (mTabVisibleCount != 1) {

                int xValue = (position - (mTabVisibleCount - 2)) * tabWidth
                        + (int) (tabWidth * offset);
                this.scrollTo(xValue, 0);

            } else {
                // 为count为1时 的特殊处理
                this.scrollTo(position * tabWidth + (int) (tabWidth * offset),
                        0);
            }
        }

        invalidate();
    }

    /**
     * 对外的ViewPager的回调接口
     *
     * @author Ruffian
     *
     */
    public interface PageChangeListener {
        void onPageScrolled(int position, float positionOffset,
                            int positionOffsetPixels);

        void onPageSelected(int position);

        void onPageScrollStateChanged(int state);
    }

    // 对外的ViewPager的回调接口
    private PageChangeListener onPageChangeListener;

    // 对外的ViewPager的回调接口的设置
    public void setOnPageChangeListener(PageChangeListener pageChangeListener) {
        this.onPageChangeListener = pageChangeListener;
    }

    IndicatorAdapter mIndicatorAdapter;
    int mTabCount;
    public void setIndicatorAdapter(IndicatorAdapter adapter){
        mIndicatorAdapter = adapter;
        updateIndicator();
    }

    private void updateIndicator(){
        if(mIndicatorAdapter == null) {
            return;
        }

        if(mViewPager == null) {
            throw new NullPointerException("You must set a ViewPager first");
        }
        mTabCount = mIndicatorAdapter.getTabCount();
        PagerAdapter adapter = mViewPager.getAdapter();
        if(adapter == null) {
            throw new NullPointerException("ViewPager adapter is null");
        }


        if(mTabCount != adapter.getCount()) {
            mTabCount = adapter.getCount();
        }

        this.setWeightSum(mTabCount);

        if(getChildCount() > 0) {
            removeAllViews();
        }
        for (int i = 0;i < mTabCount; i++) {
            LinearLayout tabView = (LinearLayout) mIndicatorAdapter.getTabView(getContext(), i);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
            lp.width = getWidth() / mTabVisibleCount;
            lp.weight = 1;
            tabView.setLayoutParams(lp);
            tabView.setGravity(Gravity.CENTER);

            addView(tabView);
        }

        setItemClickEvent();
    }

    public static class Tab {
        public Tab(String title, int iconResId){
            this.title = title;
            this.iconResId = iconResId;
        }
        public String title;
        public int iconResId;
    }

}