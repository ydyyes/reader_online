/**
 * Copyright 2016 JustWayward Team
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.bule.free.ireader.ui.activity

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.bule.free.ireader.App
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.ui.base.BaseActivity
import kotlinx.android.synthetic.main.activity_web_ads.*

class WebAdsActivity : BaseActivity() {

    companion object {
        fun start(url: String) {
            val intent = Intent(App.instance, WebAdsActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent.putExtra("url",url)
            App.instance.startActivity(intent)
        }
//        fun start(url: String) {
//            val intent = Intent()
//            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
////            intent.addCategory(Intent.CATEGORY_BROWSABLE)
////            intent.data = Uri.parse(url)
//
//            App.instance.startActivity(intent)
//        }
    }

    override fun getContentId() = R.layout.activity_web_ads

    override fun processLogic() {
        super.processLogic()
        val url = intent.getStringExtra("url")
        LogUtils.i(url)
        if (url != "") {
            if (!url.startsWith("http")) {
                feedbackView.loadUrl("http://$url")
            } else {
                feedbackView.loadUrl(url)
            }
        }
    }
}
