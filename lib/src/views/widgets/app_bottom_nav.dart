import 'package:flutter/material.dart';

/// VIEW — the bottom navigation bar from the Stitch design.
///
/// Four destinations (Queue · Recent · Starred · Settings). The selected
/// destination shows the Material-3 `secondary-container` pill behind its icon.
/// Pure presentation: it reports taps via [onSelect]; the hosting screen owns
/// the navigation decision. (Recent/Starred are roadmap destinations — the host
/// surfaces a "not available yet" hint.)
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  /// 0 = Queue, 1 = Recent, 2 = Starred, 3 = Settings.
  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const List<({IconData icon, IconData selectedIcon, String label})>
      _destinations = <({IconData icon, IconData selectedIcon, String label})>[
    (icon: Icons.format_list_numbered, selectedIcon: Icons.format_list_numbered, label: 'Queue'),
    (icon: Icons.history, selectedIcon: Icons.history, label: 'Recent'),
    (icon: Icons.star_border, selectedIcon: Icons.star, label: 'Starred'),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              for (int i = 0; i < _destinations.length; i++)
                _NavItem(
                  icon: _destinations[i].icon,
                  selectedIcon: _destinations[i].selectedIcon,
                  label: _destinations[i].label,
                  selected: i == currentIndex,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    // The selected destination is a single pill enclosing BOTH icon and label
    // (Stitch design), not just the icon.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(selected ? selectedIcon : icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
