package com.bule.free.ireader.model

import com.bule.free.ireader.common.utils.ServerTimeUtil
import com.bule.free.ireader.common.utils.SharedPreUtils

/**
 * Created by suikajy on 2019/3/25
 *
 * 接口策略缓存
 */
object ApiConfig {

    //> STRATEGY_FREE_AD_OPEN:  自由广告展示开关
    //> STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY":自由广告每天展示次数
    //> STRATEGY_FREE_AD_SHOW_INTV:  自由广告展示间隔(单位:分钟)
    //> STRATEGY_AD_OPEN :广告SDK展示开关
    //> STRATEGY_AD_CHAPTER_END_INTV ：章节末广告展示间隔
    //> AD_BROWSE_LIMIT : 每日浏览视频广告总数限制
    //> EXCHANGE_GOLD_NUM: 缓存一本书所需的金币
    //> SHARE_TIMES_LIMIT ： 每日分享总数限制
    //> STRATEGY_START_RATIO ：开屏广告SDK展示配置
    //> STRATEGY_CHAPTER_END_RATIO 章节末尾广告SDK展示配置
    //> STRATEGY_VIDEO_RATIO 视频任务广告SDK展示配置

    // todo :添加分享金币，观看视频广告金币数量配置

    private const val EXCHANGE_GOLD_NUM = "exchange_gold_num"
    private const val AD_BROWSE_LIMIT = "ad_browse_limit"
    private const val SHARE_TIMES_LIMIT = "share_times_limit"
    private const val STRATEGY_AD_CHAPTER_END_INTV = "strategy_ad_chapter_end_intv"
    private const val STRATEGY_AD_OPEN = "strategy_ad_open"
    private const val STRATEGY_CHAPTER_END_RATIO = "strategy_chapter_end_ratio"
    private const val STRATEGY_FREE_AD_OPEN = "strategy_free_ad_open"
    private const val STRATEGY_FREE_AD_SHOW_INTV = "strategy_free_ad_show_intv"
    private const val STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY = "strategy_free_ad_show_times_everyday"
    private const val STRATEGY_START_RATIO = "strategy_start_ratio"
    private const val STRATEGY_VIDEO_RATIO = "strategy_video_ratio"
    private const val STRATEGY_RED_PACKET = "strategy_red_packet"
    private const val BANNER_AD_SWITCH = "banner_ad_switch"
    private const val BANNER_AD_RATIO = "banner_ad_ratio"
    private const val BANNER_AD_LIMIT = "banner_ad_limit"
    private const val CONTACT_US = "contact_us"
    private const val STRATEGY_SCREEN_LIMIT = "strategy_screen_limit"
    private const val STRATEGY_SCREEN_RATIO = "strategy_screen_ratio"
    private const val STRATEGY_SCREEN_SWITCH = "strategy_screen_switch"
    private const val STRATEGY_START_LOAD = "strategy_start_load"
    private const val BANNER_AD_LOAD = "banner_ad_load"

    private val sp = SharedPreUtils.getInstance()

    var exchangeGoldNum: Int
        set(value) = sp.putInt(EXCHANGE_GOLD_NUM, value)
        get() = sp.getInt(EXCHANGE_GOLD_NUM, 0)

    var shareTimesLimit: Int
        set(value) = sp.putInt(SHARE_TIMES_LIMIT, value)
        get() = sp.getInt(SHARE_TIMES_LIMIT, 5)

    var adBrowseLimit: Int
        set(value) = sp.putInt(AD_BROWSE_LIMIT, value)
        get() = sp.getInt(AD_BROWSE_LIMIT, 5)

    var strategyAdChapterEndIntv: Long
        set(value) = sp.putLong(STRATEGY_AD_CHAPTER_END_INTV, value)
        get() = sp.getLong(STRATEGY_AD_CHAPTER_END_INTV, 0L)

    var strategy_ad_open: Boolean
        set(value) = sp.putBoolean(STRATEGY_AD_OPEN, value)
        get() = sp.getBoolean(STRATEGY_AD_OPEN, false)

    var strategy_chapter_end_ratio: String
        set(value) = sp.putString(STRATEGY_CHAPTER_END_RATIO, value)
        get() = sp.getString(STRATEGY_CHAPTER_END_RATIO)

    var strategy_start_ratio: String
        set(value) = sp.putString(STRATEGY_START_RATIO, value)
        get() = sp.getString(STRATEGY_START_RATIO)

    var strategy_red_packet: String
        set(value) = sp.putString(STRATEGY_RED_PACKET, value)
        get() = sp.getString(STRATEGY_RED_PACKET)
    // 阅读页底部banner开关
    var banner_ad_switch: String
        set(value) = sp.putString(BANNER_AD_SWITCH, value)
        get() = sp.getString(BANNER_AD_SWITCH)
    // 阅读页底部banner比例
    var banner_ad_ratio: String
        set(value) = sp.putString(BANNER_AD_RATIO, value)
        get() = sp.getString(BANNER_AD_RATIO)
    // 阅读页底部banner广告间隔
    var banner_ad_limit: String
        set(value) = sp.putString(BANNER_AD_LIMIT, value)
        get() = sp.getString(BANNER_AD_LIMIT)

    // 每日推荐下面的联系我们
    var contact_us: String
        set(value) = sp.putString(CONTACT_US, value)
        get() = sp.getString(CONTACT_US)

    // 阅读页面插屏广告展示间隔（单位：秒）
    var strategy_screen_limit: Long
        set(value) = sp.putLong(STRATEGY_SCREEN_LIMIT, value)
        get() = sp.getLong(STRATEGY_SCREEN_LIMIT, 15 * 60 * 1000)

    // 阅读页面插屏广告展示配置（广、穿、百）
    var strategy_screen_ratio: String
        set(value) = sp.putString(STRATEGY_SCREEN_RATIO, value)
        get() = sp.getString(STRATEGY_SCREEN_RATIO)

    // 阅读页面插屏广告展示间隔（单位：秒）
    var strategy_screen_switch: Boolean
        set(value) = sp.putBoolean(STRATEGY_SCREEN_SWITCH, value)
        get() = sp.getBoolean(STRATEGY_SCREEN_SWITCH, false)

    // 切换应用展示开屏广告间隔（单位：秒）
    var strategy_start_load: Long
        set(value) = sp.putLong(STRATEGY_START_LOAD, value)
        get() = sp.getLong(STRATEGY_START_LOAD, 60 * 1000L)

    // banner广告重新加载时间（单位：秒）
    var banner_ad_load: Long
        set(value) = sp.putLong(BANNER_AD_LOAD, value)
        get() = sp.getLong(BANNER_AD_LOAD, 3 * 60 * 1000)

    // true为无广告
    fun isNoAd() = !strategy_ad_open || ServerTimeUtil.serverTime < User.expire
//    fun isNoAd() = !showSdkAdStrategy || ServerTimeUtil.serverTime < -100000
}