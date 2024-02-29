import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/num_parser.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_polygon.dart';

class OysterBedsV2 extends SaltStrongPolygon {
  final int id;
  final String description;
  final LatLng location;
  final String type;
  final double distance;

  OysterBedsV2({
    required this.id,
    required this.description,
    required this.location,
    required this.type,
    required this.distance,
    required super.points,
  });

  factory OysterBedsV2.fromMap(Map<String, dynamic> map) {
    final decoded = jsonDecode(map["coordinates"]);
    final points = <LatLng>[];
    for (var d in decoded[0]) {
      points.add(LatLng(doParse(d[1]), doParse(d[0])));
    }

    return OysterBedsV2(
      id: map['id'],
      description: map['description'],
      location: LatLng(doParse(map['lat']), doParse(map['lng'])),
      points: points,
      type: map['type'],
      distance: map['distance'],
    );
  }

  @override
   List<Object?> get props => [id, description, location, type, distance];
}
