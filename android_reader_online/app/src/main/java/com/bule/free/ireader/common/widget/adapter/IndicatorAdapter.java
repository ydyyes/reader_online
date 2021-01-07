package com.bule.free.ireader.common.widget.adapter;

import android.content.Context;
import android.view.View;

/**
 * Created by liumin on 2018/12/11.
 */

public interface IndicatorAdapter {
    View getTabView(Context context, int position);

    /*tabview的数量，如果绑定了ViewPager，则tab数量默认和ViewPager数据量保持一致*/
    int getTabCount();

    /**
     * 当page在互动的过程中，可以联动indicator
     *
     * @param tabView       是当前的tabView
     * @param position      是当前的tabView对应的索引
     * @param selectPercent 是当前的tabView在正常状态下，任何属性需要改变的百分比
     */
    void onTabChange(View tabView, int position, float selectPercent);
}
