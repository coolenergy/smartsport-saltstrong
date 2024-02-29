import 'package:flutter/material.dart';
import 'package:salt_strong_poc/playground/modelsV2/layer_option.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/saved_layers.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/layer_controller.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/search_popup.dart';

enum LayerType {
  tile,

  marker,

  poly;
}

enum LayerGroup {
  spotTypes,
  elements,
  mapLayers,
}

/// Layer wrapper wraps a [LayerType] widget
/// [LayerWrapper.visibleLayer] can essentially be any widget but we should use
/// acutal layers that are rendered based on [realtimeSyncMapPosProvider] change

class LayerWrapper {
  /// Displayed name of the layer
  final String name;

  /// Opacity of the layer, for some layers we use toggles
  /// to show/hide them, but for some layers we use opacity, 0.0 opacity generally
  /// means the layer is hidden
  final double opacity;

  final LayerType layerType;

  final LayerGroup layerGroup;

  /// If options is empty this should not be
  final Widget? layer;

  final Widget icon;

  final List<LayerOption> options;

  final int selectedOptionIndex;

  // for example the satelite layer is not togglable
  final bool isToggleable;

  // this means that "Normal" layer would always be visible with others overlaying it
  final bool alwaysShowBaseLayer;

  bool get isTranslucent {
    return LayerType.tile != layerType;
  }

  const LayerWrapper({
    required this.name,
    this.isToggleable = true,
    this.alwaysShowBaseLayer = false,
    required this.layerGroup,
    required this.icon,
    this.layerType = LayerType.tile,
    this.opacity = 0,
    this.layer,
    this.options = const [],
    this.selectedOptionIndex = 0,
  });

  String get id => name;

  Widget get visibleLayer {
    if (options.isNotEmpty) {
      return options.elementAtOrNull(selectedOptionIndex)?.layer ?? layer ?? const SizedBox.shrink();
    }
    return layer!;
  }

  bool get isEnabled => opacity != 0;

  ValueKey get key => ValueKey(toString());

  // TODO: refactor with equatable
  @override
  bool operator ==(Object other) => other.toString() == toString();

  @override
  String toString() {
    return 'LayerWrapper{'
        'icon $icon'
        'name: $name, opacity: $opacity, layerType: $layerType, layer: $layer, $selectedOptionIndex, options: $options, layerGroup: $layerGroup,   }';
  }

  LayerWrapper copyWith({
    String? name,
    Widget? layer,
    double? opacity,
    LayerType? layerType,
    LayerGroup? layerGroup,
    Widget? icon,
    int? selectedOptionIndex,
    List<LayerOption>? options,
    bool? alwaysShowBaseLayer,
    bool? isToggleable,
  }) {
    return LayerWrapper(
      isToggleable: isToggleable ?? this.isToggleable,
      alwaysShowBaseLayer: alwaysShowBaseLayer ?? this.alwaysShowBaseLayer,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      options: options ?? this.options,
      icon: icon ?? this.icon,
      layer: layer ?? this.layer,
      name: name ?? this.name,
      opacity: opacity ?? this.opacity,
      layerType: layerType ?? this.layerType,
      layerGroup: layerGroup ?? this.layerGroup,
    );
  }

  LayerWrapper configureWith({required SavedLayer savedLayer,}) {
    return LayerWrapper(
      selectedOptionIndex: savedLayer.selectedOptionIndex ?? 0,
      opacity: savedLayer.opacity,
      name: savedLayer.name,
      isToggleable: isToggleable,
      alwaysShowBaseLayer: alwaysShowBaseLayer,
      options: options,
      icon: icon,
      layer: layer,
      layerType: layerType,
      layerGroup: layerGroup,

    );
  }

}

class LayerWrapperWidget extends StatelessWidget {
  final LayerWrapper layerWrapper;

  const LayerWrapperWidget({super.key, required this.layerWrapper});

  @override
  Widget build(BuildContext context) {
    if (layerWrapper.opacity <= 0.05) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: layerWrapper.opacity,
      key: ValueKey(layerWrapper.name + layerWrapper.selectedOptionIndex.toString()),
      child: layerWrapper.alwaysShowBaseLayer
          ? Stack(
              children: [
                if (layerWrapper.selectedOptionIndex != 0) layerWrapper.options.first.layer,
                layerWrapper.visibleLayer,
              ],
            )
          : layerWrapper.visibleLayer,
    );
  }
}
