#!/bin/bash

# 设置错误时退出
set -e

echo "安装必要的工具..."
gem install xcodeproj

echo "备份现有的FishingWidget目录..."
if [ -d "FishingWidget" ]; then
  rm -rf FishingWidget.bak
  mv FishingWidget FishingWidget.bak
fi

echo "创建FishingWidget目录..."
mkdir -p FishingWidget

echo "创建必要的文件..."

# 创建FishingWidget.swift
cat > FishingWidget/FishingWidget.swift << 'EOL'
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
EOL

# 创建Info.plist
cat > FishingWidget/Info.plist << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>钓鱼天气</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.widgetkit-extension</string>
	</dict>
</dict>
</plist>
EOL

# 创建entitlements文件
cat > FishingWidget/FishingWidget.entitlements << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.cn.leoobai.fishingweather</string>
	</array>
</dict>
</plist>
EOL

# 创建Runner.entitlements文件
cat > Runner/Runner.entitlements << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.cn.leoobai.fishingweather</string>
	</array>
</dict>
</plist>
EOL

echo "修改Xcode项目..."
ruby -e '
require "xcodeproj"

# 打开项目
project_path = "Runner.xcodeproj"
project = Xcodeproj::Project.open(project_path)

# 获取主目标
main_target = project.targets.find { |t| t.name == "Runner" }
raise "未找到Runner目标" unless main_target

# 设置主应用的entitlements
main_target.build_configurations.each do |config|
  config.build_settings["CODE_SIGN_ENTITLEMENTS"] = "Runner/Runner.entitlements"
end

# 创建Widget Extension目标
widget_target = project.new_target(:app_extension, "FishingWidget", :ios)

# 设置构建设置
widget_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_NAME"] = "FishingWidget"
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "cn.leoobai.fishingweather.FishingWidget"
  config.build_settings["CODE_SIGN_ENTITLEMENTS"] = "FishingWidget/FishingWidget.entitlements"
  config.build_settings["INFOPLIST_FILE"] = "FishingWidget/Info.plist"
  config.build_settings["SWIFT_VERSION"] = "5.0"
  config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "14.0"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
end

# 添加文件引用
widget_group = project.main_group.find_subpath("FishingWidget", true)
widget_group.clear

# 添加Swift文件
file_ref = widget_group.new_file("FishingWidget/FishingWidget.swift")
widget_target.add_file_references([file_ref])

# 添加Info.plist和entitlements文件
info_ref = widget_group.new_file("FishingWidget/Info.plist")
entitlements_ref = widget_group.new_file("FishingWidget/FishingWidget.entitlements")

# 添加目标依赖
main_target.add_dependency(widget_target)

# 创建Embed App Extensions构建阶段
embed_phase = main_target.new_copy_files_build_phase("Embed App Extensions")
embed_phase.symbol_dst_subfolder_spec = :plug_ins

# 添加产品引用到Embed App Extensions构建阶段
product_ref = widget_target.product_reference
if product_ref
  puts "添加了产品引用到Embed App Extensions构建阶段"
  build_file = embed_phase.add_file_reference(product_ref)
  build_file.settings = { "ATTRIBUTES" => ["RemoveHeadersOnCopy"] }
else
  puts "警告：未找到产品引用"
end

# 保存项目
project.save
puts "成功保存项目配置"
'

echo "更新Podfile..."
cat > Podfile << 'EOL'
# Uncomment this line to define a global platform for your project
platform :ios, '14.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

# 主应用目标
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

# Widget Extension目标
target 'FishingWidget' do
  use_frameworks!
  use_modular_headers!
  
  # 基础Flutter pod
  pod 'Flutter', :path => '../Flutter'
  
  # 手动添加需要的插件，排除workmanager
  pod 'path_provider_foundation', :path => '.symlinks/plugins/path_provider_foundation/darwin'
  pod 'shared_preferences_foundation', :path => '.symlinks/plugins/shared_preferences_foundation/darwin'
  pod 'geolocator_apple', :path => '.symlinks/plugins/geolocator_apple/ios'
  pod 'permission_handler_apple', :path => '.symlinks/plugins/permission_handler_apple/ios'
  pod 'package_info_plus', :path => '.symlinks/plugins/package_info_plus/ios'
  pod 'google_mobile_ads', :path => '.symlinks/plugins/google_mobile_ads/ios'
  pod 'home_widget', :path => '.symlinks/plugins/home_widget/ios'
  pod 'sqflite', :path => '.symlinks/plugins/sqflite/ios'
  pod 'webview_flutter_wkwebview', :path => '.symlinks/plugins/webview_flutter_wkwebview/ios'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # 添加权限描述
    target.build_configurations.each do |config|
      # 位置权限
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
EOL

echo "运行pod install..."
pod install

echo "Widget Extension设置完成！"
echo "请在Xcode中打开项目，确保正确配置签名和权限"