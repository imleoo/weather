import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/weather_model.dart';
import '../utils/weather_icons.dart';
import '../l10n/app_localizations.dart';

class CurrentWeather extends StatefulWidget {
  final CurrentCondition currentCondition;

  const CurrentWeather({super.key, required this.currentCondition});

  @override
  State<CurrentWeather> createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 优化：减少动画持续时间，降低性能开销
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // 从10秒减少到6秒
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // 减少缩放幅度
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: -0.02, // 减少旋转幅度
      end: 0.02,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 延迟启动动画，让主界面先渲染完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAnimation();
      }
    });
  }

  void _startAnimation() {
    if (_isVisible) {
      _animationController.repeat(reverse: true);
    }
  }

  void _stopAnimation() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build()
    
    final weatherColor = WeatherIcons.getWeatherColor(
      widget.currentCondition.weatherCode,
    );

    return VisibilityDetector(
      key: Key('current_weather_${widget.currentCondition.weatherCode}'),
      onVisibilityChanged: (visibilityInfo) {
        if (!mounted) return;
        
        final wasVisible = _isVisible;
        _isVisible = visibilityInfo.visibleFraction > 0.5;

        if (wasVisible != _isVisible) {
          if (_isVisible) {
            _startAnimation();
          } else {
            _stopAnimation();
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              weatherColor.withOpacity(0.7),
              weatherColor.withOpacity(0.4),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: weatherColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentCondition.tempC,
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${AppLocalizations.feelsLike}: ${widget.currentCondition.feelsLikeC}°C',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              WeatherIcons.getWeatherIcon(
                                widget.currentCondition.weatherCode,
                              ),
                              size: 80,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: _buildWeatherDescriptionWithTooltip(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherInfoItem(
                      Icons.water_drop,
                      '${widget.currentCondition.humidity}%',
                      AppLocalizations.humidity,
                      Colors.blue.shade300,
                    ),
                    _buildDivider(),
                    _buildWeatherInfoItem(
                      Icons.air,
                      widget.currentCondition.windspeedKmph,
                      AppLocalizations.kmh,
                      Colors.blueGrey.shade300,
                    ),
                    _buildDivider(),
                    _buildWeatherInfoItem(
                      Icons.visibility,
                      widget.currentCondition.visibility,
                      AppLocalizations.km,
                      Colors.amber.shade300,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfoItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // 构建带工具提示的天气描述，处理长文本显示
  Widget _buildWeatherDescriptionWithTooltip() {
    final weatherDesc = widget.currentCondition.weatherDesc;
    
    // 如果文本很短，直接显示
    if (weatherDesc.length <= 15) {
      return Text(
        weatherDesc,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    // 如果文本很长，显示截断版本并提供工具提示
    return Tooltip(
      message: weatherDesc,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      preferBelow: true,
      verticalOffset: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        weatherDesc,
        style: const TextStyle(
          fontSize: 20, // 长文本时稍微减小字体
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }
}
