package com.bule.free.ireader

import android.app.Application
import android.content.Context
import android.support.multidex.MultiDex
import com.bule.free.ireader.api.consumer.ErrorConsumer
import com.bule.free.ireader.common.adv.ttad.config.TTAdManagerHolder
import com.bule.free.ireader.common.adv.yomi.YoMiDel
import com.bule.free.ireader.common.download.BookDownloader
import com.bule.free.ireader.common.umeng.UmengDel
import com.bule.free.ireader.common.utils.CurrentActivityGetter
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.model.local.DatabaseUtils
import com.check.ox.sdk.LionSDK
import io.reactivex.plugins.RxJavaPlugins

/**
 * Created by suikajy on 2019/2/28
 */
class App : Application() {

    companion object {
        lateinit var instance: App
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        DatabaseUtils.initHelper(this, "book.db")
        UmengDel.init(this)
        CurrentActivityGetter.instance.register(this)
        BookDownloader.init()
        TTAdManagerHolder.init(this)
        YoMiDel.init()
        LionSDK.init(this)
        RxJavaPlugins.setErrorHandler(ErrorConsumer)  // 设置全局错误默认处理，如果dispose()的调用先于onError调用，不设置这个会崩溃
    }


    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        MultiDex.install(base)
    }
}