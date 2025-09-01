# iOS小部件手动配置指南

由于自动脚本无法正确添加Widget Extension目标，我们需要手动在Xcode中配置小部件。请按照以下步骤操作：

## 1. 打开Xcode项目

```bash
cd /Users/leoobai/jiwu-project/app/weather
open ios/Runner.xcworkspace
```

## 2. 添加Widget Extension目标

1. 在Xcode中，点击左上角的"File" > "New" > "Target..."
2. 在模板选择器中，选择"iOS" > "Widget Extension"
3. 点击"Next"
4. 在配置页面中：
   - Product Name: 输入 `FishingWidget`
   - Organization Identifier: 保持与主应用相同
   - Language: 选择 `Swift`
   - Include Configuration Intent: 取消勾选
   - Embed in Application: 选择 `Runner`
5. 点击"Finish"
6. 如果Xcode询问是否要激活新的scheme，点击"Activate"

## 3. 配置App Group

1. 选择新创建的FishingWidget目标
2. 点击"Signing & Capabilities"选项卡
3. 点击"+ Capability"按钮
4. 添加"App Groups"能力
5. 在App Groups下添加：`group.cn.leoobai.fishingweather`
6. 确保Runner目标也有相同的App Group配置

## 4. 替换生成的文件

Xcode会自动生成一些文件，我们需要用我们自己的实现替换它们：

1. 在Xcode的项目导航器中，找到FishingWidget目录
2. 删除自动生成的Swift文件
3. 右键点击FishingWidget目录，选择"Add Files to 'FishingWidget'..."
4. 导航到项目的`ios/FishingWidget`目录
5. 选择以下文件：
   - FishingWidget.swift
   - FishingWidgetBundle.swift
6. 点击"Add"

## 5. 配置Info.plist

1. 在FishingWidget目录中找到Info.plist
2. 确保它包含以下键值对：
   - CFBundleDisplayName: 钓鱼天气
   - NSExtensionPointIdentifier: com.apple.widgetkit-extension

## 6. 配置Entitlements文件

1. 在FishingWidget目录中找到或创建FishingWidget.entitlements文件
2. 确保它包含以下内容：

```xml
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
```

## 7. 修复Widget Service

确保`lib/services/widget_service.dart`中的iOS小部件名称与我们的实现匹配：

```dart
static const String iOSWidgetName = "FishingWidget";
```

## 8. 构建和运行

1. 在Xcode中，选择一个iOS模拟器
2. 点击"Product" > "Build"
3. 如果构建成功，点击"Run"

## 9. 测试小部件

1. 在模拟器中，长按主屏幕的空白区域
2. 点击左上角的"+"按钮
3. 搜索"钓鱼天气"
4. 添加小部件到主屏幕
5. 按照测试指南进行测试

## 常见问题解决

### 找不到小部件

如果在添加小部件时找不到"钓鱼天气"小部件，请检查：
1. 确保应用已经至少运行过一次
2. 确保App Group ID在所有地方都配置正确
3. 重启模拟器

### 小部件显示"No Content Available"

如果小部件显示"No Content Available"，请检查：
1. 确保应用已经成功写入了共享数据
2. 检查App Group ID是否正确
3. 在应用中手动触发一次小部件更新

### 构建错误

如果遇到构建错误，请检查：
1. 确保所有文件路径正确
2. 确保所有文件内容正确
3. 检查Xcode的签名配置