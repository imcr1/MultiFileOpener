import 'package:flutter/material.dart';

import '../../models/target_app.dart';

/// VIEW — bottom sheet listing PDF-capable apps (Stitch "Choose target app"
/// design). Returns the chosen [TargetApp] via `Navigator.pop`. Holds no
/// business logic; it just renders the future supplied by the controller.
class AppPickerSheet extends StatelessWidget {
  const AppPickerSheet({super.key, required this.loader});

  /// Supplied by the controller (`controller.loadPdfApps`).
  final Future<List<TargetApp>> Function() loader;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Text(
              'Choose target app',
              style: text.titleLarge?.copyWith(color: cs.onSurface),
            ),
          ),
          Flexible(
            child: FutureBuilder<List<TargetApp>>(
              future: loader(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Failed to load apps: ${snapshot.error}'),
                  );
                }
                final apps = snapshot.data ?? <TargetApp>[];
                if (apps.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No apps found that can open PDFs.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                  itemCount: apps.length,
                  itemBuilder: (context, i) => _AppRow(
                    app: apps[i],
                    onTap: () => Navigator.of(context).pop(apps[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app, required this.onTap});

  final TargetApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.2),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: app.icon != null
                  ? Image.memory(app.icon!, width: 48, height: 48, fit: BoxFit.cover)
                  : Icon(Icons.picture_as_pdf, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                app.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(color: cs.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
