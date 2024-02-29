import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/filters/filters.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/line_chart_widget.dart';

import '../../../../controller/customized_providers.dart';

class BarChartWidget extends ConsumerWidget {
  const BarChartWidget({
    super.key,
    required this.barsData,
  });

  final List<BarChartPoint> barsData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilters = ref.watch(selectedFilterProvider);

    return AspectRatio(
      aspectRatio: 1.8,
      child: BarChart(
        BarChartData(
          // alignment: BarChartAlignment.start,
          // groupsSpace: 0,
          minY: 0,
          maxY: 10,
          barGroups: _chartGroups(barsData, selectedFilters),
          borderData: FlBorderData(
              border: const Border(
            bottom: BorderSide(color: SaltStrongColors.greyStroke),
          )),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: false,
            drawVerticalLine: true,
            getDrawingVerticalLine: (value) =>
                const FlLine(color: SaltStrongColors.greyStroke, strokeWidth: 1),

            /// no of verticalIntervals = no of bars todo will need adjust
            verticalInterval: 1 / barsData.length,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: _bottomTitles),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
              enabled: false,
              touchCallback: (event, response) {
                if (event is FlTapDownEvent) {
                  final FlSpot? spot = response!.spot?.spot;
                  if (spot == null) return;
                  // showChartValueSnackbar(spot, context, "Feed Level", "");
                }
              }),
        ),
        swapAnimationCurve: Curves.fastOutSlowIn,
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// designing bars for lists of values
  List<BarChartGroupData> _chartGroups(
    List<BarChartPoint> barsData,
    List<SmartTidesFilter> selectedFilters,
  ) {
    List<BarChartGroupData> barchartGroupData = [];
    for (var i = 0; i < barsData.length; i++) {
      final gradientColor =
          barsData[i].y >= 6 ? SaltStrongColors.barChartGreen : SaltStrongColors.primaryBlue;
      final barsGradient = selectedFilters.contains(SmartTidesFilter.feedingTimes)
          ? SaltStrongColors.barChartGradient(gradientColor)
          : null;
      barchartGroupData.add(BarChartGroupData(x: barsData[i].x.toInt(), barRods: [
        BarChartRodData(
          toY: selectedFilters.contains(SmartTidesFilter.feedingTimes)
              ? barsData[i].y.toDouble()
              : 0.0,
          gradient: barsGradient,
          borderRadius:
              selectedFilters.contains(SmartTidesFilter.feedingTimes) ? BorderRadius.zero : null,
          width: 46.w,
        )
      ]));
    }
    return barchartGroupData;
  }
}

SideTitles get _bottomTitles => SideTitles(
      showTitles: true,
      reservedSize: 45,
      getTitlesWidget: (value, meta) {
        var title = getTitle(value);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: title.contains('12') ? FontWeight.w800 : FontWeight.w500),
          ),
        );
      },
    );

String getTitle(double value) {
  final result = value.toInt();
  final hour = DateFormat('h').format(DateTime.fromMillisecondsSinceEpoch(result));
  final amPmMarker = DateFormat('a').format(DateTime.fromMillisecondsSinceEpoch(result));
  return hour == '12' ? '$hour${amPmMarker.toLowerCase()}' : hour;
}
