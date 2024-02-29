import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/search/search_location.dart';
import 'package:salt_strong_poc/playground/services/search/location_search_service.dart';

final mockedData = [
  SearchLocation(name: "Tampa Bay", latLng: LatLng(27.9506, -82.4572)),
  SearchLocation(name: "St. Petersburg", latLng: LatLng(27.7676, -82.6403)),
  SearchLocation(name: "Clearwater", latLng: LatLng(27.9659, -82.8001)),
  SearchLocation(name: "Sarasota", latLng: LatLng(27.3364, -82.5307)),
  SearchLocation(name: "Bradenton", latLng: LatLng(27.4989, -82.5748)),
  SearchLocation(name: "Venice", latLng: LatLng(27.0998, -82.4543)),
  SearchLocation(name: "Fort Myers", latLng: LatLng(26.6406, -81.8723)),
  SearchLocation(name: "Naples", latLng: LatLng(26.1420, -81.7948)),
  SearchLocation(name: "Marco Island", latLng: LatLng(25.9393, -81.7074)),
  SearchLocation(name: "Everglades City", latLng: LatLng(25.8594, -81.3840)),
  SearchLocation(name: "Chokoloskee", latLng: LatLng(25.8107, -81.3614)),
  SearchLocation(name: "Flamingo", latLng: LatLng(25.1380, -80.9216)),
  SearchLocation(name: "Islamorada", latLng: LatLng(24.9293, -80.6270)),
];

class MockedLocationSearchService extends LocationSearchService {
  @override
  Future<List<SearchLocation>> search(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    return mockedData.toList();
  }
}
