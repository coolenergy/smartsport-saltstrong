import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/models/markers.dart';

class LeafletMap extends StatefulWidget {
  const LeafletMap({
    Key? key,
  }) : super(key: key);
  @override
  State<LeafletMap> createState() => _LeafletMapState();
}

class _LeafletMapState extends State<LeafletMap> {
  List<MapMarker> markers = [];
  @override
  void initState() {
    super.initState();
    _loadMarkers().then((value) {
      setState(() {
        markers = value;
      });
    });
  }

  Future<List<MapMarker>> _loadMarkers() async {
    String data = await rootBundle.loadString('assets/response.json');
    List markersJson = json.decode(data)['result'];
    return markersJson.map((m) => MapMarker.fromJson(m)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(51.509364, -0.128928),
          zoom: 5.2,
        ),
        nonRotatedChildren: [],
        children: [
          Opacity(
            opacity: 0.6,
            child: TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
          ),
          // Opacity(
          //   opacity: 0.3,
          //   child: TileLayer(
          //     urlTemplate: 'http://{s}.google.com/vt?lyrs=p&x={x}&y={y}&z={z}',
          //     subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
          //     userAgentPackageName: 'com.example.app',
          //   ),
          // ),
          MarkerLayer(
              markers: markers
                  .where((element) =>
                      element.feedlat != null && (element.feedlng) != null)
                  .map(
                    (e) => Marker(
                      point: LatLng(e.feedlat!, e.feedlng!),
                      width: 80,
                      height: 80,
                      builder: (context) => Icon(Icons.location_on),
                    ),
                  )
                  .toList()),
        ],
      ),
    );
  }
}
