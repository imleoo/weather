import 'package:flutter/material.dart';
import '../services/widget_service.dart';

/// 应用生命周期管理器
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用进入前台
        WidgetService.onAppForeground();
        break;
      case AppLifecycleState.paused:
        // 应用进入后台
        WidgetService.onAppBackground();
        break;
      case AppLifecycleState.detached:
        // 应用被终止
        WidgetService.stopAllTimers();
        break;
      case AppLifecycleState.inactive:
        // 应用处于非活动状态
        WidgetService.onAppBackground();
        break;
      case AppLifecycleState.hidden:
        // 应用处于隐藏状态
        WidgetService.onAppBackground();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}