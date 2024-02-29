import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';

class TideStation extends SaltStrongMarker {
  // "id": 1962,
  // "stationid": "8727061",
  // "station_name": "Hudson, Hudson Creek",
  // "station_state": "Florida",
  // "state_abbrev": "FL",
  // "station_city": "Hudson",
  // "lng": "-82.71",
  // "lat": "28.3617",
  // "distance": 23.487393032174023

  final String id;
  final String stationid;
  final String stationName;
  final String stationState;
  final String stateAbbrev;
  final String stationCity;
  final double lng;
  final double lat;
  final double distance;

  TideStation({
    required this.id,
    required this.stationid,
    required this.stationName,
    required this.stationState,
    required this.stateAbbrev,
    required this.stationCity,
    required this.lng,
    required this.lat,
    required this.distance,
  }) : super(LatLng(lat, lng));

  factory TideStation.fromMap(Map<String, dynamic> map) {
    return TideStation(
      id: map["id"].toString(),
      stationid: map["stationid"].toString(),
      stationName: map["station_name"].toString(),
      stationState: map["station_state"].toString(),
      stateAbbrev: map["state_abbrev"].toString(),
      stationCity: map["station_city"].toString(),
      lng: double.parse(map["lng"].toString()),
      lat: double.parse(map["lat"].toString()),
      distance: double.parse(map["distance"].toString()),
    );
  }

  @override
  String toString() {
    return 'TideStation{id: $id, stationid: $stationid, stationName: $stationName, stationState: $stationState, stateAbbrev: $stateAbbrev, stationCity: $stationCity, lng: $lng, lat: $lat, distance: $distance}';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}
