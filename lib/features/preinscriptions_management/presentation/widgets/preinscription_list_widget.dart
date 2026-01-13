import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/preinscription_model.dart';

class PreinscriptionListWidget extends StatefulWidget {
  final List<PreinscriptionModel> preinscriptions;
  final bool isLoading;
  final Function(PreinscriptionModel) onTap;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const PreinscriptionListWidget({
    Key? key,
    required this.preinscriptions,
    required this.isLoading,
    required this.onTap,
    this.onLoadMore,
    this.hasMore = false,
  }) : super(key: key);

  @override
  State<PreinscriptionListWidget> createState() => _PreinscriptionListWidgetState();
}

class _PreinscriptionListWidgetState extends State<PreinscriptionListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      print('📋 [WIDGET DEBUG] PreinscriptionListWidget initState appelé avec ${widget.preinscriptions.length} préinscriptions');
    }
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (widget.hasMore && widget.onLoadMore != null && !widget.isLoading) {
          if (kDebugMode) {
            print('📜 [WIDGET DEBUG] Load more déclenché');
          }
          widget.onLoadMore!();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🎨 [WIDGET DEBUG] PreinscriptionListWidget build appelé - isLoading: ${widget.isLoading}, preinscriptions: ${widget.preinscriptions.length}');
    }
    
    if (widget.isLoading && widget.preinscriptions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.preinscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16.0),
            Text(
              'Aucune préinscription trouvée',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Essayez de modifier vos filtres ou votre recherche',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: widget.preinscriptions.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.preinscriptions.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final preinscription = widget.preinscriptions[index];
        return PreinscriptionCard(
          preinscription: preinscription,
          onTap: () => widget.onTap(preinscription),
        );
      },
    );
  }
}

class PreinscriptionCard extends StatelessWidget {
  final PreinscriptionModel preinscription;
  final VoidCallback onTap;

  const PreinscriptionCard({
    Key? key,
    required this.preinscription,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${preinscription.firstName} ${preinscription.lastName}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (preinscription.middleName != null)
                          Text(
                            preinscription.middleName!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  _buildStatusChip(preinscription.status),
                ],
              ),
              const SizedBox(height: 12.0),
              
              // Key information
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      preinscription.faculty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      preinscription.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Text(
                    preinscription.phoneNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4.0),
                  Text(
                    _formatDate(preinscription.submissionDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              // Additional info row
              if (preinscription.desiredProgram != null || 
                  preinscription.paymentStatus != 'pending') ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    if (preinscription.desiredProgram != null) ...[
                      Icon(Icons.book, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          preinscription.desiredProgram!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8.0),
                    _buildPaymentStatusChip(preinscription.paymentStatus),
                  ],
                ),
              ],
              
              // Priority indicator
              if (preinscription.reviewPriority != 'NORMAL') ...[
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      _getPriorityIcon(preinscription.reviewPriority),
                      size: 16,
                      color: _getPriorityColor(preinscription.reviewPriority),
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Priorité: ${preinscription.reviewPriority}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getPriorityColor(preinscription.reviewPriority),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        label = 'En attente';
        break;
      case 'under_review':
        color = Colors.blue;
        icon = Icons.visibility;
        label = 'En révision';
        break;
      case 'accepted':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Accepté';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Rejeté';
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.block;
        label = 'Annulé';
        break;
      case 'deferred':
        color = Colors.purple;
        icon = Icons.schedule;
        label = 'Reporté';
        break;
      case 'waitlisted':
        color = Colors.amber;
        icon = Icons.hourglass_empty;
        label = 'Liste d\'attente';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
    Color color;
    IconData icon;
    String label;
    
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.payment;
        label = 'Paiement en attente';
        break;
      case 'paid':
        color = Colors.green;
        icon = Icons.payment;
        label = 'Payé';
        break;
      case 'confirmed':
        color = Colors.blue;
        icon = Icons.verified;
        label = 'Confirmé';
        break;
      case 'refunded':
        color = Colors.purple;
        icon = Icons.money_off;
        label = 'Remboursé';
        break;
      case 'partial':
        color = Colors.amber;
        icon = Icons.pie_chart;
        label = 'Partiel';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = paymentStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return Icons.arrow_downward;
      case 'HIGH':
        return Icons.arrow_upward;
      case 'URGENT':
        return Icons.priority_high;
      default:
        return Icons.remove;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'HIGH':
        return Colors.orange;
      case 'URGENT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
