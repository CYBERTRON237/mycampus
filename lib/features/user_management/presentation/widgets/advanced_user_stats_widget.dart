import 'package:flutter/material.dart';
import '../../data/models/institution_department_model.dart';

class AdvancedUserStatsWidget extends StatelessWidget {
  final UserStatistics stats;

  const AdvancedUserStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          _buildOverviewCards(context),
          
          const SizedBox(height: 24),
          
          // Institution statistics
          _buildSectionTitle('Statistiques par Institution'),
          const SizedBox(height: 12),
          _buildInstitutionStats(context),
          
          const SizedBox(height: 24),
          
          // Role statistics
          _buildSectionTitle('Statistiques par Rôle'),
          const SizedBox(height: 12),
          _buildRoleStats(context),
          
          const SizedBox(height: 24),
          
          // Department statistics
          if (stats.usersByDepartment.isNotEmpty) ...[
            _buildSectionTitle('Statistiques par Département'),
            const SizedBox(height: 12),
            _buildDepartmentStats(context),
            const SizedBox(height: 24),
          ],
          
          // Region statistics
          if (stats.usersByRegion.isNotEmpty) ...[
            _buildSectionTitle('Statistiques par Région'),
            const SizedBox(height: 12),
            _buildRegionStats(context),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          context,
          'Total Utilisateurs',
          '${stats.totalUsers}',
          Icons.people,
          Theme.of(context).colorScheme.primary,
        ),
        _buildStatCard(
          context,
          'Utilisateurs Actifs',
          '${stats.activeUsers}',
          Icons.person,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Utilisateurs Inactifs',
          '${stats.inactiveUsers}',
          Icons.person_off,
          Colors.red,
        ),
        _buildStatCard(
          context,
          'En Attente',
          '${stats.pendingUsers}',
          Icons.hourglass_empty,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                if (title.contains('Actif'))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${stats.totalUsers > 0 ? ((stats.activeUsers / stats.totalUsers) * 100).toStringAsFixed(1) : 0}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInstitutionStats(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Répartition par Institution',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${stats.institutionStats.length} institutions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Institution list
          ...stats.institutionStats.map((institutionStat) {
            return ExpansionTile(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      institutionStat.institutionShortName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          institutionStat.institutionName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${institutionStat.region} • ${institutionStat.city}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${institutionStat.totalUsers}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'utilisateurs',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Role distribution
                      _buildRoleDistribution(context, [
                        ('Étudiants', institutionStat.studentCount, Colors.blue),
                        ('Enseignants', institutionStat.teacherCount, Colors.green),
                        ('Personnel', institutionStat.staffCount, Colors.orange),
                      ]),
                      
                      const SizedBox(height: 12),
                      
                      // Activity status
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityIndicator(
                              context,
                              'Actifs',
                              institutionStat.activeUsers,
                              institutionStat.totalUsers,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActivityIndicator(
                              context,
                              'Inactifs',
                              institutionStat.inactiveUsers,
                              institutionStat.totalUsers,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRoleStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Répartition par Rôle',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Role breakdown
            ...stats.roleStats.map((roleStat) {
              final roleColor = _getRoleColor(roleStat.roleName);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: roleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roleStat.roleDisplayName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Niveau ${roleStat.roleLevel} • ${roleStat.recentLoginCount} connexions récentes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${roleStat.userCount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${roleStat.activeCount} actifs',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Départements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Department breakdown
            ...(stats.usersByDepartment.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value))
            ).take(5)
              .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
              .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Répartition par Région',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Region breakdown
           // Region breakdown
...(() {
  final sortedEntries = stats.usersByRegion.entries
    .where((entry) => entry.value > 0)
    .toList()
    ..sort((a, b) => b.value.compareTo(a.value));
    
  return sortedEntries.map((entry) {
    final percentage = stats.totalUsers > 0 
        ? (entry.value / stats.totalUsers * 100).toStringAsFixed(1)
        : '0.0';
        
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(entry.key)),
              Text(
                '${entry.value} utilisateurs',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: stats.totalUsers > 0 ? entry.value / stats.totalUsers : 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage% du total',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }).toList();
})(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDistribution(
    BuildContext context,
    List<(String, int, Color)> roles,
  ) {
    final total = roles.fold<int>(0, (sum, role) => sum + role.$2);
    
    return Row(
      children: roles.map((role) {
        final percentage = total > 0 ? (role.$2 / total * 100).toStringAsFixed(1) : '0.0';
        return Expanded(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: role.$3,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role.$1,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '${role.$2} ($percentage%)',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityIndicator(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'superadmin':
        return Colors.purple;
      case 'admin_national':
        return Colors.red;
      case 'admin_local':
        return Colors.orange;
      case 'leader':
        return Colors.teal;
      case 'teacher':
        return Colors.green;
      case 'staff':
        return Colors.blue;
      case 'moderator':
        return Colors.indigo;
      case 'student':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
