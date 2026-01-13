import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mycampus/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/core/providers/theme_provider.dart';
import 'package:mycampus/core/widgets/main_navigation.dart';
import 'package:mycampus/features/auth/services/auth_service.dart';

class PreinscriptionInfoPage extends StatefulWidget {
  const PreinscriptionInfoPage({Key? key}) : super(key: key);

  @override
  State<PreinscriptionInfoPage> createState() => _PreinscriptionInfoPageState();
}

class _PreinscriptionInfoPageState extends State<PreinscriptionInfoPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Scaffold(
      backgroundColor: isDarkTheme ? const Color(0xFF0A0E21) : Colors.grey.shade50,
      appBar: CustomAppBar(
        title: 'Préinscriptions UY1 2025-2026',
        isDarkTheme: isDarkTheme,
        user: authService.currentUser,
        onThemeToggle: () => themeProvider.toggleTheme(),
        onProfileTap: () {
          Navigator.pushReplacementNamed(context, '/profile');
        },
        onSettingsTap: () {
          Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                'Procédure de préinscription en ligne',
                [
                  'Les préinscriptions pour l\'année académique 2025-2026 à l\'Université de Yaoundé I sont ouvertes du lundi 11 août 2025 au vendredi 26 septembre 2025.',
                  'Lisez toutes les informations contenues dans cette page, puis cliquez sur l\'établissement de votre choix.',
                  'Réglez vos droits de préinscriptions selon les modalités indiquées.',
                  'Remplissez vos informations et enregistrez en cliquant sur le bouton "Valider".',
                  'Après validation, imprimez la fiche obtenue qui contient votre identifiant unique.'
                ],
                Icons.info_outline,
                Colors.blue,
                isDarkTheme,
              ),
              
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Modalités de paiement',
                [
                  'Frais de préinscription : 10 000 FCFA',
                  'Paiement possible dans les agences agréées à travers le pays.',
                  'Conservez précieusement votre reçu de paiement.'
                ],
                Icons.payment,
                Colors.green,
                isDarkTheme,
              ),
              
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Pièces à fournir pour le dépôt physique du dossier',
                [
                  'Reçu de paiement des frais de préinscription (10 000 FCFA)',
                  '02 exemplaires de votre fiche de préinscription',
                  'Photocopie Certifiée Conforme du Relevé de Notes du Baccalauréat',
                  'Photocopie Certifiée Conforme du Probatoire/GCE-O Level ou de l\'Attestation de Réussite',
                  'Pour la Faculté des Sciences de l\'Éducation : Photocopie Certifiée Conforme du diplôme de Licence ou équivalent',
                  'Photocopie certifiée conforme de l\'Acte de naissance',
                  '04 photos couleurs 4x4'
                ],
                Icons.folder_open,
                Colors.orange,
                isDarkTheme,
              ),
              
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Calendrier important',
                [
                  'Date limite de dépôt des dossiers : 26 septembre 2025',
                  'Publication des listes d\'admission : À partir du 15 septembre 2025',
                  'Visites médicales : Au cours du 1er mois du 1er semestre',
                  'Rentrée universitaire : 15 septembre 2025'
                ],
                Icons.calendar_today,
                Colors.purple,
                isDarkTheme,
              ),
              
              const SizedBox(height: 24),
              _buildEtablissementsSection(context),
              
              const SizedBox(height: 24),
              _buildInfoCard(
                context,
                'Important',
                'Seuls les baccalauréats délivrés par l\'Office du Baccalauréat du Cameroun (ou admis en équivalence) et les GCE délivrés par le GCE Board (ou les GCE admis en équivalence) sont acceptés. Les Brevets de Techniciens ne sont pas reçus.',
                Icons.warning_amber_rounded,
                Colors.amber,
                isDarkTheme,
              ),
              
              const SizedBox(height: 24),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkTheme
                          ? [Colors.grey.shade800, Colors.grey.shade700]
                          : [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkTheme 
                            ? Colors.black.withOpacity(0.3)
                            : AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour à la sélection de formation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items, IconData icon, Color color, bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F)]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkTheme ? Colors.white.withOpacity(0.1) : color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : color,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Container(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkTheme ? Colors.white.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: isDarkTheme ? Colors.white70 : color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content, IconData icon, Color color, bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? [color.withOpacity(0.15), color.withOpacity(0.08)]
              : [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme ? color.withOpacity(0.3) : color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme ? Colors.black.withOpacity(0.3) : color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: isDarkTheme ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtablissementsSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    final List<Map<String, dynamic>> etablissements = [
      {'name': 'Faculté des Arts, Lettres et Sciences Humaines', 'hasForm': true},
      {'name': 'Faculté des Sciences (FS)', 'hasForm': true},
      {'name': 'Faculté des Sciences de l\'Éducation (FSE)', 'hasForm': false},
      {'name': 'Faculté de Médecine et des Sciences Biomédicales (FMSB)', 'hasForm': false},
      {'name': 'Institut Universitaire des Technologies du Bois de Mbalmayo', 'hasForm': false},
      {'name': 'École Nationale Supérieure Polytechnique de Yaoundé', 'hasForm': false},
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme
              ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F)]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDarkTheme ? Colors.white.withOpacity(0.1) : Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red, Colors.red.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  'ÉTABLISSEMENTS',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...etablissements.map((etablissement) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                  if (etablissement['hasForm'] == true) {
                    if (etablissement['name'].contains('FALSH')) {
                      Navigator.pushNamed(context, '/preinscription/falsh');
                    } else if (etablissement['name'].contains('Sciences (FS)')) {
                      Navigator.pushNamed(context, '/preinscription/fs');
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Le formulaire de préinscription pour ${etablissement['name']} sera bientôt disponible.'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: isDarkTheme ? Colors.grey.shade700 : Colors.orange.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                splashColor: etablissement['hasForm'] == true 
                    ? Colors.green.withOpacity(0.3) 
                    : Colors.blue.withOpacity(0.3),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: etablissement['hasForm'] == true
                          ? (isDarkTheme 
                              ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
                              : [Colors.green.shade50, Colors.green.shade100])
                          : (isDarkTheme
                              ? [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)]
                              : [Colors.blue.shade50, Colors.grey.shade100]),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: etablissement['hasForm'] == true
                          ? (isDarkTheme ? Colors.green.withOpacity(0.3) : Colors.green.shade600)
                          : (isDarkTheme ? Colors.blue.withOpacity(0.2) : Colors.blue.shade300),
                      width: etablissement['hasForm'] == true ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: etablissement['hasForm'] == true
                            ? (isDarkTheme ? Colors.green.withOpacity(0.2) : Colors.green.shade200)
                            : (isDarkTheme ? Colors.blue.withOpacity(0.1) : Colors.blue.shade100),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: etablissement['hasForm'] == true
                                ? [Colors.green, Colors.green.withOpacity(0.8)]
                                : [Colors.blue, Colors.blue.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: etablissement['hasForm'] == true
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          etablissement['hasForm'] == true
                              ? Icons.play_arrow_rounded
                              : Icons.touch_app_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          etablissement['name']!,
                          style: TextStyle(
                            color: isDarkTheme 
                                ? Colors.white70
                                : (etablissement['hasForm'] == true
                                    ? Colors.green.shade800
                                    : Colors.blue.shade800),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (etablissement['hasForm'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.green.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'CLIQUEZ ICI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkTheme ? Colors.grey.shade600 : Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'BIENTÔT',
                            style: TextStyle(
                              color: isDarkTheme ? Colors.white70 : Colors.blue.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0, // Page info n'est pas dans la navigation principale, on utilise 0 par défaut
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              // Explorer - non implémenté
              break;
            case 2:
              // Messages - non implémenté
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: themeProvider.isDarkTheme ? Colors.white : Colors.blue.shade600,
        unselectedItemColor: isDarkTheme ? Colors.white54 : Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            activeIcon: Icon(Icons.message_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
