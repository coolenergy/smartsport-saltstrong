import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/helpers/num_parser.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_polygon.dart';

class SeaGrassV2 extends SaltStrongPolygon {
  final String id;
  final String description;
  SeaGrassV2({
    required this.id,
    required this.description,
    required super.points,
  });

  factory SeaGrassV2.fromMap(Map<String, dynamic> map) {
    final decoded = jsonDecode(map["coordinates"]);
    final points = <LatLng>[];
    try {
      for (var d in decoded[0]) {
        points.add(LatLng(doParse(d[1]), doParse(d[0])));
      }
    } catch (e) {
      logger.shout(e);
    }

    return SeaGrassV2(id: map["id"].toString(), points: points, description: map["description"].toString());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeaGrassV2 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          description == other.description &&
          points == other.points;

  @override
  int get hashCode => id.hashCode ^ points.hashCode;

  @override
   List<Object?> get props => [id, description, points];
}
