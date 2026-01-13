import 'package:flutter/material.dart';
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';
import 'dart:math' as math;

class PreinscriptionValidationStatsWidget extends StatelessWidget {
  final ValidationStatsModel? stats;
  final Future<void> Function() onRefresh;

  const PreinscriptionValidationStatsWidget({
    super.key,
    required this.stats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              'Statistiques de Validation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cartes de statistiques principales
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'En attente de validation',
                    stats!.pendingValidation.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Avec compte utilisateur',
                    stats!.withUserAccount.toString(),
                    Icons.person,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Statuts par préinscription
            _buildStatusBreakdown(context),
            
            const SizedBox(height: 16),
            
            // Répartition par faculté
            _buildFacultyBreakdown(context),
          ],
        ),
      ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                if (value != '0')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Nouveau',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(BuildContext context) {
    final statusData = stats!.byStatus;
    final total = statusData.values.fold<int>(0, (sum, count) => sum + count);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            
            // Graphique circulaire simplifié
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Graphique
                  Expanded(
                    flex: 2,
                    child: _buildPieChart(statusData),
                  ),
                  const SizedBox(width: 16),
                  // Légende
                  Expanded(
                    flex: 3,
                    child: _buildStatusLegend(context, statusData, total),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> statusData) {
    final total = statusData.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) {
      return const Center(
        child: Text('Aucune donnée'),
      );
    }

    return CustomPaint(
      size: const Size(150, 150),
      painter: PieChartPainter(
        data: statusData,
        colors: {
          'pending': Colors.orange,
          'under_review': Colors.blue,
          'accepted': Colors.green,
          'rejected': Colors.red,
          'cancelled': Colors.grey,
          'deferred': Colors.purple,
          'waitlisted': Colors.teal,
        },
      ),
    );
  }

  Widget _buildStatusLegend(BuildContext context, Map<String, int> statusData, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statusData.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0.0';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getStatusDisplayName(entry.key),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                '${entry.value} ($percentage%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFacultyBreakdown(BuildContext context) {
    final facultyData = stats!.byFaculty;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par faculté',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Liste des facultés
            ...facultyData.map((facultyData) {
              final faculty = facultyData['faculty'] as String;
              final status = facultyData['status'] as String;
              final count = facultyData['count'] as int;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Icône de la faculté
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getFacultyColor(faculty).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getFacultyIcon(faculty),
                        color: _getFacultyColor(faculty),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Informations
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFacultyDisplayName(faculty),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _getStatusDisplayName(status),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Nombre
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'deferred':
        return Colors.purple;
      case 'waitlisted':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En cours de révision';
      case 'accepted':
        return 'Acceptées';
      case 'rejected':
        return 'Rejetées';
      case 'cancelled':
        return 'Annulées';
      case 'deferred':
        return 'Reportées';
      case 'waitlisted':
        return 'Liste d\'attente';
      default:
        return status;
    }
  }

  Color _getFacultyColor(String faculty) {
    switch (faculty) {
      case 'UY1':
        return Colors.blue;
      case 'FALSH':
        return Colors.purple;
      case 'FS':
        return Colors.green;
      case 'FSE':
        return Colors.orange;
      case 'IUT':
        return Colors.red;
      case 'ENSPY':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getFacultyIcon(String faculty) {
    switch (faculty) {
      case 'UY1':
        return Icons.school;
      case 'FALSH':
        return Icons.menu_book;
      case 'FS':
        return Icons.science;
      case 'FSE':
        return Icons.psychology;
      case 'IUT':
        return Icons.computer;
      case 'ENSPY':
        return Icons.engineering;
      default:
        return Icons.account_balance;
    }
  }

  String _getFacultyDisplayName(String faculty) {
    switch (faculty) {
      case 'UY1':
        return 'Université de Yaoundé 1';
      case 'FALSH':
        return 'Faculté des Arts, Lettres et Sciences Humaines';
      case 'FS':
        return 'Faculté des Sciences';
      case 'FSE':
        return 'Faculté des Sciences de l\'Éducation';
      case 'IUT':
        return 'Institut Universitaire de Technologie';
      case 'ENSPY':
        return 'École Nationale Supérieure Polytechnique';
      default:
        return faculty;
    }
  }
}

// Custom painter pour le graphique circulaire
class PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final Map<String, Color> colors;

  PieChartPainter({
    required this.data,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    final total = data.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return;
    
    double startAngle = -math.pi / 2;
    
    data.forEach((status, count) {
      final sweepAngle = (count / total) * 2 * math.pi;
      final color = colors[status] ?? Colors.grey;
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Import pour math
