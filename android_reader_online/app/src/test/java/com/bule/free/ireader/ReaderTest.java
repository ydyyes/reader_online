package com.bule.free.ireader;

import com.bule.free.ireader.common.utils.AES;

import org.junit.Test;

import java.util.Locale;

import static org.junit.Assert.assertEquals;

/**
 * Created by suikajy on 2019/3/29
 */
public class ReaderTest {

    @Test
    public void test() {
        assertEquals(2, 1 + 1);
        double percentage = 0.13581218;
        String percentageParam = String.format(Locale.CHINESE, "%.2f", percentage * 100);
        System.out.println(percentageParam);
    }

    @Test
    public void decode() {
        String sign = "t3B1lDN+l4PIMJDaJmsgYa52eeloBCUPUBEGAa4h79HQGTA/XmV650B3a+Say1xmhr4G/aSfqpN7\n" +
                "3o39ZqO6NviXR9Pqea4LVIUBggYoZ4JfYSG1rHeaOmfNUSOk6Y10kpEt+RjK2k/7OBUis899C3B7\n" +
                "KCWofajQJNNtYk6cYX9niIJeE9SSXuiRScyQTMWL";
        System.out.println(AES.decrypt(sign));
    }
}
