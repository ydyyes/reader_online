package com.bule.free.ireader.api.exception

/**
 * Created by suikajy on 2019/2/26
 */

class ApiException(val errorno: Int, msg: String) : RuntimeException(msg) {
    companion object {
        const val JSON_CAST_EXCEPTION = 600
        const val HTTP_FAIL = 700
    }
}