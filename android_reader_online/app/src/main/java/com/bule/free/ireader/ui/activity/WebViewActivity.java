package com.bule.free.ireader.ui.activity;

import android.content.Intent;
import android.net.http.SslError;
import android.os.Build;
import android.util.Log;
import android.view.KeyEvent;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.bule.free.ireader.App;
import com.bule.free.ireader.R;
import com.bule.free.ireader.common.utils.WebViewUtils;
import com.bule.free.ireader.common.widget.ToolBarView;
import com.bule.free.ireader.ui.base.BaseActivity2;

/**
 * Created by suikajy on 2019-06-06
 */
public class WebViewActivity extends BaseActivity2 {
    private static final String WEB_TITLE = "web_title";
    private static final String WEB_URL = "web_url";

    private String mUrl;
    private WebView mWv;
    private ToolBarView mTbv;
    private String mTitle;

    public static void start(String url) {
        start(url, "");
    }


    public static void start(String url, String title) {
        App context = App.instance;
        Intent intent = new Intent(context, WebViewActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_URL, url);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) {
            if (mWv.canGoBack()) {
                mWv.goBack();
                return true;
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public int getLayoutId() {
        return R.layout.activity_web_view;
    }

    @Override
    protected void init() {
        Intent intent = getIntent();
        mTitle = intent.getStringExtra(WEB_TITLE);
        mUrl = intent.getStringExtra(WEB_URL);
        mWv = findViewById(R.id.wv);
        mTbv = findViewById(R.id.toolbar_view);
        mTbv.setTitle(mTitle);
        WebViewUtils.initWebView(mWv);
        mWv.loadUrl(mUrl);
    }

    @Override
    protected void setListener() {

    }
}
