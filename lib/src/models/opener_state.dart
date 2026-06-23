import 'queue_item.dart';
import 'target_app.dart';

/// How a file is handed to the target app.
/// - [open]  -> ACTION_VIEW (the app opens the file directly)
/// - [share] -> ACTION_SEND (the file is shared into the app)
enum HandoffMode { open, share }

/// How the queue advances between files.
/// - [auto]   -> the next file fires automatically when the user returns.
/// - [manual] -> the user taps "Open Next" for each file.
enum AdvanceMode { auto, manual }

/// MODEL — the full application state as plain data.
///
/// Holds no business logic beyond derived getters; all mutation and
/// decision-making lives in the controller.
class OpenerState {
  final List<QueueItem> queue;
  TargetApp? targetApp;
  HandoffMode handoffMode;
  AdvanceMode advanceMode;

  /// Index of the next file to open. Equals [total] when the run is done.
  int currentIndex;

  /// Whether a run has been started.
  bool running;

  OpenerState({
    List<QueueItem>? queue,
    this.targetApp,
    this.handoffMode = HandoffMode.open,
    this.advanceMode = AdvanceMode.manual,
    this.currentIndex = 0,
    this.running = false,
  }) : queue = queue ?? <QueueItem>[];

  int get total => queue.length;

  int get openedCount =>
      queue.where((q) => q.status == OpenStatus.opened).length;

  int get failedCount =>
      queue.where((q) => q.status == OpenStatus.failed).length;

  /// True once every file has been attempted (opened or failed).
  bool get isDone => running && currentIndex >= total && total > 0;

  /// True when a run can begin: files queued and a target chosen.
  bool get canStart => total > 0 && targetApp != null;
}
