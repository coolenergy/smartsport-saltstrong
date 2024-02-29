import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/helpers/keep_alive_provider.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/models/map_position.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/tide_station.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/oyster_beds_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/sea_grass.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/smart_spot_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_polygon.dart';
import 'package:salt_strong_poc/playground/services/http/http_service.dart';
import 'package:salt_strong_poc/playground/services/markers/customized_providers.dart';
import 'package:salt_strong_poc/playground/services/polygons/requests.dart';

import '../../view/home_map/controller/layer_controller.dart';

enum PolygonType { smartSpots, seaGrass, oysterBeds }

final polygonLoaderProvider =
    FutureProvider.autoDispose.family<List<SaltStrongPolygon>, PolygonType>((ref, type) async {
  // ref.onDispose(() {
  //   Future((){
  //     final value = ref.read(loadingMapProvider.notifier);
  //     value.remove(type);
  //   });
  //
  // });
  ref.onCancel(() {
    Future(() {
      final value = ref.read(loadingMapProvider.notifier);
      value.remove(type);
    });
  });
  ref.listenSelf((previous, next) {
    Future(() {
      // print("start loading ${type}");
      final value = ref.read(loadingMapProvider.notifier);
      value.update(type, next);
    });
  });
  final mapPos = ref.watch(fineGrainedMapPosProvider(MapPosThresholds.minimal));
  List<SaltStrongPolygon> responsePolygons = [];

  final dioService = ref.read(httpServiceProvider);

  var token = ref.refresh(httpCancelTokenProvider(type));
  await Future(() {});

  switch (type) {
    case PolygonType.smartSpots:
      final dateTime = ref.watch(selectedDateTimeProvider);
      final time = ref.read(selectedTimeProvider);
      final date = ref.read(selectedDateProvider);
      responsePolygons = await ref.watch(_smartSpotLoader((date, time)).future);
      ref.notifyListeners();
      // print("showing polygons for $date $time");
      break;
    case PolygonType.seaGrass:
      responsePolygons = await dioService.request(
        SeaGrassRequest(lat: mapPos.x, lng: mapPos.y, dist: mapPos.zoomBasedHaversineDist),
        cancelToken: token,
        converter: (response) {
          return (response["result"] as List).map((e) {
            return SeaGrassV2.fromMap(e);
          }).toList();
        },
      );
      break;
    case PolygonType.oysterBeds:
      responsePolygons = await dioService.request(
        OysterBedsRequest(lat: mapPos.x, lng: mapPos.y, dist: mapPos.zoomBasedHaversineDist),
        cancelToken: token,
        converter: (response) {
          return (response["result"] as List).map((e) {
            return OysterBedsV2.fromMap(e);
          }).toList();
        },
      );
      break;
  }

  return responsePolygons;
});

// loads smart spots for the current date and time
final _smartSpotLoader = FutureProvider.autoDispose.family<List<SmartSpotV5>, (DateTime, TimeOfDay)>((ref, arg) async {
  // this would always return only the hour value with minute set to 0
  final SmartSpotsV5Response dailyData = await ref.watch(_dailySmartSpotLoader(arg.$1).future);

  return dailyData.smartSpotsHourlyData[arg.$2] ?? [];
});

//this provider only rebuilds when the date changes ( its cached )
final _dailySmartSpotLoader = FutureProvider.autoDispose.family<SmartSpotsV5Response, DateTime>((ref, date) async {
  final link = ref.keepAlive();

  final mapPos = ref.watch(fineGrainedMapPosProvider(MapPosThresholds.minimal));
  final dioService = ref.read(httpServiceProvider);

  var token = ref.refresh(httpCancelTokenProvider(PolygonType.smartSpots.toString() + date.formattedDate));
  await Future(() {});
  final sw = Stopwatch()..start();
  final request = SmartSpotsRequest(
    dist: mapPos.zoomBasedHaversineDist,
    lat: mapPos.x,
    lng: mapPos.y,
    targetDate: date.formattedDate,
  );
  try {
    var response = await dioService.request(
      request,
      cancelToken: token,
      converter: (response) {
        try {
          return SmartSpotsV5Response.fromMap(response);
        } catch (e, st) {
          link.close();

          logger.shout(" $e");
          debugPrintStack(stackTrace: st);
          throw e;
        }
      },
    ).whenComplete(() {
      sw.stop();
     });
    return response;
  } catch (e) {
    // logger.shout(" $e");
    link.close();
    throw e;
  }
});
