import 'package:flutter/material.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';

class EnhancedStudentStatsWidget extends StatelessWidget {
  final StudentStatistics statistics;
  final VoidCallback? onRefresh;

  const EnhancedStudentStatsWidget({
    super.key,
    required this.statistics,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Statistiques des Étudiants',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualiser',
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Overview cards
            _buildOverviewCards(context),
            
            const SizedBox(height: 24),
            
            // Status distribution
            _buildStatusDistribution(context),
            
            const SizedBox(height: 24),
            
            // Academic level distribution
            _buildLevelDistribution(context),
            
            const SizedBox(height: 24),
            
            // Institution distribution
            _buildInstitutionDistribution(context),
            
            const SizedBox(height: 24),
            
            // GPA statistics
            _buildGpaStatistics(context),
            
            const SizedBox(height: 24),
            
            // Scholarship statistics
            _buildScholarshipStatistics(context),
            
            const SizedBox(height: 24),
            
            // Demographics
            _buildDemographics(context),
            
            const SizedBox(height: 24),
            
            // Performance metrics
            _buildPerformanceMetrics(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              'Total des étudiants',
              '${statistics.totalStudents}',
              Icons.people,
              Theme.of(context).colorScheme.primary,
            ),
            _buildStatCard(
              context,
              'Étudiants actifs',
              '${statistics.activeStudents}',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'Étudiants vérifiés',
              '${statistics.verifiedStudents}',
              Icons.verified,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Diplômés',
              '${statistics.studentsByStatus[StudentStatus.graduated] ?? 0}',
              Icons.school,
              Colors.purple,
            ),
          ],
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
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par statut',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...StudentStatus.values.map((status) {
              final count = statistics.studentsByStatus[status] ?? 0;
              final percentage = statistics.totalStudents > 0 
                  ? (count / statistics.totalStudents * 100).toStringAsFixed(1)
                  : '0.0';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 20,
                      color: _getStatusColor(status),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.label,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          LinearProgressIndicator(
                            value: statistics.totalStudents > 0 ? count / statistics.totalStudents : 0,
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelDistribution(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par niveau académique',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AcademicLevel.values.map((level) {
                final count = statistics.studentsByLevel[level] ?? 0;
                if (count == 0) return const SizedBox.shrink();
                
                return Chip(
                  label: Text('${level.label} ($count)'),
                  backgroundColor: _getLevelColor(level).withOpacity(0.1),
                  side: BorderSide(color: _getLevelColor(level)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionDistribution(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par institution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...statistics.studentsByInstitution.entries.map((entry) {
              final institution = entry.key;
              final count = entry.value;
              final percentage = statistics.totalStudents > 0 
                  ? (count / statistics.totalStudents * 100).toStringAsFixed(1)
                  : '0.0';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        institution,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: statistics.totalStudents > 0 ? count / statistics.totalStudents : 0,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$count ($percentage%)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGpaStatistics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques GPA',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (statistics.averageGpa != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildGpaStatItem(
                      context,
                      'Moyenne',
                      statistics.averageGpa!.toStringAsFixed(2),
                      Icons.calculate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGpaStatItem(
                      context,
                      'Médiane',
                      statistics.medianGpa?.toStringAsFixed(2) ?? 'N/A',
                      Icons.bar_chart,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGpaStatItem(
                      context,
                      'Minimum',
                      statistics.minGpa?.toStringAsFixed(2) ?? 'N/A',
                      Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGpaStatItem(
                      context,
                      'Maximum',
                      statistics.maxGpa?.toStringAsFixed(2) ?? 'N/A',
                      Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Center(
                child: Text('Aucune donnée GPA disponible'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGpaStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipStatistics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques des bourses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildScholarshipCard(
                    context,
                    'Boursiers',
                    '${statistics.scholarshipRecipients}',
                    Icons.school,
                    Colors.green,
                    '${statistics.scholarshipRate.toStringAsFixed(1)}%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScholarshipCard(
                    context,
                    'Non boursiers',
                    '${statistics.totalStudents - statistics.scholarshipRecipients}',
                    Icons.money_off,
                    Colors.grey,
                    '${(100 - statistics.scholarshipRate).toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Scholarship status breakdown
            ...ScholarshipStatus.values.map((status) {
              final count = statistics.studentsByScholarshipStatus[status] ?? 0;
              if (count == 0) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 20,
                      color: _getScholarshipColor(status),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status.label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarshipCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            percentage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Données démographiques',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Gender distribution
            if (statistics.studentsByGender.isNotEmpty) ...[
              Text(
                'Répartition par genre',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...statistics.studentsByGender.entries.map((entry) {
                final gender = entry.key;
                final count = entry.value;
                final percentage = statistics.totalStudents > 0 
                    ? (count / statistics.totalStudents * 100).toStringAsFixed(1)
                    : '0.0';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        gender == 'male' ? Icons.male : gender == 'female' ? Icons.female : Icons.transgender,
                        size: 20,
                        color: gender == 'male' ? Colors.blue : gender == 'female' ? Colors.pink : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          gender == 'male' ? 'Masculin' : gender == 'female' ? 'Féminin' : 'Autre',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '$count ($percentage%)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            
            const SizedBox(height: 16),
            
            // Regional distribution
            if (statistics.studentsByRegion.isNotEmpty) ...[
              Text(
                'Répartition par région',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...statistics.studentsByRegion.entries.take(5).map((entry) {
                final region = entry.key;
                final count = entry.value;
                final percentage = statistics.totalStudents > 0 
                    ? (count / statistics.totalStudents * 100).toStringAsFixed(1)
                    : '0.0';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          region,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '$count ($percentage%)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            
            // Average age
            if (statistics.averageAge != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Âge moyen: ${statistics.averageAge} ans',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indicateurs de performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Taux d\'activité',
                    '${statistics.activeRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    statistics.activeRate > 80 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Taux de vérification',
                    '${statistics.verifiedRate.toStringAsFixed(1)}%',
                    Icons.verified_user,
                    statistics.verifiedRate > 80 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Taux de diplomation',
                    '${statistics.graduationRate.toStringAsFixed(1)}%',
                    Icons.school,
                    statistics.graduationRate > 50 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Mémoires de thèse',
                    '${statistics.studentsWithThesis}',
                    Icons.description,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(StudentStatus status) {
    switch (status) {
      case StudentStatus.enrolled:
        return Icons.check_circle;
      case StudentStatus.graduated:
        return Icons.school;
      case StudentStatus.suspended:
        return Icons.pause_circle;
      case StudentStatus.withdrawn:
        return Icons.exit_to_app;
      case StudentStatus.deferred:
        return Icons.schedule;
      case StudentStatus.onLeave:
        return Icons.beach_access;
      case StudentStatus.expelled:
        return Icons.block;
      case StudentStatus.deceased:
        return Icons.memory;
    }
  }

  Color _getStatusColor(StudentStatus status) {
    switch (status) {
      case StudentStatus.enrolled:
        return Colors.green;
      case StudentStatus.graduated:
        return Colors.blue;
      case StudentStatus.suspended:
        return Colors.orange;
      case StudentStatus.withdrawn:
        return Colors.red;
      case StudentStatus.deferred:
        return Colors.purple;
      case StudentStatus.onLeave:
        return Colors.teal;
      case StudentStatus.expelled:
        return Colors.red.shade900;
      case StudentStatus.deceased:
        return Colors.grey;
    }
  }

  Color _getLevelColor(AcademicLevel level) {
    switch (level.degreeType) {
      case 'Licence':
        return Colors.blue;
      case 'Master':
        return Colors.purple;
      case 'Doctorat':
        return Colors.red;
      case 'Ingénieur':
        return Colors.orange;
      case 'BTS':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getScholarshipColor(ScholarshipStatus status) {
    switch (status) {
      case ScholarshipStatus.none:
        return Colors.grey;
      case ScholarshipStatus.partial:
        return Colors.blue;
      case ScholarshipStatus.full:
        return Colors.green;
      case ScholarshipStatus.merit:
        return Colors.purple;
      case ScholarshipStatus.need:
        return Colors.orange;
      case ScholarshipStatus.athletic:
        return Colors.red;
      case ScholarshipStatus.research:
        return Colors.teal;
    }
  }
}
