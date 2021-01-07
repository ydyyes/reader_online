package com.bule.free.ireader.common.share

import android.support.v4.app.FragmentActivity


/**
 * Created by suikajy on 2019/3/4
 */

object ShareUtils {
    fun shareText(fragmentActivity: FragmentActivity, content: String, predicate: (Boolean) -> Unit) {
        ShareHandleFragment.startShare(fragmentActivity, content, predicate)
    }
}