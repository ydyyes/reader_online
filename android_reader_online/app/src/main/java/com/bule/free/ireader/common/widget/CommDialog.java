package com.bule.free.ireader.common.widget;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

import com.bule.free.ireader.R;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;

/**
 * Created by liumin on 2019/1/1.
 */

public class CommDialog extends Dialog implements View.OnClickListener {


    private Unbinder unbinder;

    private OnClickListener okClick;

    public OnClickListener getOkClick() {
        return okClick;
    }

    public void setOkClick(OnClickListener okClick) {
        this.okClick = okClick;
    }

    public CommDialog(@NonNull Context context) {
        super(context, R.style.CommonDialog);
    }


    @BindView(R.id.tv_title)
    TextView mTitle;

    @BindView(R.id.tv_content)
    TextView mContent;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.dialog_comm);

        unbinder = ButterKnife.bind(this);

        setUpWindow();

    }

    private void setUpWindow() {
        WindowManager.LayoutParams lp = getWindow().getAttributes();
        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
        lp.height = WindowManager.LayoutParams.MATCH_PARENT;
        lp.horizontalMargin = 0;
    }

    public void setTitle(String value){
        if(!TextUtils.isEmpty(value)){
            mTitle.setText(value);
        }
    }

    public void setContent(String value){
        if(!TextUtils.isEmpty(value)){
            mContent.setText(value);
        }
    }


    @Override
    public void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        unbinder.unbind();
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {

        }
    }


    @OnClick(R.id.btn_cancel)
    public void onClickCancel() {
        dismiss();
    }

    @OnClick(R.id.btn_ok)
    public void onClickOk() {
        if(okClick!=null){
            okClick.onClick(this,-1);
        }
        dismiss();
    }
}
