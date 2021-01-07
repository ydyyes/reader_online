package com.bule.free.ireader;

import android.support.v4.util.TimeUtils;

import com.bule.free.ireader.api.Api;

import org.junit.Test;

import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import io.reactivex.Scheduler;
import io.reactivex.Single;
import io.reactivex.SingleObserver;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

/**
 * Created by suikajy on 2019/4/19
 */
public class RxJavaErrorTest {


    @Test
    public void test() {
        String badUrl = "http://dwtxt2.xs8.ltd/153261d1/60f33b7d_6ddb1cf7/114_ded56421fc146d6dfa9d55cf90a3a8e52.txt";
        ExecutorService executorService = Executors.newSingleThreadExecutor();
        executorService.submit(() -> {
            System.out.println("1 " + Thread.currentThread().toString());
            Single.<String>create(emitter -> {
                System.out.println("3 " + Thread.currentThread().toString());
               // if (true) throw new IllegalArgumentException("get error2");
                emitter.onError(new IllegalArgumentException("get error"));
                emitter.onSuccess("");
            }).subscribeOn(Schedulers.io())
                    .observeOn(new Scheduler() {
                        @Override
                        public Worker createWorker() {
                            return new Worker() {
                                @Override
                                public Disposable schedule(Runnable run, long delay, TimeUnit unit) {
                                    executorService.submit(run);
                                    return null;
                                }

                                @Override
                                public void dispose() {

                                }

                                @Override
                                public boolean isDisposed() {
                                    return false;
                                }
                            };
                        }
                    })
                    .subscribe(new SingleObserver<String>() {
                        @Override
                        public void onSubscribe(Disposable d) {
                            System.out.println("onSubscribe " + Thread.currentThread().toString());
                            System.out.println("onSubscribe");
                        }

                        @Override
                        public void onSuccess(String s) {
                            System.out.println("onShow " + Thread.currentThread().toString());
                            System.out.println("onShow");
                        }

                        @Override
                        public void onError(Throwable e) {
                            System.err.println("onError " + Thread.currentThread().toString());
                            System.out.println("onError "+e.toString());
                        }
                    });
        });
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

}
