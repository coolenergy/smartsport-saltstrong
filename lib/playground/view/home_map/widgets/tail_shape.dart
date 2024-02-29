import 'package:flutter/material.dart';

class TailShape extends ShapeBorder {
  final double tailWidth;
  final double tailHeight;

  TailShape({this.tailWidth = 20, this.tailHeight = 10});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: tailHeight);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect.deflate(tailHeight / 2), Radius.circular(8)))
      ..moveTo(rect.width / 2 - tailWidth / 2, rect.height - tailHeight / 2)
      ..relativeLineTo(tailWidth / 2, tailHeight)
      ..relativeLineTo(tailWidth / 2, -tailHeight)
      ..relativeQuadraticBezierTo(tailWidth / 2, tailHeight, tailWidth, 0);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => this.getOuterPath(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
