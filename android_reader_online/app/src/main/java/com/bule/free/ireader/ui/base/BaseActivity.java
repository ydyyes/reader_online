package com.bule.free.ireader.ui.base;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;

import com.bule.free.ireader.R;
import com.bule.free.ireader.model.ChangeNightModeEvent;
import com.bule.free.ireader.newbook.ReadBookConfig;
import com.bule.free.ireader.ui.base.action.DisposableHandler;
import com.bule.free.ireader.common.utils.AppExtKt;
import com.bule.free.ireader.common.utils.RxBus;
import com.bule.free.ireader.common.utils.StatusBarCompat;
import com.bule.free.ireader.common.library.qmui.QMUIStatusBarHelper;
import com.umeng.analytics.MobclickAgent;
import com.umeng.message.PushAgent;

import butterknife.ButterKnife;
import butterknife.Unbinder;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import kotlin.Unit;

/**
 * Created by PC on 2016/9/8.
 */
@Deprecated
public abstract class BaseActivity extends AppCompatActivity implements DisposableHandler {
    private static final int INVALID_VAL = -1;

    protected CompositeDisposable mDisposable;
    //ButterKnife
    protected Toolbar mToolbar;

    private Unbinder unbinder;

    /****************************abstract area*************************************/

    @LayoutRes
    protected abstract int getContentId();

    /************************init area************************************/
    @Override
    public void addDisposable(Disposable d) {
        if (mDisposable == null) {
            mDisposable = new CompositeDisposable();
        }
        mDisposable.add(d);
    }

    /**
     * 配置Toolbar
     *
     * @param toolbar
     */
    protected void setUpToolbar(Toolbar toolbar) {
    }

    protected void initData(Bundle savedInstanceState) {
    }

    /**
     * 初始化零件
     */
    protected void initWidget() {

    }

    /**
     * 初始化点击事件
     */
    protected void initClick() {
    }

    /**
     * 逻辑使用区
     */
    protected void processLogic() {
    }

    /*************************lifecycle area*****************************************************/

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        if (Build.VERSION.SDK_INT >= 21) {
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            getWindow().setStatusBarColor(Color.TRANSPARENT);
        }

        QMUIStatusBarHelper.setStatusBarLightMode(this);
        setContentView(getContentId());
        initData(savedInstanceState);
        unbinder = ButterKnife.bind(this);
        PushAgent.getInstance(this).onAppStart();
        initToolbar();
        initWidget();
        initClick();
        AppExtKt.setUIMode(this, ReadBookConfig.INSTANCE.getUiMode());
        RxBus.INSTANCE.toObservable(this, ChangeNightModeEvent.class, changeNightModeEvent -> {
            AppExtKt.setUIMode(this, changeNightModeEvent.getUiMode());
            return Unit.INSTANCE;
        });
        processLogic();

    }

    private void initToolbar() {
        //更严谨是通过反射判断是否存在Toolbar
        mToolbar = ButterKnife.findById(this, R.id.toolbar);
        if (mToolbar != null) {
            supportActionBar(mToolbar);
            setUpToolbar(mToolbar);

            getSupportActionBar().setTitle("");
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
        if (mDisposable != null) {
            mDisposable.dispose();
        }
    }

    /**************************used method area*******************************************/

    protected void startActivity(Class<? extends AppCompatActivity> activity) {
        Intent intent = new Intent(this, activity);
        startActivity(intent);
    }

    protected ActionBar supportActionBar(Toolbar toolbar) {
        setSupportActionBar(toolbar);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowHomeEnabled(true);
        }
        mToolbar.setNavigationOnClickListener(
                (v) -> finish()
        );
        return actionBar;
    }

    protected void setStatusBarColor(int statusColor) {
        StatusBarCompat.compat(this, ContextCompat.getColor(this, statusColor));
    }

    @Override
    protected void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }
}
