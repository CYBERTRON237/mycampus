import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final Function(String)? onActionSelected;

  const QuickActions({
    super.key,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final actions = [
      {
        'title': 'Nouveau cours',
        'icon': Icons.add_circle_outline,
        'color': Colors.blue,
        'role': 'admin',
      },
      {
        'title': 'Nouveau devoir',
        'icon': Icons.assignment,
        'color': Colors.green,
        'role': 'teacher',
      },
      {
        'title': 'Annonce',
        'icon': Icons.announcement,
        'color': Colors.orange,
        'role': 'admin',
      },
      {
        'title': 'Événement',
        'icon': Icons.event,
        'color': Colors.purple,
        'role': 'admin',
      },
      {
        'title': 'Message',
        'icon': Icons.message,
        'color': Colors.teal,
        'role': 'all',
      },
      {
        'title': 'Rapport',
        'icon': Icons.bar_chart,
        'color': Colors.red,
        'role': 'admin',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: actions.map((action) {
                return _buildActionButton(
                  context: context,
                  title: action['title'] as String,
                  icon: action['icon'] as IconData,
                  color: action['color'] as Color,
                  onTap: () {
                    if (onActionSelected != null) {
                      onActionSelected!(action['title'] as String);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}