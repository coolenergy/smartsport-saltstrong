import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/helpers/keep_alive_provider.dart';
import 'package:salt_strong_poc/playground/modelsV2/markers/marker_info.dart';
import 'package:salt_strong_poc/playground/services/markers/requests.dart';

import '../../../services/http/http_service.dart';
import 'layer_controller.dart';

final markerInfoProvider = FutureProvider.autoDispose.family<MarkerInfo, String>((ref, id) async {
  keepAlive(ref);
  final type = "MarkerInfo";
  ref.onDispose(() {
    final value = ref.read(loadingMapProvider.notifier);
    value.remove(type);
  });
  ref.onCancel(() {
    final value = ref.read(loadingMapProvider.notifier);
    value.remove(type);
  });
  ref.listenSelf((previous, next) {
    Future(() {
      final value = ref.read(loadingMapProvider.notifier);
      value.update(type, next);
    });
  });
  final dioService = ref.read(httpServiceProvider);

  final responseMarkers = await dioService.request(
    GetMarkerInfoRequest(feedid: id),
    converter: (response) {
      return (response["result"] as List).map((e) {
        return MarkerInfo.fromMap(e);
      }).toList();
    },
  );
  return responseMarkers.first;
});
