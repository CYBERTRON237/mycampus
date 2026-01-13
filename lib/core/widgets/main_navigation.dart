import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../features/dashboards/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/professional_profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/messaging/presentation/pages/messaging_home_page.dart';
import '../../features/notifications/presentation/pages/notification_list_page.dart';
import '../../features/user_management/presentation/pages/user_management_page.dart';
import '../../features/institutions/presentation/pages/institutions_list_page.dart';
import '../../features/university/presentation/pages/university_management_page.dart';
import '../../features/course/presentation/pages/course_management_page.dart';
import '../../features/program/presentation/pages/program_management_page.dart';
import '../../features/department/presentation/pages/department_management_page.dart';
import '../../features/faculty/presentation/pages/faculty_management_page.dart';
import '../../features/student_management/presentation/pages/enhanced_student_management_page.dart';
import '../../features/preinscription/presentation/pages/preinscription_home_page.dart' as preinscription;
import '../../features/preinscription/presentation/pages/preinscription_form_page.dart';
import '../../features/preinscriptions_management/presentation/pages/preinscription_home_page.dart' as preinscriptions_management;
import '../../features/announcements_management/presentation/pages/announcement_home_page.dart';
import '../providers/theme_provider.dart';
import '../services/navigation_service.dart';
import '../models/navigation_item_model.dart';
import '../widgets/comprehensive_navigation_drawer.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/models/user_model.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isDarkTheme;
  final UserModel? user;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isDarkTheme = false,
    this.user,
    this.onThemeToggle,
    this.onNotificationTap,
    this.onProfileTap,
    this.onSettingsTap,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(120);
}

class _CustomAppBarState extends State<CustomAppBar> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  bool _hasNotifications = true;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkTheme
              ? [
                  const Color(0xFF1D1E33),
                  const Color(0xFF0A0E21),
                ]
              : [
                  Colors.white,
                  Colors.grey.shade50,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: widget.isDarkTheme ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1000),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Text(
                                'Bienvenue!',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.isDarkTheme ? Colors.white60 : Colors.black45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildThemeToggle(),
                  const SizedBox(width: 8),
                  _buildProfileButton(),
                  const SizedBox(width: 8),
                  _buildSettingsButton(),
                  const SizedBox(width: 8),
                  _buildNotificationButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 0.1,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.cyan.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: widget.onThemeToggle,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDarkTheme
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  widget.isDarkTheme ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(widget.isDarkTheme),
                  color: widget.isDarkTheme ? Colors.amber : Colors.blue.shade800,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileButton() {
    return IconButton(
      icon: Icon(
        Icons.person_rounded,
        size: 24,
        color: widget.isDarkTheme ? Colors.white70 : Colors.black54,
      ),
      onPressed: widget.onProfileTap ?? () {
        // Naviguer vers l'onglet profil
        final mainNavigationState = context.findAncestorStateOfType<_MainNavigationState>();
        mainNavigationState?.navigateToProfile();
      },
      tooltip: 'Profil',
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
      icon: Icon(
        Icons.settings_rounded,
        size: 24,
        color: widget.isDarkTheme ? Colors.white70 : Colors.black54,
      ),
      onPressed: widget.onSettingsTap ?? () {
        // Naviguer vers l'onglet paramètres
        final mainNavigationState = context.findAncestorStateOfType<_MainNavigationState>();
        mainNavigationState?.navigateToSettings();
      },
      tooltip: 'Paramètres',
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }


  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            size: 24,
            color: widget.isDarkTheme ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            widget.onNotificationTap?.call();
            setState(() => _hasNotifications = false);
          },
          tooltip: 'Notifications',
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        if (_hasNotifications)
          Positioned(
            right: 8,
            top: 8,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MainNavigation extends StatefulWidget {
  final String? initialRoute;
  const MainNavigation({super.key, this.initialRoute});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute ?? '/dashboard';
  }
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    final user = authService.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: _getPageTitle(_currentRoute),
        isDarkTheme: isDarkTheme,
        user: user,
        onThemeToggle: () => themeProvider.toggleTheme(),
        onNotificationTap: () => _navigateToRoute('/notifications'),
        onProfileTap: () => _navigateToRoute('/profile'),
        onSettingsTap: () => _navigateToRoute('/settings'),
      ),
      drawer: ComprehensiveNavigationDrawer(
        currentRoute: _currentRoute,
        onItemSelected: (NavigationItem item) {
          _navigateToRoute(item.route);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Material(
  color: Theme.of(context).scaffoldBackgroundColor,
  child: _buildCurrentPage(),
),

      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentRoute) {
      case '/dashboard':
        return const DashboardPage();
      case '/notifications':
        return const NotificationListPage();
      case '/messaging':
        return const MessagingHomePage();
      case '/announcements':
        return const AnnouncementHomePage();
      case '/profile':
        return const ProfilePage();
      case '/profile-pro':
        return const ProfessionalProfilePage();
      case '/settings':
        return const SettingsPage();
      case '/user-management':
        return const UserManagementPage();
      case '/student-management':
        return const EnhancedStudentManagementPage();
      case '/institutions':
        return const InstitutionsListPage();
      case '/university':
        return const UniversityManagementPage();
      case '/courses':
        return const CourseManagementPage();
      case '/programs':
        return const ProgramManagementPage();
      case '/departments':
        return const DepartmentManagementPage();
      case '/faculties':
        return const FacultyManagementPage();
      case '/preinscriptions-management':
        return const preinscriptions_management.PreinscriptionHomePage();
      case '/preinscriptions':
        return const preinscriptions_management.PreinscriptionHomePage();
      case '/preinscription':
        return const preinscription.PreinscriptionHomePage();
      case '/preinscription/form':
        return PreinscriptionFormPage(formationType: 'Général');
      default:
        return _buildComingSoonPage(_currentRoute);
    }
  }

  Widget _buildComingSoonPage(String route) {
    final navigationItem = NavigationService.getAllNavigationItems()
        .where((item) => item.route == route)
        .firstOrNull;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.cyan.shade50,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 120,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              navigationItem?.title ?? 'Module',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'En cours de développement',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 48,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bientôt disponible',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ce module est actuellement en développement et sera disponible prochainement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToRoute('/dashboard'),
                    icon: const Icon(Icons.home),
                    label: const Text('Retour au tableau de bord'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRoute(String route) {
    setState(() {
      _currentRoute = route;
    });
    
    // Fermer le drawer
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  String _getPageTitle(String route) {
    final navigationItem = NavigationService.getAllNavigationItems()
        .where((item) => item.route == route)
        .firstOrNull;
    
    return navigationItem?.title ?? 'MyCampus';
  }

  void navigateToProfile() {
    _navigateToRoute('/profile');
  }

  void navigateToSettings() {
    _navigateToRoute('/settings');
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _getBottomNavIndex(_currentRoute),
      onTap: (index) {
        _navigateToRoute(_getBottomNavRoute(index));
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue.shade600,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Profile Pro',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Alertes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Compte',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    // Afficher le bouton d'ajout pour les pages universitaires
    if (_currentRoute.startsWith('/university')) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout d'université
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter une université',
      );
    } else if (_currentRoute.startsWith('/faculties')) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout de faculté
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter une faculté',
      );
    } else if (_currentRoute.startsWith('/departments')) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout de département
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un département',
      );
    } else if (_currentRoute.startsWith('/programs')) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout de programme
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter une filière',
      );
    } else if (_currentRoute.startsWith('/courses')) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: Implémenter l'ajout de cours
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un cours',
      );
    }
    return const SizedBox.shrink();
  }

  int _getBottomNavIndex(String route) {
    switch (route) {
      case '/dashboard':
        return 0;
      case '/profile-pro':
        return 1;
      case '/university':
      case '/courses':
      case '/programs':
      case '/departments':
      case '/faculties':
        return 2;
      case '/messaging':
        return 3;
      case '/notifications':
        return 4;
      case '/profile':
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }

  String _getBottomNavRoute(int index) {
    switch (index) {
      case 0:
        return '/dashboard';
      case 1:
        return '/profile-pro';
      case 2:
        return '/messaging';
      case 3:
        return '/notifications';
      case 4:
        return '/profile';
      case 5:
        return '/settings';
      default:
        return '/dashboard';
    }
  }
}
