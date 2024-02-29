import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';

class ArtificialReef extends SaltStrongMarker {
  final int id;
  final String description;

  final String type;
  final Map<String, dynamic> metadata;

  String get name => metadata["deployment_name"] as String? ?? "";
  ArtificialReef({
    required this.id,
    required this.description,
    required this.type,
    required this.metadata,
    required LatLng point,
  }) : super(point);

  factory ArtificialReef.fromMap(Map<String, dynamic> map) {
    return ArtificialReef(
      id: map['id'] as int? ?? 0,
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? '',
      metadata: tryDecode(map),
      point: LatLng(
        double.tryParse(map['lat'].toString()) ?? 0.0,
        double.tryParse(map['lng'].toString()) ?? 0.0,
      ),
    );
  }

  static Map<String, dynamic> tryDecode(Map<String, dynamic> map) {
    try {
      return (json.decode(map['metadata'] as String? ?? '{}'));
    } catch (e) {
      return {
        " ": map["metadata"],
      };
    }
  }

  @override
  List<Object?> get props => [id];
}

class MetaData {
  final String deployId;
  final String country;
  final String deployDate;
  final String deploymentName;
  final String description;
  final String primaryMaterial;
  final String tons;
  final String relief;
  final String depth;
  final String jurisdiction;
  final String coast;
  final String latDm;
  final String longDm;
  final String locationAccuracy;

  MetaData({
    required this.deployId,
    required this.country,
    required this.deployDate,
    required this.deploymentName,
    required this.description,
    required this.primaryMaterial,
    required this.tons,
    required this.relief,
    required this.depth,
    required this.jurisdiction,
    required this.coast,
    required this.latDm,
    required this.longDm,
    required this.locationAccuracy,
  });

  factory MetaData.fromMap(Map<String, dynamic> map) {
    return MetaData(
      deployId: map['deploy_id'] as String? ?? '',
      country: map['country'] as String? ?? '',
      deployDate: map['deploy_date'] as String? ?? '',
      deploymentName: map['deployment_name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      primaryMaterial: map['primary_material'] as String? ?? '',
      tons: map['tons'] as String? ?? '',
      relief: map['relief'] as String? ?? '',
      depth: map['depth'] as String? ?? '',
      jurisdiction: map['jurisdiction'] as String? ?? '',
      coast: map['coast'] as String? ?? '',
      latDm: map['lat_dm'] as String? ?? '',
      longDm: map['long_dm'] as String? ?? '',
      locationAccuracy: map['location_accuracy'] as String? ?? '',
    );
  }
}
