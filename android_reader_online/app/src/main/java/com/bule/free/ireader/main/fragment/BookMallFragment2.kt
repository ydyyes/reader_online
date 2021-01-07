package com.bule.free.ireader.main.fragment

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.View.GONE
import android.view.View.VISIBLE
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.library.banner.GlideImageLoader
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.common.utils.WebViewUtils
import com.bule.free.ireader.main.MainActivity
import com.bule.free.ireader.model.BookMallBean3_0
import com.bule.free.ireader.model.CateMode
import com.bule.free.ireader.model.MainActivityChangePageEvent
import com.bule.free.ireader.model.User
import com.bule.free.ireader.model.bean.BannerBean
import com.bule.free.ireader.module.bookcate.BookCateActivity
import com.bule.free.ireader.module.coin.MyCoinActivity
import com.bule.free.ireader.module.pay.PayListActivity
import com.bule.free.ireader.ui.activity.*
import com.bule.free.ireader.ui.base.BaseFragment2
import com.umeng.analytics.MobclickAgent
import com.youth.banner.BannerConfig
import kotlinx.android.synthetic.main.fragment_book_mall.*
import kotlinx.android.synthetic.main.layout_book_mall_editor_rec.*
import kotlinx.android.synthetic.main.layout_book_mall_gentleman.*
import kotlinx.android.synthetic.main.layout_book_mall_hot_search.*
import kotlinx.android.synthetic.main.layout_book_mall_hot_update.*
import kotlinx.android.synthetic.main.layout_book_mall_lady.*
import kotlinx.android.synthetic.main.layout_book_mall_new_book.*
import kotlinx.android.synthetic.main.layout_book_mall_over_book.*

/**
 * Created by suikajy on 2019-05-15
 *
 * 第五版的书城
 */
class BookMallFragment2 : BaseFragment2() {

    private val mBannerBeans = mutableListOf<BannerBean>()
    override fun getContentViewId() = R.layout.fragment_book_mall

    override fun init(savedInstanceState: Bundle?) {
        banner_view.setDelayTime(3000)
        banner_view.setIndicatorGravity(BannerConfig.CENTER)
        banner_view.setImageLoader(GlideImageLoader())
        swipe_refresh_layout.isRefreshing = true
        refresh()
    }

    override fun setListener() {
        btn_category.setOnClickListener { BookCateActivity.start(activity!!) }
        banner_view.setOnBannerListener(this::onBannerClick)
        swipe_refresh_layout.setOnRefreshListener { refresh() }
        btn_hot_rank.setOnClickListener { BookListActivity.start(activity!!, CateMode.HOT) }
        btn_evaluation_rank.setOnClickListener { BookListActivity.start(activity!!, CateMode.HIGH_QUALITY) }
        btn_new_book_rank.setOnClickListener { BookListActivity.start(activity!!, CateMode.NEW) }
        btn_over_rank.setOnClickListener { BookListActivity.start(activity!!, CateMode.FINISHED) }
        btn_more_update.setOnClickListener { BookListActivity.start(activity!!, CateMode.HOT_UPDATE) }
        btn_more_editor_rec.setOnClickListener { BookListActivity.start(activity!!, CateMode.EDITOR_REC) }
        btn_more_hot_search.setOnClickListener { BookListActivity.start(activity!!, CateMode.HOT_SEARCH) }
        btn_more_new_book.setOnClickListener { BookListActivity.start(activity!!, CateMode.NEW) }
        btn_more_over_book.setOnClickListener { BookListActivity.start(activity!!, CateMode.FINISHED) }
        btn_more_gentleman.setOnClickListener { BookListActivity.start(activity!!, CateMode.GENTLEMAN) }
        btn_more_lady.setOnClickListener { BookListActivity.start(activity!!, CateMode.LADY) }
    }

