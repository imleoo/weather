import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), weatherData: WeatherData.placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), weatherData: WeatherData.placeholder)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.cn.leoobai.fishingweather")
        
        var weatherData = WeatherData.placeholder
        
        if let data = userDefaults?.data(forKey: "fishing_weather_data") {
            if let decoded = try? JSONDecoder().decode(WeatherData.self, from: data) {
                weatherData = decoded
            }
        }
        
        let entry = SimpleEntry(date: Date(), weatherData: weatherData)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weatherData: WeatherData
}

struct WeatherData: Codable {
    let temperature: String
    let weatherCondition: String
    let location: String
    let fishingScore: Int
    let fishingAdvice: String
    let updateTime: String
    
    static var placeholder: WeatherData {
        return WeatherData(
            temperature: "25°C",
            weatherCondition: "晴",
            location: "未知位置",
            fishingScore: 3,
            fishingAdvice: "今日钓鱼指数一般",
            updateTime: "未更新"
        )
    }
}

struct FishingWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.weatherData.location)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(entry.weatherData.temperature)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(entry.weatherData.weatherCondition)
                    .font(.headline)
            }
            
            Spacer()
            
            HStack {
                Text("钓鱼指数")
                    .font(.caption)
                
                Spacer()
                
                ForEach(0..<5) { i in
                    Image(systemName: i < entry.weatherData.fishingScore ? "star.fill" : "star")
                        .foregroundColor(i < entry.weatherData.fishingScore ? .yellow : .gray)
                        .font(.system(size: 8))
                }
            }
            
            Text(entry.weatherData.updateTime)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.weatherData.location)
                    .font(.headline)
                
                HStack {
                    Text(entry.weatherData.temperature)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(entry.weatherData.weatherCondition)
                        .font(.headline)
                }
                
                Spacer()
                
                Text(entry.weatherData.updateTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("钓鱼指数")
                    .font(.headline)
                
                HStack {
                    ForEach(0..<5) { i in
                        Image(systemName: i < entry.weatherData.fishingScore ? "star.fill" : "star")
                            .foregroundColor(i < entry.weatherData.fishingScore ? .yellow : .gray)
                    }
                }
                
                Spacer()
                
                Text(entry.weatherData.fishingAdvice)
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.weatherData.location)
                    .font(.headline)
                
                Spacer()
                
                Text(entry.weatherData.updateTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(entry.weatherData.temperature)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(entry.weatherData.weatherCondition)
                        .font(.title2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("钓鱼指数")
                        .font(.headline)
                    
                    HStack {
                        ForEach(0..<5) { i in
                            Image(systemName: i < entry.weatherData.fishingScore ? "star.fill" : "star")
                                .foregroundColor(i < entry.weatherData.fishingScore ? .yellow : .gray)
                                .font(.title2)
                        }
                    }
                }
            }
            
            Spacer()
            
            Text("钓鱼建议")
                .font(.headline)
            
            Text(entry.weatherData.fishingAdvice)
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct FishingWidget: Widget {
    let kind: String = "FishingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FishingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("钓鱼天气")
        .description("显示当前位置的钓鱼天气指数")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
