import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/lat_lng_ext.dart';
import 'package:salt_strong_poc/playground/models/map_position.dart';
import 'package:salt_strong_poc/playground/modelsV2/layer_option.dart';
import 'package:salt_strong_poc/playground/modelsV2/marker_popup_data.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/saved_layers.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/smart_spot_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';
import 'package:salt_strong_poc/playground/services/markers/markers_service.dart';
import 'package:salt_strong_poc/playground/services/polygons/polygon_service.dart';
import 'package:salt_strong_poc/playground/services/storage/storage_service.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/customized_providers.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_spot_marker_popup.dart';

import '../../../modelsV2/layer_wrapper.dart';
import '_layers.dart';
import 'layer_state.dart';
import "package:polybool/polybool.dart" as polybool;

export 'customized_providers.dart';

final saltStrongLayerControllerProvider = NotifierProvider.autoDispose<SaltMapLayerController, SaltMapState>(() {
  return SaltMapLayerController();
});

typedef LoadingState = Map<Object, AsyncValue>;
final loadingMapProvider = NotifierProvider.autoDispose<LoadingProvider, LoadingState>(() {
  return LoadingProvider();
});

class LoadingProvider extends AutoDisposeNotifier<Map<Object, AsyncValue>> {
  @override
  Map<Object, AsyncValue> build() {
    ref.keepAlive();

    return <Object, AsyncValue>{};
  }

  void update(Object key, AsyncValue value) {
    state = Map.from(state)..addAll({key: value});
  }

  void remove(Object key) {
    state = Map.from(state)..remove(key);
  }
}

final isLoadingProvider = Provider.autoDispose<bool>((ref) {
  ref.keepAlive();
  Timer? timer;
  ref.listen(loadingMapProvider, (previous, next) {
    // print(next.keys);
    timer?.cancel();
    // this is used to prevent flickering
    timer = Timer(
      const Duration(milliseconds: 20),
      () => ref.state = ref.read(loadingMapProvider).values.any((element) => element.isLoading),
    );
  });

  return ref.read(loadingMapProvider).values.any((element) => element.isLoading);
});

//const kInitialPos = MapPos(x: 26.0, y: -80.0, z: 5);
const kInitialPos = MapPos(x: 27.763, y: -82.544, z: 10);

class SaltMapLayerController extends AutoDisposeNotifier<SaltMapState> {
  final MapController mapController = MapController();
  @override
  SaltMapState build() {
    _keepAliveHandler();

    return const SaltMapState(
      layers: [],
      smartTides: [],
      currentPos: kInitialPos,
      lastSearchLocation: null,
    );
  }

  void moveToInitialPosition() {
    Future(() {
      mapController.move(
        LatLng(kInitialPos.x, kInitialPos.y),
        kInitialPos.z,
      );
    });
  }

  void updateSearchLocation(SearchLocation location) {
    state = state.copyWith(lastSearchLocation: location);
  }

  void centerOnSearchLocation(SearchLocation location) {
    mapController.move(
      location.latLng,
      mapController.zoom,
    );
  }

  void zoomIn() {
    final zoomLevel = mapController.zoom + 1; // Adjust the increment as needed
    mapController.move(mapController.center, zoomLevel);
  }

  void zoomOut() {
    final zoomLevel = mapController.zoom - 1; // Adjust the decrement as needed
    mapController.move(mapController.center, zoomLevel);
  }

  void _keepAliveHandler() {
    // keep alive for 20 seconds
    // for example if we pushed to a new page we would dispose this only after 20s

    Timer? timer;

    final KeepAliveLink link = ref.keepAlive();

    ref.onCancel(() {
      timer = Timer(
        const Duration(seconds: 20),
        () => link.close(),
      );
    });

    ref.onDispose(() {
      timer?.cancel();
    });

    ref.onResume(() {
      timer?.cancel();
    });
  }

  void initLayers() {
    state = state.copyWith(
      layers: saltStrongLayers,
    );
  }

  Future<void> showSavedLayersOnMap() async {
    final newLayersFromStorage = await loadSavedLayers();

    final newLayers = saltStrongLayers
        .map((layer) =>
            layer.configureWith(savedLayer: newLayersFromStorage.firstWhere((element) => element.name == layer.name)))
        .toList();
    state = state.copyWith(layers: newLayers);
  }

  Future<void> saveLayersToStorage() async {
    const key = StorageKeys.savedLayers;
    // Get current layers
    final layers = state.layers
        .toList()
        .map(
          (e) => SavedLayer(
            name: e.name,
            opacity: e.opacity,
            selectedOptionIndex: e.selectedOptionIndex,
          ),
        )
        .toList();
    // Save em all together
    ref.read(storageServiceProvider).setValue(
          key: key,
          data: jsonEncode(layers),
        );
  }

  Future<List<SavedLayer>> loadSavedLayers() async {
    const key = StorageKeys.savedLayers;
    // Get saved layers
    final savedLayers = (jsonDecode(
      ref.read(storageServiceProvider).getValue(key) ?? '[]',
    ) as List<dynamic>)
        .map((item) => SavedLayer.fromJson(item))
        .toList();

    return savedLayers;
  }

  void swapLayers(int oldIndex, int newIndex) {
    final layers = state.layers.toList();
    final oldLayer = layers[oldIndex];
    final newLayer = layers[newIndex];

    layers[oldIndex] = newLayer;
    layers[newIndex] = oldLayer;

    state = state.copyWith(
      layers: layers,
    );
  }

  void updateLayerOpacity(LayerWrapper layerWrapper, double value) {
    final List<LayerWrapper> layers = state.layers.toList();
    final index = layers.indexWhere((element) => element.id == layerWrapper.id);

    layers[index] = layers[index].copyWith(opacity: value);

    state = state.copyWith(layers: layers);
  }

  void updatePosition(MapPos mapPos) {
    state = state.copyWith(currentPos: mapPos);
  }

  void toggleLayer({required LayerWrapper layer, required bool isEnabled}) {
    if (!layer.isToggleable && !isEnabled) return;
    final layers = state.layers.toList();
    final index = layers.indexWhere((element) => element.id == layer.id);

    layers[index] = layers[index].copyWith(opacity: isEnabled ? 1 : 0);

    state = state.copyWith(layers: layers);
  }

  void updateLayerOption({required LayerWrapper layer, required LayerOption option}) {
    final layers = state.layers.toList();
    final index = layers.indexWhere((element) => element.id == layer.id);
    final optionIndex = layer.options.indexWhere((element) => element.title == option.title);
    layers[index] = layers[index].copyWith(selectedOptionIndex: optionIndex);

    state = state.copyWith(layers: layers);
  }

  void handleMapTap(LatLng latlng, BuildContext context) async {
    final smartSpotsEnabled = this.state.isSmartSpotEnabled;

    // we have to do this because polygons dont have on tap
    // currently it only handles smart spots
    if (smartSpotsEnabled) {
      final latestValue = ref.read(polygonLoaderProvider(PolygonType.smartSpots)).value;
      if (latestValue == null) return;

      final smartSpots = latestValue.map((e) => (
            Polygon(points: e.points),
            (e as SmartSpotV5).markerPopupData,
          ));
      final collisions = findPolygonCollisions(latlng: latlng, polygons: smartSpots.toList());
      if (collisions.isEmpty) return;
      return SmartSpotMarkerPopUp(
        markerData: collisions.first.$2,
      ).show(context);
    }
  }
}

List<(Polygon, SmartSpotMarkerPopupData)> findPolygonCollisions({
  required List<(Polygon, SmartSpotMarkerPopupData)> polygons,
  required LatLng latlng,
}) {
  final hits = <(Polygon, SmartSpotMarkerPopupData)>[];
  for (final polygon in polygons) {
    // First do a quick pass on the rough bounding box envelope to find candidate hits.

    final points = polygon.$1.points;
    final bounds = LatLngBounds.fromPoints(points);
    if (bounds.contains(latlng)) {
      final coordinates = points.map((c) => polybool.Coordinate(c.longitude, c.latitude)).toList();
      // NOTE: Polybool requires polygons to be closed loops, i.e.: c.first == c.last.
      if (coordinates.first != coordinates.last) {
        coordinates.add(coordinates.first);
      }
      final p = polybool.Polygon(regions: [coordinates]);

      const eps = 1e-7;
      final touch = polybool.Polygon(regions: [
        [
          polybool.Coordinate(latlng.longitude, latlng.latitude),
          polybool.Coordinate(latlng.longitude + eps, latlng.latitude),
          polybool.Coordinate(latlng.longitude + eps, latlng.latitude + eps),
          polybool.Coordinate(latlng.longitude, latlng.latitude + eps),
          polybool.Coordinate(latlng.longitude, latlng.latitude),
        ]
      ]);

      final match = p.intersect(touch).regions.isNotEmpty;
      if (match) {
        hits.add(polygon);
      }
    }
  }
  if (hits.isEmpty) {
    // try to find closest polygon
    final map = SplayTreeMap<double, (Polygon, SmartSpotMarkerPopupData)>();
    final allowedDistance = 0.01;
    for (var element in polygons) {
      map[element.$2.latLng.distanceTo(latlng)] = element;
    }

    if (map.firstKey()! > allowedDistance) return [];
    print("using closest polygon method");
    hits.add(map.values.first);
  }

  return hits;
}
