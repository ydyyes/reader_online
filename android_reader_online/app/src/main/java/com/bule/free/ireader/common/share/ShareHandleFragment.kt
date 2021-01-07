package com.bule.free.ireader.common.share

import android.content.Intent
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentActivity
import com.bule.free.ireader.common.utils.LogUtils
import java.util.*

/**
 * Created by suikajy on 2019/3/4
 */
class ShareHandleFragment : Fragment() {

    companion object {
        const val SHARE_REQ_CODE = 0x768
        const val TAG = "shf"

        fun startShare(fragmentActivity: FragmentActivity, content: String, block: (Boolean) -> Unit) {
            val shareHandleFragment = ShareHandleFragment()
            fragmentActivity.supportFragmentManager.beginTransaction()
                    .add(shareHandleFragment, TAG)
                    .commitNow()
            shareHandleFragment.shareText(content, block)
        }


    }

    private var mShareStartTime = 0L
    private var mCallback: ((Boolean) -> Unit)?=null

    fun shareText(content: String, block: (Boolean) -> Unit) {
        mCallback = block
        val textIntent = Intent(Intent.ACTION_SEND)
        textIntent.type = "text/plain"
        textIntent.putExtra(Intent.EXTRA_TEXT, content)
        mShareStartTime = System.currentTimeMillis()
        startActivityForResult(Intent.createChooser(textIntent, "分享"), SHARE_REQ_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SHARE_REQ_CODE) {
            LogUtils.d("onActivityResult $SHARE_REQ_CODE")
            if (System.currentTimeMillis() - mShareStartTime >= getInterval()) {
                mCallback?.invoke(true)
            } else {
                mCallback?.invoke(false)
            }
        }
    }

    private fun getInterval(): Long {
        val curCal = Calendar.getInstance()!!
        val hour = curCal.get(Calendar.HOUR_OF_DAY)
        val y = (hour * (24 - hour)).toFloat() / 72 + 1
        return (y * 1000).toLong()
    }
}