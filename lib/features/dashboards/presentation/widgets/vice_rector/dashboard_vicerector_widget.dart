import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vice_rector_dashboard_service.dart';
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
import '../../../../../features/student_management/presentation/pages/student_management_page.dart';
import '../../../../../features/profile/presentation/pages/professional_profile_page.dart';
import '../../../../../features/notifications/presentation/pages/notification_list_page.dart';
import '../../../../../features/preinscription/presentation/pages/preinscription_home_page.dart' as preinscription_student;

class DashboardViceRectorPage extends StatefulWidget {
  const DashboardViceRectorPage({super.key});

  @override
  State<DashboardViceRectorPage> createState() => _DashboardViceRectorPageState();
}

class _DashboardViceRectorPageState extends State<DashboardViceRectorPage> with TickerProviderStateMixin {
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
    _tabController = TabController(length: 4, vsync: this);
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
                      _buildAcademicActions(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Onglet Académique
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAcademicManagement(isDarkMode),
                      _buildFacultyPerformance(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Onglet Supervision
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSupervisionTools(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                // Onglet Rapports
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportsSection(isDarkMode),
                      _buildRecentActivities(isDarkMode),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDarkMode ? const Color(0xFF0A0E21) : const Color(0xFF2E7D32),
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
                ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                : [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationListPage()),
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
          Tab(icon: Icon(Icons.visibility_outlined), text: 'Supervision'),
          Tab(icon: Icon(Icons.analytics_outlined), text: 'Rapports'),
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
            color: isDarkMode ? Colors.black26 : Colors.green.withOpacity(0.1),
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
                    colors: [Colors.green.shade400, Colors.teal.shade600],
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
                      'Bienvenue, Vice-Rector',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supervision académique et pédagogique',
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
              _buildInfoChip('6 Facultés', Icons.domain_outlined, isDarkMode),
              const SizedBox(width: 12),
              _buildInfoChip('12,500+ Étudiants', Icons.school_outlined, isDarkMode),
              const SizedBox(width: 12),
              _buildInfoChip('1,800+ Personnel', Icons.people_outline, isDarkMode),
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
      future: ViceRectorDashboardService.getQuickStats(),
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
                color: const Color(0xFF2E7D32),
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
                'Vue d\'ensemble académique',
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

  Widget _buildAcademicActions(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Académiques',
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
                'Validation Académique',
                Icons.verified_outlined,
                Colors.green.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module validation académique en cours de développement...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                'Supervision Facultés',
                Icons.visibility_outlined,
                Colors.teal.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FacultyManagementPage()),
                ),
              ),
              _buildModernActionCard(
                'Programmes d\'études',
                Icons.menu_book_outlined,
                Colors.indigo.shade500,
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgramManagementPage()),
                ),
              ),
              _buildModernActionCard(
                'Qualité Pédagogique',
                Icons.assessment_outlined,
                Colors.orange.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module qualité pédagogique en cours de développement...'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                'Recherche',
                Icons.science_outlined,
                Colors.purple.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module recherche en cours de développement...'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                'Partenariats',
                Icons.handshake_outlined,
                Colors.blue.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module partenariats en cours de développement...'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
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

  Widget _buildAcademicManagement(bool isDarkMode) {
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
            'Gestion Académique',
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
                'Facultés',
                Icons.school_outlined,
                const Color(0xFF2E7D32),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FacultyManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Départements',
                Icons.business_outlined,
                const Color(0xFF1976D2),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DepartmentManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Programmes',
                Icons.menu_book_outlined,
                const Color(0xFF7B1FA2),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProgramManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Cours',
                Icons.class_outlined,
                const Color(0xFFD32F2F),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CourseManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Étudiants',
                Icons.person_outline,
                const Color(0xFF388E3C),
                isDarkMode,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentManagementPage()),
                ),
              ),
              _buildManagementItem(
                'Profil Professionnel',
                Icons.badge_outlined,
                const Color(0xFF00796B),
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyPerformance(bool isDarkMode) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ViceRectorDashboardService.getFacultyPerformance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: const Color(0xFF2E7D32),
              ),
            ),
          );
        }

        final faculties = snapshot.data ?? [];

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
                'Performance des Facultés',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faculties.length,
                itemBuilder: (context, index) {
                  final faculty = faculties[index];
                  return _buildFacultyPerformanceItem(faculty, isDarkMode);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFacultyPerformanceItem(Map<String, dynamic> faculty, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1D1E33) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                faculty['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  '${faculty['success_rate'].toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPerformanceMetric('Étudiants', '${faculty['students']}', isDarkMode),
              const SizedBox(width: 16),
              _buildPerformanceMetric('Programmes', '${faculty['programs']}', isDarkMode),
              const SizedBox(width: 16),
              _buildPerformanceMetric('Satisfaction', '${faculty['satisfaction'].toStringAsFixed(1)}/5', isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.white60 : const Color(0xFF7F8C8D),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisionTools(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outils de Supervision',
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
              _buildSupervisionCard(
                'Audit Académique',
                Icons.assessment_outlined,
                Colors.red.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module audit académique en cours de développement...'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
              _buildSupervisionCard(
                'Évaluations',
                Icons.grading_outlined,
                Colors.orange.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module évaluations en cours de développement...'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
              _buildSupervisionCard(
                'Accréditations',
                Icons.verified_outlined,
                Colors.green.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module accréditations en cours de développement...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              _buildSupervisionCard(
                'Rapports Qualité',
                Icons.analytics_outlined,
                Colors.blue.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module rapports qualité en cours de développement...'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisionCard(String title, IconData icon, Color color, bool isDarkMode, VoidCallback onTap) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsSection(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapports Académiques',
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
              _buildReportCard(
                'Rapport Annuel',
                Icons.description_outlined,
                Colors.indigo.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Génération du rapport annuel...'),
                      backgroundColor: Colors.indigo,
                    ),
                  );
                },
              ),
              _buildReportCard(
                'Statistiques',
                Icons.bar_chart_outlined,
                Colors.teal.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statistiques académiques en préparation...'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                },
              ),
              _buildReportCard(
                'Performance',
                Icons.trending_up_outlined,
                Colors.green.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Analyse des performances en cours...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              _buildReportCard(
                'Recherche',
                Icons.science_outlined,
                Colors.purple.shade500,
                isDarkMode,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rapport de recherche en préparation...'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, Color color, bool isDarkMode, VoidCallback onTap) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(bool isDarkMode) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ViceRectorDashboardService.getRecentActivities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(
                color: const Color(0xFF2E7D32),
              ),
            ),
          );
        }

        final activities = snapshot.data ?? [];

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
                'Activités Récentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _buildActivityItem(activity, isDarkMode);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, bool isDarkMode) {
    Color priorityColor;
    IconData priorityIcon;
    
    switch (activity['priority']) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.warning;
        break;
      case 'low':
        priorityColor = Colors.green;
        priorityIcon = Icons.check_circle;
        break;
      default:
        priorityColor = Colors.grey;
        priorityIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1D1E33) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              priorityIcon,
              color: priorityColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.white60 : const Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }
}
