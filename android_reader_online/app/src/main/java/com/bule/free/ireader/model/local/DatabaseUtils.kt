package com.bule.free.ireader.model.local

import android.content.Context

/**
 * Created by liumin on 2018/12/20.
 */

object DatabaseUtils {

    private var mHelper: IOpenHelper? = null

    val helper: IOpenHelper
        get() {
            if (mHelper == null) {
                throw RuntimeException("MyOpenHelper is null,No init it")
            }
            return mHelper!!
        }

    /**
     * 一般来说这里的initHelper放到application中去初始化
     * 当然也可以在项目运行阶段初始化
     */
    fun initHelper(context: Context, name: String) {
        if (mHelper == null) {
            mHelper = MyOpenHelper(context, name)
        }
    }

}
