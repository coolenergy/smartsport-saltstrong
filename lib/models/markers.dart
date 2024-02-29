import 'dart:convert';

class MapMarker {
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

  MapMarker({
    required this.feedid,
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
  });

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    return MapMarker(
      feedid: json['feedid'],
      userPhotoId: json['user_photo_id'],
      feedTopics: json['feed_topics'],
      feedRegion: json['feedRegion'],
      feedLocation: json['feed_location'],
      timestamp: json['timestamp'],
      feedlat: json["feedlat"] != null &&
              json["feedlat"] != '' &&
              json["feedlat"] != 'undefined'
          ? double.parse(json["feedlat"].toString())
          : null,
      feedlng: json["feedlng"] != null &&
              json["feedlng"] != '' &&
              json["feedlng"] != 'undefined'
          ? double.parse(json["feedlng"].toString())
          : null,
      postType: json['postType'],
      isDeleted: json['isDeleted'],
      markerColor: json['markerColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'feedid': feedid,
      'userPhotoId': userPhotoId,
      'feedTopics': feedTopics,
      'feedRegion': feedRegion,
      'feedLocation': feedLocation,
      'timestamp': timestamp,
      'feedlat': feedlat,
      'feedlng': feedlng,
      'postType': postType,
      'isDeleted': isDeleted,
      'markerColor': markerColor,
    };
  }

  factory MapMarker.fromMap(Map<String, dynamic> map) {
    return MapMarker(
      feedid: map['feedid'] as int,
      userPhotoId: map['userPhotoId'] as int,
      feedTopics: map['feedTopics'] as int,
      feedRegion: map['feedRegion'] as int,
      feedLocation: map['feedLocation'] as int,
      timestamp: map['timestamp'] as String,
      feedlat: double.parse(map["feedlat"].toString()),
      feedlng: double.parse(map["feedlng"].toString()),
      postType: map['postType'] as int,
      isDeleted: map['isDeleted'] as int,
      markerColor: map['markerColor'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MapMarker.fromString(String source) =>
      MapMarker.fromMap(json.decode(source) as Map<String, dynamic>);
}
