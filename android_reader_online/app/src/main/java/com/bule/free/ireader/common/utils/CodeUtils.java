package com.bule.free.ireader.common.utils;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.util.TypedValue;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.util.Hashtable;

/**
 * 二维码生成相关
 */
public class CodeUtils {

    // 宽度值，影响中间图片大小
    private static final int IMAGE_HALFWIDTH = 40;

    /**
     * 生成中间带图片的二维码
     *
     * @param context 上下文
     * @param content 二维码内容
     * @param logo    二维码中间的图片
     * @return 生成的二维码图片
     * @throws WriterException 生成二维码异常
     */
    public static Bitmap createCode(Context context, String content, Bitmap logo) throws WriterException {
        Matrix m = new Matrix();
        float sx = (float) 2 * IMAGE_HALFWIDTH / logo.getWidth();
        float sy = (float) 2 * IMAGE_HALFWIDTH / logo.getHeight();
        // 设置缩放信息
        m.setScale(sx, sy);
        // 将logo图片按martix设置的信息缩放
        logo = Bitmap.createBitmap(logo, 0, 0, logo.getWidth(),
                logo.getHeight(), m, false);
        MultiFormatWriter writer = new MultiFormatWriter();
        Hashtable<EncodeHintType, Object> hst = new Hashtable();
        // 设置字符编码
        hst.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        // 设置二维码容错率
        hst.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H);
        // 生成二维码矩阵信息
        BitMatrix matrix = writer.encode(content, BarcodeFormat.QR_CODE,
                DensityUtils.dp2px(context, 300),
                DensityUtils.dp2px(context, 300), hst);
        // 矩阵高度
        int width = matrix.getWidth();
        // 矩阵宽度
        int height = matrix.getHeight();
        int halfW = width / 2;
        int halfH = height / 2;
        // 定义数组长度为矩阵高度*矩阵宽度，用于记录矩阵中像素信息
        int[] pixels = new int[width * height];
        // 从行开始迭代矩阵
        for (int y = 0; y < height; y++) {
            // 迭代列
            for (int x = 0; x < width; x++) {
                // 该位置用于存放图片信息
                if (x > halfW - IMAGE_HALFWIDTH && x < halfW + IMAGE_HALFWIDTH
                        && y > halfH - IMAGE_HALFWIDTH
                        && y < halfH + IMAGE_HALFWIDTH) {
                    // 记录图片每个像素信息
                    pixels[y * width + x] = logo.getPixel(x - halfW
                            + IMAGE_HALFWIDTH, y - halfH + IMAGE_HALFWIDTH);
                } else {
                    // 如果有黑块点，记录信息
                    if (matrix.get(x, y)) {
                        // 记录黑块信息
                        pixels[y * width + x] = 0xff000000;
                    }
//                    else {
//                        pixels[y * width + x] = Color.WHITE;
//                    }
                }

            }
        }
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        // 通过像素数组生成bitmap
        bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
        return bitmap;
    }

    /**
     * 生成用户的二维码
     *
     * @param context 上下文
     * @param content 二维码内容
     * @return 生成的二维码图片
     * @throws WriterException 生成二维码异常
     */
    public static Bitmap createCode(Context context, String content) throws WriterException {
        //生成二维矩阵,编码时指定大小,不要生成了图片以后再进行缩放,这样会模糊导致识别失败

        int dp156 = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 156, context.getResources().getDisplayMetrics());
        Hashtable hints = new Hashtable();
        hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
        BitMatrix matrix = new MultiFormatWriter().encode(content, BarcodeFormat.QR_CODE, dp156, dp156, hints);
        int width = matrix.getWidth();
        int height = matrix.getHeight();
        int[] pixels = new int[width * height];
        boolean isFirstBlackPoint = false;
        int startX = 0;
        int startY = 0;
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                if (matrix.get(x, y)) {
                    if (isFirstBlackPoint == false) {
                        isFirstBlackPoint = true;
                        startX = x;
                        startY = y;
                    }
                    pixels[y * width + x] = 0xff000000;
                }
            }
        }

        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        bitmap.setPixels(pixels, 0, width, 0, 0, width, height);
        if (startX <= 3)
            return bitmap;
        int x1 = startX - 3;
        int y1 = startY - 3;
        if (x1 < 0 || y1 < 0) return bitmap;
        int w1 = width - x1 * 2;
        int h1 = height - y1 * 2;
        Bitmap bitmapQR = Bitmap.createBitmap(bitmap, x1, y1, w1, h1);
        return bitmapQR;
    }

    static class DensityUtils {

        public static int dp2px(Context context, float dp) {
            //获取设备密度
            float density = context.getResources().getDisplayMetrics().density;
            //4.3, 4.9, 加0.5是为了四舍五入
            int px = (int) (dp * density );
            return px;
        }

        public static float px2dp(Context context, int px) {
            //获取设备密度
            float density = context.getResources().getDisplayMetrics().density;
            float dp = px / density;
            return dp;
        }
    }

}
