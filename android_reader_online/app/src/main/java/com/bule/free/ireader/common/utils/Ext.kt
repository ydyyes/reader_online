package com.bule.free.ireader.common.utils

import android.app.Activity
import android.app.Application
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.drawable.Drawable
import android.graphics.drawable.StateListDrawable
import android.provider.Settings
import android.provider.Settings.System.*
import android.support.annotation.IntRange
import android.view.View
import com.bule.free.ireader.App
import com.bule.free.ireader.Const
import com.bule.free.ireader.api.consumer.ErrorConsumer
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.ui.base.action.DisposableHandler
import io.reactivex.Completable
import io.reactivex.CompletableObserver
import io.reactivex.Observable
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import java.lang.Exception
import java.lang.IllegalArgumentException
import java.text.SimpleDateFormat
import java.util.*

/**
 * Created by suikajy on 2019/2/25
 */

/*********************************** rx java *************************************************/

inline fun <T> Single<T>.go(disposableHandler: DisposableHandler,
                            crossinline consumer: (T) -> Unit) {
    disposableHandler.addDisposable(this.subscribe(Consumer<T> {
        consumer(it)
    }, ErrorConsumer))
}

inline fun <T> Observable<T>.go(disposableHandler: DisposableHandler,
                                crossinline consumer: (T) -> Unit) {
    disposableHandler.addDisposable(this.subscribe(Consumer<T> {
        consumer(it)
    }, ErrorConsumer))
}

inline fun Completable.go(disposableHandler: DisposableHandler,
                          crossinline action: () -> Unit = {}) {
    subscribe(object : CompletableObserver {
        override fun onComplete() {
            action()
        }

        override fun onSubscribe(d: Disposable) {
            disposableHandler.addDisposable(d)
        }

        override fun onError(e: Throwable) {
            ErrorConsumer.accept(e)
        }
    })
}

fun <T> Single<T>.go(disposableHandler: DisposableHandler,
                     consumer: (T) -> Unit,
                     errorConsumer: ((Throwable) -> Unit)? = null) {
    disposableHandler.addDisposable(this.subscribe(object : SimpleCallback<T> {
        override fun onSuccess(t: T) {
            consumer(t)
        }

        override fun onException(throwable: Throwable) {
            errorConsumer?.invoke(throwable)
        }
    }))
}

fun <T> Single<T>.async(): Single<T> = subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())

fun <T> Observable<T>.async(): Observable<T> = subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())

fun Completable.async(): Completable = subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())

/*********************************** System method *************************************************/

// 将字符串粘贴到剪切板
fun String.toClipboard() {
    val cm = App.instance.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    val mClipData = ClipData.newPlainText("Label", this)
    cm.primaryClip = mClipData
}

fun Activity.setScreenBrightnessMode(isManual: Boolean) {
    try {
        val mode = Settings.System.getInt(contentResolver, SCREEN_BRIGHTNESS_MODE)
        if (mode == SCREEN_BRIGHTNESS_MODE_AUTOMATIC && isManual) {
            Settings.System.putInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE, SCREEN_BRIGHTNESS_MODE_MANUAL)
        } else if (mode == SCREEN_BRIGHTNESS_MODE_MANUAL && isManual.not()) {
            Settings.System.putInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS_MODE, SCREEN_BRIGHTNESS_MODE_AUTOMATIC)
        }
    } catch (e: Exception) {

    }
}

fun Activity.setWindowBrightness(brightness: Float) {
    val lp = window.attributes
    lp.screenBrightness = brightness / 255.0f
    window.attributes = lp
}

@IntRange(from = 0, to = 255)
fun Application.getScreenBrightness() = Settings.System.getInt(contentResolver, Settings.System.SCREEN_BRIGHTNESS, 125)

/*********************************** dimens *************************************************/
// 将dp转换成px
fun dp(value: Float): Int = (value * App.instance.resources.displayMetrics.density).toInt()

fun dp(value: Int) = dp(value.toFloat())

/*********************************** time *************************************************/
fun Long.isToday(): Boolean {
    val calendar = Calendar.getInstance()
    calendar.timeInMillis = this
    val todayCalendar = Calendar.getInstance()
    todayCalendar.set(Calendar.HOUR_OF_DAY, 0)
    todayCalendar.set(Calendar.MINUTE, 0)
    todayCalendar.set(Calendar.SECOND, 0)
    return calendar > todayCalendar
}

fun Long.toDateString(pattern: String = "yyyy-MM-dd HH:mm:ss") = SimpleDateFormat(pattern).format(Date(this))

fun Long.toMinute() = this / 1000 / 60

fun Long.toSecond() = this / 1000

/*********************************** View *************************************************/
inline fun View.onClick(crossinline block: (View) -> Unit) {
    setOnClickListener { v -> block(v) }
}

var safeClickStartTime = 0L

// 防止短时间内的多次点击
inline fun View.onSafeClick(crossinline block: (View) -> Unit) {
    setOnClickListener {
        val currentTimeMillis = System.currentTimeMillis()
        if (currentTimeMillis - safeClickStartTime > 600) {
            safeClickStartTime = currentTimeMillis
            block(it)
        }
    }
}

/*********************************** Debug *************************************************/
// 调试模式下会运行的代码块
@Suppress("ConstantConditionIf")
inline fun debug(block: () -> Unit) {
    if (Const.DEBUG) block()
}

// 生产模式下运行的代码块
@Suppress("ConstantConditionIf")
inline fun release(block: () -> Unit) {
    if (!Const.DEBUG) block()
}

/*********************************** DSL *************************************************/
fun selector(block: SelectorDrawableBuilder.() -> Unit) = SelectorDrawableBuilder().apply(block).build()

class SelectorDrawableBuilder {
    private val stateListDrawable = StateListDrawable()
    var pressedDrawable: Drawable? = null
    var checkedDrawable: Drawable? = null
    var focusedDrawable: Drawable? = null
    var enabledDrawable: Drawable? = null
    var selectedDrawable: Drawable? = null
    var normalDrawable: Drawable? = null

    fun build(): StateListDrawable {
        normalDrawable?.apply { stateListDrawable.addState(intArrayOf(), this) }
                ?: throw IllegalArgumentException("Selector drawable build fail, need normal drawable.")
        pressedDrawable?.apply { stateListDrawable.addState(intArrayOf(android.R.attr.state_pressed), this) }
        checkedDrawable?.apply { stateListDrawable.addState(intArrayOf(android.R.attr.state_checked), this) }
        focusedDrawable?.apply { stateListDrawable.addState(intArrayOf(android.R.attr.state_focused), this) }
        enabledDrawable?.apply { stateListDrawable.addState(intArrayOf(android.R.attr.state_enabled), this) }
        selectedDrawable?.apply { stateListDrawable.addState(intArrayOf(android.R.attr.state_selected), this) }
        return stateListDrawable
    }
}