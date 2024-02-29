import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/view/home_map/map.dart';

class MapPos extends Equatable {
  final double x;
  final double y;
  final double z;

  const MapPos({
    required this.x,
    required this.y,
    required this.z,
  });

  LatLng get latLng => LatLng(x, y);

  double get zoom => z;

  double get lat => x;

  double get lng => y;

  int get zoomBasedHaversineDist {
    final currentZoomPercent = z / mapMaxZoom;
    var zoomBasedHaversineDist =
        (haversineDistance - (haversineDistance * currentZoomPercent) * zoomBasedHaverFactor).round();

    return zoomBasedHaversineDist.constrain(5, 30).toInt();
  }

  @override
  List<Object?> get props => [
        x,
        y,
        z,
      ];
}

extension on num {
  num constrain(double min, double max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

const zoomBasedHaverFactor = 1.1;
const haversineDistance = 100;
