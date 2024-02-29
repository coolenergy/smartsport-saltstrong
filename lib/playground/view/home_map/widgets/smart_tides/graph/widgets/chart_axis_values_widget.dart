import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/search_popup.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/graph/widgets/line_chart_widget.dart';

// if orientation == portrait -> widget is aligned top.start, needs positionedLeft because of DailyForecastWidget;
// if orientation == landscape -> widget is aligned bottom.start, needs bottom padding of 35
Positioned chartAxisValuesWidget({required BuildContext context, required Maximums maximumsY, required double positionedLeft, required double positionedTop, double? graphWidth, double? graphHeight, bool hasBottomSpace = false}) {
  return Positioned(
    top: positionedTop,
    left: positionedLeft,
    child: TranslucentPointer(
      child: SizedBox(
        height: graphHeight ?? 145,
        child: AspectRatio(
          aspectRatio: (graphWidth == null || graphHeight == null) ? 1.8 : graphWidth / graphHeight,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(),
              ],
              maxY: maximumsY.max,
              //minY: maximumsY.min,
              minY: maximumsY.min > 0 ? 0 : -1,

              borderData: FlBorderData(
                border: Border.all(
                  style: BorderStyle.none,
                ),
              ),
              gridData: const FlGridData(
                show: false,
                drawHorizontalLine: false,
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: hasBottomSpace, reservedSize: 45, getTitlesWidget: (value, meta) => const SizedBox())),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        interval: hasBottomSpace ? 0.5 : 1,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                         return Text(
                            hasBottomSpace ? "${value.toStringAsFixed(1)} ft" : "${value.toInt()} ft",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87, fontSize: 12),
                            textAlign: TextAlign.center,
                          );
                        })),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
            // swapAnimationCurve: Curves.fastOutSlowIn,
            // swapAnimationDuration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    ),
  );
}