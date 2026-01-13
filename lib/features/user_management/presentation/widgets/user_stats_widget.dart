import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserStatsWidget extends StatelessWidget {
  final List<UserRoleStats> stats;

  const UserStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total users
        _buildTotalStats(),
        const SizedBox(height: 16),
        
        // Stats by role
        Text(
          'Statistiques par rôle',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        ...stats.map((stat) => _buildRoleStat(context, stat)),
      ],
    );
  }

  Widget _buildTotalStats() {
    final totalUsers = stats.fold<int>(0, (sum, stat) => sum + stat.userCount);
    final totalActive = stats.fold<int>(0, (sum, stat) => sum + stat.activeCount);
    final totalRecent = stats.fold<int>(0, (sum, stat) => sum + stat.recentLoginCount);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    totalUsers.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Actifs',
                    totalActive.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Récents',
                    totalRecent.toString(),
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleStat(BuildContext context, UserRoleStats stat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Role icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRoleColor(stat.roleName).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getRoleIcon(stat.roleName),
                    color: _getRoleColor(stat.roleName),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Role info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.roleDisplayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Niveau ${stat.roleLevel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stat.userCount}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stat.activeCount} actifs',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Progress bar for active users
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Taux d\'activité',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${stat.userCount > 0 ? ((stat.activeCount / stat.userCount) * 100).round() : 0}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stat.userCount > 0 ? stat.activeCount / stat.userCount : 0,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
            
            // Recent login indicator
            if (stat.recentLoginCount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${stat.recentLoginCount} connexion${stat.recentLoginCount > 1 ? 's' : ''} récente${stat.recentLoginCount > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Colors.purple;
      case 'admin_national':
        return Colors.red;
      case 'admin_local':
        return Colors.deepOrange;
      case 'leader':
        return Colors.indigo;
      case 'teacher':
        return Colors.blue;
      case 'staff':
        return Colors.teal;
      case 'moderator':
        return Colors.amber;
      case 'alumni':
        return Colors.brown;
      case 'student':
        return Colors.green;
      case 'guest':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return Icons.security;
      case 'admin_national':
        return Icons.admin_panel_settings;
      case 'admin_local':
        return Icons.location_city;
      case 'leader':
        return Icons.group;
      case 'teacher':
        return Icons.school;
      case 'staff':
        return Icons.work;
      case 'moderator':
        return Icons.gavel;
      case 'alumni':
        return Icons.history_edu;
      case 'student':
        return Icons.person;
      case 'guest':
        return Icons.person_outline;
      default:
        return Icons.person;
    }
  }
}
