import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // 全球热门城市，按区域分类，包含英文和中文名称
  final Map<String, List<Map<String, String>>> _globalCities = {
    'North America': [
      {'en': 'New York', 'zh': '纽约'},
      {'en': 'Los Angeles', 'zh': '洛杉矶'},
      {'en': 'Chicago', 'zh': '芝加哥'},
      {'en': 'Toronto', 'zh': '多伦多'},
      {'en': 'Mexico City', 'zh': '墨西哥城'},
      {'en': 'Vancouver', 'zh': '温哥华'},
    ],
    'Europe': [
      {'en': 'London', 'zh': '伦敦'},
      {'en': 'Paris', 'zh': '巴黎'},
      {'en': 'Berlin', 'zh': '柏林'},
      {'en': 'Rome', 'zh': '罗马'},
      {'en': 'Madrid', 'zh': '马德里'},
      {'en': 'Amsterdam', 'zh': '阿姆斯特丹'},
    ],
    'Asia': [
      {'en': 'Tokyo', 'zh': '东京'},
      {'en': 'Beijing', 'zh': '北京'},
      {'en': 'Shanghai', 'zh': '上海'},
      {'en': 'Seoul', 'zh': '首尔'},
      {'en': 'Singapore', 'zh': '新加坡'},
      {'en': 'Bangkok', 'zh': '曼谷'},
    ],
    'South America': [
      {'en': 'Rio de Janeiro', 'zh': '里约热内卢'},
      {'en': 'Buenos Aires', 'zh': '布宜诺斯艾利斯'},
      {'en': 'Lima', 'zh': '利马'},
      {'en': 'Santiago', 'zh': '圣地亚哥'},
      {'en': 'Bogota', 'zh': '波哥大'},
    ],
    'Oceania': [
      {'en': 'Sydney', 'zh': '悉尼'},
      {'en': 'Melbourne', 'zh': '墨尔本'},
      {'en': 'Auckland', 'zh': '奥克兰'},
      {'en': 'Brisbane', 'zh': '布里斯班'},
    ],
    'Africa': [
      {'en': 'Cairo', 'zh': '开罗'},
      {'en': 'Cape Town', 'zh': '开普敦'},
      {'en': 'Nairobi', 'zh': '内罗毕'},
      {'en': 'Lagos', 'zh': '拉各斯'},
    ],
  };

  // 区域名称的本地化映射
  Map<String, String> get _regionNames => {
        'North America': AppLocalizations.northAmerica,
        'Europe': AppLocalizations.europe,
        'Asia': AppLocalizations.asia,
        'South America': AppLocalizations.southAmerica,
        'Oceania': AppLocalizations.oceania,
        'Africa': AppLocalizations.africa,
      };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.isEnglish ? 'Select City' : '选择城市',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.isEnglish ? 'Enter city name' : '输入城市名称',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _globalCities.length,
              itemBuilder: (context, index) {
                final region = _globalCities.keys.elementAt(index);
                final cities = _globalCities[region]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        _regionNames[region] ?? region,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: cities.length,
                      itemBuilder: (context, cityIndex) {
                        return InkWell(
                          onTap: () {
                            // 根据当前语言返回对应的城市名称
                            final cityName = AppLocalizations.isEnglish
                                ? cities[cityIndex]['en']
                                : cities[cityIndex]['zh'];
                            Navigator.pop(context, cityName);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.3)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              // 根据当前语言显示对应的城市名称
                              AppLocalizations.isEnglish
                                  ? cities[cityIndex]['en']!
                                  : cities[cityIndex]['zh']!,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
