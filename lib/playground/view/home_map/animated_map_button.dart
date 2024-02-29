import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Positioned floating action button used for main map options: zoom in, zoom out and oepn/close bottom sheet
class MapButton extends StatelessWidget {
  const MapButton({
    super.key,
    required this.onPressed,
    this.left,
    this.right,
    this.bottom,
    this.top,
    this.isLeftBorderRounded = false,
    this.isRightBorderRounded = false,
    this.child,
  });

  final double? left;
  final double? right;
  final double? bottom;
  final double? top;
  final bool? isLeftBorderRounded;
  final bool? isRightBorderRounded;
  final Widget? child;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(left ?? 0, top ?? 0, right ?? 0, bottom ?? 0),
        child: RawMaterialButton(
          onPressed: onPressed,

          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          constraints: BoxConstraints.tightFor(
            width: 42.w,
            height: 42.h,
          ),
          fillColor: Colors.black.withOpacity(0.5),
          // mini: true,
          // backgroundColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isLeftBorderRounded! ? Radius.circular(10.r) : Radius.zero,
              bottomLeft: isLeftBorderRounded! ? Radius.circular(10.r) : Radius.zero,
              topRight: isRightBorderRounded! ? Radius.circular(10.r) : Radius.zero,
              bottomRight: isRightBorderRounded! ? Radius.circular(10.r) : Radius.zero,
            ),
          ),
          child: child,
        ),
      );
}
