import 'package:flutter/material.dart';

// data for particular hour
class WeatherHourData {
  final int? timestamp;
  final Widget icon;
  final int temperature;
  final int windMinMPH;
  final int windMaxMPH;
  final String windDirection;

  WeatherHourData({
    this.timestamp,
    required this.icon,
    required this.temperature,
    required this.windMinMPH,
    required this.windMaxMPH,
    required this.windDirection,
  });
}
