import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/opener_state.dart';
import '../models/target_app.dart';

/// SERVICE — persists the user's choices between runs.
///
/// Used only by the controller. The target app's icon is persisted (base64)
/// so the remembered app keeps its icon across restarts without re-querying.
class PrefsService {
  static const String _kPkg = 'target_pkg';
  static const String _kLabel = 'target_label';
  static const String _kIcon = 'target_icon';
  static const String _kHandoff = 'handoff_mode';
  static const String _kAdvance = 'advance_mode';

  Future<void> saveTargetApp(TargetApp? app) async {
    final p = await SharedPreferences.getInstance();
    if (app == null) {
      await p.remove(_kPkg);
      await p.remove(_kLabel);
      await p.remove(_kIcon);
    } else {
      await p.setString(_kPkg, app.packageName);
      await p.setString(_kLabel, app.label);
      final icon = app.icon;
      if (icon != null) {
        await p.setString(_kIcon, base64Encode(icon));
      } else {
        await p.remove(_kIcon);
      }
    }
  }

  Future<TargetApp?> loadTargetApp() async {
    final p = await SharedPreferences.getInstance();
    final pkg = p.getString(_kPkg);
    if (pkg == null) return null;
    final iconB64 = p.getString(_kIcon);
    return TargetApp(
      label: p.getString(_kLabel) ?? pkg,
      packageName: pkg,
      icon: iconB64 != null ? base64Decode(iconB64) : null,
    );
  }

  Future<void> saveHandoff(HandoffMode mode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kHandoff, mode.name);
  }

  Future<HandoffMode> loadHandoff() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_kHandoff);
    return HandoffMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => HandoffMode.open,
    );
  }

  Future<void> saveAdvance(AdvanceMode mode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAdvance, mode.name);
  }

  Future<AdvanceMode> loadAdvance() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_kAdvance);
    return AdvanceMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AdvanceMode.manual,
    );
  }
}
