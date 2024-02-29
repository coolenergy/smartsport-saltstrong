import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/smart_spot_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';

class InsiderSpot extends SaltStrongMarker with SaltColorConverterMixin, EquatableMixin {
  final String? feedId;
  final String userPhotoId;
  final String feedTopics;
  final String feedRegion;
  final String feedLocation;
  final DateTime timestamp;
  final double feedlat;
  final double feedlng;
  final String postType;
  final bool isDeleted;
  final String markerColor;
  final double distance;

  InsiderSpot({
    required this.feedId,
    required this.userPhotoId,
    required this.feedTopics,
    required this.feedRegion,
    required this.feedLocation,
    required this.timestamp,
    required this.feedlat,
    required this.feedlng,
    required this.postType,
    required this.isDeleted,
    required this.markerColor,
    required this.distance,
  }) : super(LatLng(feedlat, feedlng));

  factory InsiderSpot.fromMap(Map<String, dynamic> map) {
    return InsiderSpot(
      feedId: map['feedid']?.toString(),
      userPhotoId: map['user_photo_id'].toString(),
      feedTopics: map['feed_topics'].toString(),
      feedRegion: map['feed_region'].toString(),
      feedLocation: map['feed_location'].toString(),
      timestamp: DateTime.parse(map['timestamp'] as String? ?? ''),
      feedlat: double.tryParse(map['feedlat'].toString()) ?? 0.0,
      feedlng: double.tryParse(map['feedlng'].toString()) ?? 0.0,
      postType: map['postType'].toString(),
      isDeleted: map['isDeleted'].toString() == "1",
      markerColor: map['markerColor'] as String? ?? '',
      distance: double.tryParse(map['distance'].toString()) ?? 0.0,
    );
  }

  @override
  String get colorText => markerColor;

  @override
  List<Object?> get props => [
        feedId,
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
