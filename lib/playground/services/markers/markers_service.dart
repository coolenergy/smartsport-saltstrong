import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/helpers/keep_alive_provider.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/artificial_reefs.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/boat_ramps.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/insider_spot.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/marker_info.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/markers_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/tide_station.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';
import 'package:salt_strong_poc/playground/services/http/http_service.dart';
import 'package:salt_strong_poc/playground/services/markers/requests.dart';

import '../../view/home_map/controller/layer_controller.dart';

enum MarkerType {
  artificialReefs,

  ///markers is community spots
  markers,
  boatRamps,
  insiderSpots,
  tideStation
}

final markerLoaderProvider = FutureProvider.autoDispose.family<List<SaltStrongMarker>, MarkerType>((ref, type) async {
  // ignoring for tide station because its shown up top
  if (type != MarkerType.tideStation) {
    ref.onCancel(() {
      Future(() {
        final value = ref.read(loadingMapProvider.notifier);
        value.remove(type);
      });
    });
    ref.listenSelf((previous, next) {
      Future(() {
        try {
          final value = ref.read(loadingMapProvider.notifier);
          value.update(type, next);
        } catch (e) {}
      });
    });
  }

  final mapPos = ref.watch(realtimeSyncMapPosProvider);

  List<SaltStrongMarker> responseMarkers = [];

  final dioService = ref.read(httpServiceProvider);

  var token = ref.refresh(httpCancelTokenProvider(type));
  await Future(() {});

  switch (type) {
    case MarkerType.tideStation:
      responseMarkers = await dioService.request(
          TideStationRequest(
            lat: mapPos.x,
            lng: mapPos.y,
            dist: mapPos.zoomBasedHaversineDist,
          ), converter: (response) {
        return (response["result"] as List).map((e) {
          return TideStation.fromMap(e);
        }).toList();
      });

    case MarkerType.insiderSpots:
      responseMarkers = await dioService.request(
          InsiderSpotsRequest(
            lat: mapPos.x,
            lng: mapPos.y,
            dist: mapPos.zoomBasedHaversineDist,
          ), converter: (response) {
        return (response["result"] as List).map((e) {
          return InsiderSpot.fromMap(e);
        }).toList();
      }, cancelToken: token);

    case MarkerType.artificialReefs:
      responseMarkers = await dioService.request(
        ArtificialReefsRequest(
          lat: mapPos.x,
          lng: mapPos.y,
          dist: mapPos.zoomBasedHaversineDist,
        ),
        cancelToken: token,
        converter: (response) {
          return (response["result"] as List).map((e) {
            return ArtificialReef.fromMap(e);
          }).toList();
        },
      );

      break;

    case MarkerType.markers:
      responseMarkers = await ref.watch(communitySpotLoaderProvider.future);
      break;
    case MarkerType.boatRamps:
      responseMarkers = await dioService.request(
        BoatRampsRequest(lat: mapPos.x, lng: mapPos.y, dist: mapPos.zoomBasedHaversineDist),
        cancelToken: token,
        converter: (response) {
          return (response["result"] as List).map((e) {
            return BoatRamp.fromMap(e);
          }).toList();
        },
      );
      break;
  }

  return responseMarkers;
});

final communitySpotLoaderProvider = FutureProvider.autoDispose<List<MapMarkerEntityV2>>((ref) async {
  ref.keepAlive();

  final dioService = ref.read(httpServiceProvider);
  return ref.state.valueOrNull ??
      await dioService.request(
        CommunitySpotsRequest(),
        converter: (response) {
          return (response["result"] as List).map((e) {
            return MapMarkerEntityV2.fromMap(e);
          }).toList();
        },
      );
});
