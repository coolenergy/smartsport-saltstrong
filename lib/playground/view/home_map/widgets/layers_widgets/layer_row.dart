import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LayerRow extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const LayerRow({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.only(left: 24.w),
          child: Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 55,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(
                  width: 24.w,
                ),
                ...children
              ],
            ),
          ),
        ),
      ],
    );
  }
}
