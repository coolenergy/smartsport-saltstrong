import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:salt_strong_poc/playground/modelsV2/daily_strike_score_response.dart';

import '../../../../../../constants/colors.dart';

class TodayCalendarItem extends StatelessWidget {
  const TodayCalendarItem({
    super.key,
    required this.date,
    required this.strikeScore,
    this.onTap,
  });

  final DateTime date;
  final double strikeScore;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMM').format(date);
    final day = DateFormat('d').format(date);
    final weekday = DateFormat('E').format(date).toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      constraints: BoxConstraints(
        minHeight: 74.h,
        minWidth: 96.w,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: SaltStrongColors.greyStroke,
          width: 1.w,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            weekday,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
          Text(
            '$month, $day',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
          ),
          Expanded(
            child: FittedBox(
              child: Text(
                strikeScore.toString(),
                style: TextStyle(fontWeight: FontWeight.w900, color: strikeScore.color),
              ),
            ),
          ),
          Text(
            'Strike Score',
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
