import 'package:latlong2/latlong.dart';

extension LatLngExt on LatLng {
  double distanceTo(LatLng other) {
    return const Distance().as(LengthUnit.Mile, this, other);
  }
}
