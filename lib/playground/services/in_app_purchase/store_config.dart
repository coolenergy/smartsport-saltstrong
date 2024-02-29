import 'package:purchases_flutter/purchases_flutter.dart';

class StoreConfig {
  final Store store;
  final String apiKey;
  static late StoreConfig instance;

  factory StoreConfig({required Store store, required String apiKey}) {
    instance = StoreConfig._internal(store, apiKey);
    return instance;
  }

  StoreConfig._internal(this.store, this.apiKey);

  static bool isForAppleStore() => instance.store == Store.appStore;

  static bool isForGooglePlay() => instance.store == Store.playStore;
}
