import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/filters/filters.dart';

import '../../../../../../../gen/assets.gen.dart';
import '../../../../../../constants/colors.dart';
import '../../../../controller/customized_providers.dart';
import '../../../../controller/smart_tides_controller.dart';

class WeatherCardItem extends ConsumerWidget {
  static double get width => 91.w;
  static double get height => 70.h;

  const WeatherCardItem({
    super.key,
    required this.icon,
    required this.temperature,
    required this.windMinMPH,
    required this.windMaxMPH,
    required this.windDirection,
    this.timestamp,
  });

  final Widget icon;
  final int temperature;
  final int windMinMPH;
  final int windMaxMPH;
  final String windDirection;
  final int? timestamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final date = DateFormat.Md().format(DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000).toLocal());
    // final timeH = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000).toLocal());
    final selectedFilters = ref.watch(selectedFilterProvider);
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: SaltStrongColors.weatherCardGradient,
        border: Border(
          // left: BorderSide(color: SaltStrongColors.greyStroke),
          // right: BorderSide(color: SaltStrongColors.greyStroke),
          bottom: BorderSide(color: SaltStrongColors.greyStroke),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Visibility(
            visible: selectedFilters.contains(SmartTidesFilter.weather),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  SizedBox(
                    width: 4.w,
                  ),
                  Text(
                    '${temperature.toString()}°',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
          Visibility(
            visible: selectedFilters.contains(SmartTidesFilter.wind),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(windMaxMPH + windMinMPH) ~/ 2} mph',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: HelperFun.getWindIconAngle(windDirection),
                        child: Assets.icons.windDirectionSE.svg(
                          width: 11.w,
                          height: 12.h,
                        ),
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Text(
                        ' $windDirection',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Text(date),  // for testing purposes
          // Text(timeH),  // for testing purposes
        ],
      ),
    );
  }
}
