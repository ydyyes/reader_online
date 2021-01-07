package com.bule.free.ireader.main.fragment

import android.graphics.Color
import android.support.v4.app.Fragment
import android.view.View
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.model.bean.CategoryBean
import com.bule.free.ireader.ui.base.BaseFragment
import com.bule.free.ireader.common.utils.Res
import com.bule.free.ireader.common.utils.ToastUtils
import com.bule.free.ireader.common.utils.go
import com.bule.free.ireader.common.widget.MVerticalTabLayout
import com.umeng.analytics.MobclickAgent
import kotlinx.android.synthetic.main.fragment_bookmall.*
import q.rorbin.verticaltablayout.adapter.TabAdapter
import q.rorbin.verticaltablayout.widget.ITabView
import q.rorbin.verticaltablayout.widget.TabView
import java.util.*

/**
 * Created by suikajy on 2019/2/26
 */
@Deprecated("v3.4.0")
class BookMallFragment : BaseFragment() {

    override fun getContentId() = R.layout.fragment_bookmall

    override fun initClick() {
        tv_loaderr.setOnClickListener { refreshLeftTypes() }
    }

    override fun processLogic() {
        refreshLeftTypes()
        MobclickAgent.onEvent(activity, "book_mall_fragment", "book_mall")
    }

    private fun refreshLeftTypes() {
        Api.getCategory()
                .go(this, {
                    LogUtils.e("its: ${it}")
                    val cateList = it.toMutableList()
                    cateList.add(0, CategoryBean("", "-1", "推荐", "1"))
                    finishRefresh(cateList)
                }, {
                    ToastUtils.show("数据加载异常，请稍后重试")
                    tv_loaderr.visibility = View.VISIBLE
                    fragment_container.visibility = View.GONE
                    book_mall_tablayout.visibility = View.GONE
                })
    }

    fun finishRefresh(cateBeanLists: List<CategoryBean>) {
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
        book_mall_tablayout.setupWithFragment(activity!!.supportFragmentManager, R.id.fragment_container, fragments, tabAdapter)
        book_mall_tablayout.setTabSelected(0, true)

        book_mall_tablayout.addOnTabSelectedListener(object : MVerticalTabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabView, position: Int) {
                try {
                    val cateName = cateBeanLists[position].name
                    MobclickAgent.onEvent(context, "book_class_click", cateName)
                } catch (e: Exception) {
                }
            }

            override fun onTabReselected(tab: TabView, position: Int) {

            }
        })
    }

    private fun getFragments(mBookCateBeans: List<CategoryBean>): List<Fragment> {
        val fragments = ArrayList<Fragment>()

        for (mBookCateBean in mBookCateBeans) {
            val fragment = BookMallByRightFragment()
            fragment.setBookCates(mBookCateBean)
            fragments.add(fragment)
        }

        return fragments
    }
}