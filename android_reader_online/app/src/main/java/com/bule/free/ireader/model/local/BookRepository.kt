package com.bule.free.ireader.model.local

import com.bule.free.ireader.api.Api
import com.bule.free.ireader.api.consumer.SimpleCallback
import com.bule.free.ireader.common.download.BookDownloader
import com.bule.free.ireader.common.library.java1_8.Optional
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.RxBus
import com.bule.free.ireader.model.AddBookToShelfEvent
import com.bule.free.ireader.model.bean.*
import com.bule.free.ireader.model.bookchapter.BookChapterManager
import com.bule.free.ireader.model.objectbox.OB
import com.bule.free.ireader.model.objectbox.bean.*
import com.google.gson.Gson
import io.objectbox.query.QueryBuilder
import io.reactivex.Completable
import io.reactivex.Single
import io.reactivex.SingleObserver
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import java.util.concurrent.Executors

object BookRepository {

    enum class BookShelfOrder {
        UPDATE,//通过最近更新排序
        LAST_READ//通过最近阅读排序
    }

    fun getCollBookList(orderBy: BookShelfOrder): Single<List<BookBean>> {
        return Single.create { e ->
            //            val beans = DatabaseUtils.helper.queryAll(BookCollItemBean::class.java, orderBy)!!
            val bookBeanBox = OB.boxStore.boxFor(BookBean::class.java)
            val list: MutableList<BookBean> = when (orderBy) {
                BookRepository.BookShelfOrder.UPDATE -> {
                    bookBeanBox.query().order(BookBean_.updated, QueryBuilder.DESCENDING).build().find()
                }
                BookRepository.BookShelfOrder.LAST_READ -> {
                    bookBeanBox.query().order(BookBean_.lastRead, QueryBuilder.DESCENDING).build().find()
                }
            }
            e.onSuccess(list)
        }
    }

    fun delBookShelf(bookId: String): Single<Void> {
        return Single.create { e ->
            val bookBeanBox = OB.boxStore.boxFor(BookBean::class.java)
            bookBeanBox.query().equal(BookBean_.id, bookId).build().remove()
//            bookBeanBox.query().equal(BookBean_)
//            bookBeanBox.remove()
//            DatabaseUtils.helper.delete(mBookCollItemBean)
            e.onSuccess(Void())
        }
    }

    fun getChapterList(bookId: String): Single<List<BookChapterBean>> {
        return Single.create { e ->
            //val beans = DatabaseUtils.helper.queryByWhere(BookChapterBean2::class.java, "bookid=?", arrayOf(bookId), "cast(chapterIndex as '9999')")!!

//            val boxFor = OB.boxStore.boxFor(BookChapterBean::class.java)
//            val beans = boxFor.query().equal(BookChBean_.bookId, bookId).order(BookChBean_.chapterIndex).build().find()

            val beans = BookChapterManager.get(bookId)
            e.onSuccess(beans)
        }
    }

    fun getBookContent(bookId: String, chapterId: String): Single<BookChContentBean> {
        val contentId = bookId + "_" + chapterId
        return Single.create { e ->
            //            val beans = DatabaseUtils.helper.queryById(BookContentBean::class.java, contentId)
//                    ?: BookContentBean()
            val box = OB.boxStore.boxFor(BookChContentBean::class.java)
            val bean = box.query().equal(BookChContentBean_.id, contentId).build().findUnique()
            e.onSuccess(bean ?: BookChContentBean())
        }
    }

    fun addBookRecord(readRecord: ReadRecordBean) {
        Completable.fromAction {
            ReadRecordBean.put(readRecord)
        }.subscribeOn(Schedulers.io()).subscribe()
    }

    //获取阅读记录
    fun getBookRecord(bookId: String): ReadRecordBean? {
        val box = OB.boxStore.boxFor(ReadRecordBean::class.java)
        return box.query().equal(ReadRecordBean_.bookId, bookId).build().findUnique()
    }

