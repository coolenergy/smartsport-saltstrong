import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';

import '../../../../salt_strong_snackbar.dart';
import '../line_chart_widget.dart';

class LineChartWidgetLandscape extends StatelessWidget {
  const LineChartWidgetLandscape({
    super.key,
    required this.points,
    required this.displayedDate,
    required this.maximumsY,
    required this.graphHeight,
    required this.graphWidth,
  });

  final List<GraphPoint> points;
  final DateTime displayedDate;
  final Maximums maximumsY;
  final double graphWidth;
  final double graphHeight;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: graphWidth / graphHeight,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              isCurved: true,
              color: SaltStrongColors.primaryBlue,
              barWidth: 1.w,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, lineData, index) => FlDotCirclePainter(
                  radius: 4.r,
                  color: SaltStrongColors.primaryBlue,
                  strokeWidth: 0.r,
                ),
              ),
            ),
          ],

          maxY: maximumsY.max,
          minY: maximumsY.min > 0 ? 0 : -1,

          /// uncomment bellow to synchronize tide and feed level x-axis
          minX: displayedDate.date.millisecondsSinceEpoch.toDouble(),
          maxX: displayedDate.date23_59.millisecondsSinceEpoch.toDouble(),
          borderData: FlBorderData(
              border: Border(
            top: BorderSide(
              color: SaltStrongColors.greyStroke.withOpacity(0.5),
            ),
          )),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: SaltStrongColors.greyStroke.withOpacity(0.5), strokeWidth: 1);
            },
            drawVerticalLine: false,
            verticalInterval: 1,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) => const SizedBox())),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            enabled: false,
            touchSpotThreshold: const Offset(30, 30).distance,
            distanceCalculator: (Offset touchPoint, Offset spotPixelCoordinates) {
              final dx = touchPoint.dx - spotPixelCoordinates.dx;
              final dy = touchPoint.dy - spotPixelCoordinates.dy;
              return Offset(dx, dy).distance;
            },
            touchCallback: (event, response) {
              if (event is FlTapDownEvent) {
                final TouchLineBarSpot? spot = response!.lineBarSpots?[0];

                if (spot == null) return;
                showChartValueSnackbar(spot, context, "Tide Info:");
              }
            },
          ),
        ),
        // swapAnimationCurve: Curves.fastOutSlowIn,
        // swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    var flSpots = points.map((e) => FlSpot(e.x, e.y)).toList();
    return flSpots;
  }
}

void showChartValueSnackbar(FlSpot spot, context, String desc, [String unit = "ft"]) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  final content = Container(
    margin: const EdgeInsets.only(left: 250, right: 250, bottom: 5000),
    child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: SaltStrongSnackbar(
          snackbarMessageVariable:
              '$desc\n${DateTime.fromMillisecondsSinceEpoch(spot!.x.toInt()).formattedTime}\n${spot?.y.toString()}$unit',
          snackbarMessageFixed: '',
          isForCalendar: false,
          textStyle: const TextStyle(
            color: SaltStrongColors.primaryBlue,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        )),
  );
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.fixed,
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: content,
  ));
}
