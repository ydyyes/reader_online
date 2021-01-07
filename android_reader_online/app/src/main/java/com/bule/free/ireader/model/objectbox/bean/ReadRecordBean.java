package com.bule.free.ireader.model.objectbox.bean;

import com.bule.free.ireader.model.objectbox.OB;

import io.objectbox.Box;
import io.objectbox.annotation.Entity;
import io.objectbox.annotation.Id;

/**
 * Created by suikajy on 2019-06-26
 * <p>
 * 阅读记录，一本书对应一个阅读记录
 */
@Entity
public class ReadRecordBean {

    public static synchronized void put(ReadRecordBean recordBean) {
        Box<ReadRecordBean> beanBox = OB.INSTANCE.getBoxStore().boxFor(ReadRecordBean.class);
        ReadRecordBean unique = beanBox.query().equal(ReadRecordBean_.bookId, recordBean.bookId).build().findUnique();
        if (unique != null) {
            recordBean.localId = unique.localId;
        }
        beanBox.put(recordBean);
    }

    @Id
    public long localId;
    private String bookId;
    private int chapterIndex;
    private int pageIndex;

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
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
}
