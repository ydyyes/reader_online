package com.bule.free.ireader.common.utils

import com.bule.free.ireader.ui.base.action.DisposableHandler
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject

/**
 * Created by suikajy on 2019/2/26
 */
object RxBus {

    val mEventBus: PublishSubject<Any> = PublishSubject.create()

    /**
     * 发送事件(post event)
     * @param event : event object(事件的内容)
     */
    fun post(event: Any) = mEventBus.onNext(event)

    /**
     *
     * @param code
     * @param event
     */
    fun post(code: Int, event: Any) = mEventBus.onNext(Message(code, event))

    /**
     * 返回Event的管理者,进行对事件的接受
     * @return
     */
    fun toObservable() = mEventBus

    /**
     *
     * @param cls :保证接受到制定的类型
     * @param <T>
     * @return
    </T> */
    fun <T> toObservable(cls: Class<T>): Observable<T> = mEventBus.ofType(cls)

    inline fun <T> toObservable(disposableHandler: DisposableHandler, cls: Class<T>, crossinline consumer: (T) -> Unit) {
        disposableHandler.addDisposable(mEventBus.ofType(cls).subscribe ({ consumer(it) }){ throwable-> LogUtils.e("$throwable")})
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> toObservable(code: Int, cls: Class<T>): Observable<T> {
        return mEventBus.ofType(RxBus.Message::class.java)
                .filter { msg -> msg.code == code && cls.isInstance(msg.event) }
                .map { msg -> msg.event as T }

    }

    class Message(val code: Int, val event: Any)
}