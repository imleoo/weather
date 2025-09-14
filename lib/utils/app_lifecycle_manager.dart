import 'package:flutter/material.dart';
import '../services/widget_service.dart';

/// 简化的应用生命周期管理器
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
      case AppLifecycleState.detached:
        // 应用被终止时清理资源
        WidgetService.dispose();
        break;
      default:
        // 其他状态暂时不需要特殊处理
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}