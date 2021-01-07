package com.bule.free.ireader.model

import android.app.Activity
import com.bule.free.ireader.App
import com.bule.free.ireader.Const
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.sharepref.SpDel
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.common.utils.ToastUtils
import com.bule.free.ireader.model.bean.LoginRegBean
import com.bule.free.ireader.model.bean.UserInfoBean
import com.bule.free.ireader.module.login.LoginActivity

/**
 * Created by suikajy on 2019/2/25
 */
object User {

    private const val USER_TOKEN = "user_token"
    private const val USER_EXPIRE = "user_expire"
    private const val USER_PHONE = "user_phone"
    private const val USER_NAME = "USER_NAME"
    private const val SHELF_SORT = "shelf_sort"
    private const val FIRST_RUN = "first_run"
    private const val FIRST_LOAD_REMOTE_BOOK = "first_load_remote_book"
    private const val GENDER = "genderInner"
    private const val TODAY_DOWNLOAD_BOOK_TIME_COUNT = "today_download_book_time_count"
    private const val TODAY_READ_MINUTE = "today_read_minute"
    private const val LAST_OPEN_APP_TIME = "last_open_app_time"
    private const val COIN_COUNT = "coin_count"
    private const val SIGNED_DAYS_COUNT = "signed_days_count"
    private const val TODAY_SHARE_COUNT = "today_share_count"
    private const val TODAY_VIDEO_AD_COUNT = "today_video_ad_count"
    private const val TODAY_IS_SIGNED = "today_is_signed"
    private const val TODAY_READ_REWARD_COUNT = "today_read_reward_count"
    private const val IS_BOUND = "is_bound"
    private const val UNI_ID = "uni_id"
    private const val USER_AVATAR_URL = "user_avatar_url"
    private const val USER_INVITE_CODE = "user_invite_code"
    private const val NO_ADV_TIME_BY_WATCH_VIDEO = "no_adv_time_by_watch_video"
    private const val TODAY_CHAPTER_END_VIDEO_SHOW_TIMES = "today_chapter_end_video_show_times"
    private const val TODAY_SHOWED_OPENING_DIALOG = "today_showed_openning_dialog"

    /*********************************** 线上数据缓存 *************************************************/

    var token: String by UserSp(USER_TOKEN, "")

    // 免广告过期时间
    var expire: Long by UserSp(USER_EXPIRE, 0L)

    // 用户手机号
    var phone: String by UserSp(USER_PHONE, "")

    // 用户类型，游客之类
//    var u_type: String by UserSp(U_TYPE, "")

    // 金币数量
    var coinCount: Int by UserSp(COIN_COUNT, 0)

    // 后台的唯一id
    var uniId: String by UserSp(UNI_ID, "")

    // 用户昵称
    var nickName: String by UserSp(USER_NAME, phone)

    var avatarUrl: String by UserSp(USER_AVATAR_URL, "")

    var inviteCode: String by UserSp(USER_INVITE_CODE, "")

    /*********************************** 本地缓存 *************************************************/

    // 是否第一次进入App，是的话因没有书架缓存，所以要从推荐接口获取
    var isFirstLoadRemoteBook: Boolean by UserSp(FIRST_LOAD_REMOTE_BOOK, true)

    // 书架排序方式
    var shelfSort: Int by UserSp(SHELF_SORT, 0)

    // 性别
    private var genderInner: Int by UserSp(GENDER, 0)

    var gender: Const.Gender
        get() = Const.Gender.values()[genderInner]
        set(value) {
            genderInner = value.apiParam
        }

    var isFirstRun: Boolean by UserSp(FIRST_RUN, true)

    var isBound: Boolean by UserSp(IS_BOUND, false)

    // 最近一次开启App的时间
    var lastOpenAppTime: Long by UserSp(LAST_OPEN_APP_TIME, 0)

    // 今日阅读时长 毫秒级
    var todayReadTime: Long by UserSp(TODAY_READ_MINUTE, 0)

    // 今日下载次数
    var todayDownloadTimes: Int by UserSp(TODAY_DOWNLOAD_BOOK_TIME_COUNT, 0)

