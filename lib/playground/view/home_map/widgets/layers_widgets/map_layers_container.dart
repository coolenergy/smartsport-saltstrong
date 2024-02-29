import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/gen/assets.gen.dart';

import '../../../../constants/colors.dart';

class MapLayersListTile extends StatelessWidget {
  final String title;
  final Widget image;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onOptionsTap;
  const MapLayersListTile({
    Key? key,
    required this.title,
    required this.onOptionsTap,
    required this.image,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentColor = isSelected ? SaltStrongColors.primaryBlue : Colors.black;
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          onSelected(false);
        } else {
          onSelected(true);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  width: isSelected ? 2.w : 1.w,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  image,
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                    child: Text(
                      title,
                      style: TextStyle(color: contentColor),
                    ),
                  ),
                  Visibility(
                    visible: isSelected,
                    child: Container(
                      width: 1.w,
                      height: double.infinity,
                      color: Colors.grey,
                    ),
                  ),
                  InkWell(
                    onTap: onOptionsTap,
                    child: Visibility(
                      visible: isSelected,
                      child: Padding(
                        padding: EdgeInsets.all(10.0.r),
                        child: Assets.icons.layerTransparency.svg(
                          colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
