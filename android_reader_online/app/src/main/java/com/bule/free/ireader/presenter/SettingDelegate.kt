package com.bule.free.ireader.presenter

import android.app.Activity
import android.app.AlertDialog
import com.bule.free.ireader.R
import com.bule.free.ireader.model.RefreshBookShelfEvent
import com.bule.free.ireader.model.User
import com.bule.free.ireader.common.utils.FileUtils
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.common.download.BookDownloader
import com.bule.free.ireader.model.bean.BookChapterBean
import com.bule.free.ireader.model.bookchapter.BookChapterManager
import com.bule.free.ireader.model.objectbox.OB
import com.bule.free.ireader.model.objectbox.bean.*
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.functions.Consumer
import io.reactivex.schedulers.Schedulers
import java.io.File
import java.util.*

/**
 * Created by suikajy on 2019/4/11
 */
class SettingDelegate(val activity: Activity) {

    val dbSize: String
        get() {
            val dbPath = "/data/data/${activity.packageName}/files/objectbox/"
            val size = FileUtils.getDirSize(File(dbPath))
            return FileUtils.getFileSize(size)
        }

    fun showSetBookOrderDialog(consumer: Consumer<Int>? = null) {
        val sort = User.shelfSort
        AlertDialog.Builder(activity)
                .setTitle("书架排序")
                .setSingleChoiceItems(activity.resources.getStringArray(R.array.setting_dialog_sort_choice),
                        sort
                ) { dialog, which ->
                    consumer?.accept(which)
                    User.shelfSort = which
                    RxBus.post(RefreshBookShelfEvent)
                    dialog.dismiss()
                }.create().show()
    }

    fun showClearCacheDialog(successConsumer: Consumer<String>) {
        val selected = booleanArrayOf(true, false)
        AlertDialog.Builder(activity)
                .setTitle("清除缓存")
                .setCancelable(true)
                .setMultiChoiceItems(arrayOf("删除阅读记录", "清空书架列表"), selected) { dialog, which, isChecked -> selected[which] = isChecked }
                .setPositiveButton("确定") { dialog, which ->
                    Observable.create<String> { e ->
                        LogUtils.e(Arrays.toString(selected))
                        if (selected[0]) {
                            clearBookHistory()
                            clearBookContent()
                        }

                        if (selected[1]) {
                            clearBookShelf()
                        }

                        val cacheSize = dbSize
                        e.onNext(cacheSize)
                        e.onComplete()
                    }.subscribeOn(Schedulers.computation())
                            .observeOn(AndroidSchedulers.mainThread())
                            .subscribe(successConsumer)
                    dialog.dismiss()
                }.setNegativeButton("取消") { dialog, which -> dialog.dismiss() }
                .create().show()
    }

    private fun clearBookHistory() {
        try {
            OB.boxStore.boxFor(ReadRecordBean::class.java).removeAll()
            OB.boxStore.boxFor(BookChapterBean::class.java).removeAll()
            BookChapterManager.clear()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun clearBookContent() {
        try {
            //阅读记录不能清除掉下载的书本
            OB.boxStore.boxFor(DownloadTaskBean::class.java).removeAll()
            BookDownloader.downloadTaskList.clear()
//            val bookCacheList = DatabaseUtils.helper.queryByWhere(BookContentBean::class.java, "type=?", arrayOf("0"), null)
//            DatabaseUtils.helper.deleteAll(bookCacheList)
            val bookContentBox = OB.boxStore.boxFor(BookChContentBean::class.java)
            bookContentBox.query().equal(BookChContentBean_.type, 0).build().remove()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun clearBookShelf() {
        try {
            OB.boxStore.boxFor(BookBean::class.java).removeAll()
            RxBus.post(RefreshBookShelfEvent)
//            val bookCacheList = DatabaseUtils.helper.queryByWhere(BookContentBean::class.java, "type=?", arrayOf("1"), null)
//            DatabaseUtils.helper.deleteAll(bookCacheList)
        } catch (e: Exception) {
            e.printStackTrace()
        }

    }
}
