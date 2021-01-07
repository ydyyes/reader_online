package com.bule.free.ireader.common.utils

import android.app.Activity
import android.os.Build
import android.view.View
import android.view.WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
import android.widget.PopupWindow
import com.bule.free.ireader.Const
import com.bule.free.ireader.model.Global
import com.bule.free.ireader.newbook.ReadBookConfig

/**
 * Created by suikajy on 2019/3/26
 */

fun Const.MissionType.getBean() = Global.missionList.find { it.task_type == this.serverValue.toString() }

fun Const.MissionType.getHour(): Int {
    val bean = getBean() ?: return 0
    return if (bean.type == "1") bean.num.toInt() else 0
}

fun Const.MissionType.getEarnCoinCount(): Int {
    val bean = getBean() ?: return 0
    return if (bean.type == "2") bean.num.toInt() else 0
}

fun Activity.setUIMode(uiMode: ReadBookConfig.UIMode) {
    if (uiMode.isNight()) {
        setScreenBrightnessMode(true)
        setWindowBrightness(32f)
    } else {
        setScreenBrightnessMode(false)
        setWindowBrightness(BRIGHTNESS_OVERRIDE_NONE)
    }
}

fun PopupWindow.hideSystemBar() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
        contentView.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
    }
}