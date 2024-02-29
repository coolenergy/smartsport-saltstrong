import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get formattedDateTime => DateFormat('MM/dd/yyyy HH:mm').format(this);
  String get formattedDate => DateFormat('MM/dd/yyyy').format(this);
  String get formattedTime => DateFormat.jm().format(this);

  TimeOfDay get timeOfDay => TimeOfDay.fromDateTime(this);
  DateTime get date => DateTime(year, month, day);
  DateTime get date23_59 => DateTime(year, month, day, 23, 59);

  DateTime get asMonth => DateTime(year, month);
  DateTime get nextMonth => DateTime(year, month + 1);

  DateTime get previousMonth => DateTime(year, month - 1);
  DateTime get firstDayOfMonth => DateTime(year, month, 1);
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  bool isSameDay(DateTime other) => date == other.date;
}

extension DateStringExt on String {
  DateTime toDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(this);
  }
}
