package com.bule.free.ireader.ui.adapter.view;

import android.graphics.Color;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.ui.base.adapter.ViewHolderImpl;

/**
 * Created by newbiechen on 17-5-1.
 */

public class HotKeyHolder extends ViewHolderImpl<String> {

    private TextView tv_hot_key;

    @Override
    protected int getItemLayoutId() {
        return R.layout.item_hot_key;
    }

    @Override
    public void initView() {
        tv_hot_key = findById(R.id.tv_hot_key);
    }

    @Override
    public void onBind(String value, int pos) {
        tv_hot_key.setText(value);
    }
}
