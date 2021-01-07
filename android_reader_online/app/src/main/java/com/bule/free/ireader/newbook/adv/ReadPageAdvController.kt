package com.bule.free.ireader.newbook.adv

import com.bule.free.ireader.model.User

/**
 * Created by suikajy on 2019-05-22
 */

fun isReadPageAdvShow(): Boolean {
    val currentTimeMillis = System.currentTimeMillis()
    return User.noAdTimeByWatchVideo < currentTimeMillis
}