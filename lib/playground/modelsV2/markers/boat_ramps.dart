import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/num_parser.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';

class BoatRamp extends SaltStrongMarker {
  final int id;
  final String description;
  final LatLng? coordinates;
  final String type;
  final double distance;
  final Map<String, dynamic> properties;

  BoatRamp({
    required this.id,
    required this.description,
    this.coordinates,
    required this.type,
    required this.distance,
    required this.properties,
    required LatLng point,
  }) : super(point);

  String get name => properties["name"] as String? ?? "";

  factory BoatRamp.fromMap(Map<String, dynamic> map) {
    return BoatRamp(
      id: map['id'] as int? ?? 0,
      description: map['description'] as String? ?? '',
      coordinates: LatLng(
        double.tryParse(map['lat'].toString()) ?? 0.0,
        double.tryParse(map['lng'].toString()) ?? 0.0,
      ),
      type: map['type'] as String? ?? '',
      distance: (map['distance'] as num? ?? 0).toDouble(),
      properties: jsonDecode(map["properties"]),
      point: LatLng(
        double.tryParse(map['lat'] as String? ?? '') ?? 0.0,
        double.tryParse(map['lng'] as String? ?? '') ?? 0.0,
      ),
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        id,
        description,
        coordinates,
        type,
        distance,
        properties,
        point,
      ];
}

class BoatRampProperties {
  final int objectid;
  final int exdate;
  final String source;
  final String fwcid;
  final String factype;
  final String name;
  final String access;
  final String primagency;
  final String partagency;
  final String status;
  final String hours;
  final String fees;
  final int feeamt;
  final String feecollect;
  final String rampsurf;
  final String rampcond;
  final int singlelane;
  final int doublelane;
  final int totallane;
  final String docktype;
  final String parksurf;
  final String parkcond;
  final int trailer;
  final int handitrail;
  final int vehicle;
  final int handicap;
  final String restroom;
  final String handirestr;
  final String handiacces;
  final String picnic;
  final String lighting;
  final String grill;
  final String street;
  final String city;
  final String county;
  final int zip;
  final double latitude;
  final double longitude;
  final String watertype;
  final String watername;
  final String vdate;
  final String vstatus;
  final String comments;

  BoatRampProperties({
    required this.objectid,
    required this.exdate,
    required this.source,
    required this.fwcid,
    required this.factype,
    required this.name,
    required this.access,
    required this.primagency,
    required this.partagency,
    required this.status,
    required this.hours,
    required this.fees,
    required this.feeamt,
    required this.feecollect,
    required this.rampsurf,
    required this.rampcond,
    required this.singlelane,
    required this.doublelane,
    required this.totallane,
    required this.docktype,
    required this.parksurf,
    required this.parkcond,
    required this.trailer,
    required this.handitrail,
    required this.vehicle,
    required this.handicap,
    required this.restroom,
    required this.handirestr,
    required this.handiacces,
    required this.picnic,
    required this.lighting,
    required this.grill,
    required this.street,
    required this.city,
    required this.county,
    required this.zip,
    required this.latitude,
    required this.longitude,
    required this.watertype,
    required this.watername,
    required this.vdate,
    required this.vstatus,
    required this.comments,
  });

  factory BoatRampProperties.fromMap(Map<String, dynamic> map) {
    return BoatRampProperties(
      objectid: map['objectid'] as int? ?? 0,
      exdate: map['exdate'] as int? ?? 0,
      source: map['source'] as String? ?? '',
      fwcid: map['fwcid'] as String? ?? '',
      factype: map['factype'] as String? ?? '',
      name: map['name'] as String? ?? '',
      access: map['access'] as String? ?? '',
      primagency: map['primagency'] as String? ?? '',
      partagency: map['partagency'] as String? ?? '',
      status: map['status'] as String? ?? '',
      hours: map['hours'] as String? ?? '',
      fees: map['fees'] as String? ?? '',
      feeamt: doParseInt(map['feeamt']),
      feecollect: map['feecollect'] as String? ?? '',
      rampsurf: map['rampsurf'] as String? ?? '',
      rampcond: map['rampcond'] as String? ?? '',
      singlelane: map['singlelane'] as int? ?? 0,
      doublelane: map['doublelane'] as int? ?? 0,
      totallane: map['totallane'] as int? ?? 0,
      docktype: map['docktype'] as String? ?? '',
      parksurf: map['parksurf'] as String? ?? '',
      parkcond: map['parkcond'] as String? ?? '',
      trailer: map['trailer'] as int? ?? 0,
      handitrail: map['handitrail'] as int? ?? 0,
      vehicle: map['vehicle'] as int? ?? 0,
      handicap: map['handicap'] as int? ?? 0,
      restroom: map['restroom'] as String? ?? '',
      handirestr: map['handirestr'] as String? ?? '',
      handiacces: map['handiacces'] as String? ?? '',
      picnic: map['picnic'] as String? ?? '',
      lighting: map['lighting'] as String? ?? '',
      grill: map['grill'] as String? ?? '',
      street: map['street'] as String? ?? '',
      city: map['city'] as String? ?? '',
      county: map['county'] as String? ?? '',
      zip: map['zip'] as int? ?? 0,
      latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
      watertype: map['watertype'] as String? ?? '',
      watername: map['watername'] as String? ?? '',
      vdate: map['vdate'] as String? ?? '',
      vstatus: map['vstatus'] as String? ?? '',
      comments: map['comments'] as String? ?? '',
    );
  }
}
