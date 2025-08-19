import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
                      const Text('https://example.com/privacy'),
                      const SizedBox(height: 10),
                      Text('${AppLocalizations.termsOfService}:'),
                      const Text('https://example.com/terms'),
                      const SizedBox(height: 10),
                      Text('${AppLocalizations.openSourceLicenses}:'),
                      const Text('https://example.com/licenses'),
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
