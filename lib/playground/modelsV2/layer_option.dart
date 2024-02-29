import 'package:flutter/cupertino.dart';

class LayerOption {
  final String title;

  final Widget layer;

  const LayerOption({
    required this.title,
    required this.layer,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LayerOption && runtimeType == other.runtimeType && title == other.title;

  @override
  int get hashCode => title.hashCode;
}
