package com.bule.free.ireader.newbook.ui

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.view.WindowManager
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.model.NewReadBookChangeReadBgEvent
import com.bule.free.ireader.model.NewReadBookChangeTextSizeEvent
import com.bule.free.ireader.model.NewReadBookSetLightEvent
import com.bule.free.ireader.newbook.ReadBookConfig
import com.bule.free.ireader.ui.base.BaseActivity2
import com.monke.mprogressbar.OnProgressListener
import kotlinx.android.synthetic.main.activity_read_setting.*
import kotlinx.android.synthetic.main.activity_read_setting.hpb_light
import kotlinx.android.synthetic.main.activity_read_setting.scb_follow_sys

/**
 * Created by suikajy on 2019-04-25
 */
class ReadSettingActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, ReadSettingActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId = R.layout.activity_read_setting

    override fun init() {
        if (ReadBookConfig.isLightFollowSys) {
            scb_follow_sys.setChecked(true, false)
        } else {
            scb_follow_sys.setChecked(false, false)
        }
        hpb_light.durProgress = ReadBookConfig.light.toFloat()
        updateText(ReadBookConfig.textKindIndex)
        updateBg(ReadBookConfig.textDrawableIndex)
        updateTurnAnim(ReadBookConfig.turnAnim)
        cb_voice_key_turn.setCheckedImmediatelyNoEvent(ReadBookConfig.canKeyTurn)
        sb_key.setCheckedImmediatelyNoEvent(ReadBookConfig.canClickTurn)
    }

    override fun setListener() {
        btn_bright_follow_system.setOnClickListener {
            if (scb_follow_sys.isChecked) {
                scb_follow_sys.setChecked(false, true)
            } else {
                scb_follow_sys.setChecked(true, true)
            }
        }
        scb_follow_sys.setOnCheckedChangeListener { _, isChecked ->
            ReadBookConfig.isLightFollowSys = isChecked
            if (isChecked) {
                //跟随系统
                hpb_light.canTouch = false
                setScreenBrightness()
            } else {
                //不跟随系统
                hpb_light.canTouch = true
                hpb_light.durProgress = ReadBookConfig.light.toFloat()
            }
        }
        hpb_light.setProgressListener(object : OnProgressListener {
            override fun setDurProgress(dur: Float) {
            }

            override fun durProgressChange(dur: Float) {
                if (ReadBookConfig.isLightFollowSys.not()) {
                    ReadBookConfig.light = dur.toInt()
                    setScreenBrightness(dur.toInt())
                }
            }

            override fun moveStartProgress(dur: Float) {
            }

            override fun moveStopProgress(dur: Float) {
            }
        })
        btn_restore_to_default.setOnClickListener { updateText(ReadBookConfig.DEFAULT_TEXT) }
        btn_font_size_smaller.setOnClickListener { updateText(ReadBookConfig.textKindIndex - 1) }
        btn_font_size_bigger.setOnClickListener { updateText(ReadBookConfig.textKindIndex + 1) }
        cb_bg_white.setOnClickListener { updateBg(0) }
        cb_bg_yellow.setOnClickListener { updateBg(1) }
        cb_bg_green.setOnClickListener { updateBg(2) }
        cb_bg_black.setOnClickListener { updateBg(3) }
        cb_no_turn_page_anim.setOnClickListener { updateTurnAnim(false) }
        cb_override_turn_page_anim.setOnClickListener { updateTurnAnim(true) }
        cb_voice_key_turn.setOnCheckedChangeListener { _, isChecked -> ReadBookConfig.canKeyTurn = isChecked }
        sb_key.setOnCheckedChangeListener { _, isChecked -> ReadBookConfig.canClickTurn = isChecked }
    }

    // 设置屏幕亮度为跟随系统
    private fun setScreenBrightness() {
        if (ReadBookConfig.uiMode.isNight()) return
        RxBus.post(NewReadBookSetLightEvent(isFollowSys = true))
        val params = window.attributes
        params.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        window.attributes = params
    }

    // 设置屏幕亮度为自定义亮度
    private fun setScreenBrightness(value: Int) {
        RxBus.post(NewReadBookSetLightEvent(light = value))
        var realValue = value
        if (ReadBookConfig.uiMode.isNight()) {
            realValue /= 2
        }
        val params = window.attributes
        params.screenBrightness = realValue * 1.0f / 255f
        window.attributes = params
    }

    // 设置字体
    private fun updateText(textKindIndex: Int) {
        when (textKindIndex) {
            0 -> {
                btn_font_size_smaller.isEnabled = false
                btn_font_size_bigger.isEnabled = true
            }
            ReadBookConfig.textKind.size - 1 -> {
                btn_font_size_smaller.isEnabled = true
                btn_font_size_bigger.isEnabled = false
            }
            else -> {
                btn_font_size_smaller.isEnabled = true
                btn_font_size_bigger.isEnabled = true
            }
        }
        btn_restore_to_default.isEnabled = textKindIndex != ReadBookConfig.DEFAULT_TEXT
        tv_current_font_size.text = ReadBookConfig.textKind[textKindIndex].textSize.toString()
        ReadBookConfig.textKindIndex = textKindIndex
        RxBus.post(NewReadBookChangeTextSizeEvent(ReadBookConfig.textKindIndex))
    }

    // 设置背景
    private fun updateBg(index: Int) {
        cb_bg_white.borderColor = Color.TRANSPARENT
        cb_bg_green.borderColor = Color.TRANSPARENT
        cb_bg_black.borderColor = Color.TRANSPARENT
        cb_bg_yellow.borderColor = Color.TRANSPARENT
        when (index) {
            0 -> {
                cb_bg_white.borderColor = 0xFF2F94F9.toInt()
            }
            1 -> {
                cb_bg_yellow.borderColor = 0xFF2F94F9.toInt()
            }
            2 -> {
                cb_bg_green.borderColor = 0xFF2F94F9.toInt()
            }
            else -> {
                cb_bg_black.borderColor = 0xFF2F94F9.toInt()
            }
        }
        ReadBookConfig.textDrawableIndex = index
        RxBus.post(NewReadBookChangeReadBgEvent(ReadBookConfig.textDrawableIndex))
    }

    private fun updateTurnAnim(isTurn: Boolean) {
        ReadBookConfig.turnAnim = isTurn
        if (isTurn) {
            cb_no_turn_page_anim.isSelected = false
            cb_override_turn_page_anim.isSelected = true
        } else {
            cb_no_turn_page_anim.isSelected = true
            cb_override_turn_page_anim.isSelected = false
        }
    }
}