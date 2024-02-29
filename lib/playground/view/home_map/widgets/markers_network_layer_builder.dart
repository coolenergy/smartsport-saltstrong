import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/gen/assets.gen.dart';
import 'package:salt_strong_poc/playground/modelsV2/marker_popup_data.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/artificial_reefs.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/boat_ramps.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/insider_spot.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/markers_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/polygons/smart_spot_v2.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';
import 'package:salt_strong_poc/playground/services/markers/markers_service.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/marker_info_provider.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/community_insider_marker_popup.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/generic_data_popup.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_spot_marker_popup.dart';

class MarkerNetworkLayer extends ConsumerStatefulWidget {
  final MarkerType markerType;

  @override
  MarkerNetworkLayerState createState() => MarkerNetworkLayerState();

  const MarkerNetworkLayer({
    super.key,
    required this.markerType,
  });
}

class MarkerNetworkLayerState extends ConsumerState<MarkerNetworkLayer> {
  Color get clusterColor {
    Color color = Colors.red;
    switch (widget.markerType) {
      case MarkerType.tideStation:
        color = Colors.lightGreenAccent;
        break;
      case MarkerType.insiderSpots:
        color = const Color(0xffFFDF3A);
        break;
      case MarkerType.artificialReefs:
        color = Colors.red;
        break;

      case MarkerType.markers:
        color = const Color(0xffFF005C);
        break;
      case MarkerType.boatRamps:
        color = Colors.red;
        break;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    // this is a workaround to prevent markers rebuilding on move
    if (widget.markerType == MarkerType.markers) {
      return FutureBuilder(
          future: ref.read(markerLoaderProvider(widget.markerType).future),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox();
            }
            final marker = buildMarkers(snapshot.data!, widget.markerType, context);

            return buildMarkerClusterLayerWidget(marker);
          });
    }

    return ref.watch(markerLoaderProvider(widget.markerType)).when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          skipError: true,
          data: (markers) {
            final marker = buildMarkers(markers, widget.markerType, context);

            return buildMarkerClusterLayerWidget(marker);
          },
          loading: () => const SizedBox(),
          error: (Object error, StackTrace stackTrace) {
            debugPrint('Error loading ${widget.markerType}: $stackTrace');
            debugPrint(error.toString());
            // logger.info("Error loading ${widget.markerType}: $stackTrace");
            return const SizedBox();
          },
        );
  }

  MarkerClusterLayerWidget buildMarkerClusterLayerWidget(List<Marker> marker) {
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        disableClusteringAtZoom: 10,
        zoomToBoundsOnClick: false,
        centerMarkerOnClick: false,
        maxClusterRadius: 45,
        size: const Size(40, 40),
        onMarkerTap: (marker) async {
          final data = (marker.key as ValueKey).value;
          String? feedid;
          if (widget.markerType == MarkerType.markers) {
            final markerData = data as MapMarkerEntityV2;
            feedid = markerData.feedid?.toString();
          }
          if (widget.markerType == MarkerType.insiderSpots) {
            final markerData = data as InsiderSpot;
            feedid = markerData.feedId?.toString();
          }
          if (widget.markerType == MarkerType.boatRamps) {
            final markerData = data as BoatRamp;
            return GenericDataPopup(markerData.name, markerData.properties).show(context);
          }
          if (widget.markerType == MarkerType.artificialReefs) {
            final markerData = data as ArtificialReef;
            return GenericDataPopup(markerData.name, markerData.metadata).show(context);
          }
          if (feedid != null) {
            final popupData = await ref.read(markerInfoProvider(feedid).future);
            return CommunityInsiderSpotMarkerPopup(popupData).show(context);
          }
        },
        fitBoundsOptions: const FitBoundsOptions(
          padding: EdgeInsets.all(50),
          maxZoom: 15,
        ),
        markers: marker,
        builder: (context, markers) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: clusterColor),
            child: Center(
              child: Text(
                markers.length.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Marker> buildMarkers(List<SaltStrongMarker> markers, MarkerType type, BuildContext context) {
    return markers.map((spot) {
      if (type == MarkerType.tideStation) {
        return Marker(
          key: ValueKey(spot),
          width: 40,
          point: spot.point,
          builder: (ctx) {
            return Assets.icons.tideStationIcon.svg();
            // return Assets.icons.tideStationMarker.svg();
          },
        );
      }
      if (type == MarkerType.artificialReefs) {
        return Marker(
          width: 10,
          key: ValueKey(spot),
          point: spot.point,
          builder: (ctx) {
            return Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: clusterColor,
                shape: BoxShape.circle,
                //black border
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
              ),
            );
          },
        );
      }
      if (type == MarkerType.insiderSpots) {
        final insiderSpot = spot as InsiderSpot;
        return Marker(
          width: 40,
          key: ValueKey(spot),
          point: insiderSpot.point,
          builder: (ctx) {
            return Icon(
              Icons.location_on,
              color: insiderSpot.colorValue,
            );
          },
        );
      }

      if (type == MarkerType.boatRamps) {
        return Marker(
          width: 40,
          key: ValueKey(spot),
          point: spot.point,
          builder: (ctx) {
            return Assets.icons.boatRampIcon.svg(
                // color: clusterColor,
                );
          },
        );
      }

      return Marker(
        width: 30,
        key: ValueKey(spot),
        point: spot.point,
        builder: (ctx) {
          return Icon(
            Icons.location_on,
            color: clusterColor,
          );
        },
      );
    }).toList();
  }
}
