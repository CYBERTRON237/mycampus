import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/features/preinscription_validation/providers/preinscription_validation_provider.dart';

class PreinscriptionValidationStatsRedesigned extends StatelessWidget {
  const PreinscriptionValidationStatsRedesigned({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreinscriptionValidationProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête des statistiques
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Statistiques de validation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _refreshStats(context),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Cartes de statistiques principales
              _buildMainStatsCards(context, provider),
              
              const SizedBox(height: 24),
              
              // Graphiques et répartitions
              _buildStatsCharts(context, provider),
              
              const SizedBox(height: 24),
              
              // Tableau récapitulatif
              _buildSummaryTable(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainStatsCards(BuildContext context, PreinscriptionValidationProvider provider) {
    final totalPreinscriptions = provider.allPreinscriptions.length;
    final pendingCount = provider.allPreinscriptions.where((p) => p.status == 'pending').length;
    final underReviewCount = provider.allPreinscriptions.where((p) => p.status == 'under_review').length;
    final acceptedCount = provider.allPreinscriptions.where((p) => p.status == 'accepted').length;
    final rejectedCount = provider.allPreinscriptions.where((p) => p.status == 'rejected').length;
    final waitlistedCount = provider.allPreinscriptions.where((p) => p.status == 'waitlisted').length;
    
    return Column(
      children: [
        // Carte principale - Total
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total des préinscriptions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                totalPreinscriptions.toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En cours de traitement',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Cartes de statut
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'En attente',
                pendingCount.toString(),
                Colors.orange,
                Icons.pending_rounded,
                totalPreinscriptions > 0 ? (pendingCount / totalPreinscriptions * 100).round() : 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'En examen',
                underReviewCount.toString(),
                Colors.blue,
                Icons.search_rounded,
                totalPreinscriptions > 0 ? (underReviewCount / totalPreinscriptions * 100).round() : 0,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Acceptées',
                acceptedCount.toString(),
                Colors.green,
                Icons.check_circle_rounded,
                totalPreinscriptions > 0 ? (acceptedCount / totalPreinscriptions * 100).round() : 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Rejetées',
                rejectedCount.toString(),
                Colors.red,
                Icons.cancel_rounded,
                totalPreinscriptions > 0 ? (rejectedCount / totalPreinscriptions * 100).round() : 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color, IconData icon, int percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCharts(BuildContext context, PreinscriptionValidationProvider provider) {
    final faculties = <String, int>{};
    final paymentStatuses = <String, int>{};
    
    // Compter par faculté
    for (final preinscription in provider.allPreinscriptions) {
      final faculty = preinscription.faculty;
      faculties[faculty] = (faculties[faculty] ?? 0) + 1;
      
      final paymentStatus = preinscription.paymentStatus.isNotEmpty 
          ? preinscription.paymentStatus 
          : 'Non défini';
      paymentStatuses[paymentStatus] = (paymentStatuses[paymentStatus] ?? 0) + 1;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Répartitions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Répartition par faculté
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Par faculté',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...faculties.entries.map((entry) {
                final percentage = provider.allPreinscriptions.isNotEmpty 
                    ? (entry.value / provider.allPreinscriptions.length * 100).round()
                    : 0;
                return _buildProgressBar(
                  context,
                  entry.key,
                  entry.value,
                  percentage,
                  _getFacultyColor(entry.key),
                );
              }).toList(),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Répartition par statut de paiement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payment_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Statut de paiement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...paymentStatuses.entries.map((entry) {
                final percentage = provider.allPreinscriptions.isNotEmpty 
                    ? (entry.value / provider.allPreinscriptions.length * 100).round()
                    : 0;
                return _buildProgressBar(
                  context,
                  entry.key,
                  entry.value,
                  percentage,
                  _getPaymentStatusColor(entry.key),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, int value, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$value ($percentage%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context, PreinscriptionValidationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Résumé détaillé',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tableau récapitulatif
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            border: TableBorder.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            children: [
              // En-tête
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                ),
                children: [
                  _buildTableCell(
                    context,
                    'Statut',
                    isHeader: true,
                  ),
                  _buildTableCell(
                    context,
                    'Nombre',
                    isHeader: true,
                  ),
                  _buildTableCell(
                    context,
                    '%',
                    isHeader: true,
                  ),
                ],
              ),
              // Lignes de données
              ..._getStatusData(provider).map((statusData) {
                return TableRow(
                  children: [
                    _buildTableCell(
                      context,
                      statusData['label'],
                      textColor: statusData['color'],
                    ),
                    _buildTableCell(
                      context,
                      statusData['count'].toString(),
                    ),
                    _buildTableCell(
                      context,
                      '${statusData['percentage']}%',
                      textColor: statusData['color'],
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(BuildContext context, String text, {bool isHeader = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: isHeader
            ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )
            : Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
              ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Map<String, dynamic>> _getStatusData(PreinscriptionValidationProvider provider) {
    final total = provider.allPreinscriptions.length;
    if (total == 0) return [];
    
    final statuses = [
      {'status': 'pending', 'label': 'En attente', 'color': Colors.orange},
      {'status': 'under_review', 'label': 'En examen', 'color': Colors.blue},
      {'status': 'accepted', 'label': 'Acceptées', 'color': Colors.green},
      {'status': 'rejected', 'label': 'Rejetées', 'color': Colors.red},
      {'status': 'waitlisted', 'label': 'Liste d\'attente', 'color': Colors.purple},
    ];
    
    return statuses.map((statusInfo) {
      final count = provider.allPreinscriptions.where((p) => p.status == statusInfo['status']).length;
      final percentage = total > 0 ? (count / total * 100).round() : 0;
      
      return {
        'label': statusInfo['label'],
        'count': count,
        'percentage': percentage,
        'color': statusInfo['color'],
      };
    }).where((data) => data['count'] != null && (data['count'] as int) > 0).toList();
  }

  Color _getFacultyColor(String faculty) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    
    final hash = faculty.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'unpaid':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _refreshStats(BuildContext context) {
    context.read<PreinscriptionValidationProvider>().refresh();
  }
}
