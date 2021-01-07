package com.bule.free.ireader.model.objectbox.bean;

import com.bule.free.ireader.model.objectbox.OB;

import io.objectbox.Box;
import io.objectbox.annotation.Entity;
import io.objectbox.annotation.Id;
import io.objectbox.annotation.Unique;

/**
 * Created by suikajy on 2019-06-21
 * <p>
 * 用来缓存一本书的相关信息，目前用于书架，以后准备将书籍详情也统一到这个bean上
 *
 * 这个Bean改自BookCollItemBean，用来表示书架上的书籍
 */
@Entity
public class BookBean {
    //    var author: String = "",
//    var cover: String = "",
//    var gender: String = "",
//    var id: String = "",
//    var isfree: String = "",
//    var lastChapter: String = "",
//    var latelyFollower: String = "",
//    var longIntro: String = "",
//    var majorCate: String = "",
//    var over: Int = 0,
//    var retentionRatio: String = "",
//    var score: String = "",
//    var serializeWordCount: String = "",
//    var tags: String = "",
//    var title: String = "",
//    var updated: String = "",
//    var wordCount: String = "",
//    var newChapter: Boolean = false,
//    var lastRead: String = "",
//    var link: String = "" // 书籍广告点击跳转的web页

    public static synchronized void put(BookBean bookBean) {
        Box<BookBean> beanBox = OB.INSTANCE.getBoxStore().boxFor(BookBean.class);
        BookBean unique = beanBox.query().equal(BookBean_.id, bookBean.id).build().findUnique();
        if (unique != null) {
            bookBean.localId = unique.localId;
        }
        beanBox.put(bookBean);
    }

    @Id
    private long localId; // object box 的id
    private String author = ""; // 作者
    private String cover = ""; // 封面
    private String gender = "";
    @Unique
    private String id = ""; // 书籍的服务器id
    private String isfree = "";
    private String lastChapter = "";
    private String latelyFollower = "";
    private String longIntro = "";
    private String majorCate = ""; // 分类
    private int over = 0;
    private String retentionRatio = "";
    private String score = "";
    private String serializeWordCount = "";
    private String tags = "";
    private String title = "";
    private String updated = "";
    private String wordCount = "";
    private boolean newChapter = false;
    private String lastRead = "";
    private String link = "";// 书籍广告点击跳转的web页
    // 当书籍详情也统一时需要加上这个标识
    //private boolean isOnShelf = true;

    public BookBean() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getCover() {
        return cover;
    }

    public void setCover(String cover) {
        this.cover = cover;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public long getLocalId() {
        return localId;
    }

    public void setLocalId(long localId) {
        this.localId = localId;
    }

    public String getIsfree() {
        return isfree;
    }

    public void setIsfree(String isfree) {
        this.isfree = isfree;
    }

    public String getLastChapter() {
        return lastChapter;
    }

    public void setLastChapter(String lastChapter) {
        this.lastChapter = lastChapter;
    }

    public String getLatelyFollower() {
        return latelyFollower;
    }

    public void setLatelyFollower(String latelyFollower) {
        this.latelyFollower = latelyFollower;
    }

    public String getLongIntro() {
        return longIntro;
    }

    public void setLongIntro(String longIntro) {
        this.longIntro = longIntro;
    }

    public String getMajorCate() {
        return majorCate;
    }

    public void setMajorCate(String majorCate) {
        this.majorCate = majorCate;
    }

    public int getOver() {
        return over;
    }

    public void setOver(int over) {
        this.over = over;
    }

    public String getRetentionRatio() {
        return retentionRatio;
    }

    public void setRetentionRatio(String retentionRatio) {
        this.retentionRatio = retentionRatio;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public String getSerializeWordCount() {
        return serializeWordCount;
    }

    public void setSerializeWordCount(String serializeWordCount) {
        this.serializeWordCount = serializeWordCount;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getUpdated() {
        return updated;
    }

    public void setUpdated(String updated) {
        this.updated = updated;
    }

    public String getWordCount() {
        return wordCount;
    }

    public void setWordCount(String wordCount) {
        this.wordCount = wordCount;
    }

    public boolean isNewChapter() {
        return newChapter;
    }

    public void setNewChapter(boolean newChapter) {
        this.newChapter = newChapter;
    }

    public String getLastRead() {
        return lastRead;
    }

    public void setLastRead(String lastRead) {
        this.lastRead = lastRead;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    @Override
    public String toString() {
        return "BookBean{" +
                "localId=" + localId +
                ", author='" + author + '\'' +
                ", cover='" + cover + '\'' +
                ", gender='" + gender + '\'' +
                ", id='" + id + '\'' +
                ", isfree=" + isfree +
                ", lastChapter='" + lastChapter + '\'' +
                ", latelyFollower='" + latelyFollower + '\'' +
                ", longIntro='" + longIntro + '\'' +
                ", majorCate='" + majorCate + '\'' +
                ", over=" + over +
                ", retentionRatio='" + retentionRatio + '\'' +
                ", score='" + score + '\'' +
                ", serializeWordCount='" + serializeWordCount + '\'' +
                ", tags='" + tags + '\'' +
                ", title='" + title + '\'' +
                ", updated='" + updated + '\'' +
                ", wordCount='" + wordCount + '\'' +
                ", newChapter=" + newChapter +
                ", lastRead='" + lastRead + '\'' +
                ", link='" + link + '\'' +
                '}';
    }
}
