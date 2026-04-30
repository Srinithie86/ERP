import 'package:flutter/material.dart';

class AppDateUtils {
  static String formatShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }

  static String formatTime(DateTime date) {
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final hour = date.hour > 12 ? date.hour - 12
               : (date.hour == 0 ? 12 : date.hour);
    final min = date.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  static String formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final diff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Today, ${formatShort(date)}';
    if (diff == -1) return 'Yesterday, ${formatShort(date)}';
    if (diff == 1) return 'Tomorrow, ${formatShort(date)}';
    return '${date.day}/${date.month}/${date.year}';
  }
}
