package com.bule.free.ireader.model.bean;

import java.io.Serializable;

/**
 * Created by suikajy on 2019/3/1
 */
@Deprecated
public class BookChapterBean2 implements Serializable {

    /**
     * title : 蓝星某个城市内，一个略显颓废的青年，他的双目无神，神情疲惫的走在马路上，给人一种随时可能逝去的苍凉之感。
     * label : 93
     */


    private String id;//存db时的id，小说id + label

    private String title;
    private String _label;
    private int chapterIndex;//排序索引


    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String get_label() {
        return _label;
    }

    public void set_label(String label) {
        this._label = label;
    }

    private String bookid;

    public String getBookid() {
        return bookid;
    }

    public void setBookid(String bookid) {
        this.bookid = bookid;
    }

    private BookContentBean contentBean = new BookContentBean();

    public BookContentBean getContentBean() {
        return contentBean;
    }

    public void setContentBean(BookContentBean contentBean) {
        this.contentBean = contentBean;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getChapterIndex() {
        return chapterIndex;
    }

    public void setChapterIndex(int chapterIndex) {
        this.chapterIndex = chapterIndex;
    }

    @Override
    public String toString() {
        return "BookChapterBean2{" +
                "title='" + title + '\'' +
                ", _label='" + _label + '\'' +
                ", bookid='" + bookid + '\'' +
                '}';
    }
}
