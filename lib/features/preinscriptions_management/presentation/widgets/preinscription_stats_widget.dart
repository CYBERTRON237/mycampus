import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../pages/preinscription_home_page.dart';

class PreinscriptionStatsWidget extends StatelessWidget {
  final Map<String, int> stats;
  final List<Map<String, dynamic>> facultyStats;
  final bool isLoading;
  final VoidCallback onRefresh;

  const PreinscriptionStatsWidget({
    Key? key,
    required this.stats,
    required this.facultyStats,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('📊 [WIDGET DEBUG] PreinscriptionStatsWidget build appelé - isLoading: $isLoading, stats: $stats, facultyStats: ${facultyStats.length}');
    }
    
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall statistics
            _buildOverallStats(context),
            const SizedBox(height: 24.0),
            
            // Status breakdown
            _buildStatusBreakdown(context),
            const SizedBox(height: 24.0),
            
            // Faculty statistics
            _buildFacultyStats(context),
            const SizedBox(height: 24.0),
            
            // Payment statistics
            _buildPaymentStats(context),
            const SizedBox(height: 24.0),
            
            // Validation section
            _buildValidationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context) {
    final total = stats['total'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final accepted = stats['accepted'] ?? 0;
    final rejected = stats['rejected'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques Générales',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total',
                    total.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'En attente',
                    pending.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Acceptés',
                    accepted.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Rejetés',
                    rejected.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
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
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(BuildContext context) {
    final statusStats = {
      'pending': stats['pending'] ?? 0,
      'under_review': stats['under_review'] ?? 0,
      'accepted': stats['accepted'] ?? 0,
      'rejected': stats['rejected'] ?? 0,
      'cancelled': stats['cancelled'] ?? 0,
      'deferred': stats['deferred'] ?? 0,
      'waitlisted': stats['waitlisted'] ?? 0,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par Statut',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            
            ...statusStats.entries.map((entry) {
              if (entry.value == 0) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    _buildStatusIcon(entry.key),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        _formatStatusName(entry.key),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry.key).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: _getStatusColor(entry.key),
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

  Widget _buildFacultyStats(BuildContext context) {
    if (facultyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques par Faculté',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            
            ...facultyStats.map((faculty) {
              final count = faculty['count'] as int? ?? 0;
              if (count == 0) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.school, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        faculty['faculty'] as String? ?? 'Inconnue',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.blue,
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

  Widget _buildPaymentStats(BuildContext context) {
    final paymentStats = {
      'pending': stats['payment_pending'] ?? 0,
      'paid': stats['payment_paid'] ?? 0,
      'confirmed': stats['payment_confirmed'] ?? 0,
      'refunded': stats['payment_refunded'] ?? 0,
      'partial': stats['payment_partial'] ?? 0,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques de Paiement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            
            ...paymentStats.entries.map((entry) {
              if (entry.value == 0) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    _buildPaymentStatusIcon(entry.key),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        _formatPaymentStatusName(entry.key),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(entry.key).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: _getPaymentStatusColor(entry.key),
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

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color = _getStatusColor(status);
    
    switch (status.toLowerCase()) {
      case 'pending':
        icon = Icons.pending;
        break;
      case 'under_review':
        icon = Icons.visibility;
        break;
      case 'accepted':
        icon = Icons.check_circle;
        break;
      case 'rejected':
        icon = Icons.cancel;
        break;
      case 'cancelled':
        icon = Icons.block;
        break;
      case 'deferred':
        icon = Icons.schedule;
        break;
      case 'waitlisted':
        icon = Icons.hourglass_empty;
        break;
      default:
        icon = Icons.help;
    }

    return Icon(icon, size: 20, color: color);
  }

  Widget _buildPaymentStatusIcon(String status) {
    IconData icon;
    Color color = _getPaymentStatusColor(status);
    
    switch (status.toLowerCase()) {
      case 'pending':
        icon = Icons.payment;
        break;
      case 'paid':
        icon = Icons.payment;
        break;
      case 'confirmed':
        icon = Icons.verified;
        break;
      case 'refunded':
        icon = Icons.money_off;
        break;
      case 'partial':
        icon = Icons.pie_chart;
        break;
      default:
        icon = Icons.help;
    }

    return Icon(icon, size: 20, color: color);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'refunded':
        return Colors.purple;
      case 'partial':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En révision';
      case 'accepted':
        return 'Accepté';
      case 'rejected':
        return 'Rejeté';
      case 'cancelled':
        return 'Annulé';
      case 'deferred':
        return 'Reporté';
      case 'waitlisted':
        return 'Liste d\'attente';
      default:
        return status;
    }
  }

  String _formatPaymentStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Paiement en attente';
      case 'paid':
        return 'Payé';
      case 'confirmed':
        return 'Confirmé';
      case 'refunded':
        return 'Remboursé';
      case 'partial':
        return 'Partiel';
      default:
        return status;
    }
  }

  Widget _buildValidationSection(BuildContext context) {
    final pending = stats['pending'] ?? 0;
    final underReview = stats['under_review'] ?? 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.app_registration_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Validation des Préinscriptions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (pending > 0 || underReview > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${pending + underReview} à traiter',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            
            // Quick validation actions
            _buildValidationActions(context),
            
            const SizedBox(height: 16.0),
            
            // Recent pending preinscriptions (placeholder)
            _buildRecentPendingList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationActions(BuildContext context) {
    final pending = stats['pending'] ?? 0;
    final underReview = stats['under_review'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),
        
        Row(
          children: [
            // View pending preinscriptions
            Expanded(
              child: ElevatedButton.icon(
                onPressed: pending > 0 ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreinscriptionHomePage(
                        initialTab: 0, // List tab
                        initialFilters: {
                          'status': 'pending',
                        },
                      ),
                    ),
                  );
                } : null,
                icon: const Icon(Icons.pending_actions, size: 16),
                label: Text('En attente ($pending)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pending > 0 ? Colors.orange : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            
            // View under review preinscriptions
            Expanded(
              child: ElevatedButton.icon(
                onPressed: underReview > 0 ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreinscriptionHomePage(
                        initialTab: 0, // List tab
                        initialFilters: {
                          'status': 'under_review',
                        },
                      ),
                    ),
                  );
                } : null,
                icon: const Icon(Icons.search, size: 16),
                label: Text('En révision ($underReview)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: underReview > 0 ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8.0),
        
        // Batch validation button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: (pending > 0 || underReview > 0) ? () {
              _showBatchValidationDialog(context);
            } : null,
            icon: const Icon(Icons.playlist_add_check, size: 16),
            label: const Text('Validation par Lot'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(
                color: (pending > 0 || underReview > 0) ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPendingList(BuildContext context) {
    // This would show recent pending preinscriptions
    // For now, it's a placeholder that shows a message
    final totalPending = (stats['pending'] ?? 0) + (stats['under_review'] ?? 0);
    
    if (totalPending == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Toutes les préinscriptions sont traitées',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Préinscriptions Récentes en Attente',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$totalPending préinscription(s) en attente de validation',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreinscriptionHomePage(
                          initialTab: 0, // List tab
                          initialFilters: {
                            'status': 'pending',
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Voir la liste complète'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBatchValidationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation par Lot'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cette fonctionnalité vous permettra de:'),
            SizedBox(height: 8),
            Text('• Accepter plusieurs préinscriptions en une fois'),
            Text('• Rejeter plusieurs préinscriptions en une fois'),
            Text('• Planifier des entretiens par lot'),
            Text('• Mettre à jour les statuts rapidement'),
            SizedBox(height: 12),
            Text(
              'Cette fonctionnalité sera bientôt disponible.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to batch validation page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Page de validation par lot bientôt disponible'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }
}
