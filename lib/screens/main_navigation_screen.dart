import 'package:flutter/material.dart';
import 'weather_tab.dart';
import 'fishing_spots_tab.dart';
import 'share_tab.dart';
import 'my_tab.dart';
import '../l10n/app_localizations.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WeatherTab(),
    const FishingSpotsTab(),
    const ShareTab(),
    const MyTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.wb_sunny),
            label: AppLocalizations.weather,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.place),
            label: AppLocalizations.fishingSpots,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.share),
            label: AppLocalizations.share,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.my,
          ),
        ],
      ),
    );
  }
}