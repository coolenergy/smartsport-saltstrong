import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/keep_alive_provider.dart';
import 'package:salt_strong_poc/playground/helpers/lat_lng_ext.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/tide_station.dart';
import 'package:salt_strong_poc/playground/services/markers/markers_service.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/customized_providers.dart';

final closestStationProvider = FutureProvider.autoDispose<TideStation?>((ref) async {
  // keep alive for 10 seconds, this is used when user toggles the visibility of search bar
  // and we want to keep the closest station for 10 seconds

  keepAlive(ref);

  // this basically rebuilds on every map move
  var stations = await ref.watch(markerLoaderProvider(MarkerType.tideStation).future);
  final mapPos = ref.read(realtimeSyncMapPosProvider);
  stations = stations as List<TideStation>;
  if (stations.isEmpty) return null;
  final map = SplayTreeMap<double, TideStation>();
  for (var element in stations) {
    map[element.point.distanceTo(mapPos.latLng)] = element;
  }
  return map.values.firstOrNull;
});

LatLng closestPointToCurrent(LatLng current, List<LatLng> points) {
  return points.reduce((value, element) {
    if (value.distanceTo(current) < element.distanceTo(current)) {
      return value;
    } else {
      return element;
    }
  });
}
