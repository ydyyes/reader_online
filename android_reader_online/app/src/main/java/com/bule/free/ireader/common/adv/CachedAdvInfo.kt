package com.bule.free.ireader.common.adv

import com.bule.free.ireader.model.AdvListBean

/**
 * Created by suikajy on 2019-06-05
 */
object CachedAdvInfo {

    var sAdvInfoList: MutableList<AdvListBean> = mutableListOf()
    // 书籍样式广告
    fun getBookAdvList() = sAdvInfoList.filter { it.location == "3" }

    // 首页浮标广告
    fun getFloatAdvList() = sAdvInfoList.filter { it.location == "4" }
}