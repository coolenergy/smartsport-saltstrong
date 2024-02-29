import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// keeps autodispose providers alive for 10 secs (caches their values)
KeepAliveLink keepAlive(ref, {int seconds = 10}) {
  final link = ref.keepAlive();
  Timer? timer;
  ref.onDispose(() => timer?.cancel());
  ref.onCancel(() => timer = Timer(  Duration(seconds: seconds), () => link.close()));
  ref.onResume(() => timer?.cancel());
  return link;
}
