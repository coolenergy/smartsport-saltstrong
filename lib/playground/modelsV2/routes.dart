import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_polygon.dart';

class Routes extends SaltStrongPolygon {
  final String routeId;
  final String notes;

  Routes({
    required super.points,
    required this.routeId,
    required this.notes,
  });

  factory Routes.fromMap(Map<String, dynamic> map) {
    return Routes(
      points: [LatLng(double.parse(map['lat']), double.parse(map['lng']))],
      routeId: map['routeId'] as String,
      notes: map['notes'] as String,
    );
  }

  @override
   List<Object?> get props => [routeId, notes];
}

class Notes {
  final int id;
  final int userId;
  final String name;
  final List<List<Routes>> coords;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notes({
    required this.id,
    required this.userId,
    required this.name,
    required this.coords,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notes.fromMap(Map<String, dynamic> map) {
    return Notes(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      coords: (map['coords'] as List)
          .map<List<Routes>>((list) => (list as List).map<Routes>((item) => Routes.fromMap(item)).toList())
          .toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
