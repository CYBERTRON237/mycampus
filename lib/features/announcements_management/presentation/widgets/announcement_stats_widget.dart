import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';

class AnnouncementStatsWidget extends StatelessWidget {
  const AnnouncementStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOverviewCards(context, provider),
              const SizedBox(height: 24),
              _buildCategoryChart(context, provider),
              const SizedBox(height: 24),
              _buildPriorityChart(context, provider),
              const SizedBox(height: 24),
              _buildRecentActivity(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(BuildContext context, AnnouncementProvider provider) {
    final stats = provider.statistics;
    
    return Column(
      children: [
        const Text(
          'Vue d\'ensemble',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Annonces',
              '${stats['total_announcements'] ?? 0}',
              Icons.campaign,
              Colors.blue,
            ),
            _buildStatCard(
              'Actives',
              '${stats['active_announcements'] ?? 0}',
              Icons.visibility,
              Colors.green,
            ),
            _buildStatCard(
              'Expirées',
              '${stats['expired_announcements'] ?? 0}',
              Icons.schedule,
              Colors.orange,
            ),
            _buildStatCard(
              'Vues totales',
              '${stats['total_views'] ?? 0}',
              Icons.visibility,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, AnnouncementProvider provider) {
    final stats = provider.statistics;
    final categoryStats = stats['by_category'] as Map<String, dynamic>? ?? {};
    
    return Column(
      children: [
        const Text(
          'Annonces par catégorie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: categoryStats.entries.map((entry) {
              final category = entry.key;
              final count = entry.value as int;
              final total = categoryStats.values.fold<int>(0, (sum, val) => sum + (val as int));
              final percentage = total > 0 ? (count / total * 100) : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getCategoryLabel(category),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text('$count ($percentage.toStringAsFixed(1)%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(category),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChart(BuildContext context, AnnouncementProvider provider) {
    final stats = provider.statistics;
    final priorityStats = stats['by_priority'] as Map<String, dynamic>? ?? {};
    
    return Column(
      children: [
        const Text(
          'Annonces par priorité',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: priorityStats.entries.map((entry) {
              final priority = entry.key;
              final count = entry.value as int;
              final total = priorityStats.values.fold<int>(0, (sum, val) => sum + (val as int));
              final percentage = total > 0 ? (count / total * 100) : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getPriorityIcon(priority),
                              size: 16,
                              color: _getPriorityColor(priority),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getPriorityLabel(priority),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text('$count ($percentage.toStringAsFixed(1)%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPriorityColor(priority),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, AnnouncementProvider provider) {
    final stats = provider.statistics;
    final recentActivity = stats['recent_activity'] as List<dynamic>? ?? [];
    
    return Column(
      children: [
        const Text(
          'Activité récente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: recentActivity.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Aucune activité récente',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ]
                : recentActivity.map((activity) {
                    return ListTile(
                      leading: Icon(
                        _getActivityIcon(activity['type']),
                        color: _getActivityColor(activity['type']),
                      ),
                      title: Text(activity['title'] ?? ''),
                      subtitle: Text(activity['description'] ?? ''),
                      trailing: Text(
                        _formatActivityTime(activity['time']),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ),
      ],
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'academic':
        return 'Académique';
      case 'administrative':
        return 'Administrative';
      case 'event':
        return 'Événement';
      case 'urgent':
        return 'Urgent';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'academic':
        return Colors.blue;
      case 'administrative':
        return Colors.purple;
      case 'event':
        return Colors.green;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'Urgente';
      case 'high':
        return 'Haute';
      case 'medium':
        return 'Moyenne';
      case 'low':
        return 'Basse';
      default:
        return priority;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return Icons.priority_high;
      case 'high':
        return Icons.arrow_upward;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.info_outline;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'created':
        return Icons.add_circle;
      case 'updated':
        return Icons.edit;
      case 'deleted':
        return Icons.delete;
      case 'viewed':
        return Icons.visibility;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'created':
        return Colors.green;
      case 'updated':
        return Colors.blue;
      case 'deleted':
        return Colors.red;
      case 'viewed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatActivityTime(String? time) {
    if (time == null) return '';
    
    try {
      final dateTime = DateTime.parse(time);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}j';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}min';
      } else {
        return 'Maintenant';
      }
    } catch (e) {
      return time;
    }
  }
}
