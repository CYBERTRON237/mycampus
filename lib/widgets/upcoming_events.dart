import 'package:flutter/material.dart';
import '../models/event_model.dart';

class UpcomingEvents extends StatelessWidget {
  final List<dynamic> events;

  const UpcomingEvents({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                  'Événements à venir',
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Naviguer vers le calendrier
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                  ),
                  child: const Text('Tout voir'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: theme.hintColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aucun événement à venir',
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
                itemCount: events.length > 3 ? 3 : events.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final event = EventModel.fromJson(events[index]);
                  return _buildEventItem(context, event);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, EventModel event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = _getEventIcon(event.type);
    final color = _getEventColor(event.type, colorScheme);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
        event.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.formattedDate,
            style: theme.textTheme.bodySmall,
          ),
          if (event.location != null)
            Text(
              event.location!,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      onTap: () {
        // Afficher les détails de l'événement
      },
    );
  }

  IconData _getEventIcon(String type) {
    return switch (type) {
      'class' => Icons.school,
      'exam' => Icons.quiz,
      'holiday' => Icons.beach_access,
      'meeting' => Icons.people,
      'deadline' => Icons.assignment_late,
      _ => Icons.event,
    };
  }

  Color _getEventColor(String type, ColorScheme colorScheme) {
    return switch (type) {
      'class' => colorScheme.primary,
      'exam' => colorScheme.error,
      'holiday' => Colors.green,
      'meeting' => Colors.purple,
      'deadline' => Colors.orange,
      _ => colorScheme.onSurfaceVariant,
    };
  }
}