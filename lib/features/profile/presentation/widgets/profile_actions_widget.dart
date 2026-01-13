import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';

class ProfileActionsWidget extends StatelessWidget {
  final VoidCallback onViewPreinscription;
  final VoidCallback onEditProfile;
  final VoidCallback? onShareProfile;
  final VoidCallback? onPrintProfile;
  final VoidCallback? onDownloadPDF;

  const ProfileActionsWidget({
    super.key,
    required this.onViewPreinscription,
    required this.onEditProfile,
    this.onShareProfile,
    this.onPrintProfile,
    this.onDownloadPDF,
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
                Icons.dashboard_customize,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Actions rapides',
                style: AppStyles.heading3.copyWith(
                  color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Primary actions
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Voir ma préinscription',
                  Icons.visibility,
                  AppColors.primary,
                  onViewPreinscription,
                  isDarkTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Modifier le profil',
                  Icons.edit,
                  AppColors.secondary,
                  onEditProfile,
                  isDarkTheme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Secondary actions
          Row(
            children: [
              Expanded(
                child: _buildSecondaryActionButton(
                  context,
                  'Partager',
                  Icons.share,
                  onShareProfile ?? () {},
                  isDarkTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryActionButton(
                  context,
                  'Imprimer',
                  Icons.print,
                  onPrintProfile ?? () {
                    _showNotAvailableDialog(context, 'Impression');
                  },
                  isDarkTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSecondaryActionButton(
                  context,
                  'PDF',
                  Icons.picture_as_pdf,
                  onDownloadPDF ?? () {
                    _showNotAvailableDialog(context, 'Téléchargement PDF');
                  },
                  isDarkTheme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Additional options
          _buildAdditionalOptions(context, isDarkTheme),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDarkTheme,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    bool isDarkTheme,
  ) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
        side: BorderSide(
          color: isDarkTheme ? Colors.white24 : Colors.grey[300]!,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions(BuildContext context, bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.white10 : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options supplémentaires',
            style: AppStyles.caption.copyWith(
              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                context,
                'Historique',
                Icons.history,
                () => _showNotAvailableDialog(context, 'Historique'),
                isDarkTheme,
              ),
              _buildChip(
                context,
                'Documents',
                Icons.folder,
                () => _showNotAvailableDialog(context, 'Documents'),
                isDarkTheme,
              ),
              _buildChip(
                context,
                'Certificats',
                Icons.verified,
                () => _showNotAvailableDialog(context, 'Certificats'),
                isDarkTheme,
              ),
              _buildChip(
                context,
                'Paramètres',
                Icons.settings,
                () => Navigator.pushNamed(context, '/settings'),
                isDarkTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    bool isDarkTheme,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: isDarkTheme ? Colors.white12 : Colors.grey[200],
      labelStyle: AppStyles.caption.copyWith(
        color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isDarkTheme ? Colors.white24 : Colors.grey[300]!,
      ),
    );
  }

  void _showNotAvailableDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
