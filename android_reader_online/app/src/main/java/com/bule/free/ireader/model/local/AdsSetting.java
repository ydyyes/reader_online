package com.bule.free.ireader.model.local;

import com.bule.free.ireader.common.utils.SharedPreUtils;

import java.util.Calendar;
import java.util.Random;


public class AdsSetting {

    public static final String SHARED_SPLASH_AD_SHOW_TIMES = "shared_splash_ad_show_times";
    public static final String SHARED_SPLASH_AD_LAST_SHOWDATE = "shared_splash_ad_last_showdate";
    public static final String SHARED_READ_END_AD_TIMES = "shared_read_end_ad_times";
    public static final String SHARED_READ_END_AD_LAST_SHOWDATE = "shared_read_end_ad_last_showdate";

    public static final String SHARED_READ_END_AD_DATA = "shared_read_end_ad_data";

    private static volatile AdsSetting sInstance;

    private SharedPreUtils sharedPreUtils;

    public static AdsSetting getInstance() {
        if (sInstance == null) {
            synchronized (AdsSetting.class) {
                if (sInstance == null) {
                    sInstance = new AdsSetting();
                }
            }
        }
        return sInstance;
    }

    private AdsSetting() {
        sharedPreUtils = SharedPreUtils.getInstance();
    }

    public String getReadEndAdData(){
        return sharedPreUtils.getString(SHARED_READ_END_AD_DATA);
    }

    public void setReadEndAdData(String ads){
        sharedPreUtils.putString(SHARED_READ_END_AD_DATA,ads);
    }

    public int getSplashShowTimes(){
        return sharedPreUtils.getInt(SHARED_SPLASH_AD_SHOW_TIMES,0);
    }

    public void setSplashShowTimes(int times){
        sharedPreUtils.putInt(SHARED_SPLASH_AD_SHOW_TIMES,times);
    }

    public int getReadEndShowTimes(){
        return sharedPreUtils.getInt(SHARED_READ_END_AD_TIMES,0);
    }

    public void setReadEndShowTimes(int times){
        sharedPreUtils.putInt(SHARED_READ_END_AD_TIMES,times);
    }

    public long getSplashAdLastShowDate(){
        return sharedPreUtils.getLong(SHARED_SPLASH_AD_LAST_SHOWDATE,0);
    }

    public void setSplashAdLastShowDate(long date){
        sharedPreUtils.putLong(SHARED_SPLASH_AD_LAST_SHOWDATE,date);
    }


    public long getReadEndAdLastShowDate(){
        return sharedPreUtils.getLong(SHARED_READ_END_AD_LAST_SHOWDATE,0);
    }

    public void setReadEndAdLastShowDate(long date){
        sharedPreUtils.putLong(SHARED_READ_END_AD_LAST_SHOWDATE,date);
    }

    public boolean checkAdshow(int remoteShowTimes,int remoteInterval,int isSplash) {
        int  showTimes = remoteShowTimes;
        int interval = remoteInterval;
        int currentShowTimes;
        long lastShowTime;

        if(isSplash==1){

            currentShowTimes = getSplashShowTimes();

            lastShowTime = getSplashAdLastShowDate();

            if (!isToday(lastShowTime)) {
                setSplashShowTimes(0);
            }
        }else{
            currentShowTimes = getReadEndShowTimes();

            lastShowTime = getReadEndAdLastShowDate();

            if (!isToday(lastShowTime)) {
                setReadEndShowTimes(0);
            }
        }

        if (currentShowTimes >= showTimes) {
            return false;
        }

        long now = System.currentTimeMillis();
        if (now - lastShowTime < interval * 60*1000) {
            return false;
        }

        return true;

    }


    private static final int RANDOM_MINUTE = new Random().nextInt(90);
    private static final int RANDOM_MS = RANDOM_MINUTE * 60 * 1000;


    public static boolean isToday(long time){

        Calendar calendar = Calendar.getInstance();
        calendar.setTime(new java.util.Date());
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);

        long minTimeInMillis = calendar.getTimeInMillis();
        calendar.set(Calendar.HOUR_OF_DAY, 23);
        calendar.set(Calendar.MINUTE, 59);
        calendar.set(Calendar.SECOND, 59);
        long maxTimeInMillis = calendar.getTimeInMillis();

        long currentTime = System.currentTimeMillis();
        try{
            if (currentTime - minTimeInMillis > RANDOM_MS){
                return (time > minTimeInMillis && time < maxTimeInMillis);
            }}catch (Exception e){
        }
        return true;
    }


}
