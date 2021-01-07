package com.bule.free.ireader.model

import com.bule.free.ireader.main.MainActivity
import com.bule.free.ireader.newbook.ReadBookConfig

/**
 * Created by suikajy on 2019/3/4
 */
// 刷新主页书架事件
object RefreshBookShelfEvent

// 添加书籍到书架事件
object AddBookToShelfEvent

// 让主页切换到书架Page事件
object ToBookShelfEvent

// 登录事件
object LoginEvent

// 退出登录
object LogoutEvent

// 下架Event
object OffShelfEvent

data class DownloadMessage(val message: String)

// 下载进度通知事件
object DownloadNotifyEvent

// 记录今日阅读时长事件
object TodayReadTimeEvent

// 刷新用户信息
object UserInfoRefreshEvent

// 主页面ViewPager改变Page事件
data class MainActivityChangePageEvent(val page: MainActivity.Page)

object SignEvent

// 切换夜间模式事件
data class ChangeNightModeEvent(val uiMode: ReadBookConfig.UIMode)

// 改变书架样式事件
object ChangeShelfModeEvent

// 改变阅读亮度事件
data class NewReadBookSetLightEvent(val light: Int = 0, val isFollowSys: Boolean = false)

// 改变阅读字体大小事件
data class NewReadBookChangeTextSizeEvent(val index: Int)

// 改变阅读背景事件
data class NewReadBookChangeReadBgEvent(val index: Int)

// 书签管理点击书签，阅读页面跳转对应章节对应进度
data class NewReadBookBookmarkClickEvent(val bookmarkBean: BookmarkBean)

// 书签管理删除书签，通知阅读页面更改对应页的书签状态
object NewReadBookRefreshBookmarkEvent