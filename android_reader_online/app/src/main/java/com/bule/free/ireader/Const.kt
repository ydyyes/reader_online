package com.bule.free.ireader

/**
 * Created by liumin on 2018/12/14.
 */
object Const {

    const val DEBUG = false;
    // 渠道
    val channelConfig = Channel2.XIAO_MI
    const val APP_WEB_PAGE = "http://rd.17k.ren/"

    const val SHARE_TEXT = "快读免费小说，永久免费阅读！最新、最火、最全的小说阅读器！下载请戳我${APP_WEB_PAGE}超快更新，超多爽文等你来看！"

    object Api {
        const val areaCode = "+86"
    }

    // 百度广告: https://mssp.baidu.com/home
    object BDAD {
        const val APPID = "e6fcdd83"
        const val BANNER_POS_ID = "6132818"
        const val BANNER_READ_BOTTOM_POS_ID = "6198350"
        const val SPLASH_POS_ID = "6038482"
    }

    object Color {
        const val COMMON_AOI = 0xFF2F94F9.toInt()
        const val COIN_RED = 0xFFFE3B30.toInt()
    }

    // shared preference 缓存文件名
    object SpFileName {
        const val USER = "user"
        const val APP_CONFIG = "app_conf"
    }

    enum class MissionType(val serverValue: Int) {
        SIGN(1), SHARE(2), READ_120MIN(3),
        BIND_PHONE(4), WATCH_VIDEO(5), READ_30MIN(6),
        READ_60MIN(7), INVITE_1_FRIEND(8), INVITE_3_FRIEND(9);
    }

    enum class Gender(val apiParam: Int, val text: String) {
        NONE(0, "未知"), MAN(1, "男"), WOMAN(2, "女");
    }

