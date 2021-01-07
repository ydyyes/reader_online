@file:Suppress("SpellCheckingInspection")

package com.bule.free.ireader.model.bean

import com.bule.free.ireader.model.objectbox.bean.BookBean
import java.io.Serializable

data class LoginRegBean(
        val expire: Int,
        val token: String,
        val gold: Int,
        val uni_id: String,
        val invitation_code: String,
        val cover: String,
        val reader_time: Long,
        val nickname: String
)

data class CategoryBean(
        val cover: String, // 这个字段现在没用
        val id: String,
        val name: String,
        val sex: String
)

data class BannerBean(
        val inner: String,
        val banner_local: String,
        val cover: String,
        val fid: String,
        val id: String,
        val img: String,
        val link: String,
        val location: String,
        val name: String,
        val title: String,
        val type: String = "",
        val update: String
)

data class BookMallItemBean(
        val author: String,
        val cover: String = "",
        val gender: String,
        val id: String,
        val isfree: String,
        val lastChapter: String,
        val latelyFollower: String,
        val longIntro: String,
        val majorCate: String,
        val over: Int,
        val retentionRatio: String,
        val score: String,
        val serializeWordCount: String,
        val tags: String,
        val title: String,
        val updated: String,
        val wordCount: String
) {
    companion object {
        fun instanceOf(bookBean: BookBean) = BookMallItemBean(
                author = bookBean.author,
                cover = bookBean.cover,
                gender = bookBean.gender,
                id = bookBean.id,
                isfree = bookBean.isfree,
                lastChapter = bookBean.lastChapter,
                latelyFollower = bookBean.latelyFollower,
                longIntro = bookBean.longIntro,
                majorCate = bookBean.majorCate,
                over = bookBean.over,
                retentionRatio = bookBean.retentionRatio,
                score = bookBean.score,
                serializeWordCount = bookBean.serializeWordCount,
                tags = bookBean.tags,
                title = bookBean.title,
                updated = bookBean.updated,
                wordCount = bookBean.wordCount
        )
    }
}

@Deprecated("被BookBean代替了")
data class BookCollItemBean(
        var author: String = "",
        var cover: String = "",
        var gender: String = "",
        var id: String = "",
        var isfree: String = "",
        var lastChapter: String = "",
        var latelyFollower: String = "",
        var longIntro: String = "",
        var majorCate: String = "",
        var over: Int = 0,
        var retentionRatio: String = "",
        var score: String = "",
        var serializeWordCount: String = "",
        var tags: String = "",
        var title: String = "",
        var updated: String = "",
        var wordCount: String = "",
        var newChapter: Boolean = false,
        var lastRead: String = "",
        var link: String = "" // 书籍广告点击跳转的web页
) {
    companion object {
        fun instanceOf(bookMallItemBean: BookMallItemBean) = BookCollItemBean(
                author = bookMallItemBean.author,
                cover = bookMallItemBean.cover,
                gender = bookMallItemBean.gender,
                id = bookMallItemBean.id,
                isfree = bookMallItemBean.isfree,
                lastChapter = bookMallItemBean.lastChapter,
                latelyFollower = bookMallItemBean.latelyFollower,
                longIntro = bookMallItemBean.longIntro,
                majorCate = bookMallItemBean.majorCate,
                over = bookMallItemBean.over,
                retentionRatio = bookMallItemBean.retentionRatio,
                score = bookMallItemBean.score,
                serializeWordCount = bookMallItemBean.serializeWordCount,
                tags = bookMallItemBean.tags,
                title = bookMallItemBean.title,
                updated = bookMallItemBean.updated,
                wordCount = bookMallItemBean.wordCount,
                newChapter = false,
                lastRead = ""
        )
    }
}

data class UpdateVersionBean(
        val apk_url: String,
        val md5: String,
        val target_size: String,
        val update: Boolean,
        val update_log: String,
        val version: String,
        val forced_updating: String
)

data class BookDetailPageBean(
        val detail: BookDetailBean,
        val recommend: List<BookDetailBean>
) : Serializable


data class ChapterContentBean(
        val url: String
)

data class MissionBean(
        val id: String,
        val name: String,
        val describe: String
)

data class UserInfoBean(
        val expire: String,
        val gold: String,
        val mobile: String,
        val nickname: String,
        val username: String,
        val utid: String,
        val sex: String,
        val cover: String,
        val uni_id: String,
        val invitation_code: String,
        val invitation: String,
        val reader_time: String
)

data class AdvStrategyBean(
        val AD_BROWSE_LIMIT: String,
        val EXCHANGE_GOLD_NUM: Int,
        val SHARE_TIMES_LIMIT: String,
        val STRATEGY_AD_CHAPTER_END_INTV: String,
        val STRATEGY_AD_OPEN: String,
        val STRATEGY_CHAPTER_END_RATIO: String,
        val STRATEGY_FREE_AD_OPEN: String,
        val STRATEGY_FREE_AD_SHOW_INTV: String,
        val STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY: String,
        val STRATEGY_START_RATIO: String,
        val STRATEGY_VIDEO_RATIO: String,
        val STRATEGY_RED_PACKET: String,
        val BANNER_AD_SWITCH: String,
        val BANNER_AD_RATIO: String,
        val BANNER_AD_LIMIT: String,
        val CONTACT_US: String,
        val STRATEGY_SCREEN_LIMIT: String,
        val STRATEGY_SCREEN_RATIO: String,
        val STRATEGY_SCREEN_SWITCH: String,
        val STRATEGY_START_LOAD: String,
        val BANNER_AD_LOAD: String
)

