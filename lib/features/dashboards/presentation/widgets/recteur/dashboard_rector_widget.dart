import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/rector_dashboard_service.dart';
import '../../../../../core/providers/theme_provider.dart';

// Import pages for navigation
import '../../../../../features/preinscriptions_management/presentation/pages/preinscription_home_page.dart' as preinscriptions_mgmt;
import '../../../../../features/announcements_management/presentation/pages/announcement_home_page.dart';
import '../../../../../features/user_management/presentation/pages/user_management_page.dart';
import '../../../../../features/messaging/presentation/pages/messaging_home_page.dart';
import '../../../../../features/university/presentation/pages/university_management_page.dart';
import '../../../../../../features/faculty/presentation/pages/faculty_management_page.dart';
import '../../../../../../features/department/presentation/pages/department_management_page.dart';
import '../../../../../../features/program/presentation/pages/program_management_page.dart';
import '../../../../../../features/course/presentation/pages/course_management_page.dart';
import '../../../../../../features/institutions/presentation/pages/institutions_list_page.dart';
import '../../../../../features/student_management/presentation/pages/student_management_page.dart';
import '../../../../../features/profile/presentation/pages/professional_profile_page.dart';
import '../../../../../features/notifications/presentation/pages/notification_list_page.dart';
import '../../../../../features/preinscription/presentation/pages/preinscription_home_page.dart' as preinscription_student;

class DashboardRectorPage extends StatefulWidget {
  const DashboardRectorPage({super.key});

  @override
  State<DashboardRectorPage> createState() => _DashboardRectorPageState();
}

class _DashboardRectorPageState extends State<DashboardRectorPage> with TickerProviderStateMixin {
  bool _loading = true;
  String? _error;

  final ScrollController _scrollController = ScrollController();
  Timer? _stateChangeTimer;

