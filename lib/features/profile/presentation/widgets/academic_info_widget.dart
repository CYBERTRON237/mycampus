import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../models/profile_model.dart';

class AcademicInfoWidget extends StatelessWidget {
  final AcademicProfile? academicInfo;
  final ProfileModel? profile;

  const AcademicInfoWidget({
    super.key,
    required this.academicInfo,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

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
                Icons.school,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Informations académiques',
                  style: AppStyles.heading3.copyWith(
                    color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              if (profile?.hasValidPreinscription == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'VALIDÉ',
                    style: AppStyles.caption.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Academic information
          if (profile?.hasValidPreinscription == true) ...[
            _buildValidatedStudentInfo(isDarkTheme),
          ] else if (academicInfo != null) ...[
            _buildAcademicInfo(isDarkTheme),
          ] else ...[
            _buildNoAcademicInfo(isDarkTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildValidatedStudentInfo(bool isDarkTheme) {
    // Preinscription data is stored in academicInfo, not as a separate property
    final preinscriptionFaculty = academicInfo?.faculty;
    final preinscriptionStudyLevel = academicInfo?.studyLevel;
    final preinscriptionDesiredProgram = academicInfo?.desiredProgram;
    
    return Column(
      children: [
        // Institution info
        _buildInfoCard(
          'Établissement',
          preinscriptionFaculty ?? 'Université de Yaoundé I',
          Icons.account_balance,
          isDarkTheme,
        ),
        
        const SizedBox(height: 16),
        
        // Academic level
        _buildInfoCard(
          'Niveau d\'étude',
          preinscriptionStudyLevel ?? academicInfo?.level ?? 'Non spécifié',
          Icons.layers,
          isDarkTheme,
        ),
        
        const SizedBox(height: 16),
        
        // Program
        _buildInfoCard(
          'Programme',
          preinscriptionDesiredProgram ?? academicInfo?.desiredProgram ?? 'Non spécifié',
          Icons.book,
          isDarkTheme,
        ),
        
        const SizedBox(height: 16),
        
        // Student ID
        if (academicInfo?.studentId != null) ...[
          _buildInfoCard(
            'Numéro d\'admission',
            academicInfo!.studentId!,
            Icons.confirmation_number,
            isDarkTheme,
            isHighlighted: true,
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Registration date
        _buildInfoCard(
          'Date d\'inscription',
          _formatDate(academicInfo?.registrationDate),
          Icons.calendar_today,
          isDarkTheme,
        ),
        
        const SizedBox(height: 24),
        
        // Academic status badge
        _buildAcademicStatusBadge(isDarkTheme),
      ],
    );
  }

  Widget _buildAcademicInfo(bool isDarkTheme) {
    return Column(
      children: [
        // Institution
        if (academicInfo?.institutionName != null) ...[
          _buildInfoCard(
            'Établissement',
            academicInfo!.institutionName!,
            Icons.account_balance,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Department
        if (academicInfo?.departmentName != null) ...[
          _buildInfoCard(
            'Département',
            academicInfo!.departmentName!,
            Icons.business,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Level
        if (academicInfo?.level != null) ...[
          _buildInfoCard(
            'Niveau',
            academicInfo!.level!,
            Icons.layers,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Academic year
        if (academicInfo?.academicYear != null) ...[
          _buildInfoCard(
            'Année académique',
            academicInfo!.academicYear!,
            Icons.date_range,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Matricule
        if (academicInfo?.matricule != null) ...[
          _buildInfoCard(
            'Matricule',
            academicInfo!.matricule!,
            Icons.badge,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Student ID
        if (academicInfo?.studentId != null) ...[
          _buildInfoCard(
            'ID étudiant',
            academicInfo!.studentId!,
            Icons.credit_card,
            isDarkTheme,
          ),
        ],
      ],
    );
  }

  Widget _buildNoAcademicInfo(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (isDarkTheme ? Colors.white10 : Colors.grey[100])?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 48,
            color: isDarkTheme ? Colors.white54 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune information académique',
            style: AppStyles.bodyLarge.copyWith(
              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            profile?.isStudent == true
                ? 'Votre préinscription est en cours de validation.'
                : 'Les informations académiques ne sont pas disponibles pour votre rôle.',
            style: AppStyles.bodyMedium.copyWith(
              color: isDarkTheme ? Colors.white54 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    bool isDarkTheme, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (isDarkTheme ? AppColors.primary.withOpacity(0.2) : AppColors.primaryLight)
            : (isDarkTheme ? Colors.white10 : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isHighlighted ? AppColors.primary : AppColors.primary.withOpacity(0.8),
              size: 24,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppStyles.bodyLarge.copyWith(
                    color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isHighlighted) ...[
            Icon(
              Icons.verified,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcademicStatusBadge(bool isDarkTheme) {
    final status = _getAcademicStatus();
    final statusColor = _getAcademicStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getAcademicStatusIcon(status),
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getAcademicStatusMessage(status),
              style: AppStyles.bodyMedium.copyWith(
                color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAcademicStatus() {
    if (profile?.hasValidPreinscription == true) return 'validated';
    if (profile?.academicInfo.isPreinscriptionPending == true) return 'pending';
    if (academicInfo != null) return 'enrolled';
    return 'none';
  }

  Color _getAcademicStatusColor(String status) {
    switch (status) {
      case 'validated':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'enrolled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAcademicStatusIcon(String status) {
    switch (status) {
      case 'validated':
        return Icons.verified;
      case 'pending':
        return Icons.hourglass_empty;
      case 'enrolled':
        return Icons.school;
      default:
        return Icons.help_outline;
    }
  }

  String _getAcademicStatusMessage(String status) {
    switch (status) {
      case 'validated':
        return 'Préinscription validée - Étudiant officiel';
      case 'pending':
        return 'Préinscription en attente de validation';
      case 'enrolled':
        return 'Inscrit - Étudiant actif';
      default:
        return 'Statut académique non déterminé';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non spécifié';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
