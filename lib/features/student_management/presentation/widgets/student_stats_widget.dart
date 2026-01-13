import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';

class StudentStatsWidget extends StatelessWidget {
  final StudentStats stats;

  const StudentStatsWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques globales',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildMainStats(),
        const SizedBox(height: 24),
        _buildStatusStats(),
        const SizedBox(height: 24),
        _buildPerformanceStats(),
        const SizedBox(height: 24),
        _buildDemographicsStats(),
        const SizedBox(height: 24),
        _buildLevelStats(),
      ],
    );
  }

  Widget _buildMainStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Vue d\'ensemble',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    '${stats.totalStudents}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Inscrits',
                    '${stats.enrolledStudents}',
                    Icons.school,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Diplômés',
                    '${stats.graduatedStudents}',
                    Icons.emoji_events,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
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
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statut des étudiants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              'Inscrits',
              stats.enrolledStudents,
              stats.totalStudents,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Diplômés',
              stats.graduatedStudents,
              stats.totalStudents,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Suspendus',
              stats.suspendedStudents,
              stats.totalStudents,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Retirés',
              stats.withdrawnStudents,
              stats.totalStudents,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Reportés',
              stats.deferredStudents,
              stats.totalStudents,
              Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value ($percentage.toStringAsFixed(1)%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildPerformanceStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance académique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (stats.averageGpa != null)
              Row(
                children: [
                  Icon(
                    Icons.grade,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Moyenne GPA: ${stats.averageGpa!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            _buildPerformanceGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceGrid() {
    return Column(
      children: [
        const Text(
          'Répartition par performance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPerformanceItem(
                'Excellent',
                stats.excellentStudents,
                Colors.green,
                '≥ 3.5',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPerformanceItem(
                'Bon',
                stats.goodStudents,
                Colors.blue,
                '3.0 - 3.49',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPerformanceItem(
                'Moyen',
                stats.averageStudents,
                Colors.orange,
                '2.5 - 2.99',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPerformanceItem(
                'Faible',
                stats.poorStudents,
                Colors.red,
                '< 2.5',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, int count, Color color, String range) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Démographie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildGenderStat(
                    'Hommes',
                    stats.maleStudents,
                    Colors.blue,
                    Icons.male,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderStat(
                    'Femmes',
                    stats.femaleStudents,
                    Colors.pink,
                    Icons.female,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              'Avec bourse',
              stats.scholarshipStudents,
              stats.totalStudents,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderStat(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Niveaux d\'étude',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(
              'Licence',
              stats.undergraduateStudents,
              stats.totalStudents,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Master',
              stats.graduateStudents,
              stats.totalStudents,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(
              'Doctorat',
              stats.doctoralStudents,
              stats.totalStudents,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
