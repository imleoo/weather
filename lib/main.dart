import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/weather_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'services/widget_service.dart';
import 'utils/app_lifecycle_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLocalizations.init();

  // 初始化小部件服务（添加错误处理）
  try {
    await WidgetService.init().timeout(const Duration(seconds: 10));
  } catch (e) {
    // 小部件服务初始化失败不影响应用运行
    debugPrint('Widget service initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
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
              child: HomeScreen(),
            ),
          );
        },
      ),
    );
  }
}
