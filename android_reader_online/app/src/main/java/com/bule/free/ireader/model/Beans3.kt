package com.bule.free.ireader.model

import com.bule.free.ireader.model.bean.BookDetailBean
import com.bule.free.ireader.model.bean.CategoryBean

/**
 * Created by suikajy on 2019-05-06
 */

data class BookmarkBean(
        val label: String,
        val percentage: String,
        val timestemp: String,
        val title: String = "章节标题"
)

data class ProductBean(
        val create_time: String,
        val discount_price: String,
        val exchange_time: String,
        val explain: String,
        val id: String,
        val price: String,
        val product_name: String,
        val send_gold: String,
        val status: String,
        val type: String,
        val update_time: String,
        var selected: Boolean
)

data class PayOrder(
        val code: String,
        val merchant_order_no: String,
        val pay_url: String,
        val sign: String
)

data class PayLogBean(
        val pay_price: String,
        val status: String,
        val create_time: String,
        val name: String
)

// 书城新版bean，用于第五版
data class BookMallBean3_0(
        val hot_search: List<BookDetailBean?>?,
        val hot_update: List<BookDetailBean?>?,
        val new: List<BookDetailBean?>?,
        val over: List<BookDetailBean?>?,
        val recommend: List<BookDetailBean?>?,
        val gentleman: List<BookDetailBean?>?,
        val lady: List<BookDetailBean?>?
)

// 书籍分类列表
data class BookCateListBean(
        val gentleman: List<CategoryBean>,
        val lady: List<CategoryBean>
)

// 首页今日推荐Bean
data class TodayRecBookBean(
        val author: String,
        val cover: String,
        val gender: String,
        val id: String,
        val isfree: String,
        val lastChapter: String,
        val latelyFollower: String,
        val longIntro: String,
        val maCate: String,
        val majorCate: String,
        val over: String,
        val retentionRatio: String,
        val score: String,
        val serializeWordCount: String,
        val tags: String,
        val title: String,
        val updated: String,
        val wordCount: String
)