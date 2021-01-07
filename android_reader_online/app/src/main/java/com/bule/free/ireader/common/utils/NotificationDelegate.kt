package com.bule.free.ireader.common.utils

import android.annotation.TargetApi
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context.NOTIFICATION_SERVICE
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.support.annotation.DrawableRes
import android.support.v4.app.NotificationCompat
import com.bule.free.ireader.App
import com.bule.free.ireader.Const
import com.bule.free.ireader.R

/**
 * Created by suikajy on 2019/4/8
 */
object NotificationDelegate {

    // 通知是否显示角标
    private const val IS_SHOW_BADGE = true
    private const val COMMON_NOTIFICATION_ID = 1

    /**
     * App中使用的通知渠道。
     *
     * 枚举对象名为渠道id
     */
    @TargetApi(Build.VERSION_CODES.O)
    enum class Channels(private val channelName: String,
                        private val defaultImportance: Int) {
        COMMON("所有通知推送", NotificationManager.IMPORTANCE_DEFAULT);

        // 重复创建不会影响效率，系统会判断渠道是否已经创建
        fun createNotificationChannel() {
            val channel = NotificationChannel(name, channelName, defaultImportance)
            channel.setShowBadge(IS_SHOW_BADGE)
            val notificationManager = App.instance.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Channels.values().forEach { it.createNotificationChannel() }
        }
    }

    fun showNotification(contentTitle: String,
                         contentText: String,
                         whenToShow: Long = System.currentTimeMillis(),
                         @DrawableRes smallIcon: Int = Const.channelConfig.ic_launcher,
                         largeIcon: Bitmap? = null,
                         channel: Channels = NotificationDelegate.Channels.COMMON,
                         autoCancel: Boolean = true) {
        val manager = App.instance.getSystemService(NOTIFICATION_SERVICE) as NotificationManager?
        val notification = NotificationCompat.Builder(App.instance, channel.name)
                .setContentTitle(contentTitle)
                .setContentText(contentText)
                .setWhen(whenToShow)
                .setSmallIcon(smallIcon)
                .setLargeIcon(largeIcon
                        ?: BitmapFactory.decodeResource(App.instance.resources, Const.channelConfig.ic_launcher))
                .setAutoCancel(autoCancel)
                .build()
        manager?.notify(COMMON_NOTIFICATION_ID, notification)
    }

    fun getUmengNotification(contentTitle: String,
                             contentText: String,
                             whenToShow: Long = System.currentTimeMillis(),
                             @DrawableRes smallIcon: Int = Const.channelConfig.ic_launcher,
                             largeIcon: Bitmap? = null,
                             channel: Channels = NotificationDelegate.Channels.COMMON,
                             autoCancel: Boolean = true): Notification {
        return NotificationCompat.Builder(App.instance, channel.name)
                .setContentTitle(contentTitle)
                .setContentText(contentText)
                .setWhen(whenToShow)
                .setSmallIcon(smallIcon)
                .setLargeIcon(largeIcon
                        ?: BitmapFactory.decodeResource(App.instance.resources, Const.channelConfig.ic_launcher))
                .setAutoCancel(autoCancel)
                .build()
    }
}