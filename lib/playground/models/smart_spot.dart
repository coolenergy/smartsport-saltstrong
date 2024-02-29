import 'package:latlong2/latlong.dart';

import '../helpers/num_parser.dart';

class SmartSpot {
  final String id;
  final LatLng latLng;
  final List<LatLng> polygonCoords;

  const SmartSpot({
    required this.id,
    required this.latLng,
    required this.polygonCoords,
  });

  factory SmartSpot.fromMap(Map<String, dynamic> map) {
    return SmartSpot(
      id: map['id'].toString(),
      latLng: LatLng(doParse(map['lat']), doParse(map['lng'])),
      polygonCoords:
          (map['PolygonCoords'][0] as List).map<LatLng>((e) => LatLng(doParse(e['lat']), doParse(e['lng']))).toList(),
    );
  }
}
