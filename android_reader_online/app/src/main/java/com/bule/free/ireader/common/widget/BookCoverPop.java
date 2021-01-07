package com.bule.free.ireader.common.widget;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;

import com.bule.free.ireader.R;

/**
 * Created by liumin on 2019/1/3.
 */

public class BookCoverPop extends PopupWindow implements View.OnClickListener {
    private Context mContext;
    private ImageView iv_book_cover;

    public BookCoverPop(Context context) {
        super(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

        mContext = context;

        View view = LayoutInflater.from(mContext).inflate(R.layout.view_pop_bookcover, null);

        setContentView(view);

        setBackgroundDrawable(new BitmapDrawable());

        setFocusable(true);
        setTouchable(true);

        setAnimationStyle(R.style.anim_pop_bookcover);

        iv_book_cover = (ImageView) view.findViewById(R.id.iv_book_cover);

        iv_book_cover.setOnClickListener(this);
    }


    public void loadImg(Drawable drawable) {
        iv_book_cover.setImageDrawable(drawable);
    }

    @Override
    public void onClick(View v) {
        dismiss();
    }
}
