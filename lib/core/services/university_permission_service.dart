import '../../features/auth/models/user_model.dart';

enum UniversityPermission {
  viewUniversities,
  createUniversity,
  editUniversity,
  deleteUniversity,
  verifyUniversity,
  toggleUniversityStatus,
  manageUniversitySettings,
}

class UniversityPermissionService {
  static bool hasPermission(UserModel user, UniversityPermission permission) {
    final userRole = user.role?.toLowerCase();
    
    switch (permission) {
      case UniversityPermission.viewUniversities:
        return _canViewUniversities(userRole);
      case UniversityPermission.createUniversity:
        return _canCreateUniversity(userRole);
      case UniversityPermission.editUniversity:
        return _canEditUniversity(userRole);
      case UniversityPermission.deleteUniversity:
        return _canDeleteUniversity(userRole);
      case UniversityPermission.verifyUniversity:
        return _canVerifyUniversity(userRole);
      case UniversityPermission.toggleUniversityStatus:
        return _canToggleUniversityStatus(userRole);
      case UniversityPermission.manageUniversitySettings:
        return _canManageUniversitySettings(userRole);
    }
  }

  static bool _canViewUniversities(String? role) {
    if (role == null) return false;
    
    // Tous les rôles peuvent voir les universités
    const allowedRoles = [
      'super_admin',
      'admin_national',
      'recteur',
      'admin',
      'enseignant',
      'etudiant',
    ];
    
    return allowedRoles.contains(role);
  }

  static bool _canCreateUniversity(String? role) {
    if (role == null) return false;
    
    // Seuls les super admins et admins nationaux peuvent créer des universités
    const allowedRoles = [
      'super_admin',
      'admin_national',
    ];
    
    return allowedRoles.contains(role);
  }

  static bool _canEditUniversity(String? role) {
    if (role == null) return false;
    
    // Super admin, admin national et recteurs peuvent modifier
    const allowedRoles = [
      'super_admin',
      'admin_national',
      'recteur',
    ];
    
    return allowedRoles.contains(role);
  }

  static bool _canDeleteUniversity(String? role) {
    if (role == null) return false;
    
    // Seuls super admin et admin national peuvent supprimer
    const allowedRoles = [
      'super_admin',
      'admin_national',
    ];
    
    return allowedRoles.contains(role);
  }

  static bool _canVerifyUniversity(String? role) {
    if (role == null) return false;
    
    // Super admin, admin national et recteurs peuvent vérifier
    const allowedRoles = [
      'super_admin',
      'admin_national',
      'recteur',
    ];
    
    return allowedRoles.contains(role);
  }

  static bool _canToggleUniversityStatus(String? role) {
    if (role == null) return false;
    
    // Super admin, admin national et recteurs peuvent changer le statut
    const allowedRoles = [
      'super_admin',
      'admin_national',
      'recteur',
    ];
    
    return allowedRoles.contains(role);
  }

  static bool _canManageUniversitySettings(String? role) {
    if (role == null) return false;
    
    // Seuls super admin et admin national peuvent gérer les paramètres
    const allowedRoles = [
      'super_admin',
      'admin_national',
    ];
    
    return allowedRoles.contains(role);
  }

  static bool canAccessUniversityManagement(String? role) {
    if (role == null) return false;
    
    // Seuls les rôles administratifs peuvent accéder à la gestion
    const allowedRoles = [
      'super_admin',
      'admin_national',
      'recteur',
      'admin',
    ];
    
    return allowedRoles.contains(role);
  }

  static List<UniversityPermission> getUserPermissions(String? role) {
    if (role == null) return [];

    final permissions = <UniversityPermission>[];

    // Permissions de base pour voir
    if (_canViewUniversities(role)) {
      permissions.add(UniversityPermission.viewUniversities);
    }

    // Permissions de création
    if (_canCreateUniversity(role)) {
      permissions.add(UniversityPermission.createUniversity);
    }

    // Permissions de modification
    if (_canEditUniversity(role)) {
      permissions.add(UniversityPermission.editUniversity);
    }

    // Permissions de suppression
    if (_canDeleteUniversity(role)) {
      permissions.add(UniversityPermission.deleteUniversity);
    }

    // Permissions de vérification
    if (_canVerifyUniversity(role)) {
      permissions.add(UniversityPermission.verifyUniversity);
    }

    // Permissions de changement de statut
    if (_canToggleUniversityStatus(role)) {
      permissions.add(UniversityPermission.toggleUniversityStatus);
    }

    // Permissions de gestion des paramètres
    if (_canManageUniversitySettings(role)) {
      permissions.add(UniversityPermission.manageUniversitySettings);
    }

    return permissions;
  }

  static String getRoleDisplayName(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
        return 'Super Administrateur';
      case 'admin_national':
        return 'Admin National';
      case 'recteur':
        return 'Recteur';
      case 'admin':
        return 'Administrateur';
      case 'enseignant':
        return 'Enseignant';
      case 'etudiant':
        return 'Étudiant';
      default:
        return role ?? 'Inconnu';
    }
  }

  static bool isHighLevelAdmin(String? role) {
    if (role == null) return false;
    
    const highLevelRoles = [
      'super_admin',
      'admin_national',
    ];
    
    return highLevelRoles.contains(role.toLowerCase());
  }

  static bool isUniversityAdmin(String? role) {
    if (role == null) return false;
    
    const universityAdminRoles = [
      'super_admin',
      'admin_national',
      'recteur',
    ];
    
    return universityAdminRoles.contains(role.toLowerCase());
  }
}
