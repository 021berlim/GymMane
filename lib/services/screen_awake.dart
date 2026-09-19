import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenAwake {
  ScreenAwake._();

  static const _channel = MethodChannel('gymmane/screen');
  static bool? _last;

  static Future<void> keepOn(bool on) async {
    if (kIsWeb || _last == on) return;
    _last = on;
    try {
      await _channel.invokeMethod<void>('keepOn', {'on': on});
    } catch (e) {
      _last = null;
      debugPrint('ScreenAwake no disponible: $e');
    }
  }
}
