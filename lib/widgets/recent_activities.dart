import 'package:flutter/material.dart';
import '../models/activity_model.dart';

class RecentActivities extends StatelessWidget {
  final List<dynamic> activities;

  const RecentActivities({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activités récentes',
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Naviguer vers la page des activités
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: theme.hintColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune activité récente',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length > 5 ? 5 : activities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = ActivityModel.fromJson(activities[index]);
                  return _buildActivityItem(context, activity);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityModel activity) {
    final theme = Theme.of(context);
    final icon = _getActivityIcon(activity.type);
    final color = _getActivityColor(activity.type, theme);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        activity.description,
        style: theme.textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        activity.timeAgo,
        style: theme.textTheme.bodySmall,
      ),
      onTap: () {
        // Afficher les détails de l'activité
      },
    );
  }

  IconData _getActivityIcon(String type) {
    return switch (type) {
      'assignment' => Icons.assignment,
      'announcement' => Icons.announcement,
      'grade' => Icons.grade,
      'login' => Icons.login,
      'logout' => Icons.logout,
      _ => Icons.notifications,
    };
  }

  Color _getActivityColor(String type, ThemeData theme) {
    return switch (type) {
      'assignment' => theme.colorScheme.primary,
      'announcement' => Colors.green,
      'grade' => Colors.amber,
      'login' => Colors.teal,
      'logout' => Colors.red,
      _ => theme.colorScheme.onSurfaceVariant,
    };
  }
}