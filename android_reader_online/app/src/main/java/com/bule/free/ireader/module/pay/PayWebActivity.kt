package com.bule.free.ireader.module.pay

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.net.http.SslError
import android.text.TextUtils
import android.webkit.*
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.ToastUtils
import com.bule.free.ireader.model.User
import com.bule.free.ireader.ui.base.BaseActivity2
import kotlinx.android.synthetic.main.activity_payweb.*
import org.json.JSONException
import org.json.JSONObject
import com.bule.free.ireader.common.utils.AppUtils


class PayWebActivity : BaseActivity2() {

    var url: String? = null

    companion object {
        fun start(activity: Activity, url: String) {
            val intent = Intent(activity, PayWebActivity::class.java)
            intent.putExtra("url", url)
            activity.startActivity(intent)
        }
    }

    override val layoutId: Int = R.layout.activity_payweb

    override fun init() {

        url = intent.getStringExtra("url")

        mWebView.settings.javaScriptEnabled = true
        mWebView.settings.cacheMode = WebSettings.LOAD_NO_CACHE
        mWebView.settings.textZoom = 100
        mWebView.settings.useWideViewPort = false
        mWebView.settings.javaScriptCanOpenWindowsAutomatically = true
        mWebView.settings.layoutAlgorithm = WebSettings.LayoutAlgorithm.SINGLE_COLUMN
        mWebView.settings.loadWithOverviewMode = true

        mWebView.webViewClient = webClient()

        mWebView.addJavascriptInterface(AndroidtoJs(), "app")

        mWebView.loadUrl(url)
    }

    override fun setListener() {
//        btn_back.setOnClickListener {
//            if(mWebView.canGoBack()){
//                mWebView.goBack()
//            }else{
//                finish()
//            }
//        }
    }

    inner class webClient : WebViewClient() {
        override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
            // ------  对alipays:相关的scheme处理 -------
            LogUtils.e("shouldOverrideUrlLoading url $url")

//            if (url.startsWith("alipays:") || url.startsWith("alipay")) {
//                try {
//                    this@PayWebActivity.start(Intent("android.intent.action.VIEW", Uri.parse(url)))
//                } catch (e: Exception) {
//                }
//
//                return true
//            }else if (url.startsWith("weixin://wap/pay?")) {
//                try{
//                    this@PayWebActivity.start(Intent("android.intent.action.VIEW", Uri.parse(url)))
//                }catch (e:Exception){
//                    AlertDialog.Builder(this@PayWebActivity)
//                            .setMessage("未检测到微信客户端，请安装后重试。")
//                            .setPositiveButton("立即安装") { dialog, which ->
//                                val alipayUrl = Uri.parse("https://weixin.qq.com/")
//                                this@PayWebActivity.start(Intent("android.intent.action.VIEW", alipayUrl))
//                                finish()
//                            }.setNegativeButton("取消"){ dialogInterface, i ->
//                                finish()
//                            }
//                            .show()
//                }
//                return true
//            }
//
//            val extraHeaders = mutableMapOf<String,String>()
//            extraHeaders.put("Referer", "https://pay.meihaopay.com")
//            view.loadUrl(url,extraHeaders)
//            return true

            if(url.startsWith("weixin://")){
                if(!AppUtils.isInstalled(this@PayWebActivity,"com.tencent.mm")){
                    ToastUtils.show("未检测到安装微信APP，请安装后进行支付")
                    return true
                }
            }

            if(url.startsWith("http://") || url.startsWith("https://")){
                val extraHeaders = mutableMapOf<String,String>()
                extraHeaders.put("Referer", "https://pay.meihaopay.com")
                if(url.startsWith("https://wx.tenpay.com")){
                    view.loadUrl(url,extraHeaders)
                }else{
                    view.loadUrl(url)
                }
                return true
            }else{
                try{
                    this@PayWebActivity.startActivity(Intent("android.intent.action.VIEW", Uri.parse(url)))
                    return true
                }catch (e :Exception){
                    return false
                }
            }
        }


        override fun onReceivedSslError(view: WebView?, handler: SslErrorHandler, error: SslError?) {
            handler.proceed()
        }

    }

    override fun onPause() {
        super.onPause()
        if(mWebView!= null){
            mWebView.onPause()
            mWebView.pauseTimers()
        }

    }

    override fun onResume() {
        super.onResume()
        if(mWebView!=null){
            mWebView.onResume()
            mWebView.resumeTimers()
        }

    }

    override fun onBackPressed() {
        super.onBackPressed()
    }

    inner class AndroidtoJs : Any() {
        // 定义JS需要调用的方法
        // 被JS调用的方法必须加入@JavascriptInterface注解

        @JavascriptInterface
        fun hfpay_done(info: String) {
            if (!TextUtils.isEmpty(info)) {
                LogUtils.e("pay result code : $info")
                try {
                    val jsonObject = JSONObject(info)
                    if (jsonObject.optString("code") == "0000") {
                        //支付成功
                        ToastUtils.show("支付成功")
                        User.syncToServer()
                        finish()
                    } else if(jsonObject.optString("code") == "0001"){
                        //点击返回
                        ToastUtils.show("支付失败")
                        finish()
                    }else if(jsonObject.optString("code") == "0002"){
                        //点击返回
                        finish()
                    }
                } catch (e: JSONException) {
                    e.printStackTrace()
                    return
                }

            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (mWebView != null) {
            mWebView.loadDataWithBaseURL(null, "", "text/html", "utf-8", null)
            mWebView.destroy()
        }
    }
}