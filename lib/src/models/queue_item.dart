/// MODEL — the lifecycle of a single file in the open queue.
enum OpenStatus { pending, opening, opened, failed }

/// MODEL — one PDF queued to be handed to the target app.
///
/// Pure data. Only [status] is mutable, and only the controller mutates it.
class QueueItem {
  final String path;
  final String name;
  OpenStatus status;

  QueueItem({
    required this.path,
    required this.name,
    this.status = OpenStatus.pending,
  });
}
