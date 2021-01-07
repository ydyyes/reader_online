package com.bule.free.ireader.model

/**
 * Created by suikajy on 2019/3/7
 */
object Global {

    // 上次展示腾讯广告的时间，毫秒级
    var lastShowChapterEndAdvTime = 0L

    fun isCanShowNativeAd() = System.currentTimeMillis() - lastShowChapterEndAdvTime > ApiConfig.strategyAdChapterEndIntv

    var missionList: List<MissionBean2> = emptyList()

}