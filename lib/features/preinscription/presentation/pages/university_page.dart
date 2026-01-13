import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/constants/app_colors.dart';
import 'package:mycampus/core/providers/theme_provider.dart';

class UniversityPage extends StatelessWidget {
  final String universityName;
  final String universityCode;
  
  const UniversityPage({
    Key? key,
    required this.universityName,
    required this.universityCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    // Définir les facultés selon l'université
    final List<Map<String, dynamic>> faculties = _getFacultiesForUniversity(universityCode);
    
    return Scaffold(
      backgroundColor: isDarkTheme ? const Color(0xFF0A0E21) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          universityName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkTheme
                  ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F)]
                  : [AppColors.primary, AppColors.primaryDark],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkTheme
                ? [const Color(0xFF0A0E21), const Color(0xFF1D1E33)]
                : [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Bannière
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkTheme
                        ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F), const Color(0xFF0A0E21)]
                        : [AppColors.primary, AppColors.primaryDark, AppColors.accent],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        'FACULTÉS ET ÉCOLES',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choisissez votre faculté ou école',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Liste des facultés
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: faculties.map((faculty) => _buildFacultyCard(
                    context,
                    faculty['name']!,
                    faculty['code']!,
                    faculty['description']!,
                    faculty['icon']!,
                    faculty['color']!,
                    faculty['hasForm']!,
                    isDarkTheme,
                  )).toList(),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyCard(
    BuildContext context,
    String name,
    String code,
    String description,
    IconData icon,
    Color color,
    bool hasForm,
    bool isDarkTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            if (hasForm) {
              if (code == 'FS') {
                Navigator.pushNamed(context, '/preinscription/fs');
              } else if (code == 'FALSH') {
                Navigator.pushNamed(context, '/preinscription/falsh');
              } else if (code == 'FSE') {
                Navigator.pushNamed(context, '/preinscription/fse');
              } else if (code == 'FMSB') {
                Navigator.pushNamed(context, '/preinscription/fmsb');
              } else if (code == 'IUT') {
                Navigator.pushNamed(context, '/preinscription/iut');
              } else if (code == 'ENSP') {
                Navigator.pushNamed(context, '/preinscription/enspy');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Le formulaire pour $name sera bientôt disponible.'),
                    backgroundColor: Colors.orange.shade700,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Le formulaire pour $name sera bientôt disponible.'),
                  backgroundColor: Colors.orange.shade700,
                ),
              );
            }
          },
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
                      : color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: isDarkTheme ? Colors.white.withOpacity(0.1) : color.withOpacity(0.1),
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
                        colors: [color, color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
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
                            color: hasForm 
                                ? (isDarkTheme ? color.withOpacity(0.2) : color.withOpacity(0.1))
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hasForm ? 'DISPONIBLE' : 'BIENTÔT',
                            style: TextStyle(
                              fontSize: 12,
                              color: hasForm ? color : Colors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
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
                      color: hasForm 
                          ? (isDarkTheme ? color.withOpacity(0.2) : color.withOpacity(0.1))
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hasForm ? Icons.arrow_forward_rounded : Icons.schedule,
                      color: hasForm ? color : Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFacultiesForUniversity(String universityCode) {
    switch (universityCode) {
      case 'UY1':
        return [
          {
            'name': 'Faculté des Arts, Lettres et Sciences Humaines',
            'code': 'FALSH',
            'description': 'Culture, créativité et savoir humain',
            'icon': Icons.psychology,
            'color': AppColors.secondary,
            'hasForm': true,
          },
          {
            'name': 'Faculté des Sciences',
            'code': 'FS',
            'description': 'Excellence scientifique et innovation',
            'icon': Icons.science,
            'color': Colors.green,
            'hasForm': true,
          },
          {
            'name': 'Faculté des Sciences de l\'Éducation',
            'code': 'FSE',
            'description': 'Formation des enseignants et recherche en éducation',
            'icon': Icons.school,
            'color': Colors.blue,
            'hasForm': true,
          },
          {
            'name': 'Faculté de Médecine et des Sciences Biomédicales',
            'code': 'FMSB',
            'description': 'Santé, médecine et sciences biomédicales',
            'icon': Icons.local_hospital,
            'color': Colors.red,
            'hasForm': true,
          },
          {
            'name': 'École Nationale Supérieure Polytechnique',
            'code': 'ENSP',
            'description': 'Ingénierie et technologie de pointe',
            'icon': Icons.engineering,
            'color': Colors.orange,
            'hasForm': true,
          },
          {
            'name': 'Institut Universitaire de Technologies du Bois de Mbalmayo',
            'code': 'IUT',
            'description': 'Technologies du bois et industries connexes',
            'icon': Icons.forest,
            'color': Colors.green,
            'hasForm': true,
          },
        ];
      case 'UY2':
        return [
          {
            'name': 'Faculté des Sciences Juridiques et Politiques',
            'code': 'FSJP',
            'description': 'Droit, sciences politiques et relations internationales',
            'icon': Icons.gavel,
            'color': Colors.purple,
            'hasForm': false,
          },
          {
            'name': 'Faculté des Sciences Économiques et de Gestion',
            'code': 'FSEG',
            'description': 'Économie, gestion et commerce',
            'icon': Icons.trending_up,
            'color': Colors.green,
            'hasForm': false,
          },
        ];
      case 'UB':
        return [
          {
            'name': 'Faculté des Sciences',
            'code': 'FS',
            'description': 'Sciences fondamentales et appliquées',
            'icon': Icons.science,
            'color': Colors.blue,
            'hasForm': false,
          },
          {
            'name': 'Faculté des Lettres et Sciences Humaines',
            'code': 'FLSH',
            'description': 'Lettres, langues et sciences humaines',
            'icon': Icons.menu_book,
            'color': Colors.brown,
            'hasForm': false,
          },
        ];
      default:
        return [
          {
            'name': 'Faculté des Sciences',
            'code': 'FS',
            'description': 'Excellence scientifique et innovation',
            'icon': Icons.science,
            'color': Colors.green,
            'hasForm': false,
          },
        ];
    }
  }
}
