//Copyright (c) 2017. 章钦豪. All rights reserved.
package com.bule.free.ireader.newbook.ui;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.PopupWindow;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.utils.AppExtKt;
import com.bule.free.ireader.newbook.ReadBookConfig;
import com.bule.free.ireader.common.utils.LogUtils;
import com.kyleduo.switchbutton.SwitchButton;

import org.jetbrains.annotations.NotNull;

@Deprecated
public class MoreSettingPop extends PopupWindow implements ReadBookConfig.ModeChangeable {
    private Context mContext;
    private View view;

    private SwitchButton sbKey;
    private SwitchButton sbClick;

    public MoreSettingPop(Context context) {
        super(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        mContext = context;

        view = LayoutInflater.from(mContext).inflate(R.layout.view_pop_moresetting, null);
        this.setContentView(view);
        bindView();
        bindEvent();

        setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.shape_pop_checkaddshelf_bg));
        setFocusable(true);
        setTouchable(true);
        setAnimationStyle(R.style.anim_pop_windowlight);
        changeMode(ReadBookConfig.INSTANCE.getUiMode());
    }

    private void bindEvent() {
        sbKey.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                ReadBookConfig.INSTANCE.setCanKeyTurn(isChecked);
            }
        });
        sbClick.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                ReadBookConfig.INSTANCE.setCanClickTurn(isChecked);
            }
        });
    }

    private void bindView() {
        sbKey = (SwitchButton) view.findViewById(R.id.sb_key);
        sbClick = (SwitchButton) view.findViewById(R.id.sb_click);

        if (ReadBookConfig.INSTANCE.getCanKeyTurn())
            sbKey.setCheckedImmediatelyNoEvent(true);
        else sbKey.setCheckedImmediatelyNoEvent(false);
        if (ReadBookConfig.INSTANCE.getCanClickTurn())
            sbClick.setCheckedImmediatelyNoEvent(true);
        else sbClick.setCheckedImmediatelyNoEvent(false);
    }

    @Override
    public void changeMode(@NotNull ReadBookConfig.UIMode uiMode) {
        view.findViewById(R.id.ll_more_setting_bg).setBackgroundColor(uiMode.getMenuBarBgColor());
    }

    @Override
    public void showAtLocation(View parent, int gravity, int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
        AppExtKt.hideSystemBar(this);
    }
}
