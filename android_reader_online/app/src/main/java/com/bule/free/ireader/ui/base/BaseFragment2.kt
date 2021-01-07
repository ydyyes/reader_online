package com.bule.free.ireader.ui.base

import android.support.annotation.LayoutRes
import android.support.v4.app.Fragment
import android.os.Bundle
import android.support.annotation.Nullable
import android.view.ViewGroup
import android.view.LayoutInflater
import android.view.View
import com.bule.free.ireader.api.consumer.ErrorConsumer
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.ui.base.action.DisposableHandler
import com.bule.free.ireader.common.utils.RxBus
import io.reactivex.Completable
import io.reactivex.CompletableObserver
import io.reactivex.Observable
import io.reactivex.Single
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Consumer


/**
 * Created by suikajy on 2019/3/23
 */
abstract class BaseFragment2 : Fragment(), DisposableHandler {

    private val mDisposable = CompositeDisposable()

    @LayoutRes
    protected abstract fun getContentViewId(): Int

    protected abstract fun init(savedInstanceState: Bundle?)

    protected abstract fun setListener()

    @Nullable
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(getContentViewId(), container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        init(savedInstanceState)
        setListener()
    }

    override fun addDisposable(d: Disposable?) {
        d?.let { mDisposable.addAll(d) }
    }

    override fun onDestroy() {
        super.onDestroy()
        mDisposable.dispose()
    }

    fun <T> Single<T>.go(consumer: (T) -> Unit) {
        addDisposable(this.subscribe(Consumer<T> {
            consumer(it)
        }, ErrorConsumer))
    }

    fun <T> Observable<T>.go(consumer: (T) -> Unit) {
        addDisposable(this.subscribe(Consumer<T> {
            consumer(it)
        }, ErrorConsumer))
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