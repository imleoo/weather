package cn.leoobai.fishingweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.Timer
import java.util.TimerTask

/**
 * 钓鱼天气大尺寸小部件提供者
 */
class FishingWeatherWidgetLargeProvider : AppWidgetProvider() {
    
    // 时间变化广播接收器
    private var timeChangedReceiver: BroadcastReceiver? = null
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        
        // 注册时间变化广播接收器
        registerTimeChangedReceiver(context)
        
        // 启动前台服务保活widget
        startWidgetKeepAliveService(context)
    }
    
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        
        // 取消注册时间变化广播接收器
        unregisterTimeChangedReceiver(context)
        
        // 停止保活服务
        stopWidgetKeepAliveService(context)
    }
    
    /**
     * 注册时间变化广播接收器
     */
    private fun registerTimeChangedReceiver(context: Context) {
        if (timeChangedReceiver == null) {
            timeChangedReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    // 当时间变化时，更新小部件
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        ComponentName(context, FishingWeatherWidgetLargeProvider::class.java)
                    )
                    onUpdate(context, appWidgetManager, appWidgetIds)
                }
            }
            
            // 创建一个定时器，每分钟更新一次时间
            val timer = Timer()
            timer.scheduleAtFixedRate(object : TimerTask() {
                override fun run() {
                    // 在主线程中更新小部件
                    android.os.Handler(android.os.Looper.getMainLooper()).post {
                        val appWidgetManager = AppWidgetManager.getInstance(context)
                        val appWidgetIds = appWidgetManager.getAppWidgetIds(
                            ComponentName(context, FishingWeatherWidgetLargeProvider::class.java)
                        )
                        onUpdate(context, appWidgetManager, appWidgetIds)
                    }
                }
            }, 0, 60000) // 延迟0毫秒，每60000毫秒（1分钟）执行一次
        }
    }
    
    /**
     * 取消注册时间变化广播接收器
     */
    private fun unregisterTimeChangedReceiver(context: Context) {
        if (timeChangedReceiver != null) {
            try {
                context.applicationContext.unregisterReceiver(timeChangedReceiver)
            } catch (e: Exception) {
                // 忽略异常
            }
            timeChangedReceiver = null
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // 当接收到ACTION_APPWIDGET_UPDATE广播时，注册时间变化广播接收器
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            registerTimeChangedReceiver(context)
        }
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // 获取存储的数据
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.fishing_widget_layout_large).apply {
                // 直接使用应用保存的本地化文本
                // 设置标题
                val titleText = widgetData.getString("widget_title", "Fishing Weather")
                setTextViewText(R.id.widget_title, titleText)
                
                // 设置天气状况
                val weatherCondition = widgetData.getString("weatherCondition", "Unknown")
                setTextViewText(R.id.weather_condition, weatherCondition)
                
                // 设置温度
                val temperature = widgetData.getString("temperature", "--°C")
                setTextViewText(R.id.temperature, temperature)
                
                // 设置钓鱼适宜性 - 直接使用应用保存的本地化文本
                val suitabilityText = widgetData.getString("suitability", "Poor")
                val levelText = widgetData.getString("level_prefix", "Level: ") + suitabilityText
                setTextViewText(R.id.fishing_suitability, levelText)
                
                // 设置评分
                val scoreText = widgetData.getString("score", "--")
                val scoreDisplayText = widgetData.getString("score_prefix", "Score: ") + scoreText
                setTextViewText(R.id.fishing_score, scoreDisplayText)
                
                // 设置天气图标（从天气描述推断图标）
                val safeWeatherCondition = weatherCondition ?: "Unknown"
                val weatherIconRes = getWeatherIconResource(safeWeatherCondition)
                setImageViewResource(R.id.weather_icon, weatherIconRes)
                
                // 设置适宜性图标颜色（从评分推断）
                val scoreValue = try {
                    scoreText?.toIntOrNull() ?: 0
                } catch (e: Exception) {
                    0
                }
                val suitabilityColor = getSuitabilityColor(scoreValue)
                setInt(R.id.suitability_indicator, "setColorFilter", suitabilityColor)
                
                // 设置当前时间（每次更新时都会刷新，显示时分）
                val dateFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
                val currentTime = dateFormat.format(Date(System.currentTimeMillis()))
                setTextViewText(R.id.current_time, currentTime)
                
                // 设置定位地址
                val location = widgetData.getString("location", "Unknown Location")
                setTextViewText(R.id.location_text, location)
                
                // 创建一个明确的Intent来启动MainActivity
                val intent = Intent(context, MainActivity::class.java).apply {
                    // 设置标志，确保启动新的实例
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    // 添加一个唯一的action，避免系统缓存Intent
                    action = "android.intent.action.MAIN"
                    addCategory("android.intent.category.LAUNCHER")
                    // 添加当前时间戳作为额外数据，确保每次点击都是唯一的
                    putExtra("timestamp", System.currentTimeMillis())
                }
                
                // 创建PendingIntent，使用不同的requestCode确保唯一性
                val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.getActivity(context, appWidgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                } else {
                    PendingIntent.getActivity(context, appWidgetId, intent, PendingIntent.FLAG_UPDATE_CURRENT)
                }
                
                // 为整个小部件容器设置点击事件
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
    
    /**
     * 启动widget保活服务
     */
    private fun startWidgetKeepAliveService(context: Context) {
        try {
            val serviceIntent = Intent(context, WidgetKeepAliveService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
        } catch (e: Exception) {
            // 服务启动失败，忽略异常
        }
    }
    
    /**
     * 停止widget保活服务
     */
    private fun stopWidgetKeepAliveService(context: Context) {
        try {
            val serviceIntent = Intent(context, WidgetKeepAliveService::class.java)
            context.stopService(serviceIntent)
        } catch (e: Exception) {
            // 服务停止失败，忽略异常
        }
    }
    
    /**
     * 根据天气描述获取对应的图标资源ID
     */
    private fun getWeatherIconResource(weatherCondition: String): Int {
        val condition = weatherCondition.lowercase()
        return when {
            condition.contains("sunny") || condition.contains("晴") -> R.drawable.ic_sunny
            condition.contains("cloud") || condition.contains("云") || condition.contains("overcast") || condition.contains("阴") -> R.drawable.ic_partly_cloudy
            condition.contains("rain") || condition.contains("雨") || condition.contains("shower") -> R.drawable.ic_rain
            condition.contains("fog") || condition.contains("雾") || condition.contains("mist") -> R.drawable.ic_weather_default
            else -> R.drawable.ic_weather_default
        }
    }
    
    /**
     * 根据钓鱼评分获取对应的颜色
     */
    private fun getSuitabilityColor(score: Int): Int {
        return when {
            score >= 12 -> 0xFF4CAF50.toInt() // 绿色，极佳(Excellent)
            score >= 8 -> 0xFF2196F3.toInt() // 蓝色，良好(Good)
            score >= 4 -> 0xFFFF9800.toInt() // 橙色，一般(Moderate)
            else -> 0xFFF44336.toInt() // 红色，较差(Poor)
        }
    }
}