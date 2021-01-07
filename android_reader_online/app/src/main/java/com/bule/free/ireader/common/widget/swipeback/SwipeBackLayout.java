package com.bule.free.ireader.common.widget.swipeback;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.support.annotation.IntDef;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.ViewCompat;
import android.support.v4.widget.ViewDragHelper;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.bule.free.ireader.R;
import com.luck.picture.lib.tools.ScreenUtils;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;


/**
 * Thx https://github.com/ikew0ng/SwipeBackLayout
 * SwipeBackLayout
 * Created by YoKeyword on 16/4/19.
 */
public class SwipeBackLayout extends FrameLayout {
    /**
     * Edge flag indicating that the left edge should be affected.
     */
    public static final int EDGE_LEFT = ViewDragHelper.EDGE_LEFT;

    /**
     * Edge flag indicating that the right edge should be affected.
     */
    public static final int EDGE_RIGHT = ViewDragHelper.EDGE_RIGHT;

    public static final int EDGE_ALL = EDGE_LEFT | EDGE_RIGHT;


    /**
     * A view is not currently being dragged or animating as a result of a
     * fling/snap.
     */
    public static final int STATE_IDLE = ViewDragHelper.STATE_IDLE;

    /**
     * A view is currently being dragged. The position is currently changing as
     * a result of user input or simulated user input.
     */
    public static final int STATE_DRAGGING = ViewDragHelper.STATE_DRAGGING;

    /**
     * A view is currently settling into place as a result of a fling or
     * predefined non-interactive motion.
     */
    public static final int STATE_SETTLING = ViewDragHelper.STATE_SETTLING;

    private static final int DEFAULT_SCRIM_COLOR = 0x99000000;
    private static final int FULL_ALPHA = 255;
    private static final float DEFAULT_SCROLL_THRESHOLD = 0.4f;
    private static final int OVERSCROLL_DISTANCE = 10;

    private float mScrollFinishThreshold = DEFAULT_SCROLL_THRESHOLD;

    private ViewDragHelper mViewDragHelper;

    private float mScrollPercent;
    private float mScrimOpacity;

    private FragmentActivity mActivity;
    private View mContentView;
    private SwipeBackFragment mFragment;
    private Fragment mPreFragment;

    private Drawable mShadowLeft;
    private Drawable mShadowRight;
    private Rect mTmpRect = new Rect();

    private int mEdgeFlag;
    private boolean mEnable = true;
    private int mCurrentSwipeOrientation;

    private Context context;
    private EdgeLevel edgeLevel;

    public enum EdgeLevel {
        MAX, MIN, MED
    }

    /**
     * The set of listeners to be sent events through.
     */
    private List<OnSwipeListener> mListeners;

    public SwipeBackLayout(Context context) {
        this(context, null);
    }

