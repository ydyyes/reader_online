package com.bule.free.ireader.module.coin

import android.app.Activity
import android.content.Intent
import com.bule.free.ireader.R
import com.bule.free.ireader.ui.base.BaseActivity2

/**
 * Created by suikajy on 2019/3/21
 */
class CoinIntroActivity : BaseActivity2() {
    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, CoinIntroActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId = R.layout.activity_coin_intro

    override fun init() {
    }

    override fun setListener() {
    }


}