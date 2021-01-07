package com.bule.free.ireader.model.bean;

import java.io.Serializable;

/**
 * Created by liumin on 2018/12/21.
 * <p>
 * 已被ReadRecordBean代替
 */
@Deprecated
public class ReadRecord implements Serializable {

    private static final long serialVersionUID = 8083068225658101774L;
    private String _id;
    private int chapterIndex;
    private int pageIndex;
    private long lastReadTime;

    public String get_id() {
        return _id;
    }

    public void set_id(String _id) {
        this._id = _id;
    }

    public int getChapterIndex() {
        return chapterIndex;
    }

    public void setChapterIndex(int chapterIndex) {
        this.chapterIndex = chapterIndex;
    }

    public int getPageIndex() {
        return pageIndex;
    }

    public void setPageIndex(int pageIndex) {
        this.pageIndex = pageIndex;
    }

    public long getLastReadTime() {
        return lastReadTime;
    }

    public void setLastReadTime(long lastReadTime) {
        this.lastReadTime = lastReadTime;
    }
}
