import 'package:flutter/material.dart';
import '../../models/preinscription_model.dart';

class PreinscriptionValidationWidget extends StatelessWidget {
  final PreinscriptionModel preinscription;
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback onTap;
  final VoidCallback onSelectionToggle;
  final Function(String) onQuickAction;

  const PreinscriptionValidationWidget({
    Key? key,
    required this.preinscription,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    required this.onSelectionToggle,
    required this.onQuickAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with selection checkbox
              Row(
                children: [
                  if (isSelecting) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelectionToggle(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getStatusColor(preinscription.status),
                          child: Text(
                            '${preinscription.firstName[0]}${preinscription.lastName[0]}',
                            style: const TextStyle(
                              color: Colors.white,
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
                                '${preinscription.firstName} ${preinscription.lastName}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                preinscription.email,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(preinscription.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Quick info
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    preinscription.faculty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.code, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    preinscription.uniqueCode ?? 'N/A',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(preinscription.submissionDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quick actions (only when not in selection mode)
              if (!isSelecting) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickActionButton(
                      context,
                      'validate',
                      'Valider',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildQuickActionButton(
                      context,
                      'reject',
                      'Rejeter',
                      Icons.cancel,
                      Colors.red,
                    ),
                    _buildQuickActionButton(
                      context,
                      'interview',
                      'Entretien',
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                    _buildQuickActionButton(
                      context,
                      'details',
                      'Détails',
                      Icons.visibility,
                      Colors.grey,
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
    return Chip(
      label: Text(
        _formatStatusName(status),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: _getStatusColor(status).withOpacity(0.2),
      avatar: Icon(_getStatusIcon(status), size: 16, color: _getStatusColor(status)),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String action,
    String label,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => onQuickAction(action),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
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
