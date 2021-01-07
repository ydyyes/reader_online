package com.bule.free.ireader.model.bean;

import android.support.annotation.Nullable;

import java.io.Serializable;

/**
 * Created by suikajy on 2019/3/1
 */
public class BookDetailBean implements Serializable {
    public static BookDetailBean instanceOf(BookMallItemBean bean) {
        BookDetailBean bookDetailBean = new BookDetailBean();
        bookDetailBean.setId(bean.getId());
        bookDetailBean.setTitle(bean.getTitle());
        bookDetailBean.setCover(bean.getCover());
        bookDetailBean.setAuthor(bean.getAuthor());
        bookDetailBean.setLongIntro(bean.getLongIntro());
        bookDetailBean.setWordCount(Integer.parseInt(bean.getWordCount()));
        bookDetailBean.setGender(bean.getGender());
        bookDetailBean.setOver(bean.getOver());
        bookDetailBean.setScore(bean.getScore());
        bookDetailBean.setSerializeWordCount(bean.getSerializeWordCount());
        bookDetailBean.setLatelyFollower(bean.getLatelyFollower());
        bookDetailBean.setRetentionRatio(bean.getRetentionRatio());
        bookDetailBean.setIsfree(bean.getIsfree());
        bookDetailBean.setMajorCate(bean.getMajorCate());
        bookDetailBean.setLastChapter(bean.getLastChapter());
        bookDetailBean.setUpdated(bean.getUpdated());
        bookDetailBean.setTags(bean.getTags());
        return bookDetailBean;
    }

    /**
     * id : 4
     * title : 213
     * cover : http://172.16.2.160:9000/Uploads/xiaoshuo/c0/0d/3829e36c7146.png
     * author : 温泉1
     * longIntro : 温泉2
     * wordCount : 123
     * genderInner : 2
     * over : 1
     * score : 2
     * serializeWordCount : 123321
     * latelyFollower : 123
     * retentionRatio : 22.23
     * tags : ["123","312"]
     * isfree : 1
     * majorCate : 9
     * lastChapter : 1000
     * updated : 1551258987
     * cates : 乡村风情
     */

    private String id;
    private String title;
    private String cover;
    private String author;
    private String longIntro;
    private int wordCount;
    private String gender;
    private int over;
    private String score;
    private String serializeWordCount;
    private String latelyFollower;
    private String retentionRatio;
    private String isfree;
    private String majorCate;
    private String lastChapter;
    private String updated;
    private String cates;
    private String tags;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
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

    public String getLongIntro() {
        return longIntro;
    }

    public void setLongIntro(String longIntro) {
        this.longIntro = longIntro;
    }

    public int getWordCount() {
        return wordCount;
    }

    public void setWordCount(int wordCount) {
        this.wordCount = wordCount;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public int getOver() {
        return over;
    }

    public void setOver(int over) {
        this.over = over;
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

    public String getLatelyFollower() {
        return latelyFollower;
    }

    public void setLatelyFollower(String latelyFollower) {
        this.latelyFollower = latelyFollower;
    }

    public String getRetentionRatio() {
        return retentionRatio;
    }

    public void setRetentionRatio(String retentionRatio) {
        this.retentionRatio = retentionRatio;
    }

    public String getIsfree() {
        return isfree;
    }

    public void setIsfree(String isfree) {
        this.isfree = isfree;
    }

    public String getMajorCate() {
        return majorCate;
    }

    public void setMajorCate(String majorCate) {
        this.majorCate = majorCate;
    }

    public String getLastChapter() {
        return lastChapter;
    }

    public void setLastChapter(String lastChapter) {
        this.lastChapter = lastChapter;
    }

    public String getUpdated() {
        return updated;
    }

    public void setUpdated(String updated) {
        this.updated = updated;
    }

    @Nullable
    public String getCates() {
        return cates;
    }

    public void setCates(String cates) {
        this.cates = cates;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }



    @Override
    public String toString() {
        return "BookDetailBean{" +
                "id='" + id + '\'' +
                ", title='" + title + '\'' +
                ", cover='" + cover + '\'' +
                ", author='" + author + '\'' +
                ", longIntro='" + longIntro + '\'' +
                ", wordCount=" + wordCount +
                ", genderInner='" + gender + '\'' +
                ", over=" + over +
                ", score='" + score + '\'' +
                ", serializeWordCount='" + serializeWordCount + '\'' +
                ", latelyFollower='" + latelyFollower + '\'' +
                ", retentionRatio='" + retentionRatio + '\'' +
                ", isfree='" + isfree + '\'' +
                ", majorCate='" + majorCate + '\'' +
                ", lastChapter='" + lastChapter + '\'' +
                ", updated='" + updated + '\'' +
                ", cates='" + cates + '\'' +
                ", tags='" + tags + '\'' +
                '}';
    }
}
