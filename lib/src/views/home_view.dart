import 'package:flutter/material.dart';

import '../controllers/opener_controller.dart';
import '../models/opener_state.dart';
import '../models/target_app.dart';
import 'settings_view.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_picker_sheet.dart';
import 'widgets/file_tile.dart';

/// VIEW — the homepage (Stitch "Queue" screen).
///
/// Stateful only to (a) own the lifecycle observer and (b) show SnackBars.
/// All app-data decisions are delegated to [OpenerController]; this widget
/// reads state and forwards events.
class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.controller});

  final OpenerController controller;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  OpenerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _c.errorMessage.addListener(_showError);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _c.errorMessage.removeListener(_showError);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _c.onReturnedToForeground();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _c.onLeftForeground();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void _showError() {
    final msg = _c.errorMessage.value;
    if (msg == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
    _c.errorMessage.value = null;
  }

  Future<void> _pickApp() async {
    final app = await showModalBottomSheet<TargetApp>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxSheetWidth),
      builder: (_) => AppPickerSheet(loader: _c.loadPdfApps),
    );
    if (app != null) await _c.setTargetApp(app);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SettingsView(controller: _c)),
    );
  }

  void _onNav(int index) {
    switch (index) {
      case 3:
        _openSettings();
      case 1:
      case 2:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Recent and Starred aren\'t available yet.'),
            ),
          );
      default:
        break; // already on Queue
    }
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MultiFileOpener'),
        content: const Text(
          'MultiFileOpener hands a queue of PDFs to one app you choose, one '
          'after another.\n\n'
          'Android can\'t pull this app back to the foreground after launching '
          'another app, so fully hands-free batch-open isn\'t possible. In Auto '
          'mode, simply switching back to this app opens the next file — that '
          'tap is the only action needed per file.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _drawer(BuildContext context, OpenerState s) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Drawer(
      backgroundColor: cs.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.dynamic_feed, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'MultiFileOpener',
                          style: text.titleMedium?.copyWith(color: cs.onSurface),
                        ),
                        Text(
                          'Batch-open PDFs into one app',
                          style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.add, color: cs.onSurfaceVariant),
              title: const Text('Pick PDFs'),
              onTap: () {
                Navigator.of(context).pop();
                _c.pickFiles();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                _openSettings();
              },
            ),
            ListTile(
              enabled: s.queue.isNotEmpty,
              leading: Icon(Icons.delete_outline, color: cs.onSurfaceVariant),
              title: const Text('Clear queue'),
              onTap: () {
                Navigator.of(context).pop();
                _c.clearQueue();
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.info_outline, color: cs.onSurfaceVariant),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                _showAbout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final s = _c.state;
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.dynamic_feed, size: 18, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'MultiFileOpener',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              if (s.queue.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear queue',
                  color: cs.onSurfaceVariant,
                  onPressed: _c.clearQueue,
                ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                tooltip: 'More options',
                onSelected: (value) {
                  if (value == 'about') {
                    _showAbout();
                  } else if (value == 'settings') {
                    _openSettings();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                  PopupMenuItem<String>(
                    value: 'about',
                    child: Text('About this app'),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          drawer: _drawer(context, s),
          body: _body(context, s),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _actionBar(context, s),
              AppBottomNav(currentIndex: 0, onSelect: _onNav),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, OpenerState s) {
    final isWide = Breakpoints.isWide(context);
    final hPad = isWide ? 24.0 : 16.0;
    final content = Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
          child: _cards(context, s, isWide),
        ),
        if (s.total > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 8),
            child: _queueHeader(context, s),
          ),
        Expanded(
          child: s.queue.isEmpty ? _emptyState(context) : _queueList(s, hPad),
        ),
      ],
    );
    // On tablets/landscape, centre the content within a comfortable max width
    // instead of letting it stretch edge-to-edge.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
        child: content,
      ),
    );
  }

  /// Target + Progress cards: side-by-side on wide screens, stacked on phones.
  Widget _cards(BuildContext context, OpenerState s, bool isWide) {
    if (isWide && s.total > 0) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: _targetCard(context, s)),
            const SizedBox(width: 16),
            Expanded(child: _progressCard(context, s)),
          ],
        ),
      );
    }
    return Column(
      children: <Widget>[
        _targetCard(context, s),
        if (s.total > 0) ...<Widget>[
          const SizedBox(height: 12),
          _progressCard(context, s),
        ],
      ],
    );
  }

  // ---- Target app card ------------------------------------------------------

  Widget _targetCard(BuildContext context, OpenerState s) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final app = s.targetApp;
    return _BentoCard(
      onTap: _pickApp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'TARGET APP',
            style: text.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: app?.icon != null
                    ? Image.memory(app!.icon!, width: 48, height: 48, fit: BoxFit.cover)
                    : Icon(Icons.picture_as_pdf, color: cs.onPrimaryContainer, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      app?.label ?? 'No target app',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app == null ? 'Tap to choose an app' : app.packageName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.edit_outlined, color: cs.onSurfaceVariant, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Progress card --------------------------------------------------------

  Widget _progressCard(BuildContext context, OpenerState s) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final value = s.total == 0 ? 0.0 : s.openedCount / s.total;
    return _BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Queue Progress',
                      style: text.labelLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Opened ${s.openedCount} / ${s.total}',
                      style: text.titleMedium?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (s.isDone)
                    _statusChip(context, Icons.check_circle, 'Done', AppColors.success)
                  else if (s.running)
                    _statusChip(context, Icons.check_circle, 'Active', AppColors.success),
                  if (s.failedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.error, size: 14, color: cs.error),
                          const SizedBox(width: 4),
                          Text(
                            '${s.failedCount} failed',
                            style: text.labelSmall?.copyWith(color: cs.error),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Queue ----------------------------------------------------------------

  Widget _queueHeader(BuildContext context, OpenerState s) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Text(
          'File Queue',
          style: text.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${s.total} item${s.total == 1 ? '' : 's'}',
            style: text.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.picture_as_pdf_outlined, size: 48, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              'No PDFs yet',
              style: text.titleMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Pick PDFs" to add files, then choose an app to open them into.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _queueList(OpenerState s, double hPad) {
    final reorderable = !s.running;
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
      itemCount: s.queue.length,
      onReorder: reorderable ? _c.reorder : (int a, int b) {},
      itemBuilder: (context, i) {
        final item = s.queue[i];
        return FileTile(
          key: ValueKey<String>(item.path),
          item: item,
          index: i,
          showHandle: reorderable,
          showRemove: !s.running,
          onRemove: () => _c.removeAt(i),
        );
      },
    );
  }

  // ---- Bottom action bar ----------------------------------------------------

  Widget _actionBar(BuildContext context, OpenerState s) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      // Centre the row within the same max width as the body content so the
      // buttons stay aligned with the cards above on wide screens.
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
          child: SizedBox(
            width: double.infinity,
            // Right-aligned, intrinsic-width pills (Stitch). Wrap keeps them
            // from overflowing when the primary label grows ("Open Next (10)").
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _c.pickFiles,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Pick PDFs'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.outline),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
                _primaryButton(context, s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton(BuildContext context, OpenerState s) {
    final cs = Theme.of(context).colorScheme;
    final style = FilledButton.styleFrom(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    );

    if (!s.running) {
      return FilledButton.icon(
        style: style,
        icon: const Icon(Icons.play_arrow, size: 20),
        label: const Text('Start'),
        onPressed: s.canStart ? _c.start : null,
      );
    }
    if (s.isDone) {
      return FilledButton.icon(
        style: style,
        icon: const Icon(Icons.replay, size: 20),
        label: const Text('Restart'),
        onPressed: s.canStart ? _c.start : null,
      );
    }
    final remaining = s.total - s.currentIndex;
    return FilledButton.icon(
      style: style,
      icon: const Icon(Icons.skip_next, size: 20),
      label: Text('Open Next ($remaining)'),
      onPressed: _c.openNext,
    );
  }
}

/// A Stitch "bento" card: `surface-container-low` fill, 12px corners, a faint
/// outline, optional tap.
class _BentoCard extends StatelessWidget {
  const _BentoCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: child,
        ),
      ),
    );
  }
}
