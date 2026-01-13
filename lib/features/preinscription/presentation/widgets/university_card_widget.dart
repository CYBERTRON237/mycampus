import 'package:flutter/material.dart';
import '../../models/university_model.dart';
import '../../../../constants/app_colors.dart';

class UniversityCardWidget extends StatelessWidget {
  final UniversityModel university;
  final VoidCallback? onTap;

  const UniversityCardWidget({
    super.key,
    required this.university,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkTheme
                  ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F)]
                  : [Colors.white, Colors.grey.shade50],
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkTheme 
                    ? Colors.black.withOpacity(0.3)
                    : _getUniversityColor(university.colorType).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: isDarkTheme ? Colors.white.withOpacity(0.1) : _getUniversityColor(university.colorType).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getUniversityColor(university.colorType),
                        _getUniversityColor(university.colorType).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getUniversityColor(university.colorType).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getUniversityIcon(university.iconType),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkTheme ? _getUniversityColor(university.colorType).withOpacity(0.2) : _getUniversityColor(university.colorType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          university.shortName,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getUniversityColor(university.colorType),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        university.formattedDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? _getUniversityColor(university.colorType).withOpacity(0.2) : _getUniversityColor(university.colorType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: _getUniversityColor(university.colorType),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getUniversityColor(String colorType) {
    switch (colorType.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      default:
        return AppColors.primary;
    }
  }

  IconData _getUniversityIcon(String iconType) {
    switch (iconType.toLowerCase()) {
      case 'school':
        return Icons.school;
      case 'account_balance':
        return Icons.account_balance;
      case 'business':
        return Icons.business;
      case 'location_city':
        return Icons.location_city;
      case 'agriculture':
        return Icons.agriculture;
      case 'terrain':
        return Icons.terrain;
      default:
        return Icons.school;
    }
  }
}
