package com.bule.free.ireader.model.bean;

import com.bule.free.ireader.model.objectbox.bean.BookChContentBean;

/**
 * Created by suikajy on 2019-06-26
 * <p>
 * 单个章节的Bean
 */
public class BookChapterBean {

    /**
     * title : 蓝星某个城市内，一个略显颓废的青年，他的双目无神，神情疲惫的走在马路上，给人一种随时可能逝去的苍凉之感。
     * label : 93
     */

    public long localId;
    private String id;//存db时的id，小说id + label
    private String title;
    private String _label;
    private int chapterIndex;//排序索引
    private String bookId;
    private BookChContentBean contentBean = new BookChContentBean();

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        if (title == null){
            return "";
        }
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String get_label() {
        return _label;
    }

    public void set_label(String _label) {
        this._label = _label;
    }

    public int getChapterIndex() {
        return chapterIndex;
    }

    public void setChapterIndex(int chapterIndex) {
        this.chapterIndex = chapterIndex;
    }

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
    }

    public BookChContentBean getContentBean() {
        return contentBean;
    }

    public void setContentBean(BookChContentBean contentBean) {
        this.contentBean = contentBean;
    }

    @Override
    public String toString() {
        return "BookChapterBean{" +
                "id='" + id + '\'' +
                ", title='" + title + '\'' +
                ", _label='" + _label + '\'' +
                ", chapterIndex=" + chapterIndex +
                ", bookId='" + bookId + '\'' +
                ", contentBean=" + contentBean +
                '}';
    }
}
