import 'package:flutter/services.dart';

import '../models/target_app.dart';

/// SERVICE — thin wrapper over the Android MethodChannel.
///
/// Used only by the controller. Knows nothing about app state or widgets.
class NativeBridge {
  static const MethodChannel _channel = MethodChannel('multifileopener/native');

  /// Returns the installed apps that can open/receive a PDF, sorted by label.
  Future<List<TargetApp>> listPdfApps() async {
    final result = await _channel.invokeMethod<List<dynamic>>('listPdfApps');
    if (result == null) return <TargetApp>[];
    final apps = result
        .map((e) => TargetApp.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    apps.sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
    return apps;
  }

  /// Hands [filePath] to [packageName].
  ///
  /// [mode] is `'open'` (ACTION_VIEW) or `'share'` (ACTION_SEND).
  /// Returns true if the target app accepted the launch.
  Future<bool> openInApp({
    required String filePath,
    required String packageName,
    required String mode,
  }) async {
    final ok = await _channel.invokeMethod<bool>('openInApp', <String, String>{
      'filePath': filePath,
      'packageName': packageName,
      'mode': mode,
    });
    return ok ?? false;
  }
}
