import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';
import '../utils/animation_utils.dart';
import 'dart:math' as math;

class WeatherDetails extends StatefulWidget {
  final CurrentCondition currentCondition;

  const WeatherDetails({super.key, required this.currentCondition});

  @override
  State<WeatherDetails> createState() => _WeatherDetailsState();
}

class _WeatherDetailsState extends State<WeatherDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: AnimationUtils.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.weatherDetails,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // 使用Column代替GridView，避免溢出问题
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.water_drop,
                        AppLocalizations.humidity,
                        '${widget.currentCondition.humidity}%',
                        Colors.blue.shade600,
                        _buildHumidityIndicator(
                          double.parse(widget.currentCondition.humidity),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.air,
                        AppLocalizations.windSpeed,
                        '${widget.currentCondition.windspeedKmph} ${AppLocalizations.kmh}',
                        Colors.blueGrey.shade600,
                        _buildWindIndicator(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.visibility,
                        AppLocalizations.visibility,
                        '${widget.currentCondition.visibility} ${AppLocalizations.km}',
                        Colors.amber.shade700,
                        _buildVisibilityIndicator(
                          double.parse(widget.currentCondition.visibility),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.compress,
                        AppLocalizations.pressure,
                        '${widget.currentCondition.pressure} ${AppLocalizations.hPa}',
                        Colors.purple.shade600,
                        _buildPressureIndicator(
                          double.parse(widget.currentCondition.pressure),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.water,
                        AppLocalizations.precipitation,
                        '${widget.currentCondition.precipMM} ${AppLocalizations.mm}',
                        Colors.lightBlue.shade600,
                        _buildPrecipitationIndicator(
                          double.parse(widget.currentCondition.precipMM),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.wb_sunny,
                        AppLocalizations.uvIndex,
                        widget.currentCondition.uvIndex,
                        Colors.orange.shade600,
                        _buildUVIndicator(
                          int.parse(widget.currentCondition.uvIndex),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String title,
    String value,
    Color color,
    Widget indicator,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: AnimationUtils.weatherDetailDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          indicator,
        ],
      ),
    );
  }

  Widget _buildHumidityIndicator(double humidity) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: humidity / 100,
        backgroundColor: Colors.blue.shade100,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
        minHeight: 6,
      ),
    );
  }

  Widget _buildWindIndicator() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Icon(
            Icons.air,
            color: Colors.blueGrey.shade400,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildVisibilityIndicator(double visibility) {
    // 假设最大可见度为 20km
    double normalizedVisibility = math.min(visibility / 20, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: normalizedVisibility,
        backgroundColor: Colors.amber.shade100,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
        minHeight: 6,
      ),
    );
  }

  Widget _buildPressureIndicator(double pressure) {
    // 标准气压为 1013.25 hPa
    double normalizedPressure = (pressure - 970) / 100;
    normalizedPressure = math.max(0, math.min(normalizedPressure, 1));
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: normalizedPressure,
        backgroundColor: Colors.purple.shade100,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
        minHeight: 6,
      ),
    );
  }

  Widget _buildPrecipitationIndicator(double precipMM) {
    // 假设最大降水量为 25mm
    double normalizedPrecip = math.min(precipMM / 25, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: normalizedPrecip,
        backgroundColor: Colors.lightBlue.shade100,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue.shade600),
        minHeight: 6,
      ),
    );
  }

  Widget _buildUVIndicator(int uvIndex) {
    // UV指数范围通常为0-11
    Color uvColor;
    if (uvIndex <= 2) {
      uvColor = Colors.green;
    } else if (uvIndex <= 5) {
      uvColor = Colors.yellow;
    } else if (uvIndex <= 7) {
      uvColor = Colors.orange;
    } else if (uvIndex <= 10) {
      uvColor = Colors.red;
    } else {
      uvColor = Colors.purple;
    }

    return Row(
      children: List.generate(
        11,
        (index) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: index < uvIndex ? uvColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
