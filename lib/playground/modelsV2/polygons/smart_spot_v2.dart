import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/helpers/num_parser.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_polygon.dart';

import '../marker_popup_data.dart';

class SmartSpotsV5Response extends Equatable {
  final Map<TimeOfDay, List<SmartSpotV5>> smartSpotsHourlyData;

  const SmartSpotsV5Response({
    required this.smartSpotsHourlyData,
  });

  @override
  List<Object?> get props => [smartSpotsHourlyData];

  factory SmartSpotsV5Response.fromMap(Map<String, dynamic> map) {
    final sw = Stopwatch()..start();
    Map<TimeOfDay, List<SmartSpotV5>> mapped = {};
    final allSpots = map["smartSpotArr"] as List;
    final spotsById = {for (var e in allSpots) e["spot_id"].toString(): e};
    int index = 0;
    if (map["smartSpotsHourlyData"] == null) {
      throw Exception("smartSpotsHourlyData is null, it should not be");
    }
    for (var spot in map["smartSpotsHourlyData"]) {
      final time = TimeOfDay(hour: index, minute: 0);
      mapped[time] = (spot["data"] as List)
          .where((element) {
            bool visible = element["visible"].toString() == "true";
            return visible;
          })
          .map((e) {
            final additionalMapData = spotsById[e["smartSpotId"].toString()];
            if (additionalMapData == null) return null;
            try {
              return SmartSpotV5.fromMap({...e, ...additionalMapData, ...spot});
            } catch (E) {
              debugPrint(E.toString());
              return null;
            }
          })
          .whereNotNull()
          .where((element) => element.shouldShow)
          .toList();
      index++;
    }
    logger.info("SmartSpotsV5Response.fromMap took ${sw.elapsedMilliseconds}ms");
    return SmartSpotsV5Response(
      smartSpotsHourlyData: mapped,
    );
  }
}

class SmartSpotV5 extends SaltStrongPolygon with EquatableMixin, SaltColorConverterMixin {
  final int spotId;
  final int tideStationId;
  final int stateId;
  final String spotName;
  final LatLng latLng;
  final SmartSpotMarkerPopupData markerPopupData;
  final String color;
  final double opacity;
  final String targetDateStr;

  // 1 or 0 or null
  final dynamic is_on_water;

  SmartSpotV5({
    required this.targetDateStr,
    required this.spotId,
    required this.tideStationId,
    required this.stateId,
    required this.spotName,
    required this.latLng,
    required this.markerPopupData,
    required this.color,
    required this.opacity,
    required this.is_on_water,
    required super.points,
  });

  bool get shouldShow => is_on_water == null || is_on_water == 1;

  factory SmartSpotV5.fromMap(Map<String, dynamic> map) {
    return SmartSpotV5(
      is_on_water: map["is_on_water"],
      targetDateStr: map['targetDateStr'].toString(),
      opacity: double.tryParse(map['opacity'].toString()) ?? 1,
      color: map['color'].toString(),
      markerPopupData: SmartSpotMarkerPopupData.fromMap(map),
      spotId: doParseInt(map['spot_id']),
      tideStationId: doParseInt(map['tide_station_id']),
      stateId: doParseInt(map['state_id']),
      spotName: map['spot_name'],
      latLng: LatLng(doParse(map['lat']), doParse(map['lng'])),
      points:
          (map['PolygonCoords'][0] as List).map<LatLng>((e) => LatLng(doParse(e['lat']), doParse(e['lng']))).toList(),
    );
  }

  @override
  List<Object?> get props =>
      [spotId, tideStationId, stateId, spotName, latLng, markerPopupData, color, opacity, points, targetDateStr];

  @override
  String get colorText => color;
}

mixin SaltColorConverterMixin {
  String get colorText;

  Color get colorValue {
    if (colorText == "yellow") {
      return const Color(0xffFFDF3A);
    } else if (colorText == "purple") {
      return const Color(0xff6627A5);
    } else if (colorText == "red") {
      return const Color(0xffFF005C);
    }
    return const Color(0xffF4AEFF);
  }
}
