# iOS小部件开发指南

## 当前状态

目前，钓鱼天气应用在iOS平台上**不支持**主屏幕小部件功能。虽然代码中包含了小部件服务的实现（`lib/services/widget_service.dart`）和一些iOS小部件相关的文件（`ios/Runner/WidgetExtension/FishingWidgetBundle.swift`），但完整的iOS小部件配置尚未实现。

## 实现iOS小部件的步骤

要在iOS平台上添加小部件功能，需要完成以下步骤：

1. **创建Widget Extension**：
   - 在Xcode中打开项目
   - 选择File > New > Target
   - 选择Widget Extension模板
   - 配置小部件名称和其他设置

2. **配置App Groups**：
   - 在Xcode中启用App Groups功能
   - 创建一个App Group ID（与`widget_service.dart`中的`appGroupId`一致）
   - 为主应用和小部件扩展启用相同的App Group

3. **实现小部件UI**：
   - 使用SwiftUI开发小部件界面
   - 实现小部件的不同尺寸（小、中、大）
   - 设计符合iOS设计规范的小部件样式

4. **数据共享**：
   - 使用UserDefaults配合App Groups实现应用与小部件之间的数据共享
   - 确保小部件可以访问应用保存的天气数据和钓鱼适宜度评估结果

5. **小部件更新机制**：
   - 实现Timeline Provider以定期更新小部件
   - 配置适当的刷新间隔，平衡实时性和电池消耗

## 技术要求

- Xcode 12.0或更高版本
- iOS 14.0或更高版本（WidgetKit要求）
- Swift编程语言知识
- SwiftUI框架知识

## 资源链接

- [Apple WidgetKit文档](https://developer.apple.com/documentation/widgetkit)
- [SwiftUI教程](https://developer.apple.com/tutorials/swiftui)
- [App Groups配置指南](https://developer.apple.com/documentation/xcode/configuring-app-groups)

## 注意事项

- iOS小部件与Android小部件有很大不同，需要单独开发
- iOS小部件是只读的，用户与小部件的交互有限
- 小部件更新频率受系统限制，不能保证实时更新
- 小部件的内存和CPU使用受到严格限制

完成上述步骤后，钓鱼天气应用将能够在iOS平台上提供主屏幕小部件功能，为用户提供更便捷的天气和钓鱼适宜度信息查看体验。