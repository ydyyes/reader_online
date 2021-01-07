package com.bule.free.ireader.common.utils

import android.content.Context
import com.bule.free.ireader.App

/**
 * Created by suikajy on 2019/2/22
 *
 * {"token":"","requestTime":"1561619739078","vcode":"35","api_vcode":1,"uuid":"41d36d89-2582-4b0d-a0f0-b18ff6e3029e"}
 *
 * {"token":"","requestTime":"1561619789519","vcode":"35","api_vcode":1,"uuid":"af6dfe92-8e8f-4525-95bc-a05eed42b53b"}
 */
object ServerTimeUtil {
    private const val DIFF_TIME_KEY = "diffTime"

    private val sharedPre = App.instance
            .getSharedPreferences("ServerTimeStamp", Context.MODE_PRIVATE)

    private var diffTime = sharedPre.getLong(DIFF_TIME_KEY, 0L)

    var serverTime
        get() = System.currentTimeMillis() + diffTime
        set(value) {
            diffTime = System.currentTimeMillis() - value
            if (diffTime != 0L) {
                diffTime = -diffTime
            }
            sharedPre.edit().apply {
                putLong(DIFF_TIME_KEY, diffTime)
                apply()
            }
        }

}