    private fun refresh() {
        Api.getBanner().go({ bannerBeans ->
            mBannerBeans.clear()
            mBannerBeans.addAll(bannerBeans.filter { it.banner_local == "1" })
            if (mBannerBeans.isNotEmpty()) {
                banner_view.setImages(mBannerBeans)
                banner_view.start()
            }
        }, {
            LogUtils.e(it.toString())
        }, true)
        var apiParam = User.gender.apiParam
        if (apiParam != 2) {
            apiParam = 1
        }
        Api.getBookMall(apiParam).go({ bean ->
            swipe_refresh_layout.isRefreshing = false
            layout_book_mall_list.visibility = VISIBLE
            tv_layout_error.visibility = GONE
            loadData(bean)
        }, {
            swipe_refresh_layout.isRefreshing = false
            layout_book_mall_list.visibility = GONE
            tv_layout_error.visibility = VISIBLE
        })
    }

    // 毫无封装，直接硬加载，因为不确定需求
    @SuppressLint("SetTextI18n")
    private fun loadData(bean: BookMallBean3_0) {
        if (activity == null) {
            return
        }
        // 热门更新
        val hotUpdateList = bean.hot_update
        if (hotUpdateList != null && hotUpdateList.size > 4) {
            layout_hot_update.visibility = VISIBLE
            divider_hot_update.visibility = VISIBLE
            iv_hot_update_cover1.load(hotUpdateList[0]?.cover ?: "")
            iv_hot_update_cover2.load(hotUpdateList[1]?.cover ?: "")
            iv_hot_update_cover3.load(hotUpdateList[2]?.cover ?: "")
            iv_hot_update_cover4.load(hotUpdateList[3]?.cover ?: "")
            iv_hot_update_cover5.load(hotUpdateList[4]?.cover ?: "")
            tv_hot_update_book_title1.text = hotUpdateList[0]?.title ?: ""
            tv_hot_update_book_title2.text = hotUpdateList[1]?.title ?: ""
            tv_hot_update_book_title3.text = hotUpdateList[2]?.title ?: ""
            tv_hot_update_book_title4.text = hotUpdateList[3]?.title ?: ""
            tv_hot_update_book_title5.text = hotUpdateList[4]?.title ?: ""
            tv_hot_update_author1.text = "${hotUpdateList[0]?.author
                    ?: ""} | ${hotUpdateList[0]?.majorCate ?: ""}"
            tv_hot_update_author2.text = hotUpdateList[1]?.author ?: ""
            tv_hot_update_author3.text = hotUpdateList[2]?.author ?: ""
            tv_hot_update_author4.text = hotUpdateList[3]?.author ?: ""
            tv_hot_update_author5.text = hotUpdateList[4]?.author ?: ""
            tv_hot_update_book_des.text = hotUpdateList[0]?.longIntro ?: ""
            layout_hot_update_book1.setOnClickListener {
                BookDetailActivity.start(activity!!, hotUpdateList[0]?.id ?: "", false)
            }
            layout_hot_update_book2.setOnClickListener {
                BookDetailActivity.start(activity!!, hotUpdateList[1]?.id ?: "", false)
            }
            layout_hot_update_book3.setOnClickListener {
                BookDetailActivity.start(activity!!, hotUpdateList[2]?.id ?: "", false)
            }
            layout_hot_update_book4.setOnClickListener {
                BookDetailActivity.start(activity!!, hotUpdateList[3]?.id ?: "", false)
            }
            layout_hot_update_book5.setOnClickListener {
                BookDetailActivity.start(activity!!, hotUpdateList[4]?.id ?: "", false)
            }
        } else {
            layout_hot_update.visibility = GONE
            divider_hot_update.visibility = GONE
        }
        // 小编推荐
        val recommendList = bean.recommend
        if (recommendList != null && recommendList.size > 4) {
            layout_editor_rec.visibility = VISIBLE
            divider_editor_rec.visibility = VISIBLE
            iv_editor_rec_cover1.load(recommendList[0]?.cover ?: "")
            iv_editor_rec_cover2.load(recommendList[1]?.cover ?: "")
            iv_editor_rec_cover3.load(recommendList[2]?.cover ?: "")
            iv_editor_rec_cover4.load(recommendList[3]?.cover ?: "")
            iv_editor_rec_cover5.load(recommendList[4]?.cover ?: "")
            tv_editor_rec_book_title1.text = recommendList[0]?.title ?: ""
            tv_editor_rec_book_title2.text = recommendList[1]?.title ?: ""
            tv_editor_rec_book_title3.text = recommendList[2]?.title ?: ""
            tv_editor_rec_book_title4.text = recommendList[3]?.title ?: ""
            tv_editor_rec_book_title5.text = recommendList[4]?.title ?: ""
            tv_editor_rec_author1.text = "${recommendList[0]?.author
                    ?: ""} | ${recommendList[0]?.majorCate ?: ""}"
            tv_editor_rec_author2.text = "${recommendList[1]?.author
                    ?: ""} | ${recommendList[1]?.majorCate ?: ""}"
            tv_editor_rec_author3.text = "${recommendList[2]?.author
                    ?: ""} | ${recommendList[2]?.majorCate ?: ""}"
            tv_editor_rec_author4.text = "${recommendList[3]?.author
                    ?: ""} | ${recommendList[3]?.majorCate ?: ""}"
            tv_editor_rec_author5.text = "${recommendList[4]?.author
                    ?: ""} | ${recommendList[4]?.majorCate ?: ""}"
            tv_editor_rec_book_des1.text = recommendList[0]?.longIntro ?: ""
            tv_editor_rec_book_des2.text = recommendList[1]?.longIntro ?: ""
            tv_editor_rec_book_des3.text = recommendList[2]?.longIntro ?: ""
            tv_editor_rec_book_des4.text = recommendList[3]?.longIntro ?: ""
            tv_editor_rec_book_des5.text = recommendList[4]?.longIntro ?: ""
            layout_editor_rec_book1.setOnClickListener {
                BookDetailActivity.start(activity!!, recommendList[0]?.id ?: "", false)
            }
            layout_editor_rec_book2.setOnClickListener {
                BookDetailActivity.start(activity!!, recommendList[1]?.id ?: "", false)
            }
            layout_editor_rec_book3.setOnClickListener {
                BookDetailActivity.start(activity!!, recommendList[2]?.id ?: "", false)
            }
            layout_editor_rec_book4.setOnClickListener {
                BookDetailActivity.start(activity!!, recommendList[3]?.id ?: "", false)
            }
            layout_editor_rec_book5.setOnClickListener {
                BookDetailActivity.start(activity!!, recommendList[4]?.id ?: "", false)
            }
        } else {
            layout_editor_rec.visibility = GONE
            divider_editor_rec.visibility = GONE
        }

        // 热门搜索
        val hotSearchList = bean.hot_search
        if (hotSearchList != null && hotSearchList.size > 4) {
            layout_hot_search.visibility = VISIBLE
            divider_hot_search.visibility = VISIBLE
            iv_hot_search_cover1.load(hotSearchList[0]?.cover ?: "")
            iv_hot_search_cover2.load(hotSearchList[1]?.cover ?: "")
            iv_hot_search_cover3.load(hotSearchList[2]?.cover ?: "")
            iv_hot_search_cover4.load(hotSearchList[3]?.cover ?: "")
            iv_hot_search_cover5.load(hotSearchList[4]?.cover ?: "")
            tv_hot_search_book_title1.text = hotSearchList[0]?.title ?: ""
            tv_hot_search_book_title2.text = hotSearchList[1]?.title ?: ""
            tv_hot_search_book_title3.text = hotSearchList[2]?.title ?: ""
            tv_hot_search_book_title4.text = hotSearchList[3]?.title ?: ""
            tv_hot_search_book_title5.text = hotSearchList[4]?.title ?: ""
            tv_hot_search_author1.text = "${hotSearchList[0]?.author
                    ?: ""} | ${hotSearchList[0]?.majorCate ?: ""}"
            tv_hot_search_author2.text = hotSearchList[1]?.author ?: ""
            tv_hot_search_author3.text = hotSearchList[2]?.author ?: ""
            tv_hot_search_author4.text = hotSearchList[3]?.author ?: ""
            tv_hot_search_author5.text = hotSearchList[4]?.author ?: ""
            tv_hot_search_book_des.text = hotSearchList[0]?.longIntro ?: ""
            layout_hot_search_book1.setOnClickListener {
                BookDetailActivity.start(activity!!, hotSearchList[0]?.id ?: "", false)
            }
            layout_hot_search_book2.setOnClickListener {
                BookDetailActivity.start(activity!!, hotSearchList[1]?.id ?: "", false)
            }
            layout_hot_search_book3.setOnClickListener {
                BookDetailActivity.start(activity!!, hotSearchList[2]?.id ?: "", false)
            }
            layout_hot_search_book4.setOnClickListener {
                BookDetailActivity.start(activity!!, hotSearchList[3]?.id ?: "", false)
            }
            layout_hot_search_book5.setOnClickListener {
                BookDetailActivity.start(activity!!, hotSearchList[4]?.id ?: "", false)
            }
        } else {
            layout_hot_search.visibility = GONE
            divider_hot_search.visibility = GONE
        }
        // 新书榜
        val newBookList = bean.new
        if (newBookList != null && newBookList.size > 4) {
            layout_new_book.visibility = VISIBLE
            divider_new_book.visibility = VISIBLE
            iv_new_book_cover1.load(newBookList[0]?.cover ?: "")
            iv_new_book_cover2.load(newBookList[1]?.cover ?: "")
            iv_new_book_cover3.load(newBookList[2]?.cover ?: "")
            iv_new_book_cover4.load(newBookList[3]?.cover ?: "")
            iv_new_book_cover5.load(newBookList[4]?.cover ?: "")
            tv_new_book_book_title1.text = newBookList[0]?.title ?: ""
            tv_new_book_book_title2.text = newBookList[1]?.title ?: ""
            tv_new_book_book_title3.text = newBookList[2]?.title ?: ""
            tv_new_book_book_title4.text = newBookList[3]?.title ?: ""
            tv_new_book_book_title5.text = newBookList[4]?.title ?: ""
            tv_new_book_author1.text = "${newBookList[0]?.author} | ${newBookList[0]?.majorCate}"
            tv_new_book_author2.text = "${newBookList[1]?.author} | ${newBookList[1]?.majorCate}"
            tv_new_book_author3.text = "${newBookList[2]?.author} | ${newBookList[2]?.majorCate}"
            tv_new_book_author4.text = "${newBookList[3]?.author} | ${newBookList[3]?.majorCate}"
            tv_new_book_author5.text = "${newBookList[4]?.author} | ${newBookList[4]?.majorCate}"
            tv_new_book_book_des1.text = newBookList[0]?.longIntro ?: ""
            tv_new_book_book_des2.text = newBookList[1]?.longIntro ?: ""
            tv_new_book_book_des3.text = newBookList[2]?.longIntro ?: ""
            tv_new_book_book_des4.text = newBookList[3]?.longIntro ?: ""
            tv_new_book_book_des5.text = newBookList[4]?.longIntro ?: ""
            layout_new_book_book1.setOnClickListener {
                BookDetailActivity.start(activity!!, newBookList[0]?.id ?: "", false)
            }
            layout_new_book_book2.setOnClickListener {
                BookDetailActivity.start(activity!!, newBookList[1]?.id ?: "", false)
            }
            layout_new_book_book3.setOnClickListener {
                BookDetailActivity.start(activity!!, newBookList[2]?.id ?: "", false)
            }
            layout_new_book_book4.setOnClickListener {
                BookDetailActivity.start(activity!!, newBookList[3]?.id ?: "", false)
            }
            layout_new_book_book5.setOnClickListener {
                BookDetailActivity.start(activity!!, newBookList[4]?.id ?: "", false)
            }
        } else {
            layout_new_book.visibility = GONE
            divider_new_book.visibility = GONE
        }
        // 完结榜
        val overBookList = bean.over
        if (overBookList != null && overBookList.size > 4) {
            layout_over_book.visibility = VISIBLE
            divider_over_book.visibility = VISIBLE
            iv_over_book_cover1.load(overBookList[0]?.cover ?: "")
            iv_over_book_cover2.load(overBookList[1]?.cover ?: "")
            iv_over_book_cover3.load(overBookList[2]?.cover ?: "")
            iv_over_book_cover4.load(overBookList[3]?.cover ?: "")
            iv_over_book_cover5.load(overBookList[4]?.cover ?: "")
            tv_over_book_book_title1.text = overBookList[0]?.title ?: ""
            tv_over_book_book_title2.text = overBookList[1]?.title ?: ""
            tv_over_book_book_title3.text = overBookList[2]?.title ?: ""
            tv_over_book_book_title4.text = overBookList[3]?.title ?: ""
            tv_over_book_book_title5.text = overBookList[4]?.title ?: ""
            tv_over_book_author1.text = "${overBookList[0]?.author
                    ?: ""} | ${overBookList[0]?.majorCate ?: ""}"
            tv_over_book_author2.text = overBookList[1]?.author ?: ""
            tv_over_book_author3.text = overBookList[2]?.author ?: ""
            tv_over_book_author4.text = overBookList[3]?.author ?: ""
            tv_over_book_author5.text = overBookList[4]?.author ?: ""
            tv_over_book_book_des.text = overBookList[0]?.longIntro ?: ""
            layout_over_book_book1.setOnClickListener {
                BookDetailActivity.start(activity!!, overBookList[0]?.id ?: "", false)
            }
            layout_over_book_book2.setOnClickListener {
                BookDetailActivity.start(activity!!, overBookList[1]?.id ?: "", false)
            }
            layout_over_book_book3.setOnClickListener {
                BookDetailActivity.start(activity!!, overBookList[2]?.id ?: "", false)
            }
            layout_over_book_book4.setOnClickListener {
                BookDetailActivity.start(activity!!, overBookList[3]?.id ?: "", false)
            }
            layout_over_book_book5.setOnClickListener {
                BookDetailActivity.start(activity!!, overBookList[4]?.id ?: "", false)
            }
        } else {
            layout_over_book.visibility = GONE
            divider_over_book.visibility = GONE
        }
