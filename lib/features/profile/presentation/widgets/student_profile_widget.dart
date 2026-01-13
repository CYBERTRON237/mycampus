import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../models/profile_model.dart';

class StudentProfileWidget extends StatelessWidget {
  final ProfileModel profile;
  final PreinscriptionDetail? preinscription;

  const StudentProfileWidget({
    super.key,
    required this.profile,
    this.preinscription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Header avec photo et infos principales
          _buildProfileHeader(isDarkTheme),
          
          const SizedBox(height: 32),
          
          // Carte d'identité étudiante
          _buildStudentIdCard(context, isDarkTheme),
          
          const SizedBox(height: 24),
          
          // Informations académiques
          _buildAcademicInfoCard(isDarkTheme),
          
          const SizedBox(height: 24),
          
          // Contact et coordination
          _buildContactCard(isDarkTheme),
          
          const SizedBox(height: 24),
          
          // Contact d'urgence
          if (profile.professionalInfo.emergencyContact != null)
            _buildEmergencyContactCard(isDarkTheme),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo de profil
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: profile.basicInfo.profilePhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      profile.basicInfo.profilePhotoUrl!,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          
          const SizedBox(width: 20),
          
          // Infos principales
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.basicInfo.fullName,
                  style: AppStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: AppStyles.caption.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.basicInfo.email,
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final initials = profile.basicInfo.fullName
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .take(2)
        .join('');

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStudentIdCard(BuildContext context, bool isDarkTheme) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'CARTE D\'IDENTITÉ ÉTUDIANTE',
                style: AppStyles.heading3.copyWith(
                  color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Matricule et code
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Matricule',
                  profile.academicInfo.matricule ?? 'Non attribué',
                  Icons.badge,
                  isDarkTheme,
                  color: Colors.blue,
                  onTap: profile.academicInfo.matricule != null && profile.academicInfo.matricule != 'Non attribué'
                      ? () => _copyToClipboard(context, profile.academicInfo.matricule!)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Code Préinscription',
                  profile.academicInfo.preinscriptionCode ?? 'N/A',
                  Icons.confirmation_number,
                  isDarkTheme,
                  color: Colors.green,
                  onTap: profile.academicInfo.preinscriptionCode != null 
                      ? () => _copyToClipboard(context, profile.academicInfo.preinscriptionCode!)
                      : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Faculté et programme
          _buildInfoRow(
            'Faculté',
            profile.academicInfo.faculty ?? 'Non spécifiée',
            Icons.account_balance,
            isDarkTheme,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            'Programme',
            profile.academicInfo.desiredProgram ?? 'Non spécifié',
            Icons.book,
            isDarkTheme,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            'Niveau',
            profile.academicInfo.studyLevel ?? 'Non spécifié',
            Icons.trending_up,
            isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoCard(bool isDarkTheme) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_center,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'INFORMATIONS ACADÉMIQUES',
                style: AppStyles.heading3.copyWith(
                  color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoRow(
            'Université',
            profile.academicInfo.institutionName ?? 'Université de Yaoundé I',
            Icons.school,
            isDarkTheme,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            'Établissement',
            profile.academicInfo.institutionName ?? 'Université de Yaoundé I',
            Icons.location_city,
            isDarkTheme,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            'Département',
            profile.academicInfo.departmentName ?? 'Non spécifié',
            Icons.business,
            isDarkTheme,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            'Année académique',
            profile.academicInfo.academicYear ?? DateTime.now().year.toString(),
            Icons.calendar_today,
            isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(bool isDarkTheme) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.contact_phone,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'COORDONNÉES',
                style: AppStyles.heading3.copyWith(
                  color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (profile.basicInfo.phone != null)
            _buildInfoRow(
              'Téléphone',
              profile.basicInfo.phone!,
              Icons.phone,
              isDarkTheme,
            ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            'Email',
            profile.basicInfo.email,
            Icons.email,
            isDarkTheme,
          ),
          
          if (profile.professionalInfo.address != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Adresse',
              profile.professionalInfo.address!,
              Icons.location_on,
              isDarkTheme,
            ),
          ],
          
          if (profile.professionalInfo.city != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Ville',
              '${profile.professionalInfo.city}, ${profile.professionalInfo.region}',
              Icons.location_city,
              isDarkTheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(bool isDarkTheme) {
    final emergency = profile.professionalInfo.emergencyContact!;
    
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.emergency,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'CONTACT D\'URGENCE',
                style: AppStyles.heading3.copyWith(
                  color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInfoRow(
            'Nom',
            emergency.name ?? 'Non spécifié',
            Icons.person,
            isDarkTheme,
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            'Relation',
            emergency.relationship ?? 'Non spécifiée',
            Icons.family_restroom,
            isDarkTheme,
          ),
          
          const SizedBox(height: 12),
          
          if (emergency.phone != null)
            _buildInfoRow(
              'Téléphone',
              emergency.phone!,
              Icons.phone,
              isDarkTheme,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, bool isDarkTheme, {Color color = AppColors.primary, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppStyles.caption.copyWith(
                    color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(
                    Icons.copy,
                    color: color,
                    size: 16,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppStyles.bodyMedium.copyWith(
                color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Show snackbar or toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code copié: $text'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDarkTheme) {
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

  Color _getStatusColor() {
    final status = profile.academicInfo.preinscriptionStatus?.toLowerCase();
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText() {
    final status = profile.academicInfo.preinscriptionStatus?.toLowerCase();
    switch (status) {
      case 'accepted':
        return 'ADMIS';
      case 'pending':
        return 'EN ATTENTE';
      case 'rejected':
        return 'REJETÉ';
      default:
        return 'ÉTUDIANT';
    }
  }
}
