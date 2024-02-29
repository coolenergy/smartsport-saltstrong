import 'package:collection/collection.dart';
import 'package:salt_strong_poc/playground/models/map_position.dart';
import 'package:salt_strong_poc/playground/modelsV2/layer_wrapper.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';

class SaltMapState {
  final List<LayerWrapper> layers;

  final List<LayerWrapper> smartTides;

  final MapPos currentPos;

  final SearchLocation? lastSearchLocation;

  const SaltMapState({
    required this.layers,
    required this.smartTides,
    required this.currentPos,
    required this.lastSearchLocation,
  });

  List<LayerWrapper> get allLayers => layers + smartTides;

  List<LayerWrapper> get spotTypes => _whereGroup(LayerGroup.spotTypes);
  List<LayerWrapper> get elements => _whereGroup(LayerGroup.elements);
  List<LayerWrapper> get mapLayers => _whereGroup(LayerGroup.mapLayers);

  bool get isSmartSpotEnabled {
    final bool isEnabled = allLayers.firstWhereOrNull((element) => element.name == "Smart Spots")?.isEnabled ?? false;

    return isEnabled;
  }

  List<LayerWrapper> _whereGroup(LayerGroup layerGroup) =>
      layers.where((element) => element.layerGroup == layerGroup).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaltMapState &&
          runtimeType == other.runtimeType &&
          layers.toString() == other.layers.toString() &&
          smartTides.toString() == other.smartTides.toString() &&
          lastSearchLocation == other.lastSearchLocation &&
          currentPos == other.currentPos;

  @override
  int get hashCode => layers.hashCode ^ smartTides.hashCode ^ lastSearchLocation.hashCode ^ currentPos.hashCode;

  @override
  String toString() {
    return 'SaltMapState{layers: $layers, smartTides: $smartTides, currentPos: $currentPos $lastSearchLocation}';
  }

  SaltMapState copyWith({
    List<LayerWrapper>? layers,
    List<LayerWrapper>? smartTides,
    MapPos? currentPos,
    SearchLocation? lastSearchLocation,
  }) {
    return SaltMapState(
      layers: layers ?? this.layers,
      smartTides: smartTides ?? this.smartTides,
      currentPos: currentPos ?? this.currentPos,
      lastSearchLocation: lastSearchLocation ?? this.lastSearchLocation,
    );
  }
}
