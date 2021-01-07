package com.bule.free.ireader.common.utils

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.drawable.Drawable
import android.support.annotation.*
import android.support.v4.content.ContextCompat
import android.view.animation.Animation
import android.view.animation.AnimationUtils

import com.bule.free.ireader.App

/**
 * Created by suikajy on 2019/2/19
 */
object Res {
    private val application: Context
        get() = App.instance

    fun color(@ColorRes colorId: Int): Int {
        return ContextCompat.getColor(application, colorId)
    }

    fun colorStateList(@ColorRes colorListId: Int): ColorStateList {
        return application.resources.getColorStateList(colorListId)
    }

    fun string(@StringRes stringId: Int): String {
        return application.getString(stringId)
    }

    fun drawable(@DrawableRes drawableId: Int): Drawable? {
        return ContextCompat.getDrawable(application, drawableId)
    }

    fun boundDrawable(@DrawableRes drawableId: Int): Drawable {
        val drawable = ContextCompat.getDrawable(application, drawableId)
        drawable!!.setBounds(0, 0, drawable.minimumWidth, drawable.minimumHeight)
        return drawable
    }

    fun anim(@AnimRes animId: Int): Animation {
        return AnimationUtils.loadAnimation(application, animId)
    }

    fun stringArray(@ArrayRes arrayId: Int): Array<String> = application.resources.getStringArray(arrayId)
}
