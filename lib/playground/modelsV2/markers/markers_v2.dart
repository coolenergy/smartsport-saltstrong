import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';

class MapMarkerEntityV2 extends SaltStrongMarker with EquatableMixin{
  final int? feedid;
  final int? userPhotoId;
  final int? feedTopics;
  final int? feedRegion;
  final int? feedLocation;
  final String timestamp;
  final double? feedlat;
  final double? feedlng;
  final int postType;
  final int isDeleted;
  final String markerColor;
  final double distance;

  MapMarkerEntityV2({
    this.feedid,
    this.userPhotoId,
    this.feedTopics,
    this.feedRegion,
    this.feedLocation,
    required this.timestamp,
    this.feedlat,
    this.feedlng,
    required this.postType,
    required this.isDeleted,
    required this.markerColor,
    required this.distance,
  }) : super(LatLng(feedlat ?? 0, feedlng ?? 0));

  factory MapMarkerEntityV2.fromMap(Map<String, dynamic> map) {
    return MapMarkerEntityV2(
      feedid: map['feedid'] != null ? int.tryParse(map['feedid'].toString()) : null,
      userPhotoId: map['user_photo_id'] != null ? int.tryParse(map['user_photo_id'].toString()) : null,
      feedTopics: map['feed_topics'] != null ? int.tryParse(map['feed_topics'].toString()) : null,
      feedRegion: map['feed_region'] as int? ?? 0,
      feedLocation: map['feed_location'] as int? ?? 0,
      timestamp: map['timestamp'] as String? ?? '',
      feedlat: map['feedlat'] != null ? double.tryParse(map['feedlat'].toString()) : null,
      feedlng: map['feedlng'] != null ? double.tryParse(map['feedlng'].toString()) : null,
      postType: map['postType'] as int? ?? 0,
      isDeleted: map['isDeleted'] as int? ?? 0,
      markerColor: map['markerColor'] as String? ?? '',
      distance: double.tryParse(map['distance'].toString()) ?? 0.0,
    );
  }

  LatLng get latLng => LatLng(feedlat ?? 0, feedlng ?? 0);

  @override

  List<Object?> get props => [
        feedid,
        userPhotoId,
        feedTopics,
        feedRegion,
        feedLocation,
        timestamp,
        feedlat,
        feedlng,
        postType,
        isDeleted,
        markerColor,
        distance,
  ];
}