    // 今日分享次数
    var todayShareCount: Int by UserSp(TODAY_SHARE_COUNT, 0)

    // 今日观看视频广告次数
    var todayWatchVideoAdCount: Int by UserSp(TODAY_VIDEO_AD_COUNT, 0)

    // 今日是否已签到
    var todayIsSigned: Boolean by UserSp(TODAY_IS_SIGNED, false)

    // 阅读奖励 （2版暂时没有用到）
    var todayReadRewardCount: Int by UserSp(TODAY_READ_REWARD_COUNT, 0)

    // 连续签到天数
    var signedDaysCount: Int by UserSp(SIGNED_DAYS_COUNT, 0)

    var isInvited: Boolean by UserSp("is_invited", false)

    // 章节末尾看视频免30分钟广告
    var noAdTimeByWatchVideo: Long by UserSp(NO_ADV_TIME_BY_WATCH_VIDEO, 0L)

    // 章节末尾看视频广告每天最多展示3次
    var todayChapterEndVideoShowTimes: Int by UserSp(TODAY_CHAPTER_END_VIDEO_SHOW_TIMES, 0)

    // 今日是否展示过开启弹窗
    var todayShowedOpeningDialog: Boolean by UserSp(TODAY_SHOWED_OPENING_DIALOG, false)

    // 记录一次下载
    fun logDownload() = todayDownloadTimes++

    fun isCanDownload() = todayDownloadTimes < 4

    fun isLogin() = phone.isNotEmpty()

    fun checkLogin(activity: Activity, tip: String = "请先登录"): Boolean {
        return if (isLogin().not()) {
            ToastUtils.show(tip)
            LoginActivity.start(activity)
            false
        } else {
            true
        }
    }

    fun isVip() = expire > System.currentTimeMillis()

    // 同步用户服务器数据，一般用来同步金币字段
    fun syncToServer() = Api.refreshUserInfo()

    fun onLogout() {
        token = ""
        expire = 0
        phone = ""
        uniId = ""
        avatarUrl = ""
        todayReadTime = 0
        nickName = ""
        inviteCode = ""
        isInvited = false
        syncToServer()
    }

    fun onBind(loginRegBean: LoginRegBean, mobile: String) {
        expire = loginRegBean.expire.toLong() * 1000
        phone = mobile
        token = loginRegBean.token
        coinCount = loginRegBean.gold
        uniId = loginRegBean.uni_id
        avatarUrl = loginRegBean.cover
        inviteCode = loginRegBean.invitation_code
        isBound = true
        RxBus.post(LoginEvent)
        RxBus.post(UserInfoRefreshEvent)
    }

    fun onLogin(loginRegBean: LoginRegBean, mobile: String) {
        LogUtils.e("loginRegBean: $loginRegBean")
        expire = loginRegBean.expire.toLong() * 1000
        phone = mobile
        token = loginRegBean.token
        coinCount = loginRegBean.gold
        uniId = loginRegBean.uni_id
        avatarUrl = loginRegBean.cover
        inviteCode = loginRegBean.invitation_code
        todayReadTime = loginRegBean.reader_time * 1000
        nickName = loginRegBean.nickname
        isBound = true
        LogUtils.e("$todayReadTime   ${loginRegBean.reader_time}")
        RxBus.post(LoginEvent)
        RxBus.post(UserInfoRefreshEvent)
    }

    fun onRefreshUserInfo(userInfoBean: UserInfoBean) {
        LogUtils.e("$userInfoBean")
        expire = userInfoBean.expire.toLong() * 1000
        coinCount = userInfoBean.gold.toInt()
        uniId = userInfoBean.uni_id
        isBound = userInfoBean.mobile.isNotEmpty()
        inviteCode = userInfoBean.invitation_code
        avatarUrl = userInfoBean.cover
        nickName = userInfoBean.nickname
        todayReadTime = userInfoBean.reader_time.toLong() * 1000
        isInvited = userInfoBean.invitation == "1"
        RxBus.post(UserInfoRefreshEvent)
    }

    class UserSp<T>(key: String, default: T)
        : SpDel<T>(App.instance, Const.SpFileName.USER, key, default)
}