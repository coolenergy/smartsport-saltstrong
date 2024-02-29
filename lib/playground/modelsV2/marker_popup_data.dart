import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/num_parser.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/smart_spot_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_polygon.dart';

class SmartSpotMarkerPopupData extends SaltStrongPolygon with EquatableMixin {
  final LatLng latLng;
  final String spotName;
  final List<Species> species;
  final List<Winds> winds;
  final List<Tides> tides;
  final String spot_grade;
  final String currentTideName;
  SmartSpotMarkerPopupData({
    required this.latLng,
    required this.spotName,
    required this.species,
    required this.winds,
    required this.tides,
    required this.currentTideName,
    required this.spot_grade,
    required super.points,
  });

  factory SmartSpotMarkerPopupData.fromMap(Map<String, dynamic> map) {
    return SmartSpotMarkerPopupData(
      currentTideName: map["currentTideName"].toString(),
      spot_grade: map['spot_grade'] ?? "",
      latLng: LatLng(doParse(map['lat']), doParse(map['lng'])),
      spotName: map['spot_name'],
      species: (map['species'] as List).map((e) => Species.fromMap(e)).toList(),
      winds: map["winds"] == null ? [] : (map['winds'] as List).map((e) => Winds.fromMap(e)).toList(),
      tides: (map['tides'] as List).map((e) => Tides.fromMap(e)).toList(),
      points:
          (map['PolygonCoords'][0] as List).map<LatLng>((e) => LatLng(doParse(e['lat']), doParse(e['lng']))).toList(),
    );
  }

  @override
   List<Object?> get props => [latLng, spotName, species, winds, tides, spot_grade, points];
}

class Species extends Equatable {
  final int spotId;
  final String name;
  final int score;
  final String seasonName;

  Species({
    required this.spotId,
    required this.name,
    required this.score,
    required this.seasonName,
  });

  factory Species.fromMap(Map<String, dynamic> map) {
    return Species(
      spotId: doParseInt(map['species_spot_id']),
      name: map['species_name'],
      score: doParseInt(map['species_score']),
      seasonName: map['species_season_name'],
    );
  }

  @override
  String toString() {
    return name;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        spotId,
        name,
        score,
        seasonName,
      ];
}

class Winds extends Equatable {
  final int spotId;
  final String name;
  final int score;
  final String seasonName;

  Winds({
    required this.spotId,
    required this.name,
    required this.score,
    required this.seasonName,
  });

  factory Winds.fromMap(Map<String, dynamic> map) {
    return Winds(
      spotId: doParseInt(map['winds_spot_id']),
      name: map['winds_name'],
      score: doParseInt(map['winds_score']),
      seasonName: map['winds_season_name'],
    );
  }

  @override
  String toString() {
    return score.toString();
  }

  @override
  List<Object?> get props => [
        spotId,
        name,
        score,
        seasonName,
      ];
}

class Tides extends Equatable {
  final int spotId;
  final String name;
  final int score;
  final String seasonName;

  Tides({
    required this.spotId,
    required this.name,
    required this.score,
    required this.seasonName,
  });

  factory Tides.fromMap(Map<String, dynamic> map) {
    return Tides(
      spotId: doParseInt(map['tides_spot_id']),
      name: map['tides_name'],
      score: doParseInt(map['tide_score']),
      seasonName: map['tides_season_name'],
    );
  }

  @override
  String toString() {
    return name;
  }

  @override
  List<Object?> get props => [
        spotId,
        name,
        score,
        seasonName,
      ];
}