  String _selectedPeriod = 'week';
  String _selectedFaculty = 'all';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 5, vsync: this);
    _loadDashboard();
  }

  @override
  void dispose() {
    _stateChangeTimer?.cancel();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > _scrollController.position.maxScrollExtent - 200) {
      // Load more data if needed
    }
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Simuler un chargement pour l'instant
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(isDarkMode),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet Aperçu
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(isDarkMode),
                      _buildQuickStats(isDarkMode),
                      _buildStrategicActions(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Onglet Académique
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstitutionalManagement(isDarkMode),
                      _buildAcademicOversight(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Onglet Personnel
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonnelManagement(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Onglet Rapports
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComplianceReports(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Onglet Administration
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAdministrativeTools(isDarkMode),
                      _buildRecentActivities(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDarkMode ? const Color(0xFF0A0E21) : const Color(0xFF4A90E2),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode 
                ? [const Color(0xFF4A90E2), const Color(0xFF50C9C3)]
                : [const Color(0xFF4A90E2), const Color(0xFF50C9C3)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Colors.white70),
          onPressed: () {
            _loadDashboard();
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: Colors.white70),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications - Bientôt disponible')),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: Colors.white70),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                Navigator.pushNamed(context, '/profile');
                break;
              case 'settings':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paramètres - Bientôt disponible')),
                );
                break;
              case 'logout':
                // TODO: Implémenter la déconnexion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Déconnexion - Bientôt disponible')),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'profile', child: Text('Mon Profil')),
            const PopupMenuItem(value: 'settings', child: Text('Paramètres')),
            const PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard_outlined), text: 'Aperçu'),
          Tab(icon: Icon(Icons.school_outlined), text: 'Académique'),
          Tab(icon: Icon(Icons.people_outline), text: 'Personnel'),
          Tab(icon: Icon(Icons.analytics_outlined), text: 'Rapports'),
          Tab(icon: Icon(Icons.settings_outlined), text: 'Administration'),
        ],
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorWeight: 2,
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, Rector',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Voici un aperçu de votre établissement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF7F8C8D),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              _buildInfoChip('Aujourd\'hui', Icons.today_outlined, isDarkMode),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip('8 Établissements', Icons.domain_outlined, isDarkMode),
              const SizedBox(width: 12),
              _buildInfoChip('45,000+ Étudiants', Icons.school_outlined, isDarkMode),
              const SizedBox(width: 12),
              _buildInfoChip('3,200+ Personnel', Icons.people_outline, isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF4A4A4A) : const Color(0xFFE8E8E8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDarkMode ? Colors.white70 : const Color(0xFF7F8C8D)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDarkMode) {
    return FutureBuilder<Map<String, int>>(
      future: RectorDashboardService.getQuickStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {
          'preinscriptions': 0,
          'students': 0,
          'staff': 0,
          'faculties': 0,
        };

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: const Color(0xFF3498DB),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildModernStatCard(
                    'Préinscriptions',
                    '${stats['preinscriptions']}',
                    Icons.app_registration_outlined,
                    Colors.orange.shade500,
                    isDarkMode,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const preinscriptions_mgmt.PreinscriptionHomePage()),
                    ),
                  ),
                  _buildModernStatCard(
                    'Étudiants',
                    '${stats['students']}',
                    Icons.school_outlined,
                    Colors.green.shade500,
                    isDarkMode,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StudentManagementPage()),
                    ),
                  ),
                  _buildModernStatCard(
                    'Personnel',
                    '${stats['staff']}',
                    Icons.people_outline,
                    Colors.blue.shade500,
                    isDarkMode,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserManagementPage()),
                    ),
                  ),
                  _buildModernStatCard(
                    'Facultés',
                    '${stats['faculties']}',
                    Icons.account_balance_outlined,
                    Colors.purple.shade500,
                    isDarkMode,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FacultyManagementPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color color, bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black12 : const Color(0x05000000),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF7F8C8D),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategicActions(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Stratégiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildModernActionCard(
                'Gestion des Préinscriptions',
                Icons.manage_accounts_outlined,
                Colors.purple.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const preinscriptions_mgmt.PreinscriptionHomePage()),
                ),
              ),
              _buildModernActionCard(
                'Rapports Institutionnels',
                Icons.analytics_outlined,
                Colors.indigo.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module rapports en cours de développement...'),
                      backgroundColor: Colors.indigo,
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                'Communications Officielles',
                Icons.campaign_outlined,
                Colors.red.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnnouncementHomePage()),
                ),
              ),
              _buildModernActionCard(
                'Notifications',
                Icons.notifications_outlined,
                Colors.teal.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationListPage()),
                ),
              ),
              _buildModernActionCard(
                'Gestion du Personnel',
                Icons.people_outline,
                Colors.green.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                ),
              ),
              _buildModernActionCard(
                'Préinscriptions Étudiant',
                Icons.school_outlined,
                Colors.amber.shade600,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const preinscription_student.PreinscriptionHomePage()),
                ),
              ),
              _buildModernActionCard(
                'Audit et Conformité',
                Icons.verified_outlined,
                Colors.orange.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module audit en cours de développement...'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                'Messagerie',
                Icons.message_outlined,
                Colors.blue.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagingHomePage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard(String title, IconData icon, Color color, bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black12 : const Color(0x05000000),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                height: 1.2,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionalManagement(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black12 : const Color(0x05000000),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion Institutionnelle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildManagementItem(
                'Universités',
                Icons.account_balance_outlined,
                const Color(0xFF3498DB),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UniversityManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Facultés',
                Icons.school_outlined,
                const Color(0xFF27AE60),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FacultyManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Départements',
                Icons.business_outlined,
                const Color(0xFFE67E22),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DepartmentManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Programmes',
                Icons.menu_book_outlined,
                const Color(0xFF9B59B6),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgramManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Cours',
                Icons.class_outlined,
                const Color(0xFFE74C3C),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CourseManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Institutions',
                Icons.location_city_outlined,
                const Color(0xFF34495E),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstitutionsListPage()),
                ),
              ),
              _buildManagementItem(
                'Profil Professionnel',
                Icons.person_outline,
                const Color(0xFF16A085),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfessionalProfilePage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementItem(String title, IconData icon, Color color, bool isDarkMode, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black12 : const Color(0x05000000),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                height: 1.2,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicOversight(bool isDarkMode) {
    return FutureBuilder<Map<String, dynamic>>(
      future: RectorDashboardService.getAcademicOversight(),
      builder: (context, snapshot) {
        final oversightData = snapshot.data ?? {
          'active_programs': 15,
          'research_projects': 42,
          'international_partnerships': 28,
          'accreditations': 12,
        };

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black12 : const Color(0x05000000),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      color: Color(0xFF3498DB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Supervision Académique',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildAcademicCard(
                    'Programmes d\'Études',
                    '${oversightData['active_programs']} programmes actifs',
                    Icons.menu_book_outlined,
                    const Color(0xFF9B59B6),
                    isDarkMode,
                  ),
                  _buildAcademicCard(
                    'Recherche Scientifique',
                    '${oversightData['research_projects']} projets en cours',
                    Icons.science_outlined,
                    const Color(0xFFE74C3C),
                    isDarkMode,
                  ),
                  _buildAcademicCard(
                    'Partenariats Internationaux',
                    '${oversightData['international_partnerships']} universités partenaires',
                    Icons.public_outlined,
                    const Color(0xFF27AE60),
                    isDarkMode,
                  ),
                  _buildAcademicCard(
                    'Accréditations',
                    '${oversightData['accreditations']} accréditations valides',
                    Icons.verified_outlined,
                    const Color(0xFFE67E22),
                    isDarkMode,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAcademicCard(String title, String subtitle, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black12 : const Color(0x05000000),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : const Color(0xFF7F8C8D),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOversightItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        ],
      ),
    );
  }

  Widget _buildComplianceReports(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapports de Conformité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildReportItem('Rapport Annuel', 'État des lieux de l\'université', Icons.description),
                _buildReportItem('Audit Financier', 'Validation des comptes et budgets', Icons.account_balance_wallet),
                _buildReportItem('Performance Académique', 'Statistiques et indicateurs', Icons.analytics),
                _buildReportItem('Conformité Réglementaire', 'Respect des normes ministérielles', Icons.gavel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String title, String description, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: TextStyle(color: Colors.grey[600])),
      trailing: Icon(Icons.download, color: Colors.blue),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Téléchargement du rapport...')),
        );
      },
    );
  }

  Widget _buildRecentActivities(bool isDarkMode) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: RectorDashboardService.getRecentActivities(),
      builder: (context, snapshot) {
        final activities = snapshot.data ?? [
          {'title': 'Nouvelles préinscriptions', 'count': 45, 'description': 'demandes en attente de validation', 'icon': 'person_add', 'color': 'orange'},
          {'title': 'Réunion du Conseil', 'count': 1, 'description': 'Prévue le 25 Décembre 2024', 'icon': 'groups', 'color': 'blue'},
          {'title': 'Audit Ministériel', 'count': 1, 'description': 'Visite prévue le 2 Janvier 2025', 'icon': 'verified', 'color': 'green'},
          {'title': 'Nouveaux programmes', 'count': 3, 'description': 'programmes en cours d\'approbation', 'icon': 'menu_book', 'color': 'purple'},
        ];

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activités Récentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black12 : const Color(0x05000000),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: activities.map((activity) {
                    return _buildActivityItem(
                      activity['title'] ?? '',
                      activity['count'] > 1 
                          ? '${activity['count']} ${activity['description']}'
                          : activity['description'] ?? '',
                      _getIconData(activity['icon'] ?? 'info'),
                      _getColorFromName(activity['color'] ?? 'blue'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'groups':
        return Icons.groups;
      case 'verified':
        return Icons.verified;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.info;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildActivityItem(String title, String description, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: TextStyle(color: Colors.grey[600])),
      trailing: Text(
        'Aujourd\'hui',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPersonnelManagement(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestion du Personnel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildModernActionCard(
                'Gestion du Personnel',
                Icons.people_outline,
                Colors.green.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementPage()),
                ),
              ),
              _buildModernActionCard(
                'Messagerie Interne',
                Icons.message_outlined,
                Colors.blue.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagingHomePage()),
                ),
              ),
              _buildModernActionCard(
                'Communications',
                Icons.campaign_outlined,
                Colors.red.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnnouncementHomePage()),
                ),
              ),
              _buildModernActionCard(
                'Notifications',
                Icons.notifications_outlined,
                Colors.teal.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationListPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrativeTools(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outils Administratifs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildModernActionCard(
                'Audit et Conformité',
                Icons.verified_outlined,
                Colors.orange.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module audit en cours de développement...'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                'Profil Professionnel',
                Icons.person_outline,
                Colors.indigo.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfessionalProfilePage()),
                ),
              ),
              _buildModernActionCard(
                'Universités',
                Icons.account_balance_outlined,
                Colors.purple.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UniversityManagementPage()),
                ),
              ),
              _buildModernActionCard(
                'Institutions',
                Icons.location_city_outlined,
                Colors.cyan.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstitutionsListPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const preinscriptions_mgmt.PreinscriptionHomePage()),
        );
      },
      backgroundColor: Colors.purple.shade600,
      icon: const Icon(Icons.manage_accounts, color: Colors.white),
      label: const Text('Gestion Préinscriptions', style: TextStyle(color: Colors.white)),
    );
  }
}
