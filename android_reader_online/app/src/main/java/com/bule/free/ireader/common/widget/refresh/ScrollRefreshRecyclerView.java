package com.bule.free.ireader.common.widget.refresh;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.common.widget.adapter.WholeAdapter;

/**
 * Created by newbiechen on 17-4-18.
 */

public class ScrollRefreshRecyclerView extends ScrollRefreshLayout {

    private static final String TAG = "RefreshRecyclerView";

    private RecyclerView mRecyclerView;

    private static boolean showLog = true;

    /**************************public method*******************************************/

    public void setLayoutManager(RecyclerView.LayoutManager manager) {
        mRecyclerView.setLayoutManager(manager);
    }

    public void addItemDecoration(RecyclerView.ItemDecoration decoration) {
        mRecyclerView.addItemDecoration(decoration);
    }

    public void setAdapter(RecyclerView.Adapter adapter) {
        mRecyclerView.setAdapter(adapter);
        adapter.registerAdapterDataObserver(new MyAdapterDataObserver());
    }

    /**
     * 刚进入的时候不点击界面，自动刷新
     */
    public void startRefresh() {
        mRecyclerView.post(() -> setRefreshing(true));
    }

    public void finishRefresh() {
        mRecyclerView.post(() -> setRefreshing(false));
    }

    public ScrollRefreshRecyclerView(Context context) {
        super(context);
    }

    public ScrollRefreshRecyclerView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    /*************************init********************************************/
    @Override
    public View getContentView(ViewGroup parent) {
        mRecyclerView = new RecyclerView(getContext());
        return mRecyclerView;
    }

    public RecyclerView getRecyclerView() {
        return mRecyclerView;
    }

    /****************************inner method***********************************************/
    public static void log(String str) {
        if (showLog) {
            Log.d(TAG, str);
        }
    }

    /**************************inner class ************************************/
    class MyAdapterDataObserver extends RecyclerView.AdapterDataObserver {
        @Override
        public void onChanged() {
            super.onChanged();
            update();
        }

        @Override
        public void onItemRangeChanged(int positionStart, int itemCount) {
            super.onItemRangeChanged(positionStart, itemCount);
            update();
        }

        @Override
        public void onItemRangeChanged(int positionStart, int itemCount, Object payload) {
            super.onItemRangeChanged(positionStart, itemCount, payload);
            update();
        }

        @Override
        public void onItemRangeInserted(int positionStart, int itemCount) {
            super.onItemRangeInserted(positionStart, itemCount);
            update();
        }

        @Override
        public void onItemRangeRemoved(int positionStart, int itemCount) {
            super.onItemRangeRemoved(positionStart, itemCount);
            update();
        }

        @Override
        public void onItemRangeMoved(int fromPosition, int toPosition, int itemCount) {
            super.onItemRangeMoved(fromPosition, toPosition, itemCount);
            update();
        }

        private void update() {
            int count = mRecyclerView.getAdapter().getItemCount();
            if (count == 0) {
                showEmptyView();
                mRecyclerView.setVisibility(GONE);
            } else if (count == 1) {
                LogUtils.d("mRecyclerView.getAdapter().getItemViewType(0) : " + mRecyclerView.getAdapter().getItemViewType(0));
                if (mRecyclerView.getAdapter() instanceof WholeAdapter) {
                    WholeAdapter mAdapter = (WholeAdapter) mRecyclerView.getAdapter();
                    if (mAdapter.mLoadDelegate != null && mAdapter.getItemViewType(0) != 0) {
                        showEmptyView();
                        mRecyclerView.setVisibility(GONE);
                    } else {
                        hideEmptyView();
                        mRecyclerView.setVisibility(VISIBLE);
                    }
                } else {
                    hideEmptyView();
                    mRecyclerView.setVisibility(VISIBLE);
                }
            } else if (mRecyclerView.getVisibility() == GONE) {
                hideEmptyView();
                mRecyclerView.setVisibility(VISIBLE);
            }
        }
    }
}
