package com.bule.free.ireader.common.download

import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.NetworkUtils
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.model.DownloadMessage
import com.bule.free.ireader.model.DownloadNotifyEvent
import com.bule.free.ireader.model.User
import com.bule.free.ireader.model.bookchapter.BookChapterManager
import com.bule.free.ireader.model.local.DatabaseUtils
import com.bule.free.ireader.model.objectbox.OB
import com.bule.free.ireader.model.objectbox.bean.*
import com.bule.free.ireader.ui.base.action.DisposableHandler
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import java.util.*
import java.util.concurrent.Executors
import kotlin.collections.ArrayList

/**
 * Created by suikajy on 2019/3/14
 */
object BookDownloader : DisposableHandler {

    //加载状态
    private const val LOAD_ERROR = -1
    private const val LOAD_NORMAL = 0
    private const val LOAD_PAUSE = 1
    private const val LOAD_DELETE = 2 //正在加载时候，用户删除收藏书籍的情况。

    private val mDisposable = CompositeDisposable()

    private val mExecutor = Executors.newSingleThreadExecutor()
    private val mHandler = Handler(Looper.getMainLooper())
    val downloadTaskList: MutableList<DownloadTaskBean> by lazy {
        val list = OB.boxStore.boxFor(DownloadTaskBean::class.java).all
        if (list.isEmpty()) {
            return@lazy mutableListOf<DownloadTaskBean>()
        } else {
            return@lazy list
        }
//        DatabaseUtils.helper.queryAll(DownloadTaskBean::class.java)
//                ?: ArrayList<DownloadTaskBean>()
    }
    private var isBusy = false
    private var isCancel = false
    private val mDownloadTaskQueue: MutableList<DownloadTaskBean> = Collections.synchronizedList(ArrayList<DownloadTaskBean>())
    private val mDownloadListeners = mutableListOf<OnDownloadListener>()