    //检查是不是书架的书本
    fun checkCollBook(bookId: String): Single<Optional<BookBean>> {
        return Single.create { e ->
            //            val bean = Optional.ofNullable(DatabaseUtils.helper.queryById(BookCollItemBean::class.java, bookId))
            val bookBeanBox = OB.boxStore.boxFor(BookBean::class.java)
            val bookBean = bookBeanBox.query().equal(BookBean_.id, bookId).build().findUnique()
            e.onSuccess(Optional.ofNullable(bookBean))
        }
    }

    fun addBookShelf(bookBean: BookBean): Single<Void> {
        return Single.create { e ->
            synchronized(BookRepository) {
                val bookBeanBox = OB.boxStore.boxFor(BookBean::class.java)
                val findFirst = bookBeanBox.query().equal(BookBean_.id, bookBean.id).build().findFirst()
                if (findFirst == null) {
                    bookBeanBox.put(bookBean)
                } else {
                    bookBean.localId = findFirst.localId
                    bookBeanBox.put(bookBean)
                }

//            DatabaseUtils.helper.save(bookBean)
                RxBus.post(AddBookToShelfEvent)
            }

            e.onSuccess(Void())
        }
    }

    fun putChapterList(id: String, chapters: List<BookChapterBean>): Single<Void> {
        return Single.create { e ->
            val json = Gson().toJson(chapters)
            BookChapterManager.write(id, json)
//            var i = 0
//            chapters.forEach { bean ->
//                val json = Gson().toJson(chapters)
//                bean.id = id + "_" + bean._label
//                bean.bookId = id
//                bean.chapterIndex = i
//                BookChapterBean.put(bean)
//
//                i++
//            }
            e.onSuccess(Void())
        }
    }

    fun putBookContent(mBean: BookChContentBean) {
        Completable.fromAction {
            BookChContentBean.put(mBean)
        }.subscribeOn(Schedulers.io()).subscribe()
    }

    //将老数据迁移到新缓存，这个方法添加于v3.4.5。为了适配以前数据，以后酌情删除
    @Suppress("DEPRECATION")
    fun migrateOldBookShelf() {
        Single.create<Optional<MutableList<BookCollItemBean?>>> {
            val beans: MutableList<BookCollItemBean?>? = DatabaseUtils.helper.queryAll(BookCollItemBean::class.java, "lastRead desc")
            it.onSuccess(Optional.ofNullable(beans))
        }.subscribeOn(Schedulers.io())
                .subscribe(object : SingleObserver<Optional<MutableList<BookCollItemBean?>>> {
                    override fun onSuccess(oldData: Optional<MutableList<BookCollItemBean?>>) {
                        oldData.ifPresent { oldBeanList ->
                            val bookBeanBox = OB.boxStore.boxFor(BookBean::class.java)
                            oldBeanList.forEach { bookCollItemBean ->
                                if (bookCollItemBean != null) {
                                    val bookBean = BookBean()
                                    bookBean.author = bookCollItemBean.author
                                    bookBean.cover = bookCollItemBean.cover
                                    bookBean.gender = bookCollItemBean.gender
                                    bookBean.id = bookCollItemBean.id
                                    bookBean.isNewChapter = false
                                    bookBean.isfree = bookCollItemBean.isfree
                                    bookBean.lastChapter = bookCollItemBean.lastChapter
                                    bookBean.lastRead = bookCollItemBean.lastRead
                                    bookBean.latelyFollower = bookCollItemBean.latelyFollower
                                    bookBean.link = bookCollItemBean.link
                                    bookBean.longIntro = bookCollItemBean.longIntro
                                    bookBean.majorCate = bookCollItemBean.majorCate
                                    bookBean.over = bookCollItemBean.over
                                    bookBean.retentionRatio = bookCollItemBean.retentionRatio
                                    bookBean.score = bookCollItemBean.score
                                    bookBean.serializeWordCount = bookCollItemBean.serializeWordCount
                                    bookBean.tags = bookCollItemBean.tags
                                    bookBean.title = bookCollItemBean.title
                                    bookBean.updated = bookCollItemBean.updated
                                    bookBean.wordCount = bookCollItemBean.wordCount
                                    bookBeanBox.put(bookBean)
                                }
                            }
                            DatabaseUtils.helper.clear(BookCollItemBean::class.java)
                        }
                    }

                    override fun onSubscribe(d: Disposable) {
                    }

                    override fun onError(e: Throwable) {
                        LogUtils.e("e: $e")
                    }
                })
    }

