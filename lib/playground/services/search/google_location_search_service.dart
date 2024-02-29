import 'package:collection/collection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' hide LatLng;
import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';
import 'package:salt_strong_poc/playground/services/search/location_search_service.dart';
import 'dart:io' show Platform;

class GoogleLocationSearchService extends LocationSearchService {
  final apiKey = Platform.isAndroid //
      ? dotenv.env['PLACES_API_KEY_ANDROID']
      : dotenv.env['PLACES_API_KEY_IOS'];

  late final FlutterGooglePlacesSdk _places;
  bool initialized = false;
  @override
  Future<void> initialize() async {
    assert(apiKey != null, 'Google api key required');
    if(initialized) return;
    _places = FlutterGooglePlacesSdk(apiKey!);
    await _places.isInitialized();
    initialized = true;
  }

  @override
  Future<List<SearchLocation>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final result = await _places.findAutocompletePredictions(query);

    // filtered list for when we have completed data
    final searchLocations = <SearchLocation>[];
    String? shortName;

    await Future.forEach(result.predictions, (prediction) async {
      final fetchPlaceResponse = await _places.fetchPlace(
        prediction.placeId,
        fields: [PlaceField.AddressComponents, PlaceField.Location],
      );
      final lat = fetchPlaceResponse.place?.latLng?.lat;
      final lng = fetchPlaceResponse.place?.latLng?.lng;

      //-------get shortName, e.g. CA for California
      final addressComponentsList = fetchPlaceResponse.place?.addressComponents;
      shortName = addressComponentsList
          ?.firstWhereOrNull((element) => element.types.contains('administrative_area_level_1'))
          ?.shortName;
      shortName ??= addressComponentsList?.first.shortName ?? '';

      if (lat != null && lng != null) {
        searchLocations.add(SearchLocation(
          name: prediction.primaryText,
          latLng: LatLng(lat, lng),
          shortName: shortName,
        ));
      }
    });

    return searchLocations;
  }
}
