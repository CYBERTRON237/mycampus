import 'package:flutter/material.dart';
import '../../models/preinscription_model.dart';

class PreinscriptionValidationActionsWidget extends StatelessWidget {
  final PreinscriptionModel preinscription;
  final Function(String) onAction;

  const PreinscriptionValidationActionsWidget({
    Key? key,
    required this.preinscription,
    required this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPending = preinscription.status == 'pending';
    final isUnderReview = preinscription.status == 'under_review';
    final isAccepted = preinscription.status == 'accepted';
    final isRejected = preinscription.status == 'rejected';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Actions de Validation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: _getStatusColor(preinscription.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusColor(preinscription.status).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(preinscription.status), color: _getStatusColor(preinscription.status)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Statut actuel: ${_formatStatusName(preinscription.status)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(preinscription.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons based on current status
            if (isPending || isUnderReview) ...[
              // Accept action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onAction('accept'),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accepter la préinscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Reject action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onAction('reject'),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Rejeter la préinscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Request interview
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onAction('interview'),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Planifier un entretien'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else if (isAccepted) ...[
              // Actions for accepted preinscriptions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Préinscription acceptée',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (preinscription.admissionNumber != null) ...[
                      const SizedBox(height: 8),
                      Text('Numéro d\'admission: ${preinscription.admissionNumber}'),
                    ],
                    if (preinscription.registrationDeadline != null) ...[
                      const SizedBox(height: 4),
                      Text('Date limite: ${_formatDate(preinscription.registrationDeadline!)}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Additional actions for accepted
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onAction('generate_admission'),
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Générer lettre d\'admission'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else if (isRejected) ...[
              // Actions for rejected preinscriptions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Préinscription rejetée',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    if (preinscription.rejectionReason != null && preinscription.rejectionReason!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Motif: ${preinscription.rejectionReason}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Reconsider action
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onAction('reconsider'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réexaminer la demande'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            
            // Common actions
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onAction('add_notes'),
                icon: const Icon(Icons.note_add),
                label: const Text('Ajouter des notes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'under_review': return Colors.blue;
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      case 'deferred': return Colors.purple;
      case 'waitlisted': return Colors.amber;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.pending;
      case 'under_review': return Icons.visibility;
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'cancelled': return Icons.block;
      case 'deferred': return Icons.schedule;
      case 'waitlisted': return Icons.hourglass_empty;
      default: return Icons.help;
    }
  }

  String _formatStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'En attente';
      case 'under_review': return 'En révision';
      case 'accepted': return 'Accepté';
      case 'rejected': return 'Rejeté';
      case 'cancelled': return 'Annulé';
      case 'deferred': return 'Reporté';
      case 'waitlisted': return 'Liste d\'attente';
      default: return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
