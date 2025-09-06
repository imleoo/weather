import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/weather_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';
import 'services/widget_service.dart';
import 'utils/app_lifecycle_manager.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalizations.init();

  // 初始化日志系统 - 禁用文件日志以避免Android权限问题
  await AppLogger.init(
    enableConsoleLog: true,
    enableFileLog: false, // 禁用文件日志，避免Android权限问题
    minLevel: LogLevel.debug,
  );
  
  AppLogger.info('应用启动', tag: 'APP');

  // 尝试自动登录
  await _tryAutoLogin();

  // 初始化小部件服务（添加错误处理）
  try {
    await WidgetService.init().timeout(const Duration(seconds: 10));
    AppLogger.info('小部件服务初始化成功', tag: 'WIDGET');
  } catch (e) {
    // 小部件服务初始化失败不影响应用运行
    AppLogger.error('小部件服务初始化失败', error: e, tag: 'WIDGET');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          // 创建WeatherProvider实例
          final weatherProvider = WeatherProvider();
          // 设置全局实例，供小部件服务使用
          WidgetService.setGlobalWeatherProvider(weatherProvider);
          return weatherProvider;
        }),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: AppLocalizations.appTitle,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // 英文
              Locale('zh', ''), // 中文
            ],
            locale: Locale(AppLocalizations.currentLanguage, ''),
            debugShowCheckedModeBanner: false,
            home: const AppLifecycleManager(
              child: MainNavigationScreen(),
            ),
          );
        },
      ),
    );
  }
}

// 尝试自动登录
Future<void> _tryAutoLogin() async {
  try {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        AppLogger.info('自动登录成功', details: {'email': user.email}, tag: 'AUTH');
      }
    }
  } catch (e) {
    AppLogger.error('自动登录失败', error: e, tag: 'AUTH');
  }
}
