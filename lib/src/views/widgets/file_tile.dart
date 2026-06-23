import 'package:flutter/material.dart';

import '../../models/queue_item.dart';
import '../theme/app_theme.dart';

/// VIEW — renders one queue row as a Stitch-style card. No logic; calls back on
/// delete. The card's colour, border and status badge reflect [QueueItem.status].
class FileTile extends StatelessWidget {
  const FileTile({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.showHandle,
    required this.showRemove,
  });

  final QueueItem item;
  final int index;
  final VoidCallback onRemove;
  final bool showHandle;
  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFailed = item.status == OpenStatus.failed;
    final isOpening = item.status == OpenStatus.opening;

    Color background = cs.surfaceContainerLowest;
    Color border = cs.outlineVariant.withValues(alpha: 0.5);
    if (isFailed) {
      border = cs.error.withValues(alpha: 0.4);
    } else if (isOpening) {
      background = cs.primary.withValues(alpha: 0.06);
      border = cs.primary.withValues(alpha: 0.4);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Left accent strip for the active row.
                if (isOpening) Container(width: 4, color: cs.primary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        _handle(cs),
                        _statusBadge(context),
                        const SizedBox(width: 12),
                        Expanded(child: _text(context)),
                        if (showRemove)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            tooltip: 'Remove',
                            color: cs.onSurfaceVariant,
                            visualDensity: VisualDensity.compact,
                            onPressed: onRemove,
                          )
                        else
                          const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _handle(ColorScheme cs) {
    if (!showHandle) return const SizedBox(width: 4);
    return ReorderableDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(
          Icons.drag_indicator,
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color background;
    final Widget child;
    switch (item.status) {
      case OpenStatus.opened:
        background = AppColors.success.withValues(alpha: 0.12);
        child = const Icon(Icons.check, size: 20, color: AppColors.success);
      case OpenStatus.failed:
        background = cs.errorContainer;
        child = Icon(Icons.error_outline, size: 20, color: cs.onErrorContainer);
      case OpenStatus.opening:
        background = cs.primaryContainer;
        child = SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimaryContainer),
          ),
        );
      case OpenStatus.pending:
        background = cs.surfaceContainerHighest;
        child = Text(
          '${index + 1}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        );
    }
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: child,
    );
  }

  Widget _text(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final Color nameColor;
    switch (item.status) {
      case OpenStatus.failed:
        nameColor = cs.error;
      case OpenStatus.pending:
        nameColor = cs.onSurfaceVariant;
      case OpenStatus.opened:
      case OpenStatus.opening:
        nameColor = cs.onSurface;
    }

    final (String subtitle, Color subtitleColor) = switch (item.status) {
      OpenStatus.opened => ('Opened', cs.onSurfaceVariant),
      OpenStatus.opening => ('Opening…', cs.primary),
      OpenStatus.failed => (
          'Failed to open – retry?',
          cs.error.withValues(alpha: 0.9),
        ),
      OpenStatus.pending => ('Pending', cs.onSurfaceVariant),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.bodyMedium?.copyWith(
            color: nameColor,
            fontWeight: item.status == OpenStatus.opening
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.labelSmall?.copyWith(color: subtitleColor),
        ),
      ],
    );
  }
}
