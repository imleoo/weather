import 'package:flutter/material.dart';
import 'weather_tab.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WeatherTab(),
    );
  }
}
