import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/opener_state.dart';
import '../models/queue_item.dart';
import '../models/target_app.dart';
import '../services/native_bridge.dart';
import '../services/prefs_service.dart';

/// CONTROLLER — owns [OpenerState] and is the single home of business logic.
///
/// Views observe this (it is a [ChangeNotifier]) and call its methods; they
/// never touch the services directly. The auto-advance decision lives here,
/// not in the view's lifecycle callback.
class OpenerController extends ChangeNotifier {
  OpenerController({NativeBridge? native, PrefsService? prefs})
    : _native = native ?? NativeBridge(),
      _prefs = prefs ?? PrefsService();

  final NativeBridge _native;
  final PrefsService _prefs;

  final OpenerState _state = OpenerState();
  OpenerState get state => _state;

  /// Surfaces transient error messages to the view (e.g. for a SnackBar).
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  /// True after we launched an external app and are waiting to come back.
  /// Set BEFORE awaiting the native launch so it is reliably true before the
  /// platform delivers the `paused` lifecycle event (avoids an ordering race).
  bool _awaitingReturn = false;

  /// True once we have actually been backgrounded since the last launch.
  /// Prevents a stray `resumed` from auto-firing before the user really left.
  bool _leftApp = false;

  /// Re-entrancy guard: only one launch may be in flight at a time. Protects
  /// against double-taps on Start/Open Next and the auto-fail cascade.
  bool _opening = false;

  // ---- Initialization -------------------------------------------------------

  Future<void> init() async {
    _state.targetApp = await _prefs.loadTargetApp();
    _state.handoffMode = await _prefs.loadHandoff();
    _state.advanceMode = await _prefs.loadAdvance();
    notifyListeners();
  }

  // ---- Queue management -----------------------------------------------------

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
      withData: false,
    );
    if (result == null) return; // user cancelled
    for (final f in result.files) {
      final path = f.path;
      if (path == null) continue;
      if (_state.queue.any((q) => q.path == path)) continue; // de-dupe
      _state.queue.add(QueueItem(path: path, name: f.name));
    }
    _resetRun();
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _state.queue.length) return;
    _state.queue.removeAt(index);
    _resetRun();
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _state.queue.removeAt(oldIndex);
    _state.queue.insert(newIndex, item);
    _resetRun();
    notifyListeners();
  }

  void clearQueue() {
    _state.queue.clear();
    _resetRun();
    notifyListeners();
  }

  // ---- Target app & modes ---------------------------------------------------

  /// Fetched by the view to populate the app-picker sheet.
  Future<List<TargetApp>> loadPdfApps() => _native.listPdfApps();

  Future<void> setTargetApp(TargetApp app) async {
    _state.targetApp = app;
    await _prefs.saveTargetApp(app);
    notifyListeners();
  }

  Future<void> setHandoffMode(HandoffMode mode) async {
    _state.handoffMode = mode;
    await _prefs.saveHandoff(mode);
    notifyListeners();
  }

  Future<void> setAdvanceMode(AdvanceMode mode) async {
    _state.advanceMode = mode;
    await _prefs.saveAdvance(mode);
    notifyListeners();
  }

  // ---- Running the queue ----------------------------------------------------

  Future<void> start() async {
    if (!_state.canStart) return;
    if (_opening) return; // a launch is already in flight
    for (final q in _state.queue) {
      q.status = OpenStatus.pending;
    }
    _state.currentIndex = 0;
    _state.running = true;
    _awaitingReturn = false;
    _leftApp = false;
    notifyListeners();
    await _openCurrent();
  }

  /// Manual "Open Next" action, and the fallback nudge in auto mode.
  Future<void> openNext() async {
    if (!_state.running) return;
    if (_state.currentIndex >= _state.queue.length) return;
    await _openCurrent();
  }

  /// Called by the view when the app is backgrounded.
  void onLeftForeground() {
    if (_state.running && _awaitingReturn) _leftApp = true;
  }

  /// Called by the view when the app returns to the foreground.
  /// The controller — not the view — decides whether to fire the next file.
  void onReturnedToForeground() {
    if (_opening) return; // a launch is in flight; ignore stray resume
    if (!_state.running) return;
    if (!_awaitingReturn || !_leftApp) return;
    _awaitingReturn = false;
    _leftApp = false;
    if (_state.advanceMode == AdvanceMode.auto &&
        _state.currentIndex < _state.queue.length) {
      _openCurrent();
    }
  }

  /// Opens the file at [currentIndex] in the target app. In auto mode, a
  /// failure (we never actually left the app) continues immediately to the
  /// next file via the loop, so a stuck queue never relies on a resume event.
  Future<void> _openCurrent() async {
    if (_opening) return; // re-entrancy guard (double-tap / cascade)
    _opening = true;
    try {
      while (true) {
        if (_state.currentIndex >= _state.queue.length) {
          _awaitingReturn = false;
          notifyListeners();
          return;
        }
        final target = _state.targetApp;
        if (target == null) return;

        final item = _state.queue[_state.currentIndex];
        item.status = OpenStatus.opening;
        // Set BEFORE the await so onLeftForeground sees it regardless of
        // whether `paused` arrives before the native reply.
        _awaitingReturn = true;
        _leftApp = false;
        notifyListeners();

        bool ok;
        try {
          ok = await _native.openInApp(
            filePath: item.path,
            packageName: target.packageName,
            mode: _state.handoffMode.name, // 'open' | 'share'
          );
        } catch (_) {
          ok = false;
        }

        if (ok) {
          item.status = OpenStatus.opened;
          _state.currentIndex++;
          // We left the app; keep _awaitingReturn true and wait for return.
          notifyListeners();
          return;
        }

        // Failure: we never left, so no resume event will arrive.
        item.status = OpenStatus.failed;
        _state.currentIndex++;
        _awaitingReturn = false;
        _leftApp = false;
        errorMessage.value = 'Couldn\'t open "${item.name}" in ${target.label}.';
        notifyListeners();

        if (_state.advanceMode == AdvanceMode.auto &&
            _state.currentIndex < _state.queue.length) {
          continue; // try the next file immediately
        }
        return; // manual mode: wait for the user to tap "Open Next"
      }
    } finally {
      _opening = false;
    }
  }

  // ---- Internal -------------------------------------------------------------

  void _resetRun() {
    _state.running = false;
    _state.currentIndex = 0;
    _awaitingReturn = false;
    _leftApp = false;
    for (final q in _state.queue) {
      q.status = OpenStatus.pending;
    }
  }

  @override
  void dispose() {
    errorMessage.dispose();
    super.dispose();
  }
}
