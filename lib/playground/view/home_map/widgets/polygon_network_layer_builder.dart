import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/models/map_position.dart';
import 'package:salt_strong_poc/playground/models/smart_spot.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/smart_spot_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_polygon.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/customized_providers.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_spot_marker_popup.dart';

import '../../../services/polygons/polygon_service.dart';

class PolygonNetworkLayer extends ConsumerStatefulWidget {
  final PolygonType polygonType;

  const PolygonNetworkLayer({Key? key, required this.polygonType}) : super(key: key);

  @override
  PolygonNetworkLayerState createState() => PolygonNetworkLayerState();
}

class PolygonNetworkLayerState extends ConsumerState<PolygonNetworkLayer> {
  @override
  Widget build(BuildContext context) {
    final time = ref.watch(selectedDateTimeProvider);

    // we arent handling any polygon on taps here because we are doing it in [SaltMapLayerController]
    return ref.watch(polygonLoaderProvider(widget.polygonType)).when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: true,
          skipError: true,
          data: (polygons) {
            final polys = buildPolygons(polygons, widget.polygonType);
            return Stack(
              key: ValueKey(polygons.toString() + time.toString()),
              children: [
                RebuildTicker(child: PolygonLayer(polygonCulling: true, polygons: polys)),

              ],
            );
          },
          loading: () => const SizedBox(),
          error: (Object error, StackTrace stackTrace) {
            debugPrintStack(stackTrace: stackTrace, label: "Error loading ${widget.polygonType} : ${error}");
            return const SizedBox();
          },
        );
  }

  List<Polygon> buildPolygons(List<SaltStrongPolygon> polygons, PolygonType type) {
    Color color = Colors.red;
    switch (type) {
      case PolygonType.smartSpots:
        color = Colors.pink;
        break;
      case PolygonType.seaGrass:
        color = Colors.green;
        break;
      case PolygonType.oysterBeds:
        color = Colors.white;
        break;
    }

    if (polygons is List<SmartSpotV5>) {
      // print("---");
      // print("showing polygons for ${polygons.first.targetDateStr}");
      // print("---");
      return polygons.map((e) {
        return Polygon(
          isFilled: true,
          points: e.points,
          color: e.colorValue.withOpacity(0.5),
          borderStrokeWidth: 2,
          borderColor: e.colorValue,
        );
      }).toList();
    }

    return polygons.map((e) {
      return Polygon(
        points: e.points,
        color: color,
        borderStrokeWidth: 2,
        borderColor: color,
      );
    }).toList();
  }
}

// Rebuild ticker is used to rebuild the polygon layer every 8ms,
// this was done in order to fix the layer lagging behind when dragging
class RebuildTicker extends ConsumerStatefulWidget {
  final Widget child;

  @override
  ConsumerState<RebuildTicker> createState() => _RebuildTickerState();

  const RebuildTicker({
    super.key,
    required this.child,
  });
}

class _RebuildTickerState extends ConsumerState<RebuildTicker> {
  late Timer timer;
  late MapPos lastPosition;
  @override
  void initState() {
    lastPosition = ref.read(realtimeSyncMapPosProvider);
    timer = Timer.periodic(const Duration(milliseconds: 8), (timer) {
      final current = ref.read(realtimeSyncMapPosProvider);
      if (current == lastPosition) return;
      setState(() {
        lastPosition = current;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(DateTime.now()),
      child: widget.child,
    );
  }
}