    // 多渠道配置, 默认值是快读小说，华为和美阅需要改很多东西
    enum class Channel2(
            val channelName: String,
            val umeng: UmengConfig = UmengConfig("5c0600d3b465f50ae60001b6", "b2fb64ba9f013efab47de3facbfabf6f"),
            val packageName: String = "com.freex.xiaoshuo1.whalereader",
            val appName: String = "快读小说",
            val ic_launcher: Int = R.drawable.ic_launcher_online,
            val bg_splash: Int = R.drawable.bg_splash_online,
            val gdt: GDTConfig = GDTConfig("1108389604", "7040368468488980", "9080165705716311",
                    "3020351800224268", "6000256820324286", "4030166781126163"),
            val ttad: TTAdConfig = TTAdConfig("5012751", "912751441",
                    "812751802", "912751671", "912751093", "912751211", "912751990"),
            val yomi: YouMiConfig = YouMiConfig("a4004a79c607cb93", "c0ec3d6587d50a0d"),
            val tuia: TuiaConfig = TuiaConfig("2H5hGbx4zinHCRCveC6itzfNCMCp", "3W4mJJdtPUauWUKNSSzVNk9DUeR4PssDtmV88Hu", "58826", 273972)
    ) {
        // 测试渠道
        TEST(channelName = "test"),
        // 小米渠道
        XIAO_MI(channelName = "xiaomi"),
        // 官网渠道
        GUAN_WANG(channelName = "guanwang"),
        // web渠道
        WEB(channelName = "web"),
        // 不知道什么鬼的渠道
        SXIXI01(channelName = "sxixi01"),
        // 不知道什么鬼的渠道
        MIKEY(channelName = "mikey"),
        // 放自己官网的渠道
        H5TG521(channelName = "h5tg521"),
        //美阅小说
        MEI_YUE(channelName = "xiaomi",
                packageName = "com.free.android.mywhalereader",
                appName = "美阅小说",
                ic_launcher = R.drawable.ic_launcher_meiyue1,
                bg_splash = R.drawable.bg_splash_meiyue1),
        // 华为包
        HUA_WEI(channelName = "huawei",
                umeng = UmengConfig("5cb96abc3fc1951676000c60", "0f1ac2e0ceac3392257d14acf9b4fc3e"),
                packageName = "com.cohesion.kdxiaoshuo",
                gdt = GDTConfig("1108996346", "9080760488199138", "3040060745917376",
                        "4060067488095223", "5070166478293114", ""),
                ttad = TTAdConfig("5017404", "917404217",
                        "817404044", "917404740", "917404368", "917404831", ""),
                yomi = YouMiConfig("a96c35c1d7bb1ca0", "2f975bbe62e30910"),
                tuia = TuiaConfig("fCjiuzwYPsp96nYJQc2wQxaprHU", "3W5nBN7VK9VHn78qGyshAfE7VeyQxKzrQzcz2Vm", "61123", 286956)),
        VIVV(channelName = "vivv",
                umeng = HUA_WEI.umeng,
                packageName = HUA_WEI.packageName,
                gdt = HUA_WEI.gdt,
                ttad = HUA_WEI.ttad,
                yomi = HUA_WEI.yomi,
                tuia = HUA_WEI.tuia
        ),
        OPPN(channelName = "oppn",
                umeng = HUA_WEI.umeng,
                packageName = HUA_WEI.packageName,
                gdt = HUA_WEI.gdt,
                ic_launcher = R.drawable.ic_launcher_huawei1,
                ttad = HUA_WEI.ttad,
                yomi = HUA_WEI.yomi,
                tuia = HUA_WEI.tuia
        ),
        YINGY(channelName = "yingy",
                umeng = HUA_WEI.umeng,
                packageName = HUA_WEI.packageName,
                gdt = HUA_WEI.gdt,
                ttad = HUA_WEI.ttad,
                yomi = HUA_WEI.yomi,
                tuia = HUA_WEI.tuia
        ),
        MIKEY_HUA_WEI(channelName = "mikey",
                umeng = HUA_WEI.umeng,
                packageName = HUA_WEI.packageName,
                gdt = HUA_WEI.gdt,
                ttad = HUA_WEI.ttad,
                yomi = HUA_WEI.yomi,
                tuia = HUA_WEI.tuia),
        MIKEY_01(channelName = "mikey01",
                umeng = HUA_WEI.umeng,
                packageName = HUA_WEI.packageName,
                gdt = HUA_WEI.gdt,
                ttad = HUA_WEI.ttad,
                yomi = HUA_WEI.yomi,
                tuia = HUA_WEI.tuia),
        _360(channelName = "360",
                umeng = HUA_WEI.umeng,
                packageName = HUA_WEI.packageName,
                gdt = HUA_WEI.gdt,
                ttad = HUA_WEI.ttad,
                yomi = HUA_WEI.yomi,
                tuia = HUA_WEI.tuia),
        MY_XIAOM(channelName = "myxiaom",
                umeng = UmengConfig("5c0600e8b465f50d750001a3", "f75f631a60f67eac58f43968b93d5cd5"),
                packageName = "com.free.myxiaoshuo",
                gdt = GDTConfig(app_id = "1109496288",
                        read_banner_pos_id = "9080264971137488",
                        banner_pos_id = "9080264971137488",
                        native_pos_id = "7030163911637494",
                        splash_pos_id = "6060261921535480",
                        interstitial_pos_id = ""),
                ttad = TTAdConfig(app_id = "5020960",
                        feed_pos_id = "920960662",
                        banner_common_id = "920960114",
                        banner_read_bottom_pos_id = "920960114",
                        splash_pos_id = "820960022",
                        video_pos_id = "920960916",
                        interstitial_pos_id = ""),
                ic_launcher = R.drawable.ic_launcher_red_meiyue,
                bg_splash = R.drawable.bg_splash_red_meiyue,
                appName = "美阅小说"),
        MY_HUAW(channelName = "myhuaw",
                umeng = MY_XIAOM.umeng,
                packageName = MY_XIAOM.packageName,
                gdt = MY_XIAOM.gdt,
                ttad = MY_XIAOM.ttad,
                ic_launcher = MY_XIAOM.ic_launcher,
                bg_splash = MY_XIAOM.bg_splash,
                appName = MY_XIAOM.appName),
        MY_VIV(channelName = "myviv",
                umeng = MY_XIAOM.umeng,
                packageName = MY_XIAOM.packageName,
                gdt = MY_XIAOM.gdt,
                ttad = MY_XIAOM.ttad,
                ic_launcher = MY_XIAOM.ic_launcher,
                bg_splash = MY_XIAOM.bg_splash,
                appName = MY_XIAOM.appName),
        MY_YINGY(channelName = "myyingy",
                umeng = MY_XIAOM.umeng,
                packageName = MY_XIAOM.packageName,
                gdt = MY_XIAOM.gdt,
                ttad = MY_XIAOM.ttad,
                ic_launcher = MY_XIAOM.ic_launcher,
                bg_splash = MY_XIAOM.bg_splash,
                appName = MY_XIAOM.appName),
    }

    data class UmengConfig(val appKey: String, val messageSecret: String)

    // 腾讯广点通: https://adnet.qq.com
    data class GDTConfig(
            val app_id: String,
            val read_banner_pos_id: String, // 阅读页的banner id
            val banner_pos_id: String, // 除阅读页都用这个banner id
            val splash_pos_id: String, // 开屏
            val native_pos_id: String, // 原生
            val interstitial_pos_id: String // 插屏(已弃用)
    )

    data class TTAdConfig(
            val app_id: String,
            val feed_pos_id: String,
            val splash_pos_id: String,
            val video_pos_id: String,
            val banner_read_bottom_pos_id: String,// 添加阅读页底部末尾
            val banner_common_id: String, // 除阅读页的banner id
            val interstitial_pos_id: String
    )

    data class YouMiConfig(
            val app_id: String,
            val app_secret: String
    )

    data class TuiaConfig(
            val app_key: String,
            val app_secret: String,
            val app_id: String,
            val dobber_pos_id: Int
    )
}
