import 'package:flutter/material.dart';

import '../controllers/opener_controller.dart';
import '../models/target_app.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_picker_sheet.dart';
import 'widgets/handoff_advance_bar.dart';

/// VIEW — the Settings screen (Stitch design): info banner, target-app row,
/// and the handoff / advance segmented controls. Reads state from the
/// [OpenerController] and forwards events; holds no business logic.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  final OpenerController controller;

  Future<void> _pickApp(BuildContext context) async {
    final app = await showModalBottomSheet<TargetApp>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: Breakpoints.maxSheetWidth),
      builder: (_) => AppPickerSheet(loader: controller.loadPdfApps),
    );
    if (app != null) await controller.setTargetApp(app);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final s = controller.state;
          final hPad = Breakpoints.isWide(context) ? 24.0 : 16.0;
          return Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: Breakpoints.maxSettingsWidth),
              child: ListView(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                children: <Widget>[
                  const _InfoBanner(
                    text: 'After each file opens, switch back to this app and '
                        'the next one opens automatically.',
                  ),
                  const SizedBox(height: 24),
                  _TargetSection(
                    app: s.targetApp,
                    onChange: () => _pickApp(context),
                  ),
                  const SizedBox(height: 24),
                  HandoffAdvanceSettings(
                    handoffMode: s.handoffMode,
                    advanceMode: s.advanceMode,
                    onHandoffChanged: controller.setHandoffMode,
                    onAdvanceChanged: controller.setAdvanceMode,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onSelect: (i) {
          if (i == 0) {
            Navigator.of(context).pop();
          } else if (i == 1 || i == 2) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Recent and Starred aren\'t available yet.'),
                ),
              );
          }
        },
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info, color: cs.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetSection extends StatelessWidget {
  const _TargetSection({required this.app, required this.onChange});

  final TargetApp? app;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            'TARGET APP',
            style: text.labelLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: app?.icon != null
                    ? Image.memory(app!.icon!, width: 44, height: 44, fit: BoxFit.cover)
                    : Icon(Icons.picture_as_pdf, color: cs.onErrorContainer),
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
                      style: text.bodyLarge?.copyWith(color: cs.onSurface),
                    ),
                    Text(
                      app == null ? 'Tap to choose' : 'Current default',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: onChange,
                child: const Text('Change app'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
