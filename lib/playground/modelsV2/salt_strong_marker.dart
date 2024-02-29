import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class SaltStrongMarker extends Equatable {
  final LatLng point;

  SaltStrongMarker(this.point);

}
