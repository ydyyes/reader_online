package com.bule.free.ireader.ui.activity

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import android.view.View
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.model.User
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.common.share.ShareUtils
import com.google.zxing.WriterException
import com.umeng.analytics.MobclickAgent
import io.reactivex.functions.Consumer
import kotlinx.android.synthetic.main.activity_share.*
import java.io.File
import java.io.FileOutputStream

/**
 * Created by suikajy on 2019/3/27
 */
class ShareActivity : BaseActivity2() {

    companion object {
        fun start(context: Context) {
            val intent = Intent(context, ShareActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }
    }

    override val layoutId = R.layout.activity_share

    override fun init() {
        MobclickAgent.onEvent(this, "share_activity", "share")
        @Suppress("DEPRECATION")
        tv_share_web_sit.text = "也可以直接访问网址: " + Const.APP_WEB_PAGE
        tv_invite_code.text ="推荐码：${User.inviteCode}"
        try {
            val bqcode = CodeUtils.createCode(this, Const.APP_WEB_PAGE)
            img_qrcode.setImageBitmap(bqcode)
        } catch (e: WriterException) {
            e.printStackTrace()
        }
    }

    override fun setListener() {
        btn_share_to_friend.setOnClickListener {
            ShareUtils.shareText(this, Const.SHARE_TEXT + "推荐码：" + User.inviteCode) { isSuccess ->
                if (isSuccess) {
                    Api.missionPost2(Const.MissionType.SHARE.serverValue.toString())
                            .go({ missionPostBean ->
                                LogUtils.e("上报成功")
                                User.todayShareCount = missionPostBean.num
                                Api.refreshUserInfo(Consumer { ToastUtils.show("分享成功") })
                            }, { throwable ->
                                LogUtils.e(throwable.toString())
                                LogUtils.e("上报失败")
                            })
                } else {
                    ToastUtils.show("分享失败")
                }
            }
        }
        btn_save_to_album.onSafeClick {
            val bmpqr = loadBitmapFromView(layout_shared_content)
            bmpqr?.let { saveCode(bmpqr) }
        }
    }

    /**
     * 对单独某个View进行截图
     */
    private fun loadBitmapFromView(v: View): Bitmap? {
        val screenshot: Bitmap = Bitmap.createBitmap(v.width, v.height, Bitmap.Config.RGB_565)
        val c = Canvas(screenshot)
        c.translate((-v.scrollX).toFloat(), (-v.scrollY).toFloat())
        v.draw(c)
        return screenshot
    }

    private fun saveCode(btImage: Bitmap) {
        val mImageTime = System.currentTimeMillis()
        val dateSeconds = mImageTime / 1000
        val mImageFileName = "read_$dateSeconds.png"
        val filedcmi = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM)
        var mImageFilePath = Environment.getExternalStorageDirectory().toString() + File.separator + "read"

        if (filedcmi != null && filedcmi.exists()) {
            mImageFilePath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString() + File.separator + "read"
        }
        val fileDir = File(mImageFilePath)
        if (!fileDir.exists()) {
            fileDir.mkdir()
        }

        val file = File(mImageFilePath, mImageFileName)
        try {
            val out = FileOutputStream(file)
            btImage.compress(Bitmap.CompressFormat.JPEG, 90, out)
            out.flush()
            out.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }

        try {

            val mImageWidth = btImage.width
            val mImageHeight = btImage.height

            // 保存截屏到系统MediaStore
            val values = ContentValues()
            val resolver = contentResolver
            values.put(MediaStore.Images.ImageColumns.DATA, mImageFilePath)
            values.put(MediaStore.Images.ImageColumns.TITLE, mImageFileName)
            values.put(MediaStore.Images.ImageColumns.DISPLAY_NAME, mImageFileName)
            values.put(MediaStore.Images.ImageColumns.DATE_TAKEN, mImageTime)
            values.put(MediaStore.Images.ImageColumns.DATE_ADDED, dateSeconds)
            values.put(MediaStore.Images.ImageColumns.DATE_MODIFIED, dateSeconds)
            values.put(MediaStore.Images.ImageColumns.MIME_TYPE, "image/png")
            values.put(MediaStore.Images.ImageColumns.WIDTH, mImageWidth)
            values.put(MediaStore.Images.ImageColumns.HEIGHT, mImageHeight)
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    values)

            values.clear()
            values.put(MediaStore.Images.ImageColumns.SIZE,
                    File(mImageFilePath).length())
            resolver.update(uri!!, values, null, null)


            MediaStore.Images.Media.insertImage(contentResolver,
                    file.absolutePath, mImageFileName, null)

        } catch (e: Exception) {
            e.printStackTrace()
        }

        sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + file.absolutePath)))
        ToastUtils.show("二维码已保存至$mImageFilePath")
    }
}