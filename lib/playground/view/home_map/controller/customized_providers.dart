// There should be a controller wrapping the modification of this
// Some layers depend on this value

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/calendar/calendar.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/filters/filters.dart';

import '../../../models/map_position.dart';
import '../../../modelsV2/layer_wrapper.dart';
import '../../../modelsV2/search/search_location.dart';
import '../widgets/ss_bottom_sheet.dart';
import 'layer_controller.dart';

// for not updating text on search bar if SearchPopup is dismissed
final tempSearchLocation = StateProvider<SearchLocation?>((ref) => null);

// //timelineControllerOffset: when changing calendar dates, keep the scrolling offset
// final timelineControllerOffset = StateProvider<double>((ref) => 0);

// smartTidesTabBarViewIndex
final smartTidesTabBarViewIndex = StateProvider<int>((ref) => 0);

// smartTidesTabBarViewIndex
final defaultTabCtrlIndex = StateProvider<int>((ref) => 0);

// just the selected time extracted from notifier, nothing special
final selectedDateTimeProvider = Provider.autoDispose<DateTime>((ref) {
  ref.keepAlive();
  return ref.watch(calendarNotifierProvider).selectedTime;
});

final selectedDateProvider = Provider.autoDispose<DateTime>((ref) {
  return ref.watch(calendarNotifierProvider).selectedTime.date;
});

// we are using this only for smart spots and dont need minutes there
final selectedTimeProvider = Provider.autoDispose<TimeOfDay>((ref) {
  ref.keepAlive();

  return TimeOfDay.fromDateTime(ref.watch(calendarNotifierProvider).selectedTime).replacing(minute: 0);
});

final selectedFilterProvider = Provider.autoDispose<List<SmartTidesFilter>>((ref) {
  return ref.watch(filterNotifierProvider).selectedFilters;
});

// optimizing rebuilds for layers, working with lists and equality is usually complicated
final allLayersProvider = Provider.autoDispose<List<LayerWrapper>>((ref) {
  final value = ref.read(saltStrongLayerControllerProvider).allLayers;

  ref.listen(saltStrongLayerControllerProvider, (prev, next) {
    if (prev != null) {
      if (prev.allLayers.toString() != next.allLayers.toString()) {
        ref.state = next.allLayers;
      }
    }
  });

  return value;
});

final _mapPosProvider = Provider.autoDispose<MapPos>((ref) {
  return ref.watch(saltStrongLayerControllerProvider).currentPos;
});

// use this whenever you want a rebuild on *every* position change

// this is used for calculating tide station on every move
final realtimeSyncMapPosProvider = Provider.autoDispose<MapPos>((ref) {
  return ref.watch(fineGrainedMapPosProvider(MapPosThresholds.none));
});

// use this whenever you want a rebuild on [MapPosThresholds] position change
// this is useful for layers that are expensive to rebuild and for API calls
// that shouldn't be called too often
final fineGrainedMapPosProvider = Provider.autoDispose.family<MapPos, MapPosThresholds>((ref, value) {
  // we are doing read instead of watch because we just need the initial value returned
  final pos = ref.read(_mapPosProvider);
  Timer? timer;
  ref.listen(
    _mapPosProvider,
    // purposely ignoring previous because otherwise it would never update
    // considering this listener doesn't have fireImmediately true, it will be
    // called after the build of [fineGrainedMapPosProvider] is complete
    // so accessing ref.state is safe
    (_, nextValue) {
      // timer debouncer is used so that we don't update the provider to often
      // for example user might be moving the map very quickly
      // hasSignificantChange would be true in that case, but it doesn't make sense to update
      timer?.cancel();
      timer = Timer(
        Duration(milliseconds: value.debouncerDelayMilis),
        () {
          final next = ref.read(_mapPosProvider);
          final previous = ref.state;

          bool didChange = MapPosThresholds.hasSignificantChange(previous, next,
              latLngThreshold: value.latLngThreshold, zoomThreshold: value.zoomThreshold);

          if (didChange) {
            ref.state = next;
          }
        },
      );
    },
  );

  return pos;
});

class MapPosThresholds extends Equatable {
  final double latLngThreshold;
  final double zoomThreshold;
  final int debouncerDelayMilis;
  const MapPosThresholds(
    this.latLngThreshold,
    this.zoomThreshold, [
    this.debouncerDelayMilis = 1000,
  ]);

  static const none = MapPosThresholds(0.0, 0.0, 0);
  static const minimal = MapPosThresholds(0.0, 0.0, 200);
  static const small = MapPosThresholds(0.0001, 1.0, 100);
  static const medium = MapPosThresholds(0.001, 5.0);
  static const large = MapPosThresholds(0.01, 10.0);

  // use only for testing
  static const abnormal = MapPosThresholds(10.01, 10.0);

  static MapPosThresholds custom(double latLngThreshold, double zoomThreshold) {
    return MapPosThresholds(latLngThreshold, zoomThreshold);
  }

  static bool hasSignificantChange(MapPos prevPos, MapPos nextPos,
      {required double latLngThreshold, required double zoomThreshold}) {
    if (prevPos == nextPos) return false;

    if (latLngThreshold == 0.0 && zoomThreshold == 0.0) return true;

    double latDiff = (prevPos.x - nextPos.x).abs();
    double lngDiff = (prevPos.y - nextPos.y).abs();
    double zoomDiff = (prevPos.z - nextPos.z).abs();

    // Adjust the latitude and longitude threshold based on the zoom level.
    // The adjusted threshold is inversely proportional to the zoom level,
    // with a higher zoom level resulting in a smaller threshold.
    double adjustedLatLngThreshold = latLngThreshold * (1 / (nextPos.z + 1));

    if (latDiff > adjustedLatLngThreshold || lngDiff > adjustedLatLngThreshold || zoomDiff > zoomThreshold) {
      return true;
    }

    return false;
  }

  MapPosThresholds copyWith({
    double? latLngThreshold,
    double? zoomThreshold,
    int? debouncerDelayMilis,
  }) {
    return MapPosThresholds(
      latLngThreshold ?? this.latLngThreshold,
      zoomThreshold ?? this.zoomThreshold,
      debouncerDelayMilis ?? this.debouncerDelayMilis,
    );
  }

  @override
  List<Object?> get props => [latLngThreshold, zoomThreshold, debouncerDelayMilis];
}
