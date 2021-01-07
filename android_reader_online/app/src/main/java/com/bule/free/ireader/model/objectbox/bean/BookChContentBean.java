package com.bule.free.ireader.model.objectbox.bean;

import com.bule.free.ireader.model.objectbox.OB;

import java.util.ArrayList;
import java.util.List;

import io.objectbox.Box;
import io.objectbox.annotation.Entity;
import io.objectbox.annotation.Id;
import io.objectbox.annotation.Transient;
import io.objectbox.annotation.Unique;

/**
 * Created by suikajy on 2019-06-25
 * <p>
 * chapter content
 */
@Entity
public class BookChContentBean {

    public static synchronized void put(BookChContentBean bookBean) {
        Box<BookChContentBean> beanBox = OB.INSTANCE.getBoxStore().boxFor(BookChContentBean.class);
        try {
            BookChContentBean unique = beanBox.query().equal(BookChContentBean_.id, bookBean.id).build().findUnique();
            if (unique != null) {
                bookBean.localId = unique.localId;
            }
        } catch (Exception e) {
            // do nothing
        }
        beanBox.put(bookBean);
    }

    @Id
    public long localId; // object box 的id
    @Unique
    private String id; // 老的唯一标识
    private int type;//标识该条数据是来自下载还是阅读 ，0是阅读，1是下载
    // 对应的书籍id，因用到反射这个字段命名不能更改
    private String bookId; // 书籍id 可以通过它找
    private String content; // 小说章节的内容
    @Transient
    private List<String> lineContent = new ArrayList<>();// 分行之后每行的字符串列表
    private float lineSize; // 行大小
    private boolean canShowAd = false;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public List<String> getLineContent() {
        if (lineContent == null) return new ArrayList<>();
        return lineContent;
    }

    public void setLineContent(List<String> lineContent) {
        this.lineContent = lineContent;
    }

    public float getLineSize() {
        return lineSize;
    }

    public void setLineSize(float lineSize) {
        this.lineSize = lineSize;
    }

    public boolean getCanShowAd() {
        return canShowAd;
    }

    public void setCanShowAd(boolean canShowAd) {
        this.canShowAd = canShowAd;
    }

    public void needAddLineContent(int pageLineCount) {
        int allLines = getLineContent().size();
        int tmp = allLines % pageLineCount;
        if (tmp > 0.45 * pageLineCount) {
            int needLines = pageLineCount - tmp;
            for (int i = 0; i < needLines; i++
            ) {
                this.lineContent.add(" \n");
            }
            this.lineContent.add("     \n");

        }
        if (tmp == 0) {//刚好一页的
            this.lineContent.add("     \n");
        }
        this.setCanShowAd(true);
    }

    @Override
    public String toString() {
        return "BookChContentBean{" +
                "localId=" + localId +
                ", id='" + id + '\'' +
                ", type=" + type +
                ", bookId='" + bookId + '\'' +
                ", content='" + content + '\'' +
                ", lineContent=" + lineContent +
                ", lineSize=" + lineSize +
                '}';
    }
}
