import WidgetKit
import SwiftUI
import Intents

struct FishingWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> FishingWidgetEntry {
        FishingWidgetEntry(date: Date(), weatherCondition: "晴天", temperature: "25°C", suitability: "适宜", score: "10", suitabilityLevel: "good")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (FishingWidgetEntry) -> ()) {
        let entry = FishingWidgetEntry(date: Date(), weatherCondition: "晴天", temperature: "25°C", suitability: "适宜", score: "10", suitabilityLevel: "good")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<FishingWidgetEntry>) -> ()) {
        var entries: [FishingWidgetEntry] = []
        
        // 从共享UserDefaults获取数据
        let userDefaults = UserDefaults(suiteName: "group.com.example.weather")
        let weatherCondition = userDefaults?.string(forKey: "weatherCondition") ?? "未知"
        let temperature = userDefaults?.string(forKey: "temperature") ?? "--°C"
        let suitability = userDefaults?.string(forKey: "suitability") ?? "未知"
        let score = userDefaults?.string(forKey: "score") ?? "--"
        let suitabilityLevel = userDefaults?.string(forKey: "suitabilityLevel") ?? "moderate"
        
        let entry = FishingWidgetEntry(
            date: Date(),
            weatherCondition: weatherCondition,
            temperature: temperature,
            suitability: suitability,
            score: score,
            suitabilityLevel: suitabilityLevel
        )
        entries.append(entry)
        
        // 创建时间线，每30分钟刷新一次
        let timeline = Timeline(entries: entries, policy: .after(Date(timeIntervalSinceNow: 30 * 60)))
        completion(timeline)
    }
}

struct FishingWidgetEntry: TimelineEntry {
    let date: Date
    let weatherCondition: String
    let temperature: String
    let suitability: String
    let score: String
    let suitabilityLevel: String
}

struct FishingWidgetEntryView : View {
    var entry: FishingWidgetProvider.Entry
    
    var suitabilityColor: Color {
        switch entry.suitabilityLevel {
        case "excellent":
            return Color.green
        case "good":
            return Color(red: 0.55, green: 0.78, blue: 0.29)
        case "moderate":
            return Color.yellow
        case "poor":
            return Color.red
        default:
            return Color.gray
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0, green: 0, blue: 0, opacity: 0.8)
                .cornerRadius(16)
            
            VStack(spacing: 4) {
                Text("钓鱼天气")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
                
                HStack {
                    Image(systemName: getWeatherIconName(for: entry.weatherCondition))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                    
                    Text(entry.weatherCondition)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Text(entry.temperature)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Circle()
                        .fill(suitabilityColor)
                        .frame(width: 12, height: 12)
                    
                    Text("适宜性: \(entry.suitability)")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Text("评分: \(entry.score)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
    }
    
    func getWeatherIconName(for condition: String) -> String {
        if condition.contains("晴") {
            return "sun.max.fill"
        } else if condition.contains("多云") {
            return "cloud.sun.fill"
        } else if condition.contains("阴") {
            return "cloud.fill"
        } else if condition.contains("雨") {
            return "cloud.rain.fill"
        } else if condition.contains("雪") {
            return "cloud.snow.fill"
        } else if condition.contains("雾") {
            return "cloud.fog.fill"
        } else {
            return "questionmark.circle.fill"
        }
    }
}

struct FishingWeatherWidget: Widget {
    let kind: String = "FishingWeatherWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: FishingWidgetProvider()) { entry in
            FishingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("钓鱼天气")
        .description("显示当前位置的钓鱼适宜性")
        .supportedFamilies([.systemSmall])
    }
}

struct FishingWeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        FishingWidgetEntryView(entry: FishingWidgetEntry(date: Date(), weatherCondition: "晴天", temperature: "25°C", suitability: "适宜", score: "10", suitabilityLevel: "good"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}