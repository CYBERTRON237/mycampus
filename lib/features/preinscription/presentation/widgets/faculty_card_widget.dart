import 'package:flutter/material.dart';
import 'package:mycampus/features/faculty/domain/models/faculty_model.dart';
import 'package:mycampus/constants/app_colors.dart';

class FacultyCardWidget extends StatelessWidget {
  final FacultyModel faculty;
  final VoidCallback onTap;

  const FacultyCardWidget({
    Key? key,
    required this.faculty,
    required this.onTap,
  }) : super(key: key);

  Color _getFacultyColor(String facultyType) {
    switch (facultyType.toLowerCase()) {
      case 'sciences':
        return Colors.blue;
      case 'lettres':
        return Colors.purple;
      case 'droit':
        return Colors.indigo;
      case 'médecine':
        return Colors.red;
      case 'économie':
        return Colors.green;
      case 'technologie':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getFacultyIcon(String facultyType) {
    switch (facultyType.toLowerCase()) {
      case 'sciences':
        return Icons.science;
      case 'lettres':
        return Icons.menu_book;
      case 'droit':
        return Icons.gavel;
      case 'médecine':
        return Icons.local_hospital;
      case 'économie':
        return Icons.trending_up;
      case 'technologie':
        return Icons.computer;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final facultyColor = _getFacultyColor(faculty.name);
    final facultyIcon = _getFacultyIcon(faculty.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkTheme 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: facultyColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec icône et nom
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            facultyColor,
                            facultyColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: facultyColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        facultyIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faculty.name,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            faculty.shortName,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: faculty.status == FacultyStatus.active 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: faculty.status == FacultyStatus.active 
                              ? Colors.green
                              : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        faculty.status == FacultyStatus.active ? 'Active' : 'InActive',
                        style: TextStyle(
                          color: faculty.status == FacultyStatus.active 
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                if (faculty.description != null && faculty.description!.isNotEmpty) ...[
                  Text(
                    faculty.description!,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],

                // Informations supplémentaires
                Row(
                  children: [
                    if (faculty.deanName != null && faculty.deanName!.isNotEmpty) ...[
                      Icon(
                        Icons.person,
                        size: 16,
                        color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Doyen: ${faculty.deanName}',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (faculty.totalDepartments > 0) ...[
                      Icon(
                        Icons.business,
                        size: 16,
                        color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${faculty.totalDepartments} département${faculty.totalDepartments > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (faculty.totalPrograms > 0) ...[
                      Icon(
                        Icons.school,
                        size: 16,
                        color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${faculty.totalPrograms} programme${faculty.totalPrograms > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),

                // Contact
                if (faculty.contactEmail != null || faculty.contactPhone != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (faculty.contactEmail != null) ...[
                        Icon(
                          Icons.email,
                          size: 16,
                          color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            faculty.contactEmail!,
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (faculty.contactPhone != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          faculty.contactPhone!,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                // Bouton d'action
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        facultyColor,
                        facultyColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: facultyColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Choisir cette faculté'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
