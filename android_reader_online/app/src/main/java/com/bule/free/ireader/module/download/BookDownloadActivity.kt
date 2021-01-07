package com.bule.free.ireader.module.download

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.view.View
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.common.download.BookDownloader
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.paging.Paging
import com.bule.free.ireader.common.paging.SwipePagingDel
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.DownloadNotifyEvent
import com.bule.free.ireader.model.objectbox.OB
import com.bule.free.ireader.model.objectbox.bean.BookChContentBean
import com.bule.free.ireader.model.objectbox.bean.BookChContentBean_
import com.bule.free.ireader.model.objectbox.bean.DownloadTaskBean
import com.bule.free.ireader.model.objectbox.bean.DownloadTaskBean_
import com.bule.free.ireader.newbook.ui.NewReadBookActivity
import com.bule.free.ireader.ui.base.BaseActivity2
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.BaseViewHolder
import io.reactivex.Completable
import io.reactivex.Observable
import kotlinx.android.synthetic.main.activity_book_download.*
import org.jetbrains.anko.progressDialog
import java.util.concurrent.TimeUnit

/**
 * Created by suikajy on 2019/3/21
 */
class BookDownloadActivity : BaseActivity2() {
    override val layoutId: Int = R.layout.activity_book_download
    @Volatile
    private var isNeedRefreshList = false
    private var mManageMode = Mode.NORMAL
    private val mAdapter = Adapter()
    private var isDeleting = false
    private val mDownloadBeanList: MutableList<DownloadTaskBean> get() = BookDownloader.downloadTaskList
    private val paging: Paging<DownloadTaskBean> by lazy {
        SwipePagingDel(mAdapter, srv, refreshListener = {
            LogUtils.e("refresh()")
            LogUtils.e(mDownloadBeanList)
            paging.setNewData(mDownloadBeanList)
        }) {
            paging.loadMoreData(emptyList())
        }.apply { goneNoDataView() }
    }

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, BookDownloadActivity::class.java)
            activity.startActivity(intent)
        }

        const val PROGRESS_MAX = 100
    }

    override fun init() {
        changeMode(Mode.NORMAL)
        mDownloadBeanList.forEach { it.isChecked = false }
        paging.refresh()
    }

    override fun setListener() {
        toolbar.setOnRightClickListener {
            changeMode(if (mManageMode == Mode.MANAGE) Mode.NORMAL else Mode.MANAGE)
        }
        btn_delete.setOnClickListener {
            if (isDeleting) return@setOnClickListener
            if (mDownloadBeanList.all { it.isChecked.not() }) {
                return@setOnClickListener
            }
            isDeleting = true
            val progressDialog = progressDialog(message = "删除中，请稍后....")
            progressDialog.isIndeterminate = true
            progressDialog.show()
            Completable.create { source ->
                try {
                    val iterator = mDownloadBeanList.iterator()
                    val dlTaskBox = OB.boxStore.boxFor(DownloadTaskBean::class.java)
                    val contentBox = OB.boxStore.boxFor(BookChContentBean::class.java)
                    while (iterator.hasNext()) {
                        val bean = iterator.next()
                        if (bean.isChecked) {
                            iterator.remove()
                            //DatabaseUtils.helper.delete(bean)
                            dlTaskBox.query().equal(DownloadTaskBean_._id, bean._id).build().remove()
//                            DatabaseUtils.helper.deleteByWhere(BookChContentBean::class.java, "bookId", bean.bookId)
                            contentBox.query().equal(BookChContentBean_.bookId, bean.bookId).build().remove()
                            bean.status = DownloadTaskBean.STATUS_DELETED
                        }
                    }
                } catch (e: Exception) {
                    source.onError(e)
                }
                source.onComplete()
            }.async().subscribe({
                isDeleting = false
                progressDialog.dismiss()
                mAdapter.notifyDataSetChanged()
                ToastUtils.show("删除成功")
                changeMode(Mode.NORMAL)
            }) {
                isDeleting = false
                progressDialog.dismiss()
                ToastUtils.show("删除失败")
                LogUtils.e("$it")
                changeMode(Mode.NORMAL)
            }

        }
        btn_check_all.setOnClickListener {
            if (mDownloadBeanList.size == 0) return@setOnClickListener
            if (isAllChecked()) {
                mDownloadBeanList.forEach { it.isChecked = false }
            } else {
                mDownloadBeanList.forEach { it.isChecked = true }
            }
            mAdapter.notifyDataSetChanged()
            refreshCheckView()
        }
        RxBus.toObservable(this, DownloadNotifyEvent::class.java) { isNeedRefreshList = true }
        Observable.interval(1000L, TimeUnit.MILLISECONDS).async().go {
            if (isNeedRefreshList) {
                mAdapter.notifyDataSetChanged()
                isNeedRefreshList = false
            }
        }
    }

    private fun isAllChecked() = mDownloadBeanList.all { it.isChecked }

    private fun isNoneChecked() = mDownloadBeanList.all { it.isChecked.not() }

    private fun changeMode(mode: Mode) {
        when (mode) {
            Mode.NORMAL -> {
                toolbar.setRightText("编辑")
                layout_manage.visibility = View.GONE
                mDownloadBeanList.forEach { it.isChecked = false }
                refreshCheckView()
            }
            Mode.MANAGE -> {
                if (mDownloadBeanList.isEmpty()) return
                toolbar.setRightText("取消")
                layout_manage.visibility = View.VISIBLE
            }
        }
        mManageMode = mode
        mAdapter.notifyDataSetChanged()
    }

    @SuppressLint("SetTextI18n")
    private fun refreshCheckView() {
        if (mDownloadBeanList.isEmpty()) {
            btn_check_all.text = "全选"
            btn_delete.text = "删除"
            return
        }

        if (isAllChecked()) {
            btn_check_all.text = "取消全选"
        } else {
            btn_check_all.text = "全选"
        }

        if (isNoneChecked()) {
            btn_delete.text = "删除"
        } else {
            btn_delete.text = "删除 (${mDownloadBeanList.count { it.isChecked }})"
        }
    }

    inner class Adapter : BaseQuickAdapter<DownloadTaskBean, BaseViewHolder>(R.layout.item_book_download) {

        @SuppressLint("SetTextI18n")
        override fun convert(helper: BaseViewHolder, item: DownloadTaskBean) {
            LogUtils.e("item: $item")
            when (mManageMode) {
                Mode.NORMAL -> {
                    helper.setGone(R.id.iv_check_box, false)
                }
                Mode.MANAGE -> {
                    helper.setGone(R.id.iv_check_box, true)
                }
            }
            val progressBar = helper.getView<ProgressBar>(R.id.progress_bar)
            val tvCacheProgress = helper.getView<TextView>(R.id.tv_cache_progress)
            progressBar.visibility = View.VISIBLE
            progressBar.progress = (item.progress * PROGRESS_MAX).toInt()
            LogUtils.e("item: $item")
            when (item.status) {
                DownloadTaskBean.STATUS_ERROR -> {
                    tvCacheProgress.text = "出错，点击重新下载"
                }
                DownloadTaskBean.STATUS_FINISH -> {
                    tvCacheProgress.text = "已完成"
                    progressBar.visibility = View.INVISIBLE
                }
                DownloadTaskBean.STATUS_LOADING -> {
                    tvCacheProgress.text = "正在下载：${item.currentChapterTitle}"
                    progressBar.progressDrawable = Res.drawable(R.drawable.book_dl_progress_downloading)
                }
                DownloadTaskBean.STATUS_PAUSE -> {
                    tvCacheProgress.text = "暂停中，点击继续下载"
                    progressBar.progressDrawable = Res.drawable(R.drawable.book_dl_progress_pause)
                }
                DownloadTaskBean.STATUS_WAIT -> {
                    tvCacheProgress.text = "等待其它小说下载完成"
                    progressBar.visibility = View.INVISIBLE
                }
            }
            helper.check(item.isChecked)
            LogUtils.e("convert ${item._id}")
            if (helper.itemView.tag !== item._id) {
                LogUtils.e("设置新的监听")
                helper.itemView.tag = item._id
                helper.setText(R.id.tv_book_title, if (item.currentBookTitle == null || item.currentBookTitle.isEmpty()) {
                    "书名已失效"
                } else {
                    item.currentBookTitle
                })
                helper.getView<ImageView>(R.id.iv_book_cover).load(item.currentBookCover)
                helper.itemView.setOnClickListener {
                    LogUtils.e("onclick()")
                    LogUtils.e("$mManageMode")
                    if (mManageMode == Mode.NORMAL) {
                        when (item.status) {
                            DownloadTaskBean.STATUS_FINISH -> {
                                //下载完成
                                NewReadBookActivity.startActivity(this@BookDownloadActivity, item.bookId, item.currentBookTitle, item.currentBookCover)
                            }
                            DownloadTaskBean.STATUS_LOADING -> //下载中
                                BookDownloader.setDownloadStatus(item._id, DownloadTaskBean.STATUS_PAUSE)
                            DownloadTaskBean.STATUS_WAIT -> //等待
                                BookDownloader.setDownloadStatus(item._id, DownloadTaskBean.STATUS_PAUSE)
                            DownloadTaskBean.STATUS_PAUSE -> {
                                LogUtils.e("进行暂停")//暂停
                                BookDownloader.setDownloadStatus(item._id, DownloadTaskBean.STATUS_WAIT)
                            }
                            DownloadTaskBean.STATUS_ERROR -> //出错
                                BookDownloader.setDownloadStatus(item._id, DownloadTaskBean.STATUS_WAIT)
                        }
                    } else {
                        if (item.isChecked) {
                            item.isChecked = false
                            helper.check(false)
                        } else {
                            item.isChecked = true
                            helper.check(true)
                        }
                        refreshCheckView()
                    }
                }
            }
        }

        private fun BaseViewHolder.check(isChecked: Boolean) {
            setImageResource(R.id.iv_check_box, if (isChecked)
                R.drawable.book_dl_ic_checked_p
            else
                R.drawable.book_dl_ic_checked_n)
        }
    }

    private enum class Mode {
        NORMAL, MANAGE
    }

}