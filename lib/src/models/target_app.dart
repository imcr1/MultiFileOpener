import 'dart:typed_data';

/// MODEL — pure data describing an installed app that can receive PDFs.
///
/// No Flutter imports, no I/O. Produced by the native bridge (from
/// `PackageManager.queryIntentActivities`) or restored from preferences
/// (in which case [icon] is null until the app list is fetched again).
class TargetApp {
  final String label;
  final String packageName;
  final Uint8List? icon; // PNG bytes, may be null when restored from prefs.

  const TargetApp({
    required this.label,
    required this.packageName,
    this.icon,
  });

  /// Builds a [TargetApp] from the map returned over the MethodChannel.
  factory TargetApp.fromMap(Map<dynamic, dynamic> map) {
    final packageName = map['packageName'] as String;
    final rawIcon = map['icon'];
    return TargetApp(
      label: (map['label'] as String?) ?? packageName,
      packageName: packageName,
      icon: rawIcon is Uint8List ? rawIcon : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TargetApp && other.packageName == packageName;

  @override
  int get hashCode => packageName.hashCode;
}
