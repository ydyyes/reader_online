package com.bule.free.ireader.ui.activity

import android.app.Activity
import android.content.Intent
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.model.User
import com.bule.free.ireader.main.MainActivity
import com.bule.free.ireader.ui.base.BaseActivity2
import com.umeng.analytics.MobclickAgent
import kotlinx.android.synthetic.main.activity_gender_sel.*

/**
 * Created by suikajy on 2019/3/2
 *
 * 性别选择界面
 */
class GenderSelActivity : BaseActivity2() {

    companion object {
        const val TC_999 = 0xFF999999.toInt()
        const val TC_222 = 0xFF222222.toInt()

        fun start(activity: Activity) {
            val intent = Intent(activity, GenderSelActivity::class.java)
            activity.startActivity(intent)
        }
    }

    private var mSelectedGender = Const.Gender.NONE

    private var lastClickTime = 0L

    override val layoutId = R.layout.activity_gender_sel

    override fun init() {
    }

    override fun setListener() {
        btn_man.setOnClickListener { switchGender(Const.Gender.MAN) }
        btn_woman.setOnClickListener { switchGender(Const.Gender.WOMAN) }
        btn_skip.setOnClickListener {
            if (System.currentTimeMillis() - lastClickTime < 1000) return@setOnClickListener
            lastClickTime = System.currentTimeMillis()
            User.isFirstRun = false
            MobclickAgent.onEvent(this@GenderSelActivity, "gender_select", mSelectedGender.toString())
            MainActivity.start(this)
            finish()
        }
    }

    private fun switchGender(gender: Const.Gender) {
        mSelectedGender = gender
        when (mSelectedGender) {
            Const.Gender.MAN -> {
                tv_man.setTextColor(TC_222)
                tv_woman.setTextColor(TC_999)
                tv_label1.setTextColor(TC_999)
                tv_label2.setTextColor(TC_999)
                iv_men.setImageResource(R.drawable.ic_men_p)
                iv_woman.setImageResource(R.drawable.ic_women_v)
                btn_skip.text = "开始阅读"
            }
            Const.Gender.WOMAN -> {
                tv_man.setTextColor(TC_999)
                tv_woman.setTextColor(TC_222)
                tv_label1.setTextColor(TC_999)
                tv_label2.setTextColor(TC_999)
                iv_men.setImageResource(R.drawable.ic_men_v)
                iv_woman.setImageResource(R.drawable.ic_women_p)
                btn_skip.text = "开始阅读"
            }
            Const.Gender.NONE -> {
                tv_man.setTextColor(TC_222)
                tv_woman.setTextColor(TC_222)
                tv_label1.setTextColor(TC_222)
                tv_label2.setTextColor(TC_222)
                iv_men.setImageResource(R.drawable.ic_men_n)
                iv_woman.setImageResource(R.drawable.ic_women_n)
            }
        }
        User.gender = mSelectedGender
    }

    override fun onBackPressed() {
        MainActivity.start(this)
        super.onBackPressed()
    }


}