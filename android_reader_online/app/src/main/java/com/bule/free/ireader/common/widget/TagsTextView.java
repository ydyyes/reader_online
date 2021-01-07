package com.bule.free.ireader.common.widget;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.Gravity;
import android.widget.LinearLayout;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.utils.ScreenUtils;

public class TagsTextView extends android.support.v7.widget.AppCompatTextView{
    public TagsTextView(Context context) {
        super(context);
    }

    public TagsTextView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public TagsTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setBackgroundShapeColor(int color){

        GradientDrawable drawable = new GradientDrawable();
        drawable.setCornerRadius(ScreenUtils.dpToPx(2));
        drawable.setStroke(ScreenUtils.dpToPx(1), color);
        drawable.setColor(getResources().getColor(R.color.transparent));
        setBackgroundDrawable(drawable);
        setGravity(Gravity.CENTER);
        setTextSize(11);
        LinearLayout.LayoutParams lp =new LinearLayout.LayoutParams(ScreenUtils.dpToPx(56), ScreenUtils.dpToPx(22));
        lp.setMargins(0,0, ScreenUtils.dpToPx(8), 0);
        setLayoutParams(lp);

    }
}
