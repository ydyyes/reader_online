package com.bule.free.ireader.module.bookcate

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.support.v4.app.Fragment
import android.view.View
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.Res
import com.bule.free.ireader.common.utils.ToastUtils
import com.bule.free.ireader.common.widget.MVerticalTabLayout
import com.bule.free.ireader.model.bean.CategoryBean
import com.bule.free.ireader.ui.base.BaseActivity2
import com.umeng.analytics.MobclickAgent
import kotlinx.android.synthetic.main.activity_book_cate.*
import q.rorbin.verticaltablayout.adapter.TabAdapter
import q.rorbin.verticaltablayout.widget.ITabView
import q.rorbin.verticaltablayout.widget.TabView
import java.util.*

/**
 * Created by suikajy on 2019-05-21
 */
class BookCateActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, BookCateActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId = R.layout.activity_book_cate
    private var mGender = Const.Gender.MAN
    private val mGentlemanCateList = mutableListOf<CategoryBean>()
    private val mLadyBookCate = mutableListOf<CategoryBean>()

    override fun init() {
        refreshLeftTypes()
    }

    override fun setListener() {
        btn_back.setOnClickListener { finish() }
        swh_gender.setOnCheckedChangeListener { _, isChecked ->
            mGender = if (isChecked) Const.Gender.MAN else Const.Gender.WOMAN
            refreshView()
        }
    }

    private fun refreshLeftTypes() {
        Api.getBookCateList()
                .go({ bookCateListBean ->
                    LogUtils.e("bookCateListBean: $bookCateListBean")
                    mGentlemanCateList.clear()
                    mGentlemanCateList.add(CategoryBean("", "-1", "推荐", "1"))
                    mGentlemanCateList.addAll(bookCateListBean.gentleman)
                    mLadyBookCate.clear()
                    mLadyBookCate.add(CategoryBean("", "-1", "推荐", "2"))
                    mLadyBookCate.addAll(bookCateListBean.lady)
                    refreshView()
                }, {
                    ToastUtils.show("数据加载异常，请稍后重试")
                    tv_loaderr.visibility = View.VISIBLE
                    fragment_container.visibility = View.GONE
                    book_mall_tablayout.visibility = View.GONE
                }, true)
    }

    fun refreshView() {
        if (isDestroyed) return
        val cateBeanLists = if (mGender == Const.Gender.WOMAN) mLadyBookCate else mGentlemanCateList
        tv_loaderr.visibility = View.GONE
        fragment_container.visibility = View.VISIBLE
        book_mall_tablayout.visibility = View.VISIBLE
        val tabAdapter = object : TabAdapter {
            override fun getBadge(position: Int) = null

            override fun getBackground(position: Int) = Res.color(R.color.black)

            override fun getTitle(position: Int): ITabView.TabTitle {
                return ITabView.TabTitle.Builder()
                        .setContent(cateBeanLists[position].name)
                        .setTextSize(14)
                        .setTextColor(Color.BLACK, Color.BLACK)
                        .build()
            }

            override fun getCount() = cateBeanLists.size

            override fun getIcon(position: Int) = null
        }

        val fragments = getFragments(cateBeanLists)
        book_mall_tablayout.setupWithFragment(supportFragmentManager, R.id.fragment_container, fragments, tabAdapter)
        book_mall_tablayout.setTabSelected(0, true)

        book_mall_tablayout.addOnTabSelectedListener(object : MVerticalTabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabView?, position: Int) {
                try {
                    val cateName = cateBeanLists[position].name
                    MobclickAgent.onEvent(this@BookCateActivity, "book_class_click", cateName)
                } catch (e: Exception) {
                }
            }

            override fun onTabReselected(tab: TabView?, position: Int) {

            }
        })
    }

    private fun getFragments(mBookCateBeans: List<CategoryBean>): List<Fragment> {
        val fragments = ArrayList<Fragment>()

        for (mBookCateBean in mBookCateBeans) {
            val fragment = BookCateFragment()
            fragment.setBookCates(mBookCateBean)
            fragments.add(fragment)
        }

        return fragments
    }
}