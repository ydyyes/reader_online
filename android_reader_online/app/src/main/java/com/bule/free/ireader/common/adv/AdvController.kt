package com.bule.free.ireader.common.adv

import com.bule.free.ireader.model.ApiConfig
import kotlin.random.Random

/**
 * Created by suikajy on 2019/3/19
 */

enum class ShowAdType {
    // 展示腾讯广告
    GDT,
    // 展示头条广告
    TTAD,
    // 百度广告
    BDAD,
    // 不展示广告
    NONE
}

object AdvController {

    var sCurrentReadPageBottomAdType = ShowAdType.GDT

    // 获取开屏广告展示类型
    fun getSplashAdType(): ShowAdType {
        val strategyStartRatio = ApiConfig.strategy_start_ratio
        return if (strategyStartRatio.isEmpty()) ShowAdType.NONE
        else randomShowType(strategyStartRatio.split(",").map(String::toInt))
    }

    // 重新随机章节末尾广告类型
    fun invalidateChapterEndAdType() {
        val strategyChapterEndRatio = ApiConfig.strategy_chapter_end_ratio
        sCurrentReadPageBottomAdType = if (strategyChapterEndRatio.isEmpty()) ShowAdType.NONE
        else randomShowType(strategyChapterEndRatio.split(",").map(String::toInt))
    }

    // 获取章节末尾广告类型
    fun getInterstitialAdType(): ShowAdType {
        val strategyChapterEndRatio = ApiConfig.strategy_screen_ratio
        return if (strategyChapterEndRatio.isEmpty()) ShowAdType.NONE
        else randomShowType(strategyChapterEndRatio.split(",").map(String::toInt))
    }

    // 获取阅读页底部广告类型
    fun getReadPageBottomAdType(): ShowAdType {
        val strategyChapterEndRatio = ApiConfig.banner_ad_ratio
        return if (strategyChapterEndRatio.isEmpty()) ShowAdType.NONE
        else randomShowType(strategyChapterEndRatio.split(",").map(String::toInt))
    }

    private fun randomShowType(probabilityList: List<Int>): ShowAdType {
        val adTypes = ShowAdType.values()
        for (i in probabilityList.indices) {
            if (i >= adTypes.size) break
            val sum = probabilityList.takeLast(probabilityList.size - i).sum()
            if (Random.nextInt(sum) < probabilityList[i]) {
                return adTypes[i]
            }
        }
        return ShowAdType.NONE
    }
}

