import '../http/http_service.dart';

class SmartSpotsRequest extends BaseHttpRequest {
  final double lat;
  final double lng;
  final String targetDate;
  final int dist;
  final int maxResult;

  @override
  Map<String, dynamic> toMap() {
    final newMap = <String, dynamic>{
      "lat": lat,
      "dist": dist,
      "lng": lng,
      "targetDate": targetDate,
    };
    return newMap;
  }

  const SmartSpotsRequest({
    required this.lat,
    required this.dist,
    required this.lng,
    required this.targetDate,
    this.maxResult = 1000,
  }) : super(endpoint: "/getSmartSpotsV5", requestType: RequestType.post);
}

class SeaGrassRequest extends BaseHttpRequest {
  final double lat;
  final double lng;
  final int dist;

  @override
  Map<String, dynamic> toMap() {
    return {
      "lat": lat,
      "lng": lng,
      "dist": dist,
    };
  }

  const SeaGrassRequest({
    required this.lat,
    required this.lng,
    required this.dist,
  }) : super(endpoint: "/getSeagrass", requestType: RequestType.post);
}

class OysterBedsRequest extends BaseHttpRequest {
  final double lat;
  final double lng;
  final int dist;

  @override
  Map<String, dynamic> toMap() {
    return {
      "lat": lat,
      "lng": lng,
      "dist": dist,
    };
  }

  const OysterBedsRequest({
    required this.lat,
    required this.lng,
    required this.dist,
  }) : super(endpoint: "/getOysterBeds", requestType: RequestType.post);
}
