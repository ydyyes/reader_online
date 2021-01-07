package com.bule.free.ireader.ui.adapter.view;

import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.model.bean.BookMallItemBean;
import com.bule.free.ireader.ui.base.adapter.ViewHolderImpl;
import com.bule.free.ireader.common.utils.ScreenUtils;
import com.bule.free.ireader.common.library.glide.GlideExtKt;

/**
 * Created by newbiechen on 17-5-8.
 * CollectionBookView
 */

public class MallRightBookHolder extends ViewHolderImpl<BookMallItemBean> {

    private static final String TAG = "CollBookView";
    private ImageView mIvCover;
    private TextView mTvName;
    int imageWidth;
//    private ImageView iv_book_status;

    public MallRightBookHolder() {

    }

    @Override
    public void initView() {
        mIvCover = findById(R.id.coll_book_iv_cover);
        mTvName = findById(R.id.coll_book_tv_name);
        imageWidth = (ScreenUtils.getScreenWidthSize() - ScreenUtils.dpToPx(60)) / 4;
//        iv_book_status = findById(R.id.iv_book_status);
    }

    @Override
    public void onBind(BookMallItemBean value, int pos) {


        FrameLayout.LayoutParams params2 = (FrameLayout.LayoutParams) mIvCover.getLayoutParams();
        params2.width = imageWidth;
        params2.height = (int) (params2.width * 1.34);
        mIvCover.setLayoutParams(params2);
        //书的图片
        GlideExtKt.load(mIvCover,value.getCover());
        //书名
        mTvName.setText(value.getTitle());

//        if (value.getOver() == 0) {
//            iv_book_status.setVisibility(View.VISIBLE);
//            iv_book_status.setImageResource(R.drawable.ic_book_status_conti);
//        } else if (value.getOver() == 1) {
//            iv_book_status.setVisibility(View.VISIBLE);
//            iv_book_status.setImageResource(R.drawable.ic_book_status_over);
//        } else {
//            iv_book_status.setVisibility(View.GONE);
//        }
    }

    @Override
    protected int getItemLayoutId() {
        return R.layout.item_market_book;
    }
}
