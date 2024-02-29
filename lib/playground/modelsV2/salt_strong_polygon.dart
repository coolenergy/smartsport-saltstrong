import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class SaltStrongPolygon extends Equatable {
  final List<LatLng> points;

  SaltStrongPolygon({required this.points});

  @override
  String toString() {
    return 'SaltStrongPolygon{ $props}';
  }
}
