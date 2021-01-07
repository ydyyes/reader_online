package com.bule.free.ireader.ui.activity

import android.app.Activity
import android.content.Intent
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.AES
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.async
import com.bule.free.ireader.common.utils.onClick
import com.bule.free.ireader.ui.base.BaseActivity2
import io.reactivex.Single
import io.reactivex.SingleObserver
import io.reactivex.disposables.Disposable
import kotlinx.android.synthetic.main.activity_test.*

/**
 * Created by suikajy on 2019-06-17
 */
class TestActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, TestActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId = R.layout.activity_test

    override fun init() {

    }

    override fun setListener() {
        btn_test_rx.onClick { _ ->

            Single.create<Int> {
                LogUtils.e("start")
                var s = "Created by suikajy on 2019-06-17"
                repeat(10000) {
                    s = AES.encrypt(s).substring(0..10)
                }
                LogUtils.e("stop inner")
                it.onError(IllegalStateException("my ex"))
                it.onSuccess(s.length)
            }.onErrorReturn {
                3
            }.onErrorReturnItem(2).async().subscribe(object : SingleObserver<Int> {
                override fun onSuccess(t: Int) {
                    LogUtils.e("t: $t")
                }

                override fun onSubscribe(d: Disposable) {
                    addDisposable(d)
                }

                override fun onError(e: Throwable) {
                    LogUtils.e("e: $e")
                }

            })
        }
    }
}


