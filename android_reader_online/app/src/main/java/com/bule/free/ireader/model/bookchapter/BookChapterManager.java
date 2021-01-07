package com.bule.free.ireader.model.bookchapter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.text.TextUtils;

import com.bule.free.ireader.App;
import com.bule.free.ireader.model.bean.BookChapterBean;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by suikajy on 2019-06-28
 * <p>
 * 章节列表采用文件存储，避免大量的数据库操作，进行性能优化
 */
public class BookChapterManager {

    private static final String RESTORE_PATH = "book_ch_cache";
    private static File restoreDir;

    public static void write(String bookId, String chapterListJson) {
        final String fileName = "book_" + bookId;
        File file = new File(getRestoreDir(), fileName);
        if (!file.exists()) {
            try {
                file.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        try (OutputStream outstream = new FileOutputStream(file)) {
            OutputStreamWriter out = new OutputStreamWriter(outstream);
            out.write(chapterListJson);
            out.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @NonNull
    private static String readFile(@NonNull String bookId) {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new FileReader(new File(getRestoreDir(), "book_" + bookId)))) {
            String temp;
            while ((temp = br.readLine()) != null) {
                //过滤空语句
                if (!temp.equals("")) {
                    //由于sb会自动过滤\n,所以需要加上去
                    sb.append(temp);
                }
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return sb.toString();
    }

    @NonNull
    public static List<BookChapterBean> get(String bookId) {
        List<BookChapterBean> result = new ArrayList<>();
        String json = readFile(bookId);
        if (TextUtils.isEmpty(json)) return result;
        Gson gson = new Gson();
        JsonArray jsonArray = new JsonParser().parse(json).getAsJsonArray();
        for (JsonElement je : jsonArray) {
            BookChapterBean bookChapterBean = gson.fromJson(je, BookChapterBean.class);
            result.add(bookChapterBean);
        }
        return result;
    }

    public static void clear() {
        File restoreDir = getRestoreDir();
        File[] files = restoreDir.listFiles();
        if (files == null) return;
        for (File file : files) {
            file.delete();
        }
    }

    private static File getRestoreDir() {
        if (restoreDir != null) {
            return restoreDir;
        }
        File file = new File(getContext().getFilesDir(), RESTORE_PATH);
        if (!file.exists()) {
            boolean mkdir = file.mkdir();
            if (!mkdir) try {
                throw new IOException("创建存储章节列表目录失败");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        restoreDir = file;
        return restoreDir;
    }

    private static Context getContext() {
        return App.instance;
    }

}
