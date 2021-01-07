package com.bule.free.ireader.common.utils;

import android.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

/**
 * Created by suikajy on 2019/2/18
 */
public class AES {

    public static final String KEY = "J4gtW7Pbw1Xuxarq";

    /**
     * AES加密
     *
     * @return 已经加密的内容
     */
    public static String encrypt(String oriContent) {
        //不足16字节，补齐内容为差值
        byte[] data = oriContent.getBytes();
//        int len = 16 - data.length % 16;
//        for (int i = 0; i < len; i++) {
//            byte[] bytes = {(byte) len};
//            data = concat(data, bytes);
//        }
        try {
            SecretKeySpec skeySpec = new SecretKeySpec(KEY.getBytes(), "AES");
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
            return new String(Base64.encode(cipher.doFinal(data), Base64.DEFAULT));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * AES解密
     *
     * @return 已经解密的内容
     */
    public static String decrypt(String encryptedString) {
        byte[] data = Base64.decode(encryptedString, Base64.DEFAULT);
//        data = noPadding(data, -1);
        try {
            SecretKeySpec skeySpec = new SecretKeySpec(KEY.getBytes(), "AES");
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, skeySpec);
            byte[] decryptData = cipher.doFinal(data);
            //int len = 2 + byteToInt(decryptData[4]) + 3;
            //return new String(noPadding(decryptData, len));
            return new String(decryptData);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static int byteToInt(byte b) {
        return (b) & 0xff;
    }


    /**
     * 合并数组
     *
     * @param firstArray  第一个数组
     * @param secondArray 第二个数组
     * @return 合并后的数组
     */
    public static byte[] concat(byte[] firstArray, byte[] secondArray) {
        if (firstArray == null || secondArray == null) {
            return null;
        }
        byte[] bytes = new byte[firstArray.length + secondArray.length];
        System.arraycopy(firstArray, 0, bytes, 0, firstArray.length);
        System.arraycopy(secondArray, 0, bytes, firstArray.length,
                secondArray.length);
        return bytes;
    }

    /**
     * 去除数组中的补齐
     *
     * @param paddingBytes 源数组
     * @param dataLength   去除补齐后的数据长度
     * @return 去除补齐后的数组
     */
    public static byte[] noPadding(byte[] paddingBytes, int dataLength) {
        if (paddingBytes == null) {
            return null;
        }

        byte[] noPaddingBytes = null;
        if (dataLength > 0) {
            if (paddingBytes.length > dataLength) {
                noPaddingBytes = new byte[dataLength];
                System.arraycopy(paddingBytes, 0, noPaddingBytes, 0, dataLength);
            } else {
                noPaddingBytes = paddingBytes;
            }
        } else {
            int index = paddingIndex(paddingBytes);
            if (index > 0) {
                noPaddingBytes = new byte[index];
                System.arraycopy(paddingBytes, 0, noPaddingBytes, 0, index);
            }
        }

        return noPaddingBytes;
    }

    /**
     * 获取补齐的位置
     *
     * @param paddingBytes 源数组
     * @return 补齐的位置
     */
    private static int paddingIndex(byte[] paddingBytes) {
        for (int i = paddingBytes.length - 1; i >= 0; i--) {
            if (paddingBytes[i] != 0) {
                return i + 1;
            }
        }
        return -1;
    }
}
