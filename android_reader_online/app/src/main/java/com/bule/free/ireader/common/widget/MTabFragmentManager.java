package com.bule.free.ireader.common.widget;

import android.annotation.SuppressLint;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;

import java.util.List;

import q.rorbin.verticaltablayout.widget.TabView;

public class MTabFragmentManager {
    private FragmentManager mManager;
    private int mContainerResid;
    private List<Fragment> mFragments;
    private MVerticalTabLayout mTabLayout;
    private MVerticalTabLayout.OnTabSelectedListener mListener;

    public MTabFragmentManager(FragmentManager manager, List<Fragment> fragments, MVerticalTabLayout tabLayout) {
        this.mManager = manager;
        this.mFragments = fragments;
        this.mTabLayout = tabLayout;
        mListener = new MTabFragmentManager.OnFragmentTabSelectedListener();
        mTabLayout.addOnTabSelectedListener(mListener);
    }

    public MTabFragmentManager(FragmentManager manager, int containerResid, List<Fragment> fragments, MVerticalTabLayout tabLayout) {
        this(manager, fragments, tabLayout);
        this.mContainerResid = containerResid;
        changeFragment();
    }

    public void changeFragment() {
        FragmentTransaction ft = mManager.beginTransaction();
        int position = mTabLayout.getSelectedTabPosition();
        @SuppressLint("RestrictedApi") List<Fragment> addedFragments = mManager.getFragments();
        for (int i = 0; i < mFragments.size(); i++) {
            Fragment fragment = mFragments.get(i);
            if ((addedFragments == null || !addedFragments.contains(fragment)) && mContainerResid != 0) {
                ft.add(mContainerResid, fragment);
            }
            if ((mFragments.size() > position && i == position)
                    || (mFragments.size() <= position && i == mFragments.size() - 1)) {
                ft.show(fragment);
            } else {
                ft.hide(fragment);
            }
        }
        ft.commitAllowingStateLoss();
//        mManager.executePendingTransactions();
    }

    public void detach() {
        FragmentTransaction ft = mManager.beginTransaction();
        for (Fragment fragment : mFragments) {
            ft.remove(fragment);
        }
        ft.commitAllowingStateLoss();
        mManager.executePendingTransactions();
        mManager = null;
        mFragments = null;
        mTabLayout.removeOnTabSelectedListener(mListener);
        mListener = null;
        mTabLayout = null;
    }


    private class OnFragmentTabSelectedListener implements MVerticalTabLayout.OnTabSelectedListener {

        @Override
        public void onTabSelected(TabView tab, int position) {
            changeFragment();
        }

        @Override
        public void onTabReselected(TabView tab, int position) {

        }
    }
}