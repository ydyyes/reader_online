package com.bule.free.ireader.model.objectbox.bean;

import io.objectbox.annotation.Entity;
import io.objectbox.annotation.Id;

/**
 * Created by suikajy on 2019-05-20
 */
@Entity
public class BookHistoryBean {

    @Id
    private long id;
    private String bookId;
    private String cover;
    private String author;
    private String cates;
    private String longIntro;
    private long addTime; // 添加时间，用来排序
    private String title;

    // object box需要一个无参数构造函数，用来查询。
    public BookHistoryBean() {
    }

    public BookHistoryBean(String bookId, String cover, String author, String cates, String longIntro, long addTime, String title) {
        this.bookId = bookId;
        this.cover = cover;
        this.author = author;
        this.cates = cates;
        this.longIntro = longIntro;
        this.addTime = addTime;
        this.title = title;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public long getAddTime() {
        return addTime;
    }

    public void setAddTime(long addTime) {
        this.addTime = addTime;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
    }

    public String getCover() {
        return cover;
    }

    public void setCover(String cover) {
        this.cover = cover;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getCates() {
        return cates;
    }

    public void setCates(String cates) {
        this.cates = cates;
    }

    public String getLongIntro() {
        return longIntro;
    }

    public void setLongIntro(String longIntro) {
        this.longIntro = longIntro;
    }
}
