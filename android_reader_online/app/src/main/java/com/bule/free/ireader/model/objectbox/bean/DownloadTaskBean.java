package com.bule.free.ireader.model.objectbox.bean;

import com.bule.free.ireader.model.objectbox.OB;

import io.objectbox.Box;
import io.objectbox.annotation.Entity;
import io.objectbox.annotation.Id;
import io.objectbox.annotation.Transient;

/**
 * Created by suikajy on 2019-06-26
 */
@Entity
public class DownloadTaskBean {

    public static synchronized void put(DownloadTaskBean recordBean) {
        Box<DownloadTaskBean> beanBox = OB.INSTANCE.getBoxStore().boxFor(DownloadTaskBean.class);
        DownloadTaskBean unique = beanBox.query().equal(DownloadTaskBean_.bookId, recordBean.bookId).build().findUnique();
        if (unique != null) {
            recordBean.localId = unique.localId;
        }
        beanBox.put(recordBean);
    }

    public static final int STATUS_LOADING = 1;
    public static final int STATUS_WAIT = 2;
    public static final int STATUS_PAUSE = 3;
    public static final int STATUS_ERROR = 4;
    public static final int STATUS_FINISH = 5;
    public static final int STATUS_DELETED = 6;

    @Id
    public long localId;

    private String _id;//id
    private String bookId;//对应书本Id

    //章节的下载进度,默认为初始状态
    private int currentChapter = 0;
    //最后的章节
    private int lastChapter = 0;
    //状态:正在下载、下载完成、暂停、等待、下载错误。

    private volatile int status = STATUS_WAIT;

    // v2.0
    private String currentBookCover = "";

    // 当前章节标题
    private String currentChapterTitle = "";
    // 当前书本标题
    private String currentBookTitle = "";

    // 下载管理页面用到，用于在管理时控制是否选中
    @Transient
    private boolean isChecked = false;

    // v2.0end
    public DownloadTaskBean() {
    }

    public DownloadTaskBean(String _id, String bookId, int currentChapter, int lastChapter, String bookTitle, String bookCover) {
        this._id = _id;
        this.bookId = bookId;
        this.currentChapter = currentChapter;
        this.lastChapter = lastChapter;
        this.currentBookTitle = bookTitle;
        this.currentBookCover = bookCover;
    }

    public String get_id() {
        return _id;
    }

    public void set_id(String _id) {
        this._id = _id;
    }

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
    }

    public int getCurrentChapter() {
        return currentChapter;
    }

    public void setCurrentChapter(int currentChapter) {
        this.currentChapter = currentChapter;
    }

    public int getLastChapter() {
        return lastChapter;
    }

    public void setLastChapter(int lastChapter) {
        this.lastChapter = lastChapter;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public float getProgress() {
        if (lastChapter == 0) return 0;
        else return currentChapter * 1.0f / lastChapter;
    }

    public String getCurrentChapterTitle() {
        if (currentBookTitle == null) return "";
        else return currentChapterTitle;
    }

    public void setCurrentChapterTitle(String currentChapterTitle) {
        this.currentChapterTitle = currentChapterTitle;
    }

    public String getCurrentBookTitle() {
        if (currentBookTitle == null) return "";
        else return currentBookTitle;
    }

    public void setCurrentBookTitle(String currentBookTitle) {
        this.currentBookTitle = currentBookTitle;
    }

    public String getCurrentBookCover() {
        if (currentBookTitle == null) return "";
        else return currentBookCover;
    }

    public void setCurrentBookCover(String currentBookCover) {
        this.currentBookCover = currentBookCover;
    }

    public boolean isChecked() {
        return isChecked;
    }

    public void setChecked(boolean checked) {
        isChecked = checked;
    }

    @Override
    public String toString() {
        return "DownloadTaskBean2{" +
                "_id='" + _id + '\'' +
                ", bookId='" + bookId + '\'' +
                ", currentBookCover='" + currentBookCover + '\'' +
                ", currentChapter=" + currentChapter +
                ", currentChapterTitle='" + currentChapterTitle + '\'' +
                ", currentBookTitle='" + currentBookTitle + '\'' +
                ", lastChapter=" + lastChapter +
                ", status=" + status +
                ", isChecked=" + isChecked +
                '}';
    }
}
