import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:salt_strong_poc/gen/assets.gen.dart';
import 'package:salt_strong_poc/playground/modelsV2/layer_option.dart';
import 'package:salt_strong_poc/playground/modelsV2/layer_wrapper.dart';
import 'package:salt_strong_poc/playground/services/markers/markers_service.dart';
import 'package:salt_strong_poc/playground/services/polygons/polygon_service.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/markers_network_layer_builder.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/polygon_network_layer_builder.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/search_popup.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/tile_layer_providers/custom_providers.dart';
import 'package:http/http.dart' as http;

List<LayerWrapper> get saltStrongLayers => [
      LayerWrapper(
          icon: Image.asset(
            "assets/images/satellite.png",
          ),
          name: "Satellite",
          isToggleable: false,
          opacity: 1,
          layerGroup: LayerGroup.mapLayers,
          layerType: LayerType.tile,
          selectedOptionIndex: 0,
          options: [
            LayerOption(
              title: "Normal",
              layer: TileLayer(
                retinaMode: true,
                urlTemplate: 'https://{s}.google.com/vt?lyrs=s,h&x={x}&y={y}&z={z}',
                subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                userAgentPackageName: 'com.example.app',
                errorTileCallback: (tile, error, stackTrace) {
                  print(error);
                  print(stackTrace);
                },
              ),
            ),
            LayerOption(
              title: "High Res",
              layer: TileLayer(
                // retinaMode: true,
                tileProvider: HiResNetworkTileProvider(),
              ),
            ),
            LayerOption(
              title: "Bing Sat",
              layer: true
                  ? TileLayer(
                      maxZoom: 21,
                      tileProvider: BingNetworkTileProvider(),
                    )
                  : FutureBuilder(
                      future: http.get(Uri.parse(
                          'http://dev.virtualearth.net/REST/V1/Imagery/Metadata/RoadOnDemand?output=json&include=ImageryProviders&key=[YOUR_API_KEY]')),
                      builder: (context, response) {
                        if (response.connectionState == ConnectionState.waiting) {
                          return SizedBox();
                        }

                        return TileLayer(
                          maxZoom: 21,
                          urlTemplate: jsonDecode(response.data!.body)['resourceSets'][0]
                              ['resources'][0]['imageUrl'],
                          tileProvider: BingTileProvider(),
                        );
                      }),
            )
          ]),
      LayerWrapper(
        layerGroup: LayerGroup.mapLayers,
        layerType: LayerType.tile,
        name: "Shaded Relief",
        alwaysShowBaseLayer: true,
        icon: Assets.images.shadedRelief.image(),
        // layer: TileLayer(
        //   urlTemplate:
        //       'https://tiles.saltstrong.com/ts_hillshade.php?x={x}&ack2=96f0320663721148b75f0488d713fde5b08&y={y}&z={z}&pixelType=F32&ack1=cd4d2e73865e2db4d88a931f5fa67',
        // ),
        options: [
          LayerOption(
            title: "Normal",
            layer: TileLayer(
              retinaMode: true,
              urlTemplate:
                  'https://tiles.saltstrong.com/ts_hillshade.php?x={x}&ack2=96f0320663721148b75f0488d713fde5b08&y={y}&z={z}&pixelType=F32&ack1=cd4d2e73865e2db4d88a931f5fa67',
              userAgentPackageName: 'com.example.app',
            ),
          ),
          LayerOption(
            title: "Sonar",
            layer: TileLayer(
              retinaMode: true,
              urlTemplate:
                  'https://tiles.saltstrong.com/ts_hillshade.php?x={x}&ack2=96f0320663721148b75f0488d713fde5b08&y={y}&z={z}&pixelType=S32&ack1=cd4d2e73865e2db4d88a931f5fa67',
              userAgentPackageName: 'com.example.app',
            ),
          ),
          LayerOption(
            title: "High Res",
            layer: TileLayer(
              retinaMode: true,
              backgroundColor: Colors.transparent,
              urlTemplate:
                  'https://tiles.saltstrong.com/ts_hires.php?x={x}&ack2=96f0320663721148b75f0488d713fde5b08&y={y}&z={z}&ack1=cd4d2e73865e2db4d88a931f5fa67',
              userAgentPackageName: 'com.example.app',
            ),
          )
        ],
      ),
      LayerWrapper(
        name: "Marine Chart",
        icon: Assets.images.marineChart.image(),
        layerGroup: LayerGroup.mapLayers,
        layerType: LayerType.tile,
        layer: TileLayer(
            backgroundColor: Colors.transparent, tileProvider: MarineChartNetworkTileProvider()),
      ),
      // LayerWrapper(
      //   name: "Chlorophyll",
      //   icon: Assets.images.chlorophyll.image(),
      //   layerGroup: LayerGroup.mapLayers,
      //   layerType: LayerType.tile,
      //   layer: Consumer(builder: (context, ref, c) {
      //     final formatted = (ref.watch(selectedDateTimeProvider)).toIso8601String();
      //     return TileLayer(
      //       backgroundColor: Colors.transparent,
      //       wmsOptions: WMSTileLayerOptions(
      //           otherParameters: {
      //             "elevation": "0.0",
      //             "time": formatted,
      //           },
      //           transparent: true,
      //           version: "1.3.0",
      //           format: "image/png",
      //           crs: const Epsg4326(),
      //           layers: ["noaacwN20VIIRSchlaDaily:chlor_a"],
      //           baseUrl: "https://coastwatch.noaa.gov/erddap/wms/noaacwNPPVIIRSchlaSectorUXDaily/request?"),
      //     );
      //   }),
      // ),
      LayerWrapper(
        icon: Assets.icons.smartTides.svg(),
        layerType: LayerType.poly,
        layerGroup: LayerGroup.spotTypes,
        opacity: 1,
        name: "Smart Spots",
        layer: const PolygonNetworkLayer(
          polygonType: PolygonType.smartSpots,
        ),
      ),
      LayerWrapper(
          icon: Assets.icons.seeGrass.svg(),
          layerType: LayerType.poly,
          layerGroup: LayerGroup.elements,
          name: "Sea Grass",
          layer: const PolygonNetworkLayer(
            polygonType: PolygonType.seaGrass,
          )),

      LayerWrapper(
        name: "Oyster Beds",
        layerGroup: LayerGroup.elements,
        icon: Assets.icons.oysterBeds.svg(),
        layerType: LayerType.poly,
        layer: const PolygonNetworkLayer(
          polygonType: PolygonType.oysterBeds,
        ),
      ),
      LayerWrapper(
        name: "Boat Ramps",
        layerType: LayerType.marker,
        layerGroup: LayerGroup.elements,
        icon: Assets.icons.boatRamps.svg(),
        layer: const MarkerNetworkLayer(
          markerType: MarkerType.boatRamps,
        ),
      ),
      LayerWrapper(
        name: "Artificial Reefs",
        layerType: LayerType.marker,
        layerGroup: LayerGroup.elements,
        icon: Assets.icons.artificialReefs.svg(),
        layer: const MarkerNetworkLayer(
          markerType: MarkerType.artificialReefs,
        ),
      ),
      LayerWrapper(
          icon: Assets.icons.tideStations.svg(),
          layerType: LayerType.poly,
          layerGroup: LayerGroup.elements,
          name: "Tide Stations",
          layer: const MarkerNetworkLayer(
            markerType: MarkerType.tideStation,
          )),

      if (false)
        LayerWrapper(
          layerGroup: LayerGroup.spotTypes,
          layerType: LayerType.marker,
          name: "Insider Spots",
          icon: Assets.icons.insiderSpots.svg(),
          layer: const MarkerNetworkLayer(markerType: MarkerType.insiderSpots),
        ),
      if (false)
        LayerWrapper(
          name: "Community Spots",
          layerType: LayerType.marker,
          icon: Assets.icons.communitySpots.svg(),
          layer: const MarkerNetworkLayer(
            markerType: MarkerType.markers,
          ),
          layerGroup: LayerGroup.spotTypes,
        ),
    ];
