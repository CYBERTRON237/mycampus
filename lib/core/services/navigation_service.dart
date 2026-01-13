import '../models/navigation_item_model.dart';

class NavigationService {
  static List<NavigationItem> getAllNavigationItems() {
    return [
      // Tableau de bord
      NavigationItem(
        id: 'dashboard',
        title: 'Tableau de bord',
        icon: 'dashboard',
        route: '/dashboard',
        category: 'principal',
      ),

      // Modules Académiques
      NavigationItem(
        id: 'courses',
        title: 'Cours',
        icon: 'book',
        route: '/courses',
        category: 'academique',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'programs',
        title: 'Programmes',
        icon: 'school',
        route: '/programs',
        category: 'academique',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'departments',
        title: 'Départements',
        icon: 'business',
        route: '/departments',
        category: 'academique',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'faculties',
        title: 'Facultés',
        icon: 'account_balance',
        route: '/faculties',
        category: 'academique',
        requiresAuth: true,
      ),

      // Préinscriptions
      NavigationItem(
        id: 'preinscriptions_management',
        title: 'Gestion des Préinscriptions',
        icon: 'manage_accounts',
        route: '/preinscriptions-management',
        category: 'administration',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin', 'admin_local', 'admin_national', 'faculty_admin', 'manager'],
      ),
      NavigationItem(
        id: 'preinscriptions',
        title: 'Préinscriptions',
        icon: 'how_to_reg',
        route: '/preinscriptions',
        category: 'academique',
        requiresAuth: true,
        subItems: [
          NavigationItem(
            id: 'preinscription_uy1',
            title: 'UY1',
            icon: 'school',
            route: '/preinscription/uy1',
            category: 'preinscription',
          ),
          NavigationItem(
            id: 'preinscription_falsh',
            title: 'FALSH',
            icon: 'school',
            route: '/preinscription/falsh',
            category: 'preinscription',
          ),
          NavigationItem(
            id: 'preinscription_fs',
            title: 'FS',
            icon: 'school',
            route: '/preinscription/fs',
            category: 'preinscription',
          ),
          NavigationItem(
            id: 'preinscription_fse',
            title: 'FSE',
            icon: 'school',
            route: '/preinscription/fse',
            category: 'preinscription',
          ),
          NavigationItem(
            id: 'preinscription_iut',
            title: 'IUT',
            icon: 'school',
            route: '/preinscription/iut',
            category: 'preinscription',
          ),
          NavigationItem(
            id: 'preinscription_enspy',
            title: 'ENSPY',
            icon: 'school',
            route: '/preinscription/enspy',
            category: 'preinscription',
          ),
        ],
      ),

      // Communication
      NavigationItem(
        id: 'messaging',
        title: 'Messagerie',
        icon: 'chat',
        route: '/messaging',
        category: 'communication',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'notifications',
        title: 'Notifications',
        icon: 'notifications',
        route: '/notifications',
        category: 'communication',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'announcements',
        title: 'Annonces',
        icon: 'campaign',
        route: '/announcements',
        category: 'communication',
        requiresAuth: true,
      ),

      // Gestion des utilisateurs
      NavigationItem(
        id: 'user_management',
        title: 'Gestion des utilisateurs',
        icon: 'people',
        route: '/user-management',
        category: 'administration',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin', 'admin_local', 'admin_national'],
      ),

      // Gestion des étudiants
      NavigationItem(
        id: 'student_management',
        title: 'Gestion des étudiants',
        icon: 'school',
        route: '/student-management',
        category: 'administration',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin', 'admin_local', 'admin_national', 'teacher', 'staff'],
      ),

      // Gestion institutionnelle
      NavigationItem(
        id: 'institutions',
        title: 'Institutions',
        icon: 'apartment',
        route: '/institutions',
        category: 'administration',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin', 'admin_local', 'admin_national'],
      ),
      NavigationItem(
        id: 'university',
        title: 'Universités',
        icon: 'account_balance',
        route: '/university',
        category: 'administration',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin', 'admin_local', 'admin_national'],
      ),

      // Utilisateur
      NavigationItem(
        id: 'profile',
        title: 'Profil',
        icon: 'person',
        route: '/profile',
        category: 'utilisateur',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'settings',
        title: 'Paramètres',
        icon: 'settings',
        route: '/settings',
        category: 'utilisateur',
        requiresAuth: true,
      ),

      // Rapports et analytics
      NavigationItem(
        id: 'analytics',
        title: 'Analytics',
        icon: 'analytics',
        route: '/analytics',
        category: 'rapports',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin', 'admin_local', 'admin_national'],
      ),
      NavigationItem(
        id: 'reports',
        title: 'Rapports',
        icon: 'assessment',
        route: '/reports',
        category: 'rapports',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin', 'admin_local', 'admin_national'],
      ),

      // Sécurité
      NavigationItem(
        id: 'security',
        title: 'Sécurité',
        icon: 'security',
        route: '/security',
        category: 'administration',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin'],
      ),
      NavigationItem(
        id: 'audit',
        title: 'Audit',
        icon: 'fact_check',
        route: '/audit',
        category: 'administration',
        requiresAuth: true,
        requiredRoles: ['superadmin'],
      ),

      // Support
      NavigationItem(
        id: 'support',
        title: 'Support',
        icon: 'support_agent',
        route: '/support',
        category: 'support',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'help',
        title: 'Aide',
        icon: 'help',
        route: '/help',
        category: 'support',
        requiresAuth: false,
      ),

      // Utilitaires
      NavigationItem(
        id: 'documents',
        title: 'Documents',
        icon: 'folder',
        route: '/documents',
        category: 'utilitaires',
        requiresAuth: true,
      ),
      NavigationItem(
        id: 'backup',
        title: 'Sauvegarde',
        icon: 'backup',
        route: '/backup',
        category: 'utilitaires',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin'],
      ),
      NavigationItem(
        id: 'import_export',
        title: 'Import/Export',
        icon: 'swap_vert',
        route: '/import-export',
        category: 'utilitaires',
        requiresAuth: true,
        requiredRoles: ['admin', 'superadmin'],
      ),
    ];
  }

  static List<NavigationItem> getNavigationItemsByCategory(String category) {
    return getAllNavigationItems()
        .where((item) => item.category == category)
        .toList();
  }

  static List<NavigationItem> getNavigationItemsForRole(String userRole) {
    final items = getAllNavigationItems().where((item) {
      if (!item.requiresAuth) return true;
      if (item.requiredRoles == null || item.requiredRoles!.isEmpty) return true;
      return item.requiredRoles!.contains(userRole);
    }).toList();

    return items;
  }

  static List<String> getAllCategories() {
    return [
      'principal',
      'academique',
      'communication',
      'administration',
      'utilisateur',
      'rapports',
      'support',
      'utilitaires',
    ];
  }

  static Map<String, String> getCategoryLabels() {
    return {
      'principal': 'Principal',
      'academique': 'Modules Académiques',
      'communication': 'Communication',
      'administration': 'Administration',
      'utilisateur': 'Utilisateur',
      'rapports': 'Rapports & Analytics',
      'support': 'Support',
      'utilitaires': 'Utilitaires',
    };
  }
}
