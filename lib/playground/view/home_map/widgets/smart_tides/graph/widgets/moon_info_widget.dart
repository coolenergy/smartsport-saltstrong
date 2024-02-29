import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';

import '../../../../../../modelsV2/get_tides_and_feeding_response.dart';
import 'daily_forecast_widget.dart';

class MoonInfoWidget extends StatelessWidget {
  final DailyForecast dailyForecast;

  const MoonInfoWidget({
    super.key,
    required this.dailyForecast,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CachedNetworkImage(
                  imageUrl: dailyForecast.moonIcon!,
                  width: 45.w,
                  height: 45.h,
                  errorWidget: (context, error, stackTrace) {
                    return SizedBox();
                  },
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  dailyForecast.moonNamePhase.split(' ').map((word) => word.capitalize()).join(' '),
                  style: forecastStyle,
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  'Moon Rise: ${dailyForecast.moonRise?.formattedTime ?? ''}',
                  style: forecastStyle,
                ),
                Text(
                  'Moon Set: ${dailyForecast.moonSet?.formattedTime ?? ''}',
                  style: forecastStyle,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