    @Suppress("DEPRECATION")
    fun migrateOldReadRecord() {
        Single.create<Optional<MutableList<ReadRecord>>> {
            val beans = DatabaseUtils.helper.queryAll(ReadRecord::class.java)
            it.onSuccess(Optional.ofNullable(beans))
        }.subscribeOn(Schedulers.io())
                .subscribe(object : SingleObserver<Optional<MutableList<ReadRecord>>> {
                    override fun onSuccess(oldData: Optional<MutableList<ReadRecord>>) {
                        oldData.ifPresent { oldBeanList ->
                            val box = OB.boxStore.boxFor(ReadRecordBean::class.java)
                            oldBeanList.forEach { oldRecord ->
                                val readRecordBean = ReadRecordBean()
                                readRecordBean.bookId = oldRecord._id
                                readRecordBean.chapterIndex = oldRecord.chapterIndex
                                readRecordBean.pageIndex = oldRecord.pageIndex
                                box.put(readRecordBean)
                            }
                            DatabaseUtils.helper.clear(ReadRecord::class.java)
                        }
                    }

                    override fun onSubscribe(d: Disposable) {
                    }

                    override fun onError(e: Throwable) {
                        LogUtils.e("e: $e")
                    }
                })
    }


    @Suppress("DEPRECATION")
    fun migrateOldDownloadTask() {
        Single.create<Optional<MutableList<DownloadTaskBean2>>> {
            val beans = DatabaseUtils.helper.queryAll(DownloadTaskBean2::class.java)
            it.onSuccess(Optional.ofNullable(beans))
        }.subscribeOn(Schedulers.io())
                .subscribe(object : SingleObserver<Optional<MutableList<DownloadTaskBean2>>> {
                    override fun onSuccess(oldData: Optional<MutableList<DownloadTaskBean2>>) {
                        oldData.ifPresent { oldBeanList ->
                            val box = OB.boxStore.boxFor(DownloadTaskBean::class.java)
                            oldBeanList.forEach { oldTask ->
                                LogUtils.e("migrateOldDownloadTask oldTask: $oldTask")
                                val newTaskBean = DownloadTaskBean()
                                newTaskBean._id = oldTask._id
                                newTaskBean.currentChapter = 0
                                newTaskBean.currentBookCover = oldTask.currentBookCover
                                newTaskBean.currentBookTitle = oldTask.currentBookTitle
                                newTaskBean.currentChapterTitle = "章节名异常，请重试"
                                newTaskBean.bookId = oldTask.bookId
                                newTaskBean.status = DownloadTaskBean.STATUS_PAUSE
                                newTaskBean.lastChapter = oldTask.lastChapter
                                LogUtils.e("migrateOldDownloadTask newTaskBean: $newTaskBean")
                                fetchDownloadChapterList(newTaskBean.bookId)
                                box.put(newTaskBean)
                            }
                            DatabaseUtils.helper.clear(DownloadTaskBean2::class.java)
                            DatabaseUtils.helper.clear(BookContentBean::class.java)
                            DatabaseUtils.helper.clear(BookChapterBean2::class.java)
                            if (oldBeanList.size != 0) {
                                BookDownloader.refreshDownloadTaskList()
                            }
                        }
                    }

                    override fun onSubscribe(d: Disposable) {
                    }

                    override fun onError(e: Throwable) {
                        LogUtils.e("e: $e")
                    }
                })
    }


    private fun fetchDownloadChapterList(bookId: String) {
        val disposable = Api.getChapterList(bookId).observeOn(Schedulers.io())
                .subscribe(object : SimpleCallback<List<BookChapterBean>> {
                    override fun onSuccess(resultList: List<BookChapterBean>?) {
                        if (resultList != null && resultList.isNotEmpty()) {
                            BookChapterManager.write(bookId, Gson().toJson(resultList))
                        }
                    }
                })
    }
}