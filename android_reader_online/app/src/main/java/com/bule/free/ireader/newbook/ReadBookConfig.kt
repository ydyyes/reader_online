package com.bule.free.ireader.newbook

import android.graphics.Color
import android.support.annotation.DrawableRes
import com.bule.free.ireader.App
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.ChangeNightModeEvent

object ReadBookConfig {

    const val DEFAULT_TEXT = 2
    const val DEFAULT_BG = 1
    private const val KEY_CAN_CLICK_TURN = "canClickTurn"
    private const val KEY_CAN_KEY_TURN = "canKeyTurn"
    private const val KEY_TEXT_KIND_INDEX = "textKindIndex"
    private const val KEY_IS_SHOW_ANIM = "showanmi"
    private const val KEY_TEXT_DRAWABLE_INDEX = "textDrawableIndex"
    private const val KEY_UI_MODE = "uiMode"
    private const val KEY_LIGHT = "custom_light"
    private const val KEY_IS_LIGHT_FOLLOW_SYS = "is_light_follow_sys"
    private const val KEY_LAST_TEXT_DRAWABLE_INDEX = "last_text_drawable_index"

    private val sp: SharedPreUtils = SharedPreUtils.getInstance()

    var canClickTurn: Boolean
        set(value) = sp.putBoolean(KEY_CAN_CLICK_TURN, value)
        get() = sp.getBoolean(KEY_CAN_CLICK_TURN, true)

    var canKeyTurn: Boolean
        set(value) = sp.putBoolean(KEY_CAN_KEY_TURN, value)
        get() = sp.getBoolean(KEY_CAN_KEY_TURN, true)

    var turnAnim: Boolean
        set(value) = sp.putBoolean(KEY_IS_SHOW_ANIM, value)
        get() = sp.getBoolean(KEY_IS_SHOW_ANIM, true)

    var textKindIndex: Int
        set(value) = sp.putInt(KEY_TEXT_KIND_INDEX, value)
        get() = sp.getInt(KEY_TEXT_KIND_INDEX, DEFAULT_TEXT)

    var textDrawableIndex: Int
        set(value) = sp.putInt(KEY_TEXT_DRAWABLE_INDEX, value)
        get() = sp.getInt(KEY_TEXT_DRAWABLE_INDEX, DEFAULT_BG)

    var uiMode: UIMode
        set(value) = sp.putInt(KEY_UI_MODE, value.ordinal)
        get() = ReadBookConfig.UIMode.values()[sp.getInt(KEY_UI_MODE, 0)]

    var light: Int
        set(value) = sp.putInt(KEY_LIGHT, value)
        get() = sp.getInt(KEY_LIGHT, App.instance.getScreenBrightness())

    var isLightFollowSys: Boolean
        set(value) = sp.putBoolean(KEY_IS_LIGHT_FOLLOW_SYS, value)
        get() = sp.getBoolean(KEY_IS_LIGHT_FOLLOW_SYS, true)

    var lastDayModeTextDrawableIndex: Int
        set(value) = sp.putInt(KEY_LAST_TEXT_DRAWABLE_INDEX, value)
        get() = sp.getInt(KEY_LAST_TEXT_DRAWABLE_INDEX, DEFAULT_BG)

    val textKind = listOf(
            TextKind(14, dp(6.5f)),
            TextKind(16, dp(8f)),
            TextKind(18, dp(9f)),
            TextKind(20, dp(11f)),
            TextKind(21, dp(12f)),
            TextKind(22, dp(13f)),
            TextKind(23, dp(14f)),
            TextKind(24, dp(15f)),
            TextKind(25, dp(16f)),
            TextKind(26, dp(17f))
    )

    val textDrawable = listOf(
            TextDrawable(0xFF3E3D3B.toInt(), R.drawable.shape_bg_readbook_white, 0xFFEEEEEE.toInt()),
            TextDrawable(0xFF5E432E.toInt(), R.drawable.bg_readbook_yellow, 0xFFD0BFA6.toInt()),
            TextDrawable(0xFF22482C.toInt(), R.drawable.bg_readbook_green, 0xFFD8E9CE.toInt()),
            TextDrawable(0xFF808080.toInt(), R.drawable.bg_readbook_black, 0xFF2F2F2D.toInt())
    )

    // 文字大小
    val textSize get() = textKind[textKindIndex].textSize
    // 文字间距
    val textExtra get() = textKind[textKindIndex].textExtra
    // 文字颜色
    val textColor get() = textDrawable[textDrawableIndex].textColor
    // 文字背景
    val textBackground get() = textDrawable[textDrawableIndex].textBackground
    // 广告背景
    val advBackground get() = textDrawable[textDrawableIndex].bgColor

    class TextKind(val textSize: Int, val textExtra: Int)
    class TextDrawable(val textColor: Int, @DrawableRes val textBackground: Int, val bgColor: Int)
    enum class UIMode(val menuBarBgColor: Int) {
        DAY(Color.WHITE),
        NIGHT(Color.BLACK);

        fun isNight() = this == NIGHT
        fun changeMode() {
            if (isNight()) {
                LogUtils.e("night")
                lastDayModeTextDrawableIndex = textDrawableIndex
                LogUtils.e("lastDayModeTextDrawableIndex: $lastDayModeTextDrawableIndex")
                textDrawableIndex = 3
            } else {
                LogUtils.e("day")
                LogUtils.e("lastDayModeTextDrawableIndex: $lastDayModeTextDrawableIndex")
                textDrawableIndex = lastDayModeTextDrawableIndex
            }
            LogUtils.e("textDrawableIndex: $textDrawableIndex")
            uiMode = this
            RxBus.post(ChangeNightModeEvent(this))
        }
    }

    interface ModeChangeable {
        fun changeMode(uiMode: UIMode)
    }
}