//Copyright (c) 2017. 章钦豪. All rights reserved.
package com.bule.free.ireader.newbook.ui;

import android.content.Context;
import android.graphics.Color;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.utils.AppExtKt;
import com.bule.free.ireader.newbook.ReadBookConfig;

import org.jetbrains.annotations.NotNull;

import de.hdodenhof.circleimageview.CircleImageView;

@Deprecated
public class FontPop extends PopupWindow implements ReadBookConfig.ModeChangeable {
    private Context mContext;
    private View view;
    private FrameLayout flSmaller;
    private FrameLayout flBigger;
    private TextView tvTextSizedDefault;
    private TextView tvTextSize;
    private CircleImageView civBgWhite;
    private CircleImageView civBgYellow;
    private CircleImageView civBgGreen;
    private CircleImageView civBgBlack;
    private LinearLayout llFontMenuBg;
    private OnChangeProListener changeProListener;

    public interface OnChangeProListener {
        void textChange(int index);

        void bgChange(int index);
    }

    public FontPop(Context context, @NonNull OnChangeProListener changeProListener) {
        super(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        this.mContext = context;
        this.changeProListener = changeProListener;

        view = LayoutInflater.from(mContext).inflate(R.layout.view_pop_font, null);
        this.setContentView(view);
        bindView();
        bindEvent();

        setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.shape_pop_checkaddshelf_bg));
        setFocusable(true);
        setTouchable(true);
        setAnimationStyle(R.style.anim_pop_windowlight);
    }

    private void bindEvent() {
        flSmaller.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateText(ReadBookConfig.INSTANCE.getTextKindIndex() - 1);
                changeProListener.textChange(ReadBookConfig.INSTANCE.getTextKindIndex());
            }
        });
        flBigger.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateText(ReadBookConfig.INSTANCE.getTextKindIndex() + 1);
                changeProListener.textChange(ReadBookConfig.INSTANCE.getTextKindIndex());
            }
        });
        tvTextSizedDefault.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateText(ReadBookConfig.DEFAULT_TEXT);
                changeProListener.textChange(ReadBookConfig.INSTANCE.getTextKindIndex());
            }
        });

        civBgWhite.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateBg(0);
                changeProListener.bgChange(ReadBookConfig.INSTANCE.getTextDrawableIndex());
            }
        });
        civBgYellow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateBg(1);
                changeProListener.bgChange(ReadBookConfig.INSTANCE.getTextDrawableIndex());
            }
        });
        civBgGreen.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateBg(2);
                changeProListener.bgChange(ReadBookConfig.INSTANCE.getTextDrawableIndex());
            }
        });
        civBgBlack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateBg(3);
                changeProListener.bgChange(ReadBookConfig.INSTANCE.getTextDrawableIndex());
            }
        });
    }

    private void bindView() {
        flSmaller = view.findViewById(R.id.fl_smaller);
        flBigger = view.findViewById(R.id.fl_bigger);
        tvTextSizedDefault = view.findViewById(R.id.tv_textsize_default);
        tvTextSize = view.findViewById(R.id.tv_dur_textsize);
        updateText(ReadBookConfig.INSTANCE.getTextKindIndex());

        civBgWhite = view.findViewById(R.id.civ_bg_white);
        civBgYellow = view.findViewById(R.id.civ_bg_yellow);
        civBgGreen = view.findViewById(R.id.civ_bg_green);
        civBgBlack = view.findViewById(R.id.civ_bg_black);
        llFontMenuBg = view.findViewById(R.id.ll_font_menu_bg);
        changeMode(ReadBookConfig.INSTANCE.getUiMode());
        updateBg(ReadBookConfig.INSTANCE.getTextDrawableIndex());
    }

    private void updateText(int textKindIndex) {
        if (textKindIndex == 0) {
            flSmaller.setEnabled(false);
            flBigger.setEnabled(true);
        } else if (textKindIndex == ReadBookConfig.INSTANCE.getTextKind().size() - 1) {
            flSmaller.setEnabled(true);
            flBigger.setEnabled(false);
        } else {
            flSmaller.setEnabled(true);
            flBigger.setEnabled(true);

        }
        if (textKindIndex == ReadBookConfig.DEFAULT_TEXT) {
            tvTextSizedDefault.setEnabled(false);
        } else {
            tvTextSizedDefault.setEnabled(true);
        }
        tvTextSize.setText(String.valueOf(ReadBookConfig.INSTANCE.getTextKind().get(textKindIndex).getTextSize()));
        ReadBookConfig.INSTANCE.setTextKindIndex(textKindIndex);
    }

    private void updateBg(int index) {
        civBgWhite.setBorderColor(Color.parseColor("#00000000"));
        civBgYellow.setBorderColor(Color.parseColor("#00000000"));
        civBgGreen.setBorderColor(Color.parseColor("#00000000"));
        civBgBlack.setBorderColor(Color.parseColor("#00000000"));
        switch (index) {
            case 0:
                civBgWhite.setBorderColor(Color.parseColor("#F3B63F"));
                ReadBookConfig.UIMode.DAY.changeMode();
                break;
            case 1:
                civBgYellow.setBorderColor(Color.parseColor("#F3B63F"));
                ReadBookConfig.UIMode.DAY.changeMode();
                break;
            case 2:
                civBgGreen.setBorderColor(Color.parseColor("#F3B63F"));
                ReadBookConfig.UIMode.DAY.changeMode();
                break;
            default:
                civBgBlack.setBorderColor(Color.parseColor("#F3B63F"));
                ReadBookConfig.UIMode.NIGHT.changeMode();
                break;
        }
        ReadBookConfig.INSTANCE.setTextDrawableIndex(index);
    }

    @Override
    public void changeMode(@NotNull ReadBookConfig.UIMode uiMode) {
        llFontMenuBg.setBackgroundColor(uiMode.getMenuBarBgColor());
        if (uiMode.isNight()) {
            flSmaller.setBackgroundResource(R.drawable.selector_pop_font_bg_night);
            flBigger.setBackgroundResource(R.drawable.selector_pop_font_bg_night);
        } else {
            flSmaller.setBackgroundResource(R.drawable.selector_pop_font_bg);
            flBigger.setBackgroundResource(R.drawable.selector_pop_font_bg);
        }
    }

    @Override
    public void showAtLocation(View parent, int gravity, int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
        AppExtKt.hideSystemBar(this);
    }
}