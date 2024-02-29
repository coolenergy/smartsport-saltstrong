import '../http/http_service.dart';

class ArtificialReefsRequest extends BaseHttpRequest {
  final double lat;
  final double lng;
  final int dist;

  @override
  Map<String, dynamic> toMap() {
    final newMap = <String, dynamic>{
      "lat": lat,
      "lng": lng,
      "dist": dist,
    };
    return newMap;
  }

  const ArtificialReefsRequest({
    required this.lat,
    required this.lng,
    required this.dist,
  }) : super(endpoint: "/getArtificialReefs", requestType: RequestType.post);
}

class GetMarkerInfoRequest extends BaseHttpRequest {
  final String feedid;

  @override
  Map<String, dynamic> toMap() {
    return {
      "feedid": feedid,
    };
  }

  const GetMarkerInfoRequest({
    required this.feedid,
  }) : super(endpoint: "/getMarkerInfo", requestType: RequestType.post);
}

class CommunitySpotsRequest extends BaseHttpRequest {
  @override
  Map<String, dynamic> toMap() {
    return {};
  }

  const CommunitySpotsRequest() : super(endpoint: "/getMapReports", requestType: RequestType.post);
}

class BoatRampsRequest extends BaseHttpRequest {
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

  const BoatRampsRequest({
    required this.lat,
    required this.lng,
    required this.dist,
  }) : super(endpoint: "/getBoatRamps", requestType: RequestType.post);
}

class InsiderSpotsRequest extends BaseHttpRequest {
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

  const InsiderSpotsRequest({
    required this.lat,
    required this.lng,
    required this.dist,
  }) : super(endpoint: "/getInsiderReportsV2", requestType: RequestType.post);
}

class TideStationRequest extends BaseHttpRequest {
  final double lat;
  final double lng;
  final int dist;

  @override
  Map<String, dynamic> toMap() {
    return {
      "lat": lat,
      "lng": lng,
      // "dist": dist,
    };
  }

  TideStationRequest({
    required this.lat,
    required this.lng,
    required this.dist,
  }) : super(endpoint: "/getAllTideStations", requestType: RequestType.post);
}
