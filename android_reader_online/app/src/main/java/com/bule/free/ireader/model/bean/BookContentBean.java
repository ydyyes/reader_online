package com.bule.free.ireader.model.bean;


import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by liumin on 2018/12/20.
 */
@Deprecated
public class BookContentBean implements Serializable {


    private static final long serialVersionUID = 3923695409795596301L;

    private String id;

    private int type;//标识该条数据是来自下载还是阅读 ，0是阅读，1是下载
    // 对应的书籍id，因用到反射这个字段命名不能更改
    private String bookId;

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    private List<String> lineContent = new ArrayList<>();

    private float lineSize;

    public List<String> getLineContent() {
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
}
