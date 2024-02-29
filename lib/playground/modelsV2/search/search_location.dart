// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class SearchLocation extends Equatable {
  final String name;
  final LatLng latLng;
  final String? shortName;

  const SearchLocation({
    required this.name,
    required this.latLng,
    this.shortName,
  });

  factory SearchLocation.fromJson(String str) => SearchLocation.fromMap(
        json.decode(str),
      );

  String toJson() => json.encode(_toMap());

  factory SearchLocation.fromMap(Map<String, dynamic> json) => SearchLocation(
        name: json["name"],
        latLng: LatLng.fromJson(json["latLng"]),
        shortName: json["shortName"],
      );

  Map<String, dynamic> _toMap() => {
        "name": name,
        "latLng": latLng.toJson(),
        "shortName": shortName,
      };

  @override
  String toString() {
    // todo more accurate format
    final lat = latLng.latitude.toStringAsFixed(3);
    final lng = latLng.longitude.toStringAsFixed(3);

    // todo add abbreviation code
    // return '$name • $lat, $lng';
    final addressComponents = [name, shortName]..removeWhere((element) => element == '');
    return addressComponents.length == 1 ? addressComponents.first ?? '' : addressComponents.join(', ');
  }

  @override
  List<Object?> get props => [toString()];
}
