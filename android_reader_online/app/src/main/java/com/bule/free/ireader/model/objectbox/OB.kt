package com.bule.free.ireader.model.objectbox

import com.bule.free.ireader.App
import com.bule.free.ireader.common.utils.debug
import com.bule.free.ireader.model.objectbox.bean.MyObjectBox
import io.objectbox.Box
import io.objectbox.android.AndroidObjectBrowser

/**
 * Created by suikajy on 2019-05-20
 */
object OB {
    // boxStore 需要使用如下单例模式，不要在每个Activity单独创建
    val boxStore = MyObjectBox.builder().androidContext(App.instance).maxReaders(240).build()!!

    init {
        debug {
            AndroidObjectBrowser(boxStore).start(App.instance)
        }
    }


}

fun <T> boxOf(clz: Class<T>): Box<T> {
    return OB.boxStore.boxFor(clz)
}



