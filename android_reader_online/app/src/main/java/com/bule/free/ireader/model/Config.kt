package com.bule.free.ireader.model

import com.bule.free.ireader.App
import com.bule.free.ireader.Const
import com.bule.free.ireader.common.sharepref.SpDel

/**
 * Created by suikajy on 2019-04-22
 *
 * 当前应用的配置，托管shared preference
 */
object Config {

    // 书架显示模式，0为书架模式，1为列表模式
    private var bookShelfMode: Int by AppConfigSp("book_shelf_mode", 0)

    var isShelfMode: Boolean
        get() = bookShelfMode == 0
        set(value) {
            bookShelfMode = if (value) {
                0
            } else {
                1
            }
        }

    class AppConfigSp<T>(key: String, default: T) : SpDel<T>(App.instance, Const.SpFileName.APP_CONFIG, key, default)
}