package com.bule.free.ireader;

import android.util.TimeUtils;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import org.junit.Test;
import org.reactivestreams.Subscriber;
import org.reactivestreams.Subscription;

import java.util.concurrent.Callable;
import java.util.concurrent.TimeUnit;

import io.reactivex.Flowable;
import io.reactivex.Single;
import io.reactivex.SingleSource;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by suikajy on 2019-06-28
 */
public class JavaTest {

    @Test
    public void testJson() {
        String s = "[{\"a\":1,\"b\":\"s\"},{\"a\":2,\"b\":\"ss\"}]";

        Gson gson = new Gson();
        JsonArray jsonArray = new JsonParser().parse(s).getAsJsonArray();
        for (JsonElement je : jsonArray) {
            B b = gson.fromJson(je, B.class);
            System.out.println(b);
        }
    }

    static class B {
        private int a;
        private String b;

        @Override
        public String toString() {
            return "B{" +
                    "a=" + a +
                    ", b='" + b + '\'' +
                    '}';
        }
    }

    @Test
    public void testRx() {
        Single<Long> timer1 = Single.timer(1L, TimeUnit.SECONDS);
//        Single
        Single<Long> timer2 = Single.error(new IllegalArgumentException("test"));
//        Flowable<Long> concat = Single.concat(timer1, timer2);
//        timer1.concatWith(timer2).observeOn(Schedulers.newThread()).subscribe(new Subscriber<Long>() {
//            @Override
//            public void onSubscribe(Subscription s) {
//                System.out.println("onSubscribe");
//            }
//
//            @Override
//            public void onNext(Long aLong) {
//                System.out.println(String.format("aLong: %s", aLong));
//            }
//
//            @Override
//            public void onError(Throwable t) {
//                System.out.println("onError");
//            }
//
//            @Override
//            public void onComplete() {
//                System.out.println("onComplete");
//            }
//        });
        timer1.concatWith(timer2).observeOn(Schedulers.newThread()).subscribe(System.out::println, System.out::println);
//        timer2.concatWith(timer1).observeOn(Schedulers.newThread()).subscribe(System.out::println, System.out::println);
//        timer1.subscribe(System.out::println);

        try {
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testJava(){
        String param = null;
        switch (param) {
            case "null":
                System.out.println("null");
                break;
            default:
                System.out.println("default");
        }
    }
}