//        // 男频
        val gentlemanList = bean.gentleman
        if (gentlemanList != null && gentlemanList.size > 4) {
            layout_gentleman.visibility = VISIBLE
            divider_gentleman.visibility = VISIBLE
            iv_gentleman_cover1.load(gentlemanList[0]?.cover ?: "")
            iv_gentleman_cover2.load(gentlemanList[1]?.cover ?: "")
            iv_gentleman_cover3.load(gentlemanList[2]?.cover ?: "")
            iv_gentleman_cover4.load(gentlemanList[3]?.cover ?: "")
            iv_gentleman_cover5.load(gentlemanList[4]?.cover ?: "")
            tv_gentleman_book_title1.text = gentlemanList[0]?.title ?: ""
            tv_gentleman_book_title2.text = gentlemanList[1]?.title ?: ""
            tv_gentleman_book_title3.text = gentlemanList[2]?.title ?: ""
            tv_gentleman_book_title4.text = gentlemanList[3]?.title ?: ""
            tv_gentleman_book_title5.text = gentlemanList[4]?.title ?: ""
            tv_gentleman_author1.text = "${gentlemanList[0]?.author} | ${gentlemanList[0]?.majorCate}"
            tv_gentleman_author2.text = "${gentlemanList[1]?.author} | ${gentlemanList[1]?.majorCate}"
            tv_gentleman_author3.text = "${gentlemanList[2]?.author} | ${gentlemanList[2]?.majorCate}"
            tv_gentleman_author4.text = "${gentlemanList[3]?.author} | ${gentlemanList[3]?.majorCate}"
            tv_gentleman_author5.text = "${gentlemanList[4]?.author} | ${gentlemanList[4]?.majorCate}"
            tv_gentleman_book_des1.text = gentlemanList[0]?.longIntro ?: ""
            tv_gentleman_book_des2.text = gentlemanList[1]?.longIntro ?: ""
            tv_gentleman_book_des3.text = gentlemanList[2]?.longIntro ?: ""
            tv_gentleman_book_des4.text = gentlemanList[3]?.longIntro ?: ""
            tv_gentleman_book_des5.text = gentlemanList[4]?.longIntro ?: ""
            layout_gentleman_book1.setOnClickListener {
                BookDetailActivity.start(activity!!, gentlemanList[0]?.id ?: "", false)
            }
            layout_gentleman_book2.setOnClickListener {
                BookDetailActivity.start(activity!!, gentlemanList[1]?.id ?: "", false)
            }
            layout_gentleman_book3.setOnClickListener {
                BookDetailActivity.start(activity!!, gentlemanList[2]?.id ?: "", false)
            }
            layout_gentleman_book4.setOnClickListener {
                BookDetailActivity.start(activity!!, gentlemanList[3]?.id ?: "", false)
            }
            layout_gentleman_book5.setOnClickListener {
                BookDetailActivity.start(activity!!, gentlemanList[4]?.id ?: "", false)
            }
        } else {
            layout_gentleman.visibility = GONE
            divider_gentleman.visibility = GONE
        }
