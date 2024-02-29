import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/smart_tides/calendar/calendar.dart';

class CustomTimePickerDialog {
  Future<DateTime?> show(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    final initial = container.read(calendarNotifierProvider).selectedTime;
    final dateTime = (await showDatePicker(
            context: context, initialDate: initial, firstDate: DateTime(2010), lastDate: DateTime(2050))) ??
        initial;

    final hours = (await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial))) ??
        TimeOfDay.fromDateTime(initial);

    final dt = DateTime(dateTime.year, dateTime.month, dateTime.day, hours.hour, hours.minute);
    container.read(calendarNotifierProvider.notifier).setSelectedDate(dt, context);

    return dt;
  }

  const CustomTimePickerDialog();
}