    fun init() {
        val disposable = RxBus.toObservable(DownloadTaskBean::class.java)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    if (TextUtils.isEmpty(it.bookId) || !checkDownloadTask(it)) {

                        addToExecutor(it)
                    }
                }) { it.printStackTrace() }
    }

    fun saveData() {
        // DatabaseUtils.helper.saveAll(downloadTaskList)
    }

    fun refreshDownloadTaskList() {
        val list = OB.boxStore.boxFor(DownloadTaskBean::class.java).all
        downloadTaskList.clear()
        if (list.isEmpty().not()) downloadTaskList.addAll(list)
    }

    override fun addDisposable(disposable: Disposable) {
        mDisposable.add(disposable)
    }

    /**
     * 1. 查看是否任务已存在
     * 2. 修改DownloadTask的 taskName 和 list
     */
    private fun checkDownloadTask(newTask: DownloadTaskBean): Boolean {
        var isExist = false
        for (downloadTask in downloadTaskList) {
            //如果不相同则不往下执行，往下执行都是存在相同的情况
            if (downloadTask.bookId != newTask.bookId) continue

            if (downloadTask.status == DownloadTaskBean.STATUS_FINISH) {
                //判断是否newTask是已完成
                if (downloadTask.lastChapter == newTask.lastChapter) {
                    isExist = true
                    //当前书本已经缓存
                    postMessage("当前书籍已缓存")
                }
            } else {
                isExist = true
                //发送回去:已经在加载队列中。
                postMessage("任务已存在")
            }//表示该任务已经在 下载、等待、暂停、网络错误中
        }
        //重置名字
        if (!isExist) {
            postMessage("成功添加到缓存队列")
        }
        return isExist
    }

    private fun postMessage(msg: String) {
        RxBus.post(DownloadMessage(msg))
    }

    private fun post(task: DownloadTaskBean) {
        RxBus.post(task)
    }

    private fun postDownloadChange(task: DownloadTaskBean, status: Int, msg: String) {
        val position = downloadTaskList.indexOf(task)
        //通过handler,切换回主线程
        mDownloadListeners.forEach {
            mHandler.post {
                it.onDownloadChange(position, status, msg)
                it.onDownloadChange(task)
            }
        }
    }

    fun onDestory() {
        saveData()
        mDownloadListeners.clear()
        mDisposable.dispose()
    }

    fun register(downloadListener: OnDownloadListener) {
        mDownloadListeners.add(downloadListener)
    }

    fun unregister(downloadListener: OnDownloadListener) {
        mDownloadListeners.remove(downloadListener)
    }

    private fun addToExecutor(taskEvent: DownloadTaskBean) {

        //判断是否为轮询请求
        if (!TextUtils.isEmpty(taskEvent.bookId) && !TextUtils.isEmpty(taskEvent._id)) {

            if (!downloadTaskList.contains(taskEvent)) {
                //加入总列表中，表示创建，修改CollBean的状态。
                downloadTaskList.add(taskEvent)
            }
            // 添加到下载队列
            mDownloadTaskQueue.add(taskEvent)

            User.logDownload()
            DownloadTaskBean.put(taskEvent)

            LogUtils.e("addToExecutor : $taskEvent")
        }

        // 从队列顺序取出第一条下载
        if (mDownloadTaskQueue.size > 0 && !isBusy) {
            isBusy = true
            executeTask(mDownloadTaskQueue[0])
        }
    }

    private fun executeTask(taskEvent: DownloadTaskBean) {

        val runnable = {
            taskEvent.status = DownloadTaskBean.STATUS_LOADING
            var result = LOAD_NORMAL
            val bookid = taskEvent.bookId
            val bookChapterBeans = BookChapterManager.get(bookid)
            //调用for循环，下载数据
            for (i in taskEvent.currentChapter until bookChapterBeans.size) {
                if (taskEvent.status == DownloadTaskBean.STATUS_DELETED) break
                val bookChapterBean = bookChapterBeans[i]
                LogUtils.e("executeTask bookChapterBean: $bookChapterBean")
                //首先判断该章节是否曾经被加载过 (从db中判断)

                /**
                 * BookContentBean contentBean = new BookContentBean();
                 * contentBean.setContent(content);
                 * contentBean.setId(bookId + "_" + mBookChapterBean.get_label());
                 */
                // 设置任务进度
                taskEvent.currentChapter = i
                taskEvent.currentChapterTitle = bookChapterBean.title
                taskEvent.status = DownloadTaskBean.STATUS_LOADING
                //存储状态
                DownloadTaskBean.put(taskEvent)
                RxBus.post(DownloadNotifyEvent)
                val contentId = taskEvent.bookId + "_" + bookChapterBean._label
                val contentBox = OB.boxStore.boxFor(BookChContentBean::class.java)
//                val bookCache = DatabaseUtils.helper.queryById(BookContentBean::class.java, contentId)
                val bookCache = contentBox.query().equal(BookChContentBean_.id, contentId).build().findUnique()
                if (bookCache != null && !TextUtils.isEmpty(bookCache.content)) {
                    //章节加载完成
                    postDownloadChange(taskEvent, DownloadTaskBean.STATUS_LOADING, i.toString() + "")
                    //无需进行下一步
                    continue
                }
                //判断网络是否出问题
                if (!NetworkUtils.isAvailable()) {
                    //章节加载失败
                    result = LOAD_ERROR
                    break
                }
                if (isCancel) {
                    result = LOAD_PAUSE
                    isCancel = false
                    break
                }
                //加载数据
                result = loadBookContent(taskEvent.bookId, bookChapterBean._label)
                //章节加载完成
                if (result == LOAD_NORMAL) {
                    taskEvent.currentChapter = i
                    postDownloadChange(taskEvent, DownloadTaskBean.STATUS_LOADING, i.toString() + "")
                } else {
                    //遇到错误退出
                    break
                }//章节加载失败
            }

            if (result == LOAD_NORMAL) {
                //存储DownloadTask的状态
                taskEvent.status = DownloadTaskBean.STATUS_FINISH//Task的状态
                taskEvent.currentChapter = bookChapterBeans.size//当前下载的章节数量
                //发送完成状态
                postDownloadChange(taskEvent, DownloadTaskBean.STATUS_FINISH, "下载完成")
            } else if (result == LOAD_ERROR) {
                taskEvent.status = DownloadTaskBean.STATUS_ERROR//Task的状态
                //任务加载失败
                postDownloadChange(taskEvent, DownloadTaskBean.STATUS_ERROR, "资源或网络错误")
            } else if (result == LOAD_PAUSE) {
                taskEvent.status = DownloadTaskBean.STATUS_PAUSE//Task的状态
                postDownloadChange(taskEvent, DownloadTaskBean.STATUS_PAUSE, "暂停加载")
            } else if (result == LOAD_DELETE) {

            }

            //轮询下一个事件，用RxBus用来保证事件是在主线程
            //移除完成的任务
            mDownloadTaskQueue.remove(taskEvent)
            //设置为空闲
            isBusy = false
            //轮询
            post(DownloadTaskBean())
        }
        mExecutor.execute(runnable)
    }

    private fun loadBookContent(bookId: String, label: String): Int {
        LogUtils.e("loadBookContent() ")
        LogUtils.e("bookId: $bookId")
        LogUtils.e("label: $label")
        val result = intArrayOf(LOAD_NORMAL)
        val disposable = Api.getChapterContentBySync(bookId, label)
                .subscribe({ chapterContentBean ->
                    if (chapterContentBean != null && !TextUtils.isEmpty(chapterContentBean.url)) {
                        val content = Api.getBySync2(chapterContentBean.url)
                        if (!TextUtils.isEmpty(content)) {
                            val contentBean = BookChContentBean()
                            contentBean.content = content
                            contentBean.id = bookId + "_" + label
                            contentBean.bookId = bookId
                            contentBean.type = 1//来自于下载
                            BookChContentBean.put(contentBean)
                        } else {
                            result[0] = LOAD_ERROR
                        }
                    } else {
                        result[0] = LOAD_ERROR
                    }
                }, { throwable ->
                    LogUtils.e(throwable.toString())
                    result[0] = LOAD_ERROR
                })
        addDisposable(disposable)
        return result[0]
    }

    fun getDownloadTask(taskId: String): DownloadTaskBean? {
        downloadTaskList.forEach {
            if (taskId == it._id) return it
        }
        return null
    }

    fun setDownloadStatus(taskId: String, status: Int) {
        LogUtils.e("setDownloadStatus(status: $status)")
        //修改某个Task的状态
        when (status) {
            //加入缓存队列
            DownloadTaskBean.STATUS_WAIT -> for (i in downloadTaskList.indices) {
                val bean = downloadTaskList[i]
                if (taskId == bean._id) {
                    bean.status = DownloadTaskBean.STATUS_WAIT
                    mDownloadListeners.forEach {
                        it.onDownloadResponse(i, DownloadTaskBean.STATUS_WAIT)
                    }
                    addToExecutor(bean)
                    break
                }
            }
            //从缓存队列中删除
            DownloadTaskBean.STATUS_PAUSE -> {
                mDownloadTaskQueue.firstOrNull { it._id == taskId }?.apply {
                    if (this.status == DownloadTaskBean.STATUS_LOADING && this._id == taskId) {
                        isCancel = true
                    } else {
                        this.status = DownloadTaskBean.STATUS_PAUSE
                        mDownloadTaskQueue.remove(this)
                        val position = downloadTaskList.indexOf(this)
                        mDownloadListeners.forEach {
                            it.onDownloadResponse(position, DownloadTaskBean.STATUS_PAUSE)
                        }
                    }
                }
            }
        }
    }
}