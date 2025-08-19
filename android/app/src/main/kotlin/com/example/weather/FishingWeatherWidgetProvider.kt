package com.example.weather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * 钓鱼天气小部件提供者
 */
class FishingWeatherWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // 获取小部件尺寸
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            
            // 根据宽度选择布局
            val layoutId = if (minWidth >= 250) {
                R.layout.fishing_widget_layout_large
            } else {
                R.layout.fishing_widget_layout
            }
            
            // 获取存储的数据
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, layoutId).apply {
                // 获取系统语言
                val locale = context.resources.configuration.locales[0]
                val isEnglish = locale.language == "en"
                
                // 设置天气状况
                val weatherCondition = widgetData.getString("weatherCondition", if (isEnglish) "Unknown" else "未知")
                setTextViewText(R.id.weather_condition, weatherCondition)
                
                // 设置温度
                val temperature = widgetData.getString("temperature", "--°C")
                setTextViewText(R.id.temperature, temperature)
                
                // 设置钓鱼适宜性
                val suitabilityKey = if (isEnglish) "suitability_en" else "suitability"
                val suitability = widgetData.getString(suitabilityKey, if (isEnglish) "Unknown" else "未知")
                setTextViewText(R.id.fishing_suitability, suitability)
                
                // 设置钓鱼评分
                val scoreLabel = if (isEnglish) "Score: " else "评分: "
                val score = widgetData.getString("score", "--")
                setTextViewText(R.id.fishing_score, scoreLabel + score)
                
                // 设置标题
                val titleText = if (isEnglish) "Fishing Weather" else "钓鱼天气"
                setTextViewText(R.id.widget_title, titleText)
                
                // 设置天气图标
                val weatherCode = widgetData.getString("weatherCode", "") ?: ""
                val weatherIconRes = getWeatherIconResource(weatherCode)
                setImageViewResource(R.id.weather_icon, weatherIconRes)
                
                // 设置适宜性图标颜色
                val suitabilityLevel = widgetData.getString("suitabilityLevel", "") ?: ""
                val suitabilityColor = getSuitabilityColor(suitabilityLevel)
                setInt(R.id.suitability_indicator, "setColorFilter", suitabilityColor)
                
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
     * 响应小部件尺寸变化
     */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        // 当小部件尺寸变化时，更新小部件
        val minWidth = newOptions.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        
        // 根据宽度选择布局
        val layoutId = if (minWidth >= 250) {
            R.layout.fishing_widget_layout_large
        } else {
            R.layout.fishing_widget_layout
        }
        
        // 更新小部件
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, layoutId)
        
        // 重新调用onUpdate来更新小部件
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId))
    }
    
    /**
     * 根据天气代码获取对应的图标资源ID
     */
    private fun getWeatherIconResource(weatherCode: String): Int {
        return when (weatherCode) {
            "113" -> R.drawable.ic_sunny // 晴天
            "116", "119", "122" -> R.drawable.ic_partly_cloudy // 多云/阴天
            "143", "248", "260" -> R.drawable.ic_weather_default // 雾
            "176", "293", "296", "299", "302", "308", "353", "356" -> R.drawable.ic_rain // 各种雨
            else -> R.drawable.ic_weather_default // 默认天气图标
        }
    }
    
    /**
     * 根据适宜性级别获取对应的颜色
     */
    private fun getSuitabilityColor(level: String): Int {
        return when (level) {
            "excellent" -> 0xFF4CAF50.toInt() // 绿色，非常适宜
            "good" -> 0xFF8BC34A.toInt() // 浅绿色，适宜
            "moderate" -> 0xFFFFC107.toInt() // 黄色，一般
            "poor" -> 0xFFF44336.toInt() // 红色，不适宜
            else -> 0xFF9E9E9E.toInt() // 灰色，未知
        }
    }
}