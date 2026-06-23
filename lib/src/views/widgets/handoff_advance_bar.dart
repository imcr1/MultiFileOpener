import 'package:flutter/material.dart';

import '../../models/opener_state.dart';
import 'pill_segmented.dart';

/// VIEW — the "Handoff mode" and "Advance mode" sections of the Settings screen
/// (Stitch design). Pure presentation; calls back on change. All decision logic
/// stays in the controller.
class HandoffAdvanceSettings extends StatelessWidget {
  const HandoffAdvanceSettings({
    super.key,
    required this.handoffMode,
    required this.advanceMode,
    required this.onHandoffChanged,
    required this.onAdvanceChanged,
  });

  final HandoffMode handoffMode;
  final AdvanceMode advanceMode;
  final ValueChanged<HandoffMode> onHandoffChanged;
  final ValueChanged<AdvanceMode> onAdvanceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SettingsSection(
          title: 'HANDOFF MODE',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PillSegmented<HandoffMode>(
                selected: handoffMode,
                onChanged: onHandoffChanged,
                segments: const <PillSegment<HandoffMode>>[
                  PillSegment<HandoffMode>(
                    value: HandoffMode.open,
                    label: 'Open with (Rec.)',
                  ),
                  PillSegment<HandoffMode>(
                    value: HandoffMode.share,
                    label: 'Share',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _Caption(
                icon: Icons.report_outlined,
                text: "Share can't confirm delivery — Open with is more reliable.",
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: 'ADVANCE MODE',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PillSegmented<AdvanceMode>(
                selected: advanceMode,
                onChanged: onAdvanceChanged,
                segments: const <PillSegment<AdvanceMode>>[
                  PillSegment<AdvanceMode>(
                    value: AdvanceMode.auto,
                    label: 'Auto',
                  ),
                  PillSegment<AdvanceMode>(
                    value: AdvanceMode.manual,
                    label: 'Manual',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Auto advances to the next file upon returning. '
                'Manual requires a tap.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A titled card: a `primary` section label above a `surface-container` panel.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: cs.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
