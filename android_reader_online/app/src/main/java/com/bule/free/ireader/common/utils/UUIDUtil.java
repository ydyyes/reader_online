package com.bule.free.ireader.common.utils;

import android.content.Context;
import android.os.Environment;


import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.UUID;

/**
 * Created by wmmeng on 2018/8/13.
 */

public class UUIDUtil {
//    private static String deviceUUID = "af950d77-2a31-413c-ba3c-634309577d67";
    private static String deviceUUID = null;
    private static String UUID_FILE_NAME = ".ir_uuid";
    private static String EXTERNAL_UUID_SUB_DIR = "ireader";
    private static String EXTERNAL_UUID_DIR = Environment
            .getExternalStorageDirectory()
            + File.separator
            + EXTERNAL_UUID_SUB_DIR;

    public synchronized static String getUUID(Context context) {
        if (deviceUUID == null) {
            File internalUUIDFile = new File(context.getFilesDir(), UUID_FILE_NAME);
            File sdcardDir = new File(EXTERNAL_UUID_DIR);
            if(!sdcardDir.exists()) {
                sdcardDir.mkdirs();
            }
            File externalUUIDFile = new File(EXTERNAL_UUID_DIR, UUID_FILE_NAME);
            if(!externalUUIDFile.exists()) {
                try {
                    externalUUIDFile.createNewFile();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            try {
                // 1.优先从应用目录中读取
                String tempUUID = readUUIDFile(internalUUIDFile);
                // 2. 应用目录中无效，则尝试从SD卡中导入
                if (invalidUUID(tempUUID)) {
                    tempUUID = readUUIDFile(externalUUIDFile);
                    if (validUUID(tempUUID)) {
                        writeUUIDFile(internalUUIDFile, tempUUID);
                    }
                }

                // 3. 从SD卡中导入失败，则重新生成
                if (invalidUUID(tempUUID)) {
                    tempUUID = generateUUID(true);
                    writeUUIDFile(internalUUIDFile, tempUUID);
                    writeUUIDFile(externalUUIDFile, tempUUID);
                }

                deviceUUID = tempUUID;
            } catch (Exception e) {
                return null;
            }
        }
        return deviceUUID;
    }

    private static boolean validUUID(String uuid) {
        if (uuid == null || "".equals(uuid.trim())) {
            return false;
        }

        return true;
    }

    private static boolean invalidUUID(String uuid) {
        return !validUUID(uuid);
    }

    private static String readUUIDFile(File uuidFile) {
        if(uuidFile == null || !uuidFile.exists()) {
            return null;
        }
        try{
            RandomAccessFile f = new RandomAccessFile(uuidFile, "r");
            byte[] bytes = new byte[(int) f.length()];
            f.readFully(bytes);
            f.close();
            return new String(bytes);
        }catch (IOException e){
        }

        return null;
    }

    private static String generateUUID(boolean random) {
        if(random){

        }
        return UUID.randomUUID().toString();

    }

    private static void writeUUIDFile(File file, String u)
            throws IOException {
        FileUtils.writeFile(file.getAbsolutePath(), u);
    }
}
