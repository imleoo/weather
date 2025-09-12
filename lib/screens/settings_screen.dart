import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/widget_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.settings),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            children: [
              // 语言设置
              ListTile(
                title: Text(AppLocalizations.language),
                trailing: DropdownButton<String>(
                  value: AppLocalizations.currentLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      settingsProvider.setLanguage(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: AppLocalizations.languageEn,
                      child: Text(AppLocalizations.english),
                    ),
                    DropdownMenuItem(
                      value: AppLocalizations.languageZh,
                      child: Text(AppLocalizations.chinese),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // 更新频率设置
              ListTile(
                title: Text(AppLocalizations.updateFrequency),
                trailing: DropdownButton<String>(
                  value: settingsProvider.updateFrequency,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      settingsProvider.setUpdateFrequency(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'hourly',
                      child: Text(AppLocalizations.hourly),
                    ),
                    DropdownMenuItem(
                      value: 'every3hours',
                      child: Text(AppLocalizations.every3Hours),
                    ),
                    DropdownMenuItem(
                      value: 'every6hours',
                      child: Text(AppLocalizations.every6Hours),
                    ),
                    DropdownMenuItem(
                      value: 'daily',
                      child: Text(AppLocalizations.daily),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // 天气提醒设置
              SwitchListTile(
                title: Text(AppLocalizations.weatherAlerts),
                value: settingsProvider.weatherAlerts,
                onChanged: (bool value) {
                  settingsProvider.setWeatherAlerts(value);
                },
              ),
              const Divider(),

              // 更新桌面小部件
              ListTile(
                title: Text(AppLocalizations.updateWidget),
                subtitle: Text(AppLocalizations.updateWidgetSubtitle),
                trailing: const Icon(Icons.refresh),
                onTap: () async {
                  // 显示加载指示器
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.updatingWidgetData)),
                  );

                  // 更新小部件数据
                  await WidgetService.updateWidgetData();

                  // 显示成功消息
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.widgetDataUpdated)),
                    );
                  }
                },
              ),
              const Divider(),

              // 关于应用
              ListTile(
                title: Text(AppLocalizations.aboutApp),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: AppLocalizations.appTitle,
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.cloud),
                    children: [
                      const SizedBox(height: 20),
                      Text('${AppLocalizations.privacyPolicy}:'),
                      const Text('https://www.leoobai.cn/privacy'),
                      const SizedBox(height: 10),
                      Text('${AppLocalizations.termsOfService}:'),
                      const Text('https://www.leoobai.cn/terms'),
                      const SizedBox(height: 10),
                      Text('${AppLocalizations.openSourceLicenses}:'),
                      const Text('https://www.leoobai.cn/licenses'),
                      const SizedBox(height: 20),
                      Text('${AppLocalizations.telegramCommunity}:'),
                      const Text('https://t.me/+ljjbNTiM4bExMDkx'),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