//        // 女频
        val ladyList = bean.lady
        if (ladyList != null && ladyList.size > 4) {
            layout_lady.visibility = VISIBLE
            divider_lady.visibility = VISIBLE
            iv_lady_cover1.load(ladyList[0]?.cover ?: "")
            iv_lady_cover2.load(ladyList[1]?.cover ?: "")
            iv_lady_cover3.load(ladyList[2]?.cover ?: "")
            iv_lady_cover4.load(ladyList[3]?.cover ?: "")
            iv_lady_cover5.load(ladyList[4]?.cover ?: "")
            tv_lady_book_title1.text = ladyList[0]?.title ?: ""
            tv_lady_book_title2.text = ladyList[1]?.title ?: ""
            tv_lady_book_title3.text = ladyList[2]?.title ?: ""
            tv_lady_book_title4.text = ladyList[3]?.title ?: ""
            tv_lady_book_title5.text = ladyList[4]?.title ?: ""
            tv_lady_author1.text = "${ladyList[0]?.author
                    ?: ""} | ${ladyList[0]?.majorCate ?: ""}"
            tv_lady_author2.text = ladyList[1]?.author ?: ""
            tv_lady_author3.text = ladyList[2]?.author ?: ""
            tv_lady_author4.text = ladyList[3]?.author ?: ""
            tv_lady_author5.text = ladyList[4]?.author ?: ""
            tv_lady_book_des.text = ladyList[0]?.longIntro ?: ""
            layout_lady_book1.setOnClickListener {
                BookDetailActivity.start(activity!!, ladyList[0]?.id ?: "", false)
            }
            layout_lady_book2.setOnClickListener {
                BookDetailActivity.start(activity!!, ladyList[1]?.id ?: "", false)
            }
            layout_lady_book3.setOnClickListener {
                BookDetailActivity.start(activity!!, ladyList[2]?.id ?: "", false)
            }
            layout_lady_book4.setOnClickListener {
                BookDetailActivity.start(activity!!, ladyList[3]?.id ?: "", false)
            }
            layout_lady_book5.setOnClickListener {
                BookDetailActivity.start(activity!!, ladyList[4]?.id ?: "", false)
            }
        } else {
            layout_lady.visibility = GONE
            divider_lady.visibility = GONE
        }
//        // 男频
    }

    // banner点击判断
    private fun onBannerClick(position: Int) {
        if (position >= mBannerBeans.size) return
        try {
            val bean = mBannerBeans[position]
            val type = bean.type
            if (type.isEmpty()) {
                return
            }
            MobclickAgent.onEvent(context, "banner_click", bean.id)
            when (bean.inner) {
                "1" -> { // 跳转福利中心
                    RxBus.post(MainActivityChangePageEvent(MainActivity.Page.WELFARE))
                }
                "2" -> { // 跳转金币兑换
                    MyCoinActivity.start(activity!!)
                }
                "3" -> { // 跳转邀请好友
                    ShareActivity.start(activity!!)
                }
                "4" -> { // 跳转支付页面
                    PayListActivity.start(activity!!)
                }
                else -> {
                    if (type == "ad") {
                        val link = bean.link
                        if (link.isEmpty().not()) WebViewActivity.start(link)
                    } else if (type == "book") {
                        val bookId = bean.id
                        BookDetailActivity.start(context, bookId, false)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
