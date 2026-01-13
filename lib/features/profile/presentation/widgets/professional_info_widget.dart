import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../models/profile_model.dart';

class ProfessionalInfoWidget extends StatelessWidget {
  final ProfessionalProfile? professionalInfo;
  final ProfileModel? profile;

  const ProfessionalInfoWidget({
    super.key,
    required this.professionalInfo,
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
                Icons.work,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Informations professionnelles',
                  style: AppStyles.heading3.copyWith(
                    color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Professional information from preinscription (for students)
          if (profile?.isStudent == true && professionalInfo != null) ...[
            _buildStudentProfessionalInfo(isDarkTheme),
          ] else if (professionalInfo != null) ...[
            _buildGeneralProfessionalInfo(isDarkTheme),
          ] else ...[
            _buildNoProfessionalInfo(isDarkTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentProfessionalInfo(bool isDarkTheme) {
    return Column(
      children: [
        // Professional situation
        if (professionalInfo?.professionalSituation != null) ...[
          _buildInfoCard(
            'Situation professionnelle',
            _getProfessionalSituationDisplay(professionalInfo!.professionalSituation!),
            Icons.business_center,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // First language
        if (professionalInfo?.firstLanguage != null) ...[
          _buildInfoCard(
            'Première langue',
            _getLanguageDisplay(professionalInfo!.firstLanguage!),
            Icons.language,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Residence address
        if (professionalInfo?.residenceAddress != null) ...[
          _buildInfoCard(
            'Adresse de résidence',
            professionalInfo!.residenceAddress!,
            Icons.home,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Marital status
        if (professionalInfo?.maritalStatus != null) ...[
          _buildInfoCard(
            'Situation maritale',
            _getMaritalStatusDisplay(professionalInfo!.maritalStatus!),
            Icons.favorite,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Phone number
        if (professionalInfo?.phoneNumber != null) ...[
          _buildInfoCard(
            'Téléphone',
            professionalInfo!.phoneNumber!,
            Icons.phone,
            isDarkTheme,
          ),
        ],
      ],
    );
  }

  Widget _buildGeneralProfessionalInfo(bool isDarkTheme) {
    return Column(
      children: [
        // Bio
        if (professionalInfo?.bio != null && professionalInfo!.bio!.isNotEmpty) ...[
          _buildBioCard(professionalInfo!.bio!, isDarkTheme),
          const SizedBox(height: 16),
        ],
        
        // Address
        if (professionalInfo?.fullAddress.isNotEmpty == true) ...[
          _buildInfoCard(
            'Adresse complète',
            professionalInfo!.fullAddress,
            Icons.location_on,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Phone
        if (professionalInfo?.phone != null) ...[
          _buildInfoCard(
            'Téléphone',
            professionalInfo!.phone!,
            Icons.phone,
            isDarkTheme,
          ),
          const SizedBox(height: 16),
        ],
        
        // Emergency contact
        if (professionalInfo?.emergencyContactInfo.isNotEmpty == true) ...[
          _buildInfoCard(
            'Contact d\'urgence',
            professionalInfo!.emergencyContactInfo,
            Icons.contact_phone,
            isDarkTheme,
            isHighlighted: true,
          ),
        ],
      ],
    );
  }

  Widget _buildNoProfessionalInfo(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: (isDarkTheme ? Colors.white10 : Colors.grey[100])?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
            size: 48,
            color: isDarkTheme ? Colors.white54 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune information professionnelle',
            style: AppStyles.bodyLarge.copyWith(
              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            profile?.isStudent == true
                ? 'Les informations professionnelles seront disponibles après validation de votre préinscription.'
                : 'Ajoutez vos informations professionnelles pour compléter votre profil.',
            style: AppStyles.bodyMedium.copyWith(
              color: isDarkTheme ? Colors.white54 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard(String bio, bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.white10 : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Biographie',
                style: AppStyles.caption.copyWith(
                  color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio,
            style: AppStyles.bodyMedium.copyWith(
              color: isDarkTheme ? Colors.white : AppColors.textPrimary,
            ),
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
              Icons.priority_high,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  String _getProfessionalSituationDisplay(String situation) {
    switch (situation) {
      case 'SANS EMPLOI':
        return 'Sans emploi';
      case 'SALARIE(E)':
        return 'Salarié(e)';
      case 'EN AUTO-EMPLOI':
        return 'Auto-entrepreneur';
      case 'STAGIAIRE':
        return 'Stagiaire';
      case 'RETRAITE(E)':
        return 'Retraité(e)';
      default:
        return situation;
    }
  }

  String _getLanguageDisplay(String language) {
    switch (language) {
      case 'FRANÇAIS':
        return 'Français';
      case 'ANGLAIS':
        return 'Anglais';
      case 'BILINGUE':
        return 'Bilingue (Français/Anglais)';
      default:
        return language;
    }
  }

  String _getMaritalStatusDisplay(String status) {
    switch (status) {
      case 'CELIBATAIRE':
        return 'Célibataire';
      case 'MARIE(E)':
        return 'Marié(e)';
      case 'DIVORCE(E)':
        return 'Divorcé(e)';
      case 'VEUF(VE)':
        return 'Veuf(ve)';
      default:
        return status;
    }
  }
}
