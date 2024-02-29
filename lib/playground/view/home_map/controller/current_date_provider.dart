import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';
import 'package:salt_strong_poc/playground/view/home_map/controller/customized_providers.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/calendar/calendar.dart';

// Used to refetch data when date changes, but not when time changes
final currentDeviceDateProvider = Provider.autoDispose<DateTime>((ref) {
  ref.keepAlive();

  ref.listenSelf((previous, next) {
    Future(() {
      final selectedDate = ref.read(selectedDateProvider);
      if (selectedDate.millisecondsSinceEpoch < next.millisecondsSinceEpoch) {
        final time = ref.read(selectedTimeProvider);
        ref.read(calendarNotifierProvider.notifier).updateSelectedDateTime(next.copyWith(hour: time.hour));
      }
    });
  });
  Timer timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
    ref.state = DateTime.now().date;
  });
  ref.onDispose(() {
    timer.cancel();
  });

  return DateTime.now().date;
});
