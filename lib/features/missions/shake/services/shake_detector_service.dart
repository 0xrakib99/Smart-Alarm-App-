import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  ShakeDetectorService({
    required this.onShake,
    this.onError,
    this.onMagnitudeUpdate,
    this.threshold = 13.0,
    this.cooldown = const Duration(milliseconds: 300),
  });

  final VoidCallback onShake;
  final void Function(Object error)? onError;
  final void Function(double magnitude)? onMagnitudeUpdate;
  final double threshold;
  final Duration cooldown;

  StreamSubscription<dynamic>? _subscription;
  DateTime? _lastShakeTime;
  bool _isListening = false;

  bool get isListening => _isListening;

  void start() {
    if (_isListening) return;
    _isListening = true;

    try {
      _subscription = userAccelerometerEventStream().listen(
        (UserAccelerometerEvent event) {
          final magnitude = sqrt(
            (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
          );

          onMagnitudeUpdate?.call(magnitude);

          // Anti-cheat: Accept valid shakes but reject unrealistic sensor spikes (> 50 m/s^2)
          if (magnitude >= threshold && magnitude <= 50.0) {
            final now = DateTime.now();
            if (_lastShakeTime == null ||
                now.difference(_lastShakeTime!) >= cooldown) {
              _lastShakeTime = now;
              onShake();
            }
          }
        },
        onError: (Object error) {
          _isListening = false;
          onError?.call(error);
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isListening = false;
      onError?.call(e);
    }
  }

  void stop() {
    _isListening = false;
    _subscription?.cancel();
    _subscription = null;
  }
}
