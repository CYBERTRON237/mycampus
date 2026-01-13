import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final double completionPercentage;

  const ProfileCompletionWidget({
    super.key,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final percentage = (completionPercentage * 100).round();

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
                Icons.assessment,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Complétion du profil',
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
                  color: _getCompletionColor(percentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCompletionColor(percentage).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$percentage%',
                  style: AppStyles.caption.copyWith(
                    color: _getCompletionColor(percentage),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDarkTheme ? Colors.white10 : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completionPercentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCompletionColor(percentage),
                      _getCompletionColor(percentage).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status message
          Row(
            children: [
              Icon(
                _getCompletionIcon(percentage),
                color: _getCompletionColor(percentage),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCompletionMessage(percentage),
                  style: AppStyles.bodyMedium.copyWith(
                    color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Suggestions
          if (percentage < 100) ...[
            _buildSuggestions(isDarkTheme),
          ],
        ],
      ),
    );
  }

 Widget _buildSuggestions(bool isDarkTheme) {
    final suggestions = _getSuggestions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions pour compléter votre profil:',
          style: AppStyles.caption.copyWith(
            color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.radio_button_unchecked,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: AppStyles.bodySmall.copyWith(
                    color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getCompletionIcon(int percentage) {
    if (percentage >= 80) return Icons.check_circle;
    if (percentage >= 50) return Icons.warning;
    return Icons.error;
  }

  String _getCompletionMessage(int percentage) {
    if (percentage >= 80) return 'Profil presque complet !';
    if (percentage >= 50) return 'Profil en cours de complétion';
    return 'Profil incomplet - Complétez-le pour une meilleure expérience';
  }

  List<String> _getSuggestions() {
    final suggestions = <String>[];
    
    if (completionPercentage < 0.3) {
      suggestions.addAll([
        'Ajoutez votre photo de profil',
        'Complétez vos informations personnelles',
        'Ajoutez votre adresse et contact d\'urgence',
      ]);
    } else if (completionPercentage < 0.6) {
      suggestions.addAll([
        'Ajoutez votre biographie',
        'Complétez vos informations professionnelles',
      ]);
    } else if (completionPercentage < 0.8) {
      suggestions.addAll([
        'Vérifiez que toutes vos informations sont à jour',
        'Ajoutez des détails supplémentaires',
      ]);
    }
    
    return suggestions;
  }
}
