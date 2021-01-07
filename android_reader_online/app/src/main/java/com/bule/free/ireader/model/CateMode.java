package com.bule.free.ireader.model;

import android.os.Parcel;
import android.os.Parcelable;


/**
 * Created by liumin on 2018/12/19.
 */

// 推荐、最热
public enum CateMode implements Parcelable {


    FINISHED("over"),//完结
    HOT("hot"),      //热门榜
    NEW("new"),       //新书榜
    HIGH_QUALITY("reputation"),       //口碑榜
    HOT_SEARCH("2"), // 热搜
    HOT_UPDATE("1"), // 热更
    EDITOR_REC(""),//编辑推荐
    GENTLEMAN("1"),
    LADY("2");


    public final String apiParam;

    CateMode(String apiParam) {
        this.apiParam = apiParam;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(ordinal());
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<CateMode> CREATOR = new Creator<CateMode>() {
        @Override
        public CateMode createFromParcel(Parcel in) {
            return CateMode.values()[in.readInt()];
        }

        @Override
        public CateMode[] newArray(int size) {
            return new CateMode[size];
        }
    };
}
