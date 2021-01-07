package com.bule.free.ireader.ui.base

import android.content.pm.ActivityInfo
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import android.view.Window
import android.view.WindowManager
import com.bule.free.ireader.api.consumer.ErrorConsumer
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.model.ChangeNightModeEvent
import com.bule.free.ireader.newbook.ReadBookConfig
import com.bule.free.ireader.ui.base.action.DisposableHandler
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.common.library.qmui.QMUIStatusBarHelper
import com.bule.free.ireader.common.utils.setUIMode
import com.umeng.analytics.MobclickAgent
import com.umeng.message.PushAgent
import io.reactivex.Completable
import io.reactivex.CompletableObserver
import io.reactivex.Observable
import io.reactivex.Single
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Consumer


/**
 * Created by suikajy on 2019/3/21
 */
abstract class BaseActivity2 : AppCompatActivity(), DisposableHandler {

    private var mDisposable = CompositeDisposable()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (isFullScreen()) {
            this.window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN)
            this.requestWindowFeature(Window.FEATURE_NO_TITLE)
        }
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        setContentView(layoutId)
        // 固定竖屏，并消除系统StatusBar，自己来控制
        window?.apply {
            addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
                decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
                statusBarColor = Color.TRANSPARENT
            }
        }
        // 由于多数标题栏都是白色，所以采用黑色主题的status bar
        PushAgent.getInstance(this).onAppStart()
        QMUIStatusBarHelper.setStatusBarLightMode(this)
        init()
        setListener()
        setUIMode(ReadBookConfig.uiMode)
        subscribeUiMode()
    }

    override fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
    }

    override fun onPause() {
        super.onPause()
        MobclickAgent.onPause(this)
    }

    open fun subscribeUiMode() {
        subscribeEvent(ChangeNightModeEvent::class.java) { setUIMode(it.uiMode) }
    }

    open fun isFullScreen() = false

    abstract val layoutId: Int

    protected abstract fun init()

    protected abstract fun setListener()

    override fun addDisposable(d: Disposable) {
        mDisposable.add(d)
    }

    protected fun Disposable.bind() {
        mDisposable.add(this@bind)
    }

    override fun onDestroy() {
        mDisposable.dispose()
        super.onDestroy()
    }

    inline fun <T> Single<T>.go(crossinline consumer: (T) -> Unit) {
        addDisposable(this.subscribe(Consumer<T> {
            consumer(it)
        }, ErrorConsumer))
    }

    inline fun <T> Observable<T>.go(crossinline consumer: (T) -> Unit) {
        addDisposable(this.subscribe(Consumer<T> {
            consumer(it)
        }, ErrorConsumer))
    }

    inline fun <T> Observable<T>.go(crossinline consumer: (T) -> Unit, errorConsumer: Consumer<Throwable>) {
        addDisposable(this.subscribe(Consumer<T> {
            consumer(it)
        }, errorConsumer))
    }

    inline fun Completable.go(crossinline action: () -> Unit = {}) {
        subscribe(object : CompletableObserver {
            override fun onComplete() {
                action()
            }

            override fun onSubscribe(d: Disposable) {
                addDisposable(d)
            }

            override fun onError(e: Throwable) {
                ErrorConsumer.accept(e)
            }
        })
    }

    fun <T> Single<T>.go(consumer: (T) -> Unit,
                         errorConsumer: ((Throwable) -> Unit)? = null, isDefaultErrorConsumer: Boolean = true) {
        if (isDefaultErrorConsumer.not() && errorConsumer != null) {
            addDisposable(this.subscribe({ t -> consumer(t) }, { t -> errorConsumer(t) }))
            return
        }
        addDisposable(this.subscribe(object : SimpleCallback<T> {
            override fun onSuccess(t: T) {
                consumer(t)
            }

            override fun onException(throwable: Throwable) {
                errorConsumer?.invoke(throwable)
            }
        }))
    }

    inline fun <T> subscribeEvent(clz: Class<T>, crossinline consumer: (T) -> Unit) {
        RxBus.toObservable(this, clz, consumer)
    }
}