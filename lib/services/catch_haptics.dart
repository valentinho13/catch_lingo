import 'package:flutter/services.dart';

class CatchHaptics {
  const CatchHaptics._();

  static const _channel = MethodChannel('catch_lingo/haptics');

  static Future<void> grip() => _invoke('catchGrip', fallback: _fallbackGrip);

  static Future<void> land() => _invoke('catchLand', fallback: _fallbackLand);

  static Future<void> soft() =>
      _invoke('softTick', fallback: HapticFeedback.lightImpact);

  static Future<void> _invoke(
    String method, {
    required Future<void> Function() fallback,
  }) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      await fallback();
    } on PlatformException {
      await fallback();
    }
  }

  static Future<void> _fallbackGrip() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 46));
    await HapticFeedback.mediumImpact();
  }

  static Future<void> _fallbackLand() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 34));
    await HapticFeedback.lightImpact();
  }
}