    public SwipeBackLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SwipeBackLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        init();
    }

    private void init() {
        mViewDragHelper = ViewDragHelper.create(this, new ViewDragCallback());
        setShadow(R.drawable.shadow_left, EDGE_LEFT);
//        setEdgeOrientation(EDGE_ALL);
    }

    /**
     * Set scroll threshold, we will close the activity, when scrollPercent over
     * this value
     *
     * @param threshold
     */
    public void setScrollThresHold(float threshold) {
        if (threshold >= 1.0f || threshold <= 0) {
            throw new IllegalArgumentException("Threshold value should be between 0 and 1.0");
        }
        mScrollFinishThreshold = threshold;
    }

    /**
     * Enable edge tracking for the selected edges of the parent view.
     * The callback's {@link ViewDragHelper.Callback#onEdgeTouched(int, int)} and
     * {@link ViewDragHelper.Callback#onEdgeDragStarted(int, int)} methods will only be invoked
     * for edges for which edge tracking has been enabled.
     *
     * @param orientation Combination of edge flags describing the edges to watch
     * @see #EDGE_LEFT
     * @see #EDGE_RIGHT
     */
    public void setEdgeOrientation(int orientation) {
        mEdgeFlag = orientation;
        mViewDragHelper.setEdgeTrackingEnabled(orientation);

        if (orientation == EDGE_RIGHT || orientation == EDGE_ALL) {
            setShadow(R.drawable.shadow_right, EDGE_RIGHT);
        }
    }

    public void setEdgeLevel(EdgeLevel edgeLevel) {
        this.edgeLevel = edgeLevel;
        validateEdgeLevel(0, edgeLevel);
    }

    public void setEdgeLevel(int widthPixel) {
        validateEdgeLevel(widthPixel, null);
    }

    public EdgeLevel getEdgeLevel() {
        return edgeLevel;
    }

    private void validateEdgeLevel(int widthPixel, EdgeLevel edgeLevel) {
        try {
            DisplayMetrics metrics = new DisplayMetrics();
            WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            windowManager.getDefaultDisplay().getMetrics(metrics);
            Field mEdgeSize = mViewDragHelper.getClass().getDeclaredField("mEdgeSize");
            mEdgeSize.setAccessible(true);
            if (widthPixel != 0) {
                mEdgeSize.setInt(mViewDragHelper, widthPixel);
            } else {
                if (edgeLevel == EdgeLevel.MAX) {
                    mEdgeSize.setInt(mViewDragHelper, metrics.widthPixels);
                } else if (edgeLevel == EdgeLevel.MED) {
                    mEdgeSize.setInt(mViewDragHelper, metrics.widthPixels / 2);
                } else if (edgeLevel == EdgeLevel.MIN) {
                    mEdgeSize.setInt(mViewDragHelper, ((int) (20 * metrics.density + 0.5f)));
                }
            }
        } catch (NoSuchFieldException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
    }

    @IntDef({EDGE_LEFT, EDGE_RIGHT, EDGE_ALL})
    @Retention(RetentionPolicy.SOURCE)
    public @interface EdgeOrientation {
    }

    /**
     * Set a drawable used for edge shadow.
     */
    public void setShadow(Drawable shadow, int edgeFlag) {
        if ((edgeFlag & EDGE_LEFT) != 0) {
            mShadowLeft = shadow;
        } else if ((edgeFlag & EDGE_RIGHT) != 0) {
            mShadowRight = shadow;
        }
        invalidate();
    }

    /**
     * Set a drawable used for edge shadow.
     */
    public void setShadow(int resId, int edgeFlag) {
        setShadow(getResources().getDrawable(resId), edgeFlag);
    }

    /**
     * Add a callback to be invoked when a swipe event is sent to this view.
     *
     * @param listener the swipe listener to attach to this view
     */
    public void addSwipeListener(OnSwipeListener listener) {
        if (mListeners == null) {
            mListeners = new ArrayList<>();
        }
        mListeners.add(listener);
    }

    /**
     * Removes a listener from the set of listeners
     *
     * @param listener
     */
    public void removeSwipeListener(OnSwipeListener listener) {
        if (mListeners == null) {
            return;
        }
        mListeners.remove(listener);
    }

    public interface OnSwipeListener {
        /**
         * Invoke when state change
         *
         * @param state flag to describe scroll state
         * @see #STATE_IDLE
         * @see #STATE_DRAGGING
         * @see #STATE_SETTLING
         */
        void onDragStateChange(int state);

        /**
         * Invoke when edge touched
         *
         * @param oritentationEdgeFlag edge flag describing the edge being touched
         * @see #EDGE_LEFT
         * @see #EDGE_RIGHT
         */
        void onEdgeTouch(int oritentationEdgeFlag);

        /**
         * Invoke when scroll percent over the threshold for the first time
         *
         * @param scrollPercent scroll percent of this view
         */
        void onDragScrolled(float scrollPercent);


        void onDismiss();
    }

    @Override
    protected boolean drawChild(Canvas canvas, View child, long drawingTime) {
        boolean isDrawView = child == mContentView;
        boolean drawChild = super.drawChild(canvas, child, drawingTime);
        if (isDrawView && mScrimOpacity > 0 && mViewDragHelper.getViewDragState() != ViewDragHelper.STATE_IDLE) {
            drawShadow(canvas, child);
            drawScrim(canvas, child);
        }
        return drawChild;
    }

    private void drawShadow(Canvas canvas, View child) {
        final Rect childRect = mTmpRect;
        child.getHitRect(childRect);

        if ((mCurrentSwipeOrientation & EDGE_LEFT) != 0) {
            mShadowLeft.setBounds(childRect.left - mShadowLeft.getIntrinsicWidth(), childRect.top, childRect.left, childRect.bottom);
            mShadowLeft.setAlpha((int) (mScrimOpacity * FULL_ALPHA));
            mShadowLeft.draw(canvas);
        } else if ((mCurrentSwipeOrientation & EDGE_RIGHT) != 0) {
            mShadowRight.setBounds(childRect.right, childRect.top, childRect.right + mShadowRight.getIntrinsicWidth(), childRect.bottom);
            mShadowRight.setAlpha((int) (mScrimOpacity * FULL_ALPHA));
            mShadowRight.draw(canvas);
        }
    }

    private void drawScrim(Canvas canvas, View child) {
        final int baseAlpha = (DEFAULT_SCRIM_COLOR & 0xff000000) >>> 24;
        final int alpha = (int) (baseAlpha * mScrimOpacity);
        final int color = alpha << 24;

        if ((mCurrentSwipeOrientation & EDGE_LEFT) != 0) {
            canvas.clipRect(0, 0, child.getLeft(), getHeight());
        } else if ((mCurrentSwipeOrientation & EDGE_RIGHT) != 0) {
            canvas.clipRect(child.getRight(), 0, getRight(), getHeight());
        }
        canvas.drawColor(color);
    }

    @Override
    public void computeScroll() {
        mScrimOpacity = 1 - mScrollPercent;
        if (mScrimOpacity >= 0) {
            if (mViewDragHelper.continueSettling(true)) {
                ViewCompat.postInvalidateOnAnimation(this);
            }
        }
    }

    public void setFragment(SwipeBackFragment fragment, View view) {
        this.mFragment = fragment;
        mContentView = view;
    }

    public void hiddenFragment() {
        if (mPreFragment != null && mPreFragment.getView() != null) {
            mPreFragment.getView().setVisibility(GONE);
        }
    }

    public void attachToActivity(FragmentActivity activity) {
        mActivity = activity;
        TypedArray a = activity.getTheme().obtainStyledAttributes(new int[]{
                android.R.attr.windowBackground
        });
        int background = a.getResourceId(0, 0);
        a.recycle();

        ViewGroup decor = (ViewGroup) activity.getWindow().getDecorView();
        ViewGroup decorChild = (ViewGroup) decor.getChildAt(0);
        decorChild.setBackgroundResource(background);
        decor.removeView(decorChild);
        addView(decorChild);
        setContentView(decorChild);
        decor.addView(this);
    }

    public void attachToFragment(SwipeBackFragment swipeBackFragment, View view) {
        addView(view);
        setFragment(swipeBackFragment, view);
    }

    private void setContentView(View view) {
        mContentView = view;
    }

    public void setEnableGesture(boolean enable) {
        mEnable = enable;
    }

    private int mTrackingEdge;

    class ViewDragCallback extends ViewDragHelper.Callback {

        @Override
        public boolean tryCaptureView(View child, int pointerId) {
            boolean dragEnable = mViewDragHelper.isEdgeTouched(mEdgeFlag, pointerId);
            if (dragEnable) {
                if (mViewDragHelper.isEdgeTouched(EDGE_LEFT, pointerId)) {
                    mTrackingEdge = EDGE_LEFT;
                } else if (mViewDragHelper.isEdgeTouched(EDGE_RIGHT, pointerId)) {
                    mTrackingEdge = EDGE_RIGHT;
                }
            }
//            if (dragEnable) {
//                if (mViewDragHelper.isEdgeTouched(EDGE_LEFT, pointerId)) {
//                    mCurrentSwipeOrientation = EDGE_LEFT;
//                } else if (mViewDragHelper.isEdgeTouched(EDGE_RIGHT, pointerId)) {
//                    mCurrentSwipeOrientation = EDGE_RIGHT;
//                }
//
//                if (mListeners != null && !mListeners.isEmpty()) {
//                    for (OnSwipeListener listener : mListeners) {
//                        listener.onEdgeTouch(mCurrentSwipeOrientation);
//                    }
//                }
//
//                if (mPreFragment == null) {
//                    if (mFragment != null) {
//                        List<Fragment> fragmentList = mFragment.getFragmentManager().getFragments();
//                        if (fragmentList != null && fragmentList.size() > 1) {
//                            int index = fragmentList.indexOf(mFragment);
//                            for (int i = index - 1; i >= 0; i--) {
//                                Fragment fragment = fragmentList.get(i);
//                                if (fragment != null && fragment.getView() != null) {
//                                    fragment.getView().setVisibility(VISIBLE);
//                                    mPreFragment = fragment;
//                                    break;
//                                }
//                            }
//                        }
//                    }
//                } else {
//                    View preView = mPreFragment.getView();
//                    if (preView != null && preView.getVisibility() != VISIBLE) {
//                        preView.setVisibility(VISIBLE);
//                    }
//                }
//            }
            return true;
        }

        @Override
        public int clampViewPositionHorizontal(View child, int left, int dx) {
            int ret = 0;
            if ((mTrackingEdge & EDGE_LEFT) != 0) {
                ret = Math.min(child.getWidth(), Math.max(left, 0));
            } else if ((mTrackingEdge & EDGE_RIGHT) != 0) {
                ret = Math.min(0, Math.max(left, -child.getWidth()));
            }
            return left;
        }

        @Override
        public void onEdgeDragStarted(int edgeFlags, int pointerId) {
            super.onEdgeDragStarted(edgeFlags, pointerId);
            mViewDragHelper.captureChildView(mContentView, pointerId);
        }

        @Override
        public void onViewPositionChanged(View changedView, int left, int top, int dx, int dy) {
            super.onViewPositionChanged(changedView, left, top, dx, dy);
            if ((mCurrentSwipeOrientation & EDGE_LEFT) != 0) {
                mScrollPercent = Math.abs((float) left / (getWidth() + mShadowLeft.getIntrinsicWidth()));
            } else if ((mCurrentSwipeOrientation & EDGE_RIGHT) != 0) {
                mScrollPercent = Math.abs((float) left / (mContentView.getWidth() + mShadowRight.getIntrinsicWidth()));
            }
            invalidate();

            if (mListeners != null && !mListeners.isEmpty()
                    && mViewDragHelper.getViewDragState() == STATE_DRAGGING && mScrollPercent <= 1 && mScrollPercent > 0) {
                for (OnSwipeListener listener : mListeners) {
                    listener.onDragScrolled(mScrollPercent);
                }
            }

            if (mScrollPercent > 1) {
                if (mFragment != null) {
                    if (mPreFragment instanceof SwipeBackFragment) {
                        ((SwipeBackFragment) mPreFragment).mLocking = true;
                    }
                    if (!mFragment.isDetached()) {
                        mFragment.mLocking = true;
                        mFragment.getFragmentManager().popBackStackImmediate();
                        mFragment.mLocking = false;
                    }
                    if (mPreFragment instanceof SwipeBackFragment) {
                        ((SwipeBackFragment) mPreFragment).mLocking = false;
                    }
                } else {
                    if (!mActivity.isFinishing()) {
                        mActivity.finish();
                        mActivity.overridePendingTransition(0, 0);
                    }
                }
            }
        }

        @Override
        public int getViewHorizontalDragRange(View child) {
            if (mFragment != null) {
                return 1;
            } else if (mActivity != null && ((SwipeBackActivity) mActivity).swipeBackPriority()) {
                return 1;
            }

            return 0;
        }

        @Override
        public void onViewReleased(View releasedChild, float xvel, float yvel) {
            final int childWidth = releasedChild.getWidth();

            int left = 0, top = 0;
            if (DIRECTION_TO_LEFT == dragDirection) {

                left = xvel > 0 || xvel == 0 && mScrollPercent > mScrollFinishThreshold ? (childWidth
                        + mShadowLeft.getIntrinsicWidth() + OVERSCROLL_DISTANCE) : 0;
            } else if (DIRECTION_TO_RIGHT == dragDirection) {
                left = xvel < 0 || xvel == 0 && mScrollPercent > mScrollFinishThreshold ? -(childWidth
                        + mShadowRight.getIntrinsicWidth() + OVERSCROLL_DISTANCE) : 0;
            }

//            if ((mTrackingEdge & EDGE_LEFT) != 0) {
//                left = xvel > 0 || xvel == 0 && mScrollPercent > mScrollFinishThreshold ? (childWidth
//                        + mShadowLeft.getIntrinsicWidth() + OVERSCROLL_DISTANCE) : 0;
//            } else if ((mTrackingEdge & EDGE_RIGHT) != 0) {
//                left = xvel < 0 || xvel == 0 && mScrollPercent > mScrollFinishThreshold ? -(childWidth
//                        + mShadowRight.getIntrinsicWidth() + OVERSCROLL_DISTANCE) : 0;
//            }

            mViewDragHelper.settleCapturedViewAt(left, top);
            invalidate();

            /**
             * 如果 left = 0，则是复位。否则执行动画消失。所以这里通过left 是否为 0 判断。
             */
            if (left != 0) {
                onDismiss();
            }
        }

        @Override
        public void onViewDragStateChanged(int state) {
            super.onViewDragStateChanged(state);
            if (mListeners != null && !mListeners.isEmpty()) {
                for (OnSwipeListener listener : mListeners) {
                    listener.onDragStateChange(state);
                }
            }
        }

        @Override
        public void onEdgeTouched(int edgeFlags, int pointerId) {
            super.onEdgeTouched(edgeFlags, pointerId);
            if ((mEdgeFlag & edgeFlags) != 0) {
                mCurrentSwipeOrientation = edgeFlags;
            }
        }

    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        if (!mEnable) return super.onInterceptTouchEvent(ev);
        return mViewDragHelper.shouldInterceptTouchEvent(ev);
    }

    int dragDirection;
    public static final int DIRECTION_NONE = -1;
    public static final int DIRECTION_TO_RIGHT = 1;
    public static final int DIRECTION_TO_LEFT = 2;

    long actionDownTimestamp;
    float actionDownX;
    float actionDownY;

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (!mEnable) return super.onTouchEvent(event);
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                actionDownTimestamp = System.currentTimeMillis();
                actionDownX = event.getRawX();
                actionDownY = event.getRawY();
                if (actionDownX > ScreenUtils.getScreenWidth(getContext()) / 2) {
                    dragDirection = DIRECTION_TO_RIGHT;
                } else if (actionDownX < ScreenUtils.getScreenWidth(getContext()) / 2) {
                    dragDirection = DIRECTION_TO_LEFT;
                }
                break;
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                long actionUpTimestamp = System.currentTimeMillis();
                float actonUpX = event.getRawX();
                float actonUpY = event.getRawY();
                if (Math.abs(actonUpX - actionDownX) < 10 && Math.abs(actonUpY - actionDownY) < 10) {
                    if (actionUpTimestamp - actionDownTimestamp < 1000) {
                        click();
                    }
                }
                break;
        }
        mViewDragHelper.processTouchEvent(event);
        return true;
    }

    private void click() {
        if (dragDirection == DIRECTION_TO_LEFT) {
            int left = (mContentView.getMeasuredWidth()
                    + mShadowLeft.getIntrinsicWidth() + OVERSCROLL_DISTANCE);
            mViewDragHelper.smoothSlideViewTo(mContentView, left, 0);
            invalidate();
            onDismiss();
        } else if (dragDirection == DIRECTION_TO_RIGHT) {

            int left = -(mContentView.getMeasuredWidth()
                    + mShadowRight.getIntrinsicWidth() + OVERSCROLL_DISTANCE);
            mViewDragHelper.smoothSlideViewTo(mContentView, left, 0);
            invalidate();
            onDismiss();

        }
    }

    private void onDismiss() {
        postDelayed(new Runnable() {
            @Override
            public void run() {

                if (mListeners != null) {
                    for (OnSwipeListener listener : mListeners) {
                        listener.onDismiss();
                    }
                }
            }
        }, 300);
    }
}