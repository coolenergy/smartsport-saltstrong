import 'package:flutter/material.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

class GradientRectSliderTrackShape extends SliderTrackShape {
  final LinearGradient gradient;
  final double darkeningFactor;

  GradientRectSliderTrackShape({required this.gradient, this.darkeningFactor = 0.7});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight! + 4;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    Offset? secondaryOffset,
  }) {
    if (sliderTheme.trackHeight == null) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Draw the track
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(6.0)),
      Paint()..color = SaltStrongColors.sliderInactive,
    );

    final activeTrackRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeTrackRect, const Radius.circular(6.0)),
      Paint()..shader = gradient.createShader(trackRect),
    );
  }
}

class ColoredThumbSliderShape extends SliderComponentShape {
  final double thumbRadius;
  final Color innerColor;
  final Color thumbColor;

  const ColoredThumbSliderShape({required this.thumbRadius, required this.innerColor, required this.thumbColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    double value = 0.0,
    double textScaleFactor = 1.0,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final double radius = thumbRadius * enableAnimation.value;

    final innerCircle = Paint()..color = innerColor;
    final thumbCircle = Paint()..color = thumbColor;

    canvas.drawCircle(center, radius, thumbCircle);
    canvas.drawCircle(center, radius * 0.65, innerCircle);
  }
}
