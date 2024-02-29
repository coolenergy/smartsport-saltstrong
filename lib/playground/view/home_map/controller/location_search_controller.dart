import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:location/location.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';
import 'package:salt_strong_poc/playground/services/search/location_search_service.dart';

import '../../../services/storage/storage_service.dart';
import '../widgets/salt_strong_snackbar.dart';
import 'layer_controller.dart';

const defaultLocation = SearchLocation(name: 'Tampa Bay', latLng: latlng.LatLng(27.763, -82.544));

class LocationSearchState extends Equatable {
  final String query;
  final List<SearchLocation> results;
  final List<SearchLocation> recents;

  const LocationSearchState({
    required this.query,
    required this.results,
    required this.recents,
  });

  LocationSearchState copyWith({
    String? query,
    List<SearchLocation>? results,
    List<SearchLocation>? recents,
  }) {
    return LocationSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      recents: recents ?? this.recents,
    );
  }

  @override
  List<Object?> get props => [query, results];
}

final locationSearchControllerProvider = AutoDisposeAsyncNotifierProvider<LocationSearchController, LocationSearchState>(
  () => LocationSearchController(),
);

class LocationSearchController extends AutoDisposeAsyncNotifier<LocationSearchState> {
  final MapController searchMapController = MapController();

  Timer? _debounce;

  @override
  FutureOr<LocationSearchState> build() async {
    final recents = await _loadRecentLocations();
    return LocationSearchState(query: "", results: const [], recents: recents);
  }

  void search(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = const AsyncLoading();
      try {
        final results = await ref.read(locationSearchServiceProvider).search(query);
        final locationSearchState = state.value?.copyWith(query: query, results: results) ?? //
            LocationSearchState(query: query, results: results, recents: const []);

        state = AsyncData(locationSearchState);
      } catch (e, s) {
        state = AsyncError(e, s);
      }
    });
  }

  Future<List<SearchLocation>> _loadRecentLocations() async {
    const key = StorageKeys.recentSearchLocationsList;
    // Get existing locations
    final savedLocations = (jsonDecode(
      ref.read(storageServiceProvider).getValue(key) ?? '[]',
    ) as List<dynamic>)
        .map((item) => SearchLocation.fromJson(item))
        .toList();

    return savedLocations;
  }

  Future<void> _saveLocationToStorage(SearchLocation searchLocation) async {
    const key = StorageKeys.recentSearchLocationsList;
    // Get existing locations
    final savedLocations = state.value!.recents;
    // Save em all together
    ref.read(storageServiceProvider).setValue(
          key: key,
          data: jsonEncode([
            ...savedLocations,
            searchLocation.toJson(),
          ]),
        );
  }

  void addRecentSearchLocation(SearchLocation searchLocation) {
    // saving locations to local memory
    _saveLocationToStorage(searchLocation);

    final recents = [...state.value!.recents, searchLocation];
    state = AsyncData(state.value!.copyWith(recents: recents));
  }

  void centerMapOnSearchLocation(SearchLocation location) {
    searchMapController.move(location.latLng, 10.toDouble());
  }

  Future<bool> centerOnUsersLocation({bool firstEnter = false}) async {
    /// is permission granted, ask if not
    Location location = Location();
    //SearchLocation searchLocation;

    bool isServiceEnabled;
    PermissionStatus isPermissionGranted;
    LocationData locationData;

    isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        return true;
      }
    }

    isPermissionGranted = await location.hasPermission();
    if (isPermissionGranted == PermissionStatus.denied) {
      isPermissionGranted = await location.requestPermission();
      if (isPermissionGranted != PermissionStatus.granted) {
        // user didn't grant the permission
        // show snackbar from view
        return false;
      }
    }

    /// get users location
    try {
      locationData = await location.getLocation();
      //  final userLocation = SearchLocation(name: 'Home', latLng: LatLng(locationData!.latitude!, locationData!.longitude!));
      final userLocation = SearchLocation(
        name: 'Home',
        latLng: latlng.LatLng(
            locationData.latitude ?? 27.763, // if null, set defaultLocation
            locationData.longitude ?? -82.544),
        shortName: '',
      );

      // write users location to searchBar
      ref.read(saltStrongLayerControllerProvider.notifier)
        ..updateSearchLocation(userLocation)

        // center map on users location
        ..centerOnSearchLocation(userLocation);
    } catch (e) {
      debugPrint(e.toString());
    }
    return true;
  }

  void showSnackbarIfLocationPermissionDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Access to device location has been denied. You can change this in device Settings'),
      ),
    );
  }
}
