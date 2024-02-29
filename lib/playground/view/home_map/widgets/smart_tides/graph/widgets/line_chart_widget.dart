import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';

import '../../../salt_strong_snackbar.dart';

typedef GraphPoint = Point<double>;
typedef BarChartPoint = Point<int>;

class Maximums extends Equatable {
  final double min;
  final double max;

  const Maximums(this.min, this.max);

  List<int> get allIntsInInterval {
    List<int> allInts = [];
    for (int i = min.floor(); i <= max.ceil(); i++) {
      allInts.add(i);
    }
    return allInts.reversed.toList();
  }

  @override
  List<Object?> get props => [min, max];
}

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.points,
    required this.displayedDate,
    required this.maximumsY,
  });

  final List<GraphPoint> points;
  final DateTime displayedDate;
  final Maximums maximumsY;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
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
          //minY: maximumsY.min,
          minY: maximumsY.min > 0 ? 0 : -1,

          /// uncomment bellow to synchronize tide and feed level x-axis
          minX: displayedDate.date.millisecondsSinceEpoch.toDouble(),
          maxX: displayedDate.date23_59.millisecondsSinceEpoch.toDouble(),
          borderData: FlBorderData(
            border: Border.all(
              style: BorderStyle.none,
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: value == 0 ? SaltStrongColors.greyStroke : Colors.transparent,
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
            verticalInterval: 1,
          ),
          titlesData: const FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            enabled: false,
            touchSpotThreshold: const Offset(18, 18).distance,
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
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.fromLTRB(15.w, 5.h, 15.w, 20.h),
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: GestureDetector(
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
  ));
}
