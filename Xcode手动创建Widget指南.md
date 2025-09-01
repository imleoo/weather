# Xcode手动创建Widget指南

由于通过脚本添加Widget Extension遇到了一些问题，我们可以直接在Xcode中手动创建Widget Extension。以下是详细步骤：

## 1. 打开Xcode项目

```bash
cd /Users/leoobai/jiwu-project/app/weather
open ios/Runner.xcworkspace
```

## 2. 删除现有的FishingWidget目标（如果存在）

1. 在左侧项目导航器中，选择顶部的项目图标
2. 在中间区域，找到"FishingWidget"目标（如果存在）
3. 右键点击"FishingWidget"目标，选择"Delete"
4. 在弹出的对话框中，选择"Remove References"

## 3. 创建新的Widget Extension目标

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

## 4. 配置App Group

1. 选择新创建的FishingWidget目标
2. 点击"Signing & Capabilities"选项卡
3. 点击"+ Capability"按钮
4. 添加"App Groups"能力
5. 在App Groups下添加：`group.cn.leoobai.fishingweather`
6. 对Runner目标重复相同的步骤

## 5. 替换生成的文件

Xcode会自动生成一些Widget实现文件。我们需要用我们自己的实现替换它们：

1. 在Finder中，导航到`/Users/leoobai/jiwu-project/app/weather/ios/FishingWidget`
2. 复制以下文件：
   - FishingWidget.swift
   - FishingWidgetBundle.swift
3. 在Xcode的项目导航器中，找到FishingWidget目录下的相应文件
4. 右键点击每个文件，选择"Delete"，然后选择"Move to Trash"
5. 右键点击FishingWidget目录，选择"Add Files to 'FishingWidget'..."
6. 导航到`/Users/leoobai/jiwu-project/app/weather/ios/FishingWidget`
7. 选择我们的实现文件，点击"Add"

## 6. 更新Info.plist

1. 在FishingWidget目录中找到Info.plist
2. 双击打开它
3. 确保它包含以下键值对：
   - CFBundleDisplayName: 钓鱼天气
   - NSExtensionPointIdentifier: com.apple.widgetkit-extension

## 7. 构建和运行

1. 选择"Runner"方案（Scheme）
2. 选择一个iOS模拟器（如iPhone 16 Pro）
3. 点击"Product" > "Build"
4. 如果构建成功，点击"Run"

## 8. 测试Widget

1. 在模拟器中，长按主屏幕的空白区域
2. 点击左上角的"+"按钮
3. 搜索"钓鱼天气"
4. 添加小部件到主屏幕
5. 按照测试指南进行测试