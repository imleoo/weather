package cn.leoobai.fishingweather

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.appwidget.AppWidgetManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import java.util.Timer
import java.util.TimerTask

/**
 * Widget保活服务，用于防止widget被系统杀死
 */
class WidgetKeepAliveService : Service() {
    
    private var timer: Timer? = null
    private val TAG = "WidgetKeepAliveService"
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "WidgetKeepAliveService onCreate")
        
        // 创建通知渠道
        createNotificationChannel()
        
        // 启动为前台服务
        startForeground(1, createNotification())
        
        // 启动定时检查
        startPeriodicCheck()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "WidgetKeepAliveService onStartCommand")
        return START_STICKY
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "WidgetKeepAliveService onDestroy")
        
        // 停止定时器
        timer?.cancel()
        timer = null
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    /**
     * 创建通知渠道
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "widget_keep_alive_channel"
            val channelName = "Widget Keep Alive"
            val channelDescription = "Keep widget alive service"
            val importance = NotificationManager.IMPORTANCE_LOW
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                setShowBadge(false)
                setSound(null, null)
                enableVibration(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    /**
     * 创建通知
     */
    private fun createNotification(): Notification {
        val channelId = "widget_keep_alive_channel"
        
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle("Fishing Weather")
                .setContentText("Widget service is running")
                .setSmallIcon(R.drawable.ic_weather_default)
                .setOngoing(true)
                .setPriority(Notification.PRIORITY_LOW)
                .setCategory(Notification.CATEGORY_SERVICE)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Fishing Weather")
                .setContentText("Widget service is running")
                .setSmallIcon(R.drawable.ic_weather_default)
                .setOngoing(true)
                .setPriority(Notification.PRIORITY_LOW)
                .build()
        }
    }
    
    /**
     * 启动定时检查
     */
    private fun startPeriodicCheck() {
        timer?.cancel()
        
        timer = Timer()
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                try {
                    // 检查widget是否仍然存在
                    val appWidgetManager = AppWidgetManager.getInstance(this@WidgetKeepAliveService)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        ComponentName(this@WidgetKeepAliveService, FishingWeatherWidgetLargeProvider::class.java)
                    )
                    
                    if (appWidgetIds.isNotEmpty()) {
                        // 如果widget存在，触发更新
                        Log.d(TAG, "Widget exists, triggering update")
                        val widgetProvider = FishingWeatherWidgetLargeProvider()
                        widgetProvider.onUpdate(this@WidgetKeepAliveService, appWidgetManager, appWidgetIds)
                    } else {
                        // 如果widget不存在，停止服务
                        Log.d(TAG, "No widgets found, stopping service")
                        stopSelf()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error checking widget status", e)
                }
            }
        }, 60000, 300000) // 1分钟后开始，每5分钟检查一次
    }
}