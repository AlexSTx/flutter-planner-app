import 'package:flutter/material.dart';

class MiscHelper {
  static String? formatTime({TimeOfDay? tod, DateTime? dt}) {
    if (dt != null) tod = TimeOfDay(hour: dt.hour, minute: dt.minute);

    if (tod != null) {
      return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
    }

    return null;
  }
}
