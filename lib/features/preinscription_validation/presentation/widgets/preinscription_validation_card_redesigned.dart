import 'package:flutter/material.dart';
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';

class PreinscriptionValidationCardRedesigned extends StatelessWidget {
  final PreinscriptionValidationModel preinscription;
  final bool isProcessing;
  final Function(String)? onValidate;
  final Function(String)? onReject;
  final VoidCallback? onTap;

  const PreinscriptionValidationCardRedesigned({
    super.key,
    required this.preinscription,
    required this.isProcessing,
    this.onValidate,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getStatusColor().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec statut et actions
                Row(
                  children: [
                    // Avatar et infos principales
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getStatusColor().withOpacity(0.1),
                      child: Text(
                        preinscription.firstName.isNotEmpty
                            ? preinscription.firstName[0].toUpperCase()
                            : preinscription.lastName[0].toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  preinscription.email,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 14,
                            color: _getStatusColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              color: _getStatusColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Informations académiques
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              preinscription.faculty,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (preinscription.desiredProgram != null && preinscription.desiredProgram!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                preinscription.desiredProgram!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Informations supplémentaires en grille
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Code',
                        preinscription.uniqueCode,
                        Icons.qr_code,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Téléphone',
                        preinscription.phoneNumber,
                        Icons.phone_outlined,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Date',
                        _formatDate(preinscription.createdAt),
                        Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Indicateurs et badges
                Row(
                  children: [
                    if (preinscription.hasUserAccount)
                      _buildBadge(
                        context,
                        'Compte utilisateur',
                        Icons.verified_user,
                        Colors.green,
                      ),
                    if (preinscription.hasUserAccount && preinscription.canBeValidated)
                      const SizedBox(width: 8),
                    if (preinscription.canBeValidated)
                      _buildBadge(
                        context,
                        'Peut être validée',
                        Icons.check_circle_outline,
                        Colors.blue,
                      ),
                    if (preinscription.paymentStatus.isNotEmpty && preinscription.paymentStatus != 'unpaid')
                      const SizedBox(width: 8),
                    if (preinscription.paymentStatus.isNotEmpty && preinscription.paymentStatus != 'unpaid')
                      _buildBadge(
                        context,
                        'Paiement: ${_getPaymentStatusText()}',
                        Icons.payment,
                        _getPaymentStatusColor(),
                      ),
                  ],
                ),
                
                // Actions rapides
                if (onValidate != null || onReject != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onValidate != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isProcessing ? null : () => _showValidationDialog(context),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Valider'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (onValidate != null && onReject != null)
                        const SizedBox(width: 12),
                      if (onReject != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isProcessing ? null : () => _showRejectionDialog(context),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Rejeter'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (preinscription.status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'waitlisted':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (preinscription.status) {
      case 'pending':
        return Icons.pending;
      case 'under_review':
        return Icons.search;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'waitlisted':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }

  String _getStatusText() {
    switch (preinscription.status) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En examen';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Rejetée';
      case 'waitlisted':
        return 'Liste d\'attente';
      default:
        return 'Inconnu';
    }
  }

  String _getPaymentStatusText() {
    switch (preinscription.paymentStatus) {
      case 'paid':
        return 'Payé';
      case 'confirmed':
        return 'Confirmé';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échec';
      default:
        return preinscription.paymentStatus;
    }
  }

  Color _getPaymentStatusColor() {
    switch (preinscription.paymentStatus) {
      case 'paid':
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showValidationDialog(BuildContext context) {
    final commentsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider la préinscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir valider la préinscription de ${preinscription.firstName} ${preinscription.lastName}?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Commentaires (optionnel)',
                border: OutlineInputBorder(),
                hintText: 'Ajoutez des commentaires si nécessaire...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onValidate?.call(commentsController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter la préinscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir rejeter la préinscription de ${preinscription.firstName} ${preinscription.lastName}?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motif du rejet *',
                border: OutlineInputBorder(),
                hintText: 'Expliquez pourquoi vous rejetez cette préinscription...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                onReject?.call(reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }
}
