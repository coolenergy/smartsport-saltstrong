import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';

import 'google_location_search_service.dart';

final locationSearchServiceProvider = Provider<LocationSearchService>(
  (ref) => GoogleLocationSearchService(),
);

abstract class LocationSearchService {
  Future<void> initialize() async {}

  Future<List<SearchLocation>> search(String query);
}
