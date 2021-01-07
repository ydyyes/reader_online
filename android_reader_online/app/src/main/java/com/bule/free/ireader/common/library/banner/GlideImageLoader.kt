package com.bule.free.ireader.common.library.banner

import android.content.Context
import android.widget.ImageView
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.model.bean.BannerBean
import com.youth.banner.loader.ImageLoader

/**
 * Created by suikajy on 2019-06-05
 */
// banner使用的ImageLoader
class GlideImageLoader : ImageLoader() {
    override fun displayImage(context: Context?, path: Any?, imageView: ImageView?) {
        if (path != null && path is BannerBean) {
            val img = path.img
            imageView?.load(img)
        }
    }

    override fun createImageView(context: Context?): ImageView {
        val simpleDraweeView = ImageView(context)
        simpleDraweeView.scaleType = ImageView.ScaleType.CENTER_CROP
        return simpleDraweeView
    }
}