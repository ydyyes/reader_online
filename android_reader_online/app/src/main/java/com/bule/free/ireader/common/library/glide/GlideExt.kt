package com.bule.free.ireader.common.library.glide

import android.app.Activity
import android.view.View
import android.widget.ImageView
import com.bule.free.ireader.R
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions

/**
 * Created by suikajy on 2019/4/9
 */


fun ImageView.load(model: Any) {
    if (isActivityDestroyed()) return
    Glide.with(this).setDefaultRequestOptions(G.sDefaultOptions).load(model).into(this)
}

object G {
    val sDefaultOptions by lazy {
        RequestOptions()
                .error(R.drawable.common_bg_book_placeholder)
                .placeholder(R.drawable.common_bg_book_placeholder)
    }
}

private fun View.isActivityDestroyed(): Boolean {
    val tmpContext = context
    if (tmpContext is Activity) {
        return tmpContext.isDestroyed
    }
    return false
}