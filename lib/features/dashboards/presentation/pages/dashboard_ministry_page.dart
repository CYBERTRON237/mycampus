import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../services/dashboard_service.dart';
import '../../../auth/services/auth_service.dart';
import '../../../user_management/providers/user_management_provider.dart';
import '../../../institutions/presentation/providers/institution_provider.dart';
import '../../../preinscriptions_management/providers/preinscription_provider.dart';
import '../../../announcements_management/presentation/providers/announcement_provider.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../constants/app_styles.dart';

// Imports des pages de tous les modules
import '../../../preinscriptions_management/presentation/pages/preinscription_home_page.dart';
import '../../../user_management/presentation/pages/user_management_page.dart';
import '../../../messaging/presentation/pages/messaging_home_page.dart';
import '../../../notifications/presentation/pages/notification_list_page.dart';
import '../../../profile/presentation/pages/professional_profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../institutions/presentation/pages/institutions_list_page.dart';
import '../../../university/presentation/pages/university_management_page.dart';
import '../../../course/presentation/pages/course_management_page.dart';
import '../../../program/presentation/pages/program_management_page.dart';
import '../../../department/presentation/pages/department_management_page.dart';
import '../../../faculty/presentation/pages/faculty_management_page.dart';
import '../../../announcements_management/presentation/pages/announcement_home_page.dart';
import '../../../preinscription_validation/presentation/pages/preinscription_validation_home_page.dart';
import '../../../student_management/presentation/pages/student_management_page.dart';

class DashboardMinistryPage extends StatefulWidget {
  const DashboardMinistryPage({super.key});

  @override
  State<DashboardMinistryPage> createState() => _DashboardMinistryPageState();
}

class _DashboardMinistryPageState extends State<DashboardMinistryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _dashboardData;
  late DashboardService _dashboardService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Initialize dashboard service and data immediately
    _initializeDashboard();
  }

  void _initializeDashboard() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      _dashboardService = DashboardService(
        client: http.Client(),
        authService: authService,
      );
      _dashboardData = _loadDashboardData();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }

      // Charger les données principales du dashboard
      final dashboardResult = await _dashboardService.getDashboardStats();
      
      // Charger les données spécifiques au ministère
      final ministryData = await _loadMinistrySpecificData(token);
      
      // Gérer le résultat Either
      Map<String, dynamic> dashboardDataMap = {};
      dashboardResult.fold(
        (error) {
          debugPrint('Erreur dashboard: $error');
        },
        (dashboardStats) {
          // Convertir DashboardStatsModel en Map
          dashboardDataMap = {
            'totalUsers': dashboardStats.totalUsers,
            'totalStudents': dashboardStats.totalStudents,
            'totalTeachers': dashboardStats.totalTeachers,
            'totalAdmins': dashboardStats.totalAdmins,
            'totalStaff': dashboardStats.totalStaff,
            'totalPreinscriptions': dashboardStats.totalPreinscriptions,
            'totalInstitutions': dashboardStats.totalInstitutions,
            'totalFaculties': dashboardStats.totalFaculties,
            'totalDepartments': dashboardStats.totalDepartments,
            'totalPrograms': dashboardStats.totalPrograms,
            'totalCourses': dashboardStats.totalCourses,
            'totalOpportunities': dashboardStats.totalOpportunities,
            'activeStudents': dashboardStats.activeStudents,
            'activeTeachers': dashboardStats.activeTeachers,
            'activeCourses': dashboardStats.activeCourses,
            'activeOpportunities': dashboardStats.activeOpportunities,
            'newUsersThisMonth': dashboardStats.newUsersThisMonth,
            'newInstitutionsThisMonth': dashboardStats.newInstitutionsThisMonth,
            'newCoursesThisMonth': dashboardStats.newCoursesThisMonth,
            'userGrowthRate': dashboardStats.userGrowthRate,
            'institutionGrowthRate': dashboardStats.institutionGrowthRate,
            'courseGrowthRate': dashboardStats.courseGrowthRate,
            'topInstitutions': dashboardStats.topInstitutions,
            'topFaculties': dashboardStats.topFaculties,
            'topPrograms': dashboardStats.topPrograms,
            'recentActivities': dashboardStats.recentActivities,
          };
        }
      );
      
      // Combiner toutes les données
      return {
        ...dashboardDataMap,
        ...ministryData,
      };
    } catch (e) {
      debugPrint('Erreur lors du chargement des données du dashboard ministériel: $e');
      return _getFallbackData();
    }
  }

  Future<Map<String, dynamic>> _loadMinistrySpecificData(String token) async {
    // Simuler des données spécifiques au ministère
    return {
      'nationalStats': {
        'totalUniversities': 8,
        'totalInstitutions': 45,
        'totalStudents': 125000,
        'totalTeachers': 8500,
        'totalStaff': 3200,
        'totalPreinscriptions': 15200,
        'totalPrograms': 320,
        'totalFaculties': 64,
        'totalDepartments': 180,
        'budgetAnnuel': 45000000000, // 45 milliards FCFA
        'accreditationEnCours': 12,
        'auditsEnCours': 8,
        'rapportsEnAttente': 15,
      },
      'regionalDistribution': {
        'Centre': { 'universities': 3, 'students': 55000, 'budget': 18000000000 },
        'Littoral': { 'universities': 2, 'students': 35000, 'budget': 12000000000 },
        'Ouest': { 'universities': 1, 'students': 18000, 'budget': 7000000000 },
        'Nord': { 'universities': 1, 'students': 12000, 'budget': 5000000000 },
        'Est': { 'universities': 1, 'students': 5000, 'budget': 3000000000 },
      },
      'performanceIndicators': {
        'tauxReussite': 78.5,
        'tauxEmployabilite': 85.2,
        'ratioEtudiantProf': 14.7,
        'couvertureNumerique': 92.3,
        'accreditationValidees': 56,
        'normesRespectees': 89.1,
      },
      'urgentActions': [
        { 'type': 'accreditation', 'count': 5, 'priority': 'high' },
        { 'type': 'audit', 'count': 3, 'priority': 'medium' },
        { 'type': 'rapport', 'count': 8, 'priority': 'low' },
      ],
    };
  }

  Map<String, dynamic> _getFallbackData() {
    return {
      'totalUsers': 150000,
      'activeUsers': 125000,
      'totalInstitutions': 45,
      'totalCourses': 5000,
      'recentActivities': [],
      'notifications': [],
      'nationalStats': {
        'totalUniversities': 8,
        'totalInstitutions': 45,
        'totalStudents': 125000,
        'totalTeachers': 8500,
        'totalStaff': 3200,
        'totalPreinscriptions': 15200,
        'totalPrograms': 320,
        'totalFaculties': 64,
        'totalDepartments': 180,
        'budgetAnnuel': 45000000000,
        'accreditationEnCours': 12,
        'auditsEnCours': 8,
        'rapportsEnAttente': 15,
      },
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Show loading if not initialized yet
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _dashboardData = _loadDashboardData();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? _getFallbackData();
          final nationalStats = data['nationalStats'] ?? {};

          return CustomScrollView(
            slivers: [
              // Header avec dégradé ministériel
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A237E), // Deep Blue
                          const Color(0xFF283593), // Indigo
                          const Color(0xFF3949AB), // Light Indigo
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Pattern de fond ministériel
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
                            child: CustomPaint(
                              painter: MinistryPatternPainter(),
                            ),
                          ),
                        ),
                        // Contenu du header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '',
                                          style: AppStyles.heading1.copyWith(
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '',
                                          style: AppStyles.bodyText2.copyWith(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  tabs: const [
                    Tab(text: 'Aperçu', icon: Icon(Icons.dashboard)),
                    Tab(text: 'National', icon: Icon(Icons.public)),
                    Tab(text: 'Supervision', icon: Icon(Icons.visibility)),
                    Tab(text: 'Rapports', icon: Icon(Icons.assessment)),
                    Tab(text: 'Politiques', icon: Icon(Icons.policy)),
                    Tab(text: 'Audit', icon: Icon(Icons.gavel)),
                  ],
                ),
              ),
              // Contenu des onglets
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(data, theme),
                    _buildNationalTab(data, theme),
                    _buildSupervisionTab(data, theme),
                    _buildReportsTab(data, theme),
                    _buildPoliciesTab(data, theme),
                    _buildAuditTab(data, theme),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Génération du rapport national en cours...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.file_download),
            label: const Text('Rapport National'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _dashboardData = _loadDashboardData();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Données actualisées'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: const Color(0xFF283593),
            foregroundColor: Colors.white,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> data, ThemeData theme) {
    final nationalStats = data['nationalStats'] ?? {};
    final urgentActions = data['urgentActions'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message de bienvenue ministériel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.1),
                  const Color(0xFF283593).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF1A237E).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.waving_hand,
                      color: const Color(0xFF1A237E),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue, Excellence',
                            style: AppStyles.heading2.copyWith(
                              color: const Color(0xFF1A237E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ministère de l\'Enseignement Supérieur - Supervision nationale',
                            style: AppStyles.bodyText2.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Universités',
                        '${nationalStats['totalUniversities'] ?? 0}',
                        Icons.account_balance,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Étudiants',
                        '${(nationalStats['totalStudents'] ?? 0).toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]} ',
                        )}',
                        Icons.school,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Budget',
                        '${(nationalStats['budgetAnnuel'] ?? 0) / 1000000000}B FCFA',
                        Icons.attach_money,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Statistiques nationales
          Text(
            'Statistiques Nationales',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Enseignants', '${nationalStats['totalTeachers'] ?? 0}', Icons.person, Colors.purple),
              _buildStatCard('Personnel', '${nationalStats['totalStaff'] ?? 0}', Icons.people, Colors.teal),
              _buildStatCard('Programmes', '${nationalStats['totalPrograms'] ?? 0}', Icons.book, Colors.indigo),
              _buildStatCard('Facultés', '${nationalStats['totalFaculties'] ?? 0}', Icons.business, Colors.red),
            ],
          ),

          const SizedBox(height: 24),

          // Actions urgentes
          Text(
            'Actions Urgentes',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...urgentActions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUrgentActionCard(action, theme),
          )),

          const SizedBox(height: 24),

          // Distribution régionale
          Text(
            'Distribution Régionale',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRegionalDistribution(data, theme),

          const SizedBox(height: 24),

          // Indicateurs de performance
          Text(
            'Indicateurs de Performance',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPerformanceIndicators(data, theme),

          const SizedBox(height: 24),

          // Tous les modules de l'application
          Text(
            'Modules de l\'Application',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAllModulesGrid(theme),
        ],
      ),
    );
  }

  Widget _buildNationalTab(Map<String, dynamic> data, ThemeData theme) {
    final nationalStats = data['nationalStats'] ?? {};
    final regionalDistribution = data['regionalDistribution'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vue d'ensemble nationale
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.1),
                  const Color(0xFF283593).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vue d\'Ensemble Nationale',
                  style: AppStyles.heading2.copyWith(
                    color: const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNationalMetric(
                        'Budget Annuel',
                        '${(nationalStats['budgetAnnuel'] ?? 0) / 1000000000} Milliards FCFA',
                        Icons.monetization_on,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildNationalMetric(
                        'Taux de Couverture',
                        '92.3%',
                        Icons.map,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Statistiques par région
          Text(
            'Statistiques par Région',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...regionalDistribution.entries.map((region) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRegionCard(region.key, region.value, theme),
          )),

          const SizedBox(height: 24),

          // Actions stratégiques nationales
          Text(
            'Actions Stratégiques Nationales',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildActionCard(
                'Accréditations',
                '${nationalStats['accreditationEnCours'] ?? 0} en cours',
                Icons.verified,
                Colors.green,
                () => _navigateToAccreditation(),
              ),
              _buildActionCard(
                'Audits Nationaux',
                '${nationalStats['auditsEnCours'] ?? 0} actifs',
                Icons.search,
                Colors.orange,
                () => _navigateToAudit(),
              ),
              _buildActionCard(
                'Rapports Ministériels',
                '${nationalStats['rapportsEnAttente'] ?? 0} en attente',
                Icons.description,
                Colors.blue,
                () => _navigateToReports(),
              ),
              _buildActionCard(
                'Politiques Éducatives',
                '8 politiques',
                Icons.policy,
                Colors.purple,
                () => _navigateToPolicies(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisionTab(Map<String, dynamic> data, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outils de supervision
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.1),
                  const Color(0xFF283593).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outils de Supervision Ministérielle',
                  style: AppStyles.heading2.copyWith(
                    color: const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Supervision et contrôle du système éducatif supérieur',
                  style: AppStyles.bodyText2.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Modules de supervision
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _buildSupervisionModule(
                'Supervision Universitaire',
                'Contrôle des établissements',
                Icons.account_balance,
                Colors.blue,
                () => _navigateToUniversitySupervision(),
              ),
              _buildSupervisionModule(
                'Accréditation Programmes',
                'Validation des cursus',
                Icons.verified,
                Colors.green,
                () => _navigateToProgramAccreditation(),
              ),
              _buildSupervisionModule(
                'Audit Financier',
                'Contrôle des budgets',
                Icons.account_balance_wallet,
                Colors.orange,
                () => _navigateToFinancialAudit(),
              ),
              _buildSupervisionModule(
                'Contrôle Qualité',
                'Normes et standards',
                Icons.check_circle,
                Colors.purple,
                () => _navigateToQualityControl(),
              ),
              _buildSupervisionModule(
                'Inspection Académique',
                'Visites et évaluations',
                Icons.find_in_page,
                Colors.red,
                () => _navigateToAcademicInspection(),
              ),
              _buildSupervisionModule(
                'Conformité Réglementaire',
                'Vérification réglementaire',
                Icons.gavel,
                Colors.teal,
                () => _navigateToRegulatoryCompliance(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tableau de bord de supervision
          Text(
            'Tableau de Bord de Supervision',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSupervisionDashboard(data, theme),

          const SizedBox(height: 24),

          // Actions immédiates
          Text(
            'Actions Immédiates',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchNationalInspection(),
                  icon: const Icon(Icons.launch),
                  label: const Text('Lancer Inspection Nationale'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _generateMinistryReport(),
                  icon: const Icon(Icons.assessment),
                  label: const Text('Rapport Ministériel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF283593),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab(Map<String, dynamic> data, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rapports disponibles
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.1),
                  const Color(0xFF283593).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rapports Ministériels',
                  style: AppStyles.heading2.copyWith(
                    color: const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Génération et consultation des rapports nationaux',
                  style: AppStyles.bodyText2.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Types de rapports
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildReportCard(
                'Rapport Annuel',
                'État des lieux national',
                Icons.calendar_today,
                Colors.blue,
                () => _generateAnnualReport(),
              ),
              _buildReportCard(
                'Performance Académique',
                'Statistiques académiques',
                Icons.school,
                Colors.green,
                () => _generateAcademicReport(),
              ),
              _buildReportCard(
                'Audit Financier',
                'Rapports financiers',
                Icons.attach_money,
                Colors.orange,
                () => _generateFinancialReport(),
              ),
              _buildReportCard(
                'Conformité',
                'Rapports de conformité',
                Icons.verified,
                Colors.purple,
                () => _generateComplianceReport(),
              ),
              _buildReportCard(
                'Accréditations',
                'Statut des accréditations',
                Icons.verified_user,
                Colors.red,
                () => _generateAccreditationReport(),
              ),
              _buildReportCard(
                'Rapport Personnalisé',
                'Créer un rapport',
                Icons.add_chart,
                Colors.teal,
                () => _createCustomReport(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Rapports récents
          Text(
            'Rapports Récents',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentReports(theme),
        ],
      ),
    );
  }

  Widget _buildPoliciesTab(Map<String, dynamic> data, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gestion des politiques
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.1),
                  const Color(0xFF283593).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Politiques Éducatives Nationales',
                  style: AppStyles.heading2.copyWith(
                    color: const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Définition et gestion des politiques éducatives',
                  style: AppStyles.bodyText2.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Politiques actives
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildPolicyCard(
                'Réforme LMD',
                'Système Licence-Master-Doctorat',
                Icons.school,
                Colors.blue,
                () => _manageLMDReform(),
              ),
              _buildPolicyCard(
                ' Assurance Qualité',
                'Normes qualité',
                Icons.verified,
                Colors.green,
                () => _manageQualityAssurance(),
              ),
              _buildPolicyCard(
                'Numérique Éducatif',
                'Transformation numérique',
                Icons.computer,
                Colors.orange,
                () => _manageDigitalTransformation(),
              ),
              _buildPolicyCard(
                'Internationalisation',
                'Partenariats internationaux',
                Icons.public,
                Colors.purple,
                () => _manageInternationalization(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Nouvelles politiques
          Text(
            'Nouvelles Politiques',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _createNewPolicy(),
            icon: const Icon(Icons.add),
            label: const Text('Créer une Nouvelle Politique'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTab(Map<String, dynamic> data, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tableau de bord d'audit
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E).withOpacity(0.1),
                  const Color(0xFF283593).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audit et Conformité Ministérielle',
                  style: AppStyles.heading2.copyWith(
                    color: const Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Supervision des audits et conformité réglementaire',
                  style: AppStyles.bodyText2.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions d'audit
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildAuditActionCard(
                'Lancer Audit National',
                'Audit complet du système',
                Icons.play_arrow,
                Colors.green,
                () => _launchNationalAudit(),
              ),
              _buildAuditActionCard(
                'Inspections Spécifiques',
                'Inspections ciblées',
                Icons.search,
                Colors.blue,
                () => _launchSpecificInspection(),
              ),
              _buildAuditActionCard(
                'Vérification Conformité',
                'Contrôle réglementaire',
                Icons.verified,
                Colors.orange,
                () => _checkCompliance(),
              ),
              _buildAuditActionCard(
                'Rapports d\'Audit',
                'Consulter les rapports',
                Icons.description,
                Colors.purple,
                () => _viewAuditReports(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Audits en cours
          Text(
            'Audits en Cours',
            style: AppStyles.heading2.copyWith(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCurrentAudits(theme),
        ],
      ),
    );
  }

  // Widgets helpers
  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppStyles.bodyText2.copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.heading3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppStyles.heading3.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppStyles.bodyText2.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentActionCard(Map<String, dynamic> action, ThemeData theme) {
    final priority = action['priority'] as String;
    final color = priority == 'high' ? Colors.red : 
                  priority == 'medium' ? Colors.orange : Colors.blue;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActionIcon(action['type']),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActionTitle(action['type']),
                  style: AppStyles.heading3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${action['count']} éléments requièrent votre attention',
                  style: AppStyles.bodyText2.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: color,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalDistribution(Map<String, dynamic> data, ThemeData theme) {
    final regionalDistribution = data['regionalDistribution'] ?? {} as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: regionalDistribution.entries.map<Widget>((region) {
          final regionData = region.value as Map<String, dynamic>;
          final percentage = ((regionData['students'] as int) / 125000 * 100).toStringAsFixed(1);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      region.key,
                      style: AppStyles.heading3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: AppStyles.bodyText2.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: double.parse(percentage) / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${regionData['universities']} universités • ${regionData['students']} étudiants',
                        style: AppStyles.bodyText2.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      '${(regionData['budget'] as int) / 1000000000}B FCFA',
                      style: AppStyles.bodyText2.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceIndicators(Map<String, dynamic> data, ThemeData theme) {
    final performance = data['performanceIndicators'] ?? {} as Map<String, dynamic>;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: performance.entries.map<Widget>((indicator) {
        final key = indicator.key as String;
        final value = (indicator.value as num).toDouble(); // Handle both int and double
        final color = value >= 80 ? Colors.green : 
                      value >= 60 ? Colors.orange : Colors.red;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getIndicatorTitle(key),
                style: AppStyles.bodyText2.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: AppStyles.heading3.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: value / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNationalMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppStyles.bodyText2.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.heading3.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCard(String regionName, Map<String, dynamic> regionData, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFF1A237E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                regionName,
                style: AppStyles.heading3.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRegionMetric(
                  'Universités',
                  '${regionData['universities']}',
                  Icons.account_balance,
                ),
              ),
              Expanded(
                child: _buildRegionMetric(
                  'Étudiants',
                  '${regionData['students']}',
                  Icons.school,
                ),
              ),
              Expanded(
                child: _buildRegionMetric(
                  'Budget',
                  '${(regionData['budget'] as int) / 1000000000}B',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionMetric(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.heading3.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: AppStyles.bodyText2.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
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
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppStyles.heading3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.bodyText2.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisionModule(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppStyles.heading3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.bodyText2.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisionDashboard(Map<String, dynamic> data, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildSupervisionItem('Accréditations en cours', '12', Colors.orange),
          const Divider(),
          _buildSupervisionItem('Audits planifiés', '8', Colors.blue),
          const Divider(),
          _buildSupervisionItem('Inspections complétées', '24', Colors.green),
          const Divider(),
          _buildSupervisionItem('Non-conformités', '3', Colors.red),
        ],
      ),
    );
  }

  Widget _buildSupervisionItem(String title, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppStyles.bodyText2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: AppStyles.bodyText2.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
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
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppStyles.heading3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.bodyText2.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports(ThemeData theme) {
    final reports = [
      { 'title': 'Rapport Annuel 2024', 'date': '15 Déc 2024', 'status': 'Complété' },
      { 'title': 'Audit UY1', 'date': '10 Déc 2024', 'status': 'En cours' },
      { 'title': 'Performance Académique', 'date': '5 Déc 2024', 'status': 'Complété' },
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: reports.map((report) => ListTile(
          leading: const Icon(Icons.description, color: Color(0xFF1A237E)),
          title: Text(report['title'] as String),
          subtitle: Text(report['date'] as String),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (report['status'] == 'Complété' ? Colors.green : Colors.orange).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              report['status'] as String,
              style: AppStyles.bodyText2.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: report['status'] == 'Complété' ? Colors.green : Colors.orange,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPolicyCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
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
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppStyles.heading3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.bodyText2.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
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
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppStyles.heading3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.bodyText2.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAudits(ThemeData theme) {
    final audits = [
      { 'title': 'Audit Financier UY1', 'progress': 75, 'deadline': '31 Déc 2024' },
      { 'title': 'Conformité FALSH', 'progress': 45, 'deadline': '15 Jan 2025' },
      { 'title': 'Qualité FS', 'progress': 90, 'deadline': '20 Déc 2024' },
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: audits.map((audit) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    audit['title'] as String,
                    style: AppStyles.heading3.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${audit['progress']}%',
                    style: AppStyles.bodyText2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (audit['progress'] as int) / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  audit['progress'] as int >= 75 ? Colors.green :
                  audit['progress'] as int >= 50 ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deadline: ${audit['deadline']}',
                style: AppStyles.bodyText2.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // Helper methods
  IconData _getActionIcon(String type) {
    switch (type) {
      case 'accreditation':
        return Icons.verified;
      case 'audit':
        return Icons.search;
      case 'rapport':
        return Icons.description;
      default:
        return Icons.info;
    }
  }

  String _getActionTitle(String type) {
    switch (type) {
      case 'accreditation':
        return 'Accréditations en attente';
      case 'audit':
        return 'Audits à planifier';
      case 'rapport':
        return 'Rapports à valider';
      default:
        return 'Action requise';
    }
  }

  String _getIndicatorTitle(String key) {
    switch (key) {
      case 'tauxReussite':
        return 'Taux de réussite';
      case 'tauxEmployabilite':
        return 'Taux d\'employabilité';
      case 'ratioEtudiantProf':
        return 'Ratio étudiant/prof';
      case 'couvertureNumerique':
        return 'Couverture numérique';
      case 'accreditationValidees':
        return 'Accréditations validées';
      case 'normesRespectees':
        return 'Normes respectées';
      default:
        return key;
    }
  }

  // Navigation methods
  void _navigateToAccreditation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers les accréditations...')),
    );
  }

  void _navigateToAudit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Module d\'audit en cours de développement...')),
    );
  }

  void _navigateToReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Module de rapports en cours de développement...')),
    );
  }

  void _navigateToPolicies() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers les politiques...')),
    );
  }

  void _navigateToUniversitySupervision() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers la supervision universitaire...')),
    );
  }

  void _navigateToProgramAccreditation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers l\'accréditation des programmes...')),
    );
  }

  void _navigateToFinancialAudit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers l\'audit financier...')),
    );
  }

  void _navigateToQualityControl() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers le contrôle qualité...')),
    );
  }

  void _navigateToAcademicInspection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers l\'inspection académique...')),
    );
  }

  void _navigateToRegulatoryCompliance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers la conformité réglementaire...')),
    );
  }

  void _launchNationalInspection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lancement de l\'inspection nationale...')),
    );
  }

  void _generateMinistryReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du rapport ministériel...')),
    );
  }

  void _generateAnnualReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du rapport annuel...')),
    );
  }

  void _generateAcademicReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du rapport académique...')),
    );
  }

  void _generateFinancialReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du rapport financier...')),
    );
  }

  void _generateComplianceReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du rapport de conformité...')),
    );
  }

  void _generateAccreditationReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du rapport d\'accréditation...')),
    );
  }

  void _createCustomReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création d\'un rapport personnalisé...')),
    );
  }

  void _manageLMDReform() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestion de la réforme LMD...')),
    );
  }

  void _manageQualityAssurance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestion de l\'assurance qualité...')),
    );
  }

  void _manageDigitalTransformation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestion de la transformation numérique...')),
    );
  }

  void _manageInternationalization() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestion de l\'internationalisation...')),
    );
  }

  void _createNewPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création d\'une nouvelle politique...')),
    );
  }

  void _launchNationalAudit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lancement de l\'audit national...')),
    );
  }

  void _launchSpecificInspection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lancement d\'inspections spécifiques...')),
    );
  }

  void _checkCompliance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vérification de la conformité...')),
    );
  }

  void _viewAuditReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consultation des rapports d\'audit...')),
    );
  }

  Widget _buildAllModulesGrid(ThemeData theme) {
    final modules = [
      {'title': 'Gestion Utilisateurs', 'icon': Icons.people, 'color': Colors.blue, 'page': UserManagementPage()},
      {'title': 'Préinscriptions', 'icon': Icons.app_registration, 'color': Colors.purple, 'page': PreinscriptionHomePage()},
      {'title': 'Messagerie', 'icon': Icons.message, 'color': Colors.green, 'page': MessagingHomePage()},
      {'title': 'Notifications', 'icon': Icons.notifications, 'color': Colors.orange, 'page': NotificationListPage()},
      {'title': 'Profil Professionnel', 'icon': Icons.person, 'color': Colors.indigo, 'page': ProfessionalProfilePage()},
      {'title': 'Paramètres', 'icon': Icons.settings, 'color': Colors.grey, 'page': SettingsPage()},
      {'title': 'Institutions', 'icon': Icons.account_balance, 'color': Colors.brown, 'page': InstitutionsListPage()},
      {'title': 'Universités', 'icon': Icons.school, 'color': Colors.blue, 'page': UniversityManagementPage()},
      {'title': 'Cours', 'icon': Icons.book, 'color': Colors.red, 'page': CourseManagementPage()},
      {'title': 'Programmes', 'icon': Icons.menu_book, 'color': Colors.teal, 'page': ProgramManagementPage()},
      {'title': 'Départements', 'icon': Icons.business, 'color': Colors.cyan, 'page': DepartmentManagementPage()},
      {'title': 'Facultés', 'icon': Icons.apartment, 'color': Colors.deepPurple, 'page': FacultyManagementPage()},
      {'title': 'Annonces', 'icon': Icons.campaign, 'color': Colors.amber, 'page': AnnouncementHomePage()},
      {'title': 'Validation Préinscriptions', 'icon': Icons.check_circle, 'color': Colors.lime, 'page': PreinscriptionValidationHomePage()},
      {'title': 'Gestion Étudiants', 'icon': Icons.school, 'color': Colors.lightBlue, 'page': StudentManagementPage()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => module['page'] as Widget),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (module['color'] as Color).withOpacity(0.1),
                    (module['color'] as Color).withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    module['icon'] as IconData,
                    size: 32,
                    color: module['color'] as Color?,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module['title'] as String,
                    textAlign: TextAlign.center,
                    style: AppStyles.bodyText2.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter pour le pattern ministériel
class MinistryPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    // Dessiner un pattern de lignes diagonales
    const spacing = 20;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
