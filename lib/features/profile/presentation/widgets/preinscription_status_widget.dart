import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../models/profile_model.dart';

class PreinscriptionStatusWidget extends StatelessWidget {
  final PreinscriptionDetail? preinscription;

  const PreinscriptionStatusWidget({
    super.key,
    required this.preinscription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    if (preinscription == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.app_registration,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Statut de la préinscription',
                  style: AppStyles.heading3.copyWith(
                    color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(preinscription!.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(preinscription!.status).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  preinscription!.statusDisplay.toUpperCase(),
                  style: AppStyles.caption.copyWith(
                    color: _getStatusColor(preinscription!.status),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Status message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(preinscription!.status).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(preinscription!.status).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(preinscription!.status),
                  color: _getStatusColor(preinscription!.status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusMessage(preinscription!),
                    style: AppStyles.bodyMedium.copyWith(
                      color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Preinscription details
          _buildPreinscriptionDetails(isDarkTheme),
          
          const SizedBox(height: 20),
          
          // Action buttons
          _buildActionButtons(context, isDarkTheme),
        ],
      ),
    );
  }

  Widget _buildPreinscriptionDetails(bool isDarkTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de la préinscription',
          style: AppStyles.bodyLarge.copyWith(
            color: isDarkTheme ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildDetailRow(
          'Code unique',
          preinscription!.uniqueCode,
          Icons.qr_code,
          isDarkTheme,
        ),
        
        const SizedBox(height: 12),
        
        _buildDetailRow(
          'Faculté',
          preinscription!.faculty,
          Icons.school,
          isDarkTheme,
        ),
        
        const SizedBox(height: 12),
        
        _buildDetailRow(
          'Niveau d\'étude',
          preinscription!.studyLevel ?? 'Non spécifié',
          Icons.layers,
          isDarkTheme,
        ),
        
        const SizedBox(height: 12),
        
        _buildDetailRow(
          'Programme souhaité',
          preinscription!.desiredProgram ?? 'Non spécifié',
          Icons.book,
          isDarkTheme,
        ),
        
        const SizedBox(height: 12),
        
        _buildDetailRow(
          'Date de soumission',
          _formatDate(preinscription!.submissionDate),
          Icons.calendar_today,
          isDarkTheme,
        ),
        
        if (preinscription!.admissionNumber != null) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            'Numéro d\'admission',
            preinscription!.admissionNumber!,
            Icons.confirmation_number,
            isDarkTheme,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isDarkTheme,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.caption.copyWith(
                  color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(
                  color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDarkTheme) {
    return Column(
      children: [
        if (preinscription!.isPending) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/preinscription-detail',
                  arguments: preinscription!.uniqueCode,
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('Voir ma préinscription'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ] else if (preinscription!.isAccepted) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/preinscription-detail',
                  arguments: preinscription!.uniqueCode,
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Voir mon admission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ] else if (preinscription!.isRejected) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/preinscription-detail',
                  arguments: preinscription!.uniqueCode,
                );
              },
              icon: const Icon(Icons.info),
              label: const Text('Voir les détails'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/preinscription');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Soumettre une nouvelle préinscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'accepted':
      case 'confirmed':
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'under_review':
        return Icons.search;
      case 'accepted':
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      case 'deferred':
        return Icons.schedule;
      case 'waitlisted':
        return Icons.list;
      default:
        return Icons.help;
    }
  }

  String _getStatusMessage(PreinscriptionDetail preinscription) {
    switch (preinscription.status) {
      case 'pending':
        return 'Votre préinscription est en attente de validation par l\'administration. Vous serez notifié dès qu\'une décision sera prise.';
      case 'under_review':
        return 'Votre préinscription est actuellement en cours de révision par le comité d\'admission.';
      case 'accepted':
        return 'Félicitations ! Votre préinscription a été acceptée. Vous pouvez maintenant procéder à l\'inscription finale.';
      case 'confirmed':
        return 'Votre admission est confirmée. Bienvenue dans notre établissement !';
      case 'rejected':
        return 'Nous sommes désolés, votre préinscription n\'a pas été retenue. Vous pouvez consulter les motifs de rejet.';
      case 'cancelled':
        return 'Votre préinscription a été annulée à votre demande.';
      case 'deferred':
        return 'Votre préinscription a été reportée à une session ultérieure.';
      case 'waitlisted':
        return 'Vous êtes sur la liste d\'attente. Nous vous contacterons si une place se libère.';
      default:
        return 'Statut inconnu. Veuillez contacter l\'administration.';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Non spécifiée';
    }
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
