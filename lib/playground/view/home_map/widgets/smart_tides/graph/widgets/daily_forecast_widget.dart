import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';

import '../../../../../../modelsV2/get_tides_and_feeding_response.dart';

class DailyForecastWidget extends StatelessWidget {
  final DailyForecast dailyForecast;

  const DailyForecastWidget({
    super.key,
    required this.dailyForecast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CachedNetworkImage(
                imageUrl: dailyForecast.dayIcon,
                width: 50.w,
                errorWidget: (context, error, stackTrace) {
                  return SizedBox();
                },
                height: 50.h,
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                dailyForecast.shortWeather,
                style: forecastStyle,
              ),
              SizedBox(
                height: 8.h,
              ),
              Text(
                'Rise: ${dailyForecast.sunRise.formattedTime}',
                style: forecastStyle,
              ),
              Text(
                'Set: ${dailyForecast.sunSet.formattedTime}',
                style: forecastStyle,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Text(
            dailyForecast.weatherSummary,
            style: forecastStyle.copyWith(fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ),
        // Divider(
        //   color: SaltStrongColors.greyStroke,
        //   height: 8.h,
        //   thickness: 2.r,
        // ),
        // SizedBox(
        //   height: 2.h,
        // ),
        //
        // FittedBox(
        //   fit: BoxFit.scaleDown,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Text(
        //         '${dailyForecast.windSpeedMinMph}-${dailyForecast.windSpeedMaxMph} mph ',
        //         style: windStyle,
        //       ),
        //       Text(
        //         '${dailyForecast.windGustMph} gusts ',
        //         style: windStyle,
        //       ),
        //       Text(
        //         'temp ${dailyForecast.tempMinF}°F - ${dailyForecast.tempMaxF}°F',
        //         style: windStyle,
        //       ),
        //     ],
        //   ),
        // ),
        // Divider(
        //   color: SaltStrongColors.greyStroke,
        //   height: 8.h,
        //   thickness: 2.r,
        // ),
      ],
    );
  }
}

const forecastStyle = TextStyle(
  fontWeight: FontWeight.w600,
);

final windStyle = forecastStyle.copyWith(fontSize: 12);

extension CapString on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
