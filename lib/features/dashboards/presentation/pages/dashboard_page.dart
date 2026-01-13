import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mycampus/features/auth/services/api_service.dart';
import 'package:mycampus/features/auth/services/auth_service.dart';
import 'package:mycampus/features/auth/models/user_model.dart';
import 'package:mycampus/core/providers/theme_provider.dart';
import 'package:mycampus/features/preinscriptions_management/presentation/pages/preinscription_home_page.dart' as management;
import 'package:mycampus/features/preinscription/presentation/pages/preinscription_home_page.dart' as student;
import 'package:mycampus/features/messaging/presentation/pages/messaging_home_page.dart';
import 'package:mycampus/features/notifications/presentation/pages/notification_list_page.dart';
import 'package:mycampus/features/university/presentation/pages/university_management_page.dart';
import 'package:mycampus/features/faculty/presentation/pages/faculty_management_page.dart';
import 'package:mycampus/features/program/presentation/pages/program_management_page.dart';
import 'package:mycampus/features/department/presentation/pages/department_management_page.dart';
import 'package:mycampus/features/course/presentation/pages/course_management_page.dart';
import 'package:mycampus/features/user_management/presentation/pages/user_management_page.dart';
import 'package:mycampus/features/student_management/presentation/pages/student_management_page.dart';
import 'package:mycampus/features/settings/settings.dart';
import 'package:mycampus/features/announcements_management/presentation/pages/announcement_home_page.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_stats_model.dart';
import '../widgets/admin_dashboard_widget.dart';
import '../widgets/student_dashboard_widget.dart';
import '../widgets/recteur/dashboard_rector_widget.dart';
import '../widgets/vice_rector/dashboard_vicerector_widget.dart';
import '../widgets/ministry/dashboard_ministry_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _dashboardData;
  DashboardStatsModel? _dashboardStats;
  late DashboardService _dashboardService;
  bool _isLoadingStats = false;
  UserModel? _user;
  bool _loading = true;
  String? _error;
  
  bool _showExploreView = false;
  bool _showMessagesView = false;
  bool _showUniversitySelection = false;
  bool _showAdminPanel = false;
  bool _showStudentPanel = false;
  
  final ScrollController _scrollController = ScrollController();
  Timer? _stateChangeTimer;
  AuthService? _authService; // Stocker la référence
  
  String _selectedPeriod = 'today';
  String _selectedCategory = 'all';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
    _loadDashboardStats();
    _loadDashboard();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _authService?.currentUser;
      if (currentUser != null && mounted) {
        setState(() {
          _user = currentUser;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context, listen: false);
    _authService?.addListener(_onUserChanged);
    // Initialize dashboard service after auth service is available
    _dashboardService = DashboardService(
      client: http.Client(),
      authService: _authService!,
    );
  }

  @override
  void dispose() {
    _stateChangeTimer?.cancel();
    _tabController.dispose();
    _scrollController.dispose();
    _authService?.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    // Mettre à jour l'utilisateur local lorsque les données changent
    if (!mounted) return;
    
    final authService = _authService;
    if (authService == null) return;
    
    final currentUser = authService.currentUser;
    
    if (currentUser != null && _user != null) {
      if (!mounted) return;
      setState(() {
        _user = UserModel.fromJson(currentUser.toJson());
      });
    }
  }

  void _scrollListener() {
    // Scroll listener for potential UI interactions
    // Currently unused but available for future scroll-based features
    if (mounted) {
      // Example: Could be used for showing/hiding FAB, app bar animations, etc.
      final scrollOffset = _scrollController.offset;
      // Add scroll-based logic here if needed
    }
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (kDebugMode) print('\n🔄 Chargement des données du tableau de bord...');

      final dashboardData = await ApiService().fetchDashboardData();

      if (!mounted) return;

      if (dashboardData['success'] == true) {
        if (kDebugMode) {
          print('✅ Données du tableau de bord chargées avec succès');
          print('👤 Utilisateur: ${dashboardData['user']?['email']}');
        }

        setState(() {
          _user = UserModel.fromJson(dashboardData['user']);
          _dashboardData = dashboardData;
          _loading = false;
        });
        
      } else {
        final errorMsg = dashboardData['message'] ?? 'Erreur lors du chargement des données';
        if (kDebugMode) print('❌ Erreur dans les données reçues: $errorMsg');
        throw ApiException(errorMsg);
      }

    } on ApiException catch (e) {
      if (!mounted) return;

      if (kDebugMode) {
        print('❌ Erreur API: ${e.message}');
        if (e.statusCode != null) print('   Code: ${e.statusCode}');
      }

      if (e.message.contains('Session expirée') ||
          e.message.contains('non authentifié') ||
          e.message.contains('token')) {
        if (kDebugMode) print('🔒 Déconnexion de l\'utilisateur...');
        await _authService?.logout();
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          });
        }
        return;
      }

      setState(() {
        _error = e.message;
        _loading = false;
      });

    } on TimeoutException catch (e) {
      const errorMsg = 'La connexion a pris trop de temps. Vérifiez votre connexion internet.';
      if (kDebugMode) print('⏱️ $errorMsg - $e');

      if (!mounted) return;
      setState(() {
        _error = errorMsg;
        _loading = false;
      });

    } on SocketException catch (e) {
      const errorMsg = 'Pas de connexion internet. Veuillez vérifier votre connexion.';
      if (kDebugMode) print('🌐 $errorMsg - $e');

      if (!mounted) return;
      setState(() {
        _error = errorMsg;
        _loading = false;
      });

    } catch (e, stackTrace) {
      const errorMsg = 'Une erreur inattendue est survenue. Veuillez réessayer plus tard.';
      if (kDebugMode) {
        print('❌ ERREUR NON GÉRÉE: $e');
        print('   Stack trace: $stackTrace');
      }

      if (!mounted) return;
      setState(() {
        _error = errorMsg;
        _loading = false;
      });
    }
  }

Future<void> _loadDashboardStats() async {
  setState(() => _isLoadingStats = true);
  
  try {
    final result = await _dashboardService.getDashboardStats();
    result.fold(
      (error) {
        if (mounted) {
          setState(() => _isLoadingStats = false);
          print('Error loading dashboard stats: $error');
        }
      },
      (stats) {
        if (mounted) {
          setState(() {
            _dashboardStats = stats;
            _isLoadingStats = false;
          });
        }
      },
    );
  } catch (e) {
    if (mounted) {
      setState(() => _isLoadingStats = false);
      print('Exception loading dashboard stats: $e');
    }
  }
}

// ============================================================================
// ROLE CHECKING METHODS - ORGANIZED BY CATEGORY
// ============================================================================

// ---------- NATIONAL INSTITUTIONAL ROLES ----------
bool _isMinistryOfHigherEducation() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'minesup_minister';
}

bool _isMinistrySecretary() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'minesup_secretary';
}

bool _isMinistryResearchDirector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'minresip_director';
}

bool _isCNESPresident() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'cnes_president';
}

bool _isCAAQESDirector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'caaqes_director';
}

bool _isInspectorGeneral() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'inspector_general';
}

// ---------- UNIVERSITY HIERARCHY ROLES ----------
bool _isRector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'rector';
}

bool _isViceRector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'vice_rector';
}

bool _isSecretaryGeneral() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'secretary';
}

bool _isFacultyDean() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'faculty_dean';
}

bool _isSchoolDirector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'school_director';
}

bool _isDepartmentHead() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'department_head';
}

bool _isSectionHead() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'section_head';
}

bool _isProgramCoordinator() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'program_coord';
}

// ---------- TEACHING STAFF ROLES ----------
bool _isProfessorTitular() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'prof_titular';
}

bool _isProfessorAssociate() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'prof_associate';
}

bool _isMasterConference() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'master_conf';
}

bool _isCourseHolder() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'course_holder';
}

bool _isAssistant() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'assistant';
}

bool _isMonitor() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'monitor';
}

bool _isTemporaryTeacher() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'temp_teacher';
}

bool _isVisitingProfessor() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'visiting_prof';
}

bool _isPostdocResearcher() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'postdoc';
}

bool _isTeacher() {
  if (_user == null) return false;
  final role = _user!.role.toLowerCase();
  return role == 'teacher' || 
         role == 'prof_titular' || 
         role == 'prof_associate' || 
         role == 'master_conf' || 
         role == 'course_holder' || 
         role == 'assistant' || 
         role == 'monitor' || 
         role == 'temp_teacher' || 
         role == 'visiting_prof' || 
         role == 'postdoc';
}

// ---------- ADMINISTRATIVE & TECHNICAL ROLES ----------
bool _isAdministrativeAgent() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'admin_agent';
}

bool _isSecretary() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'secretary';
}

bool _isAccountant() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'accountant';
}

bool _isLibrarian() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'librarian';
}

bool _isLabTechnician() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'lab_tech';
}

bool _isMaintenanceEngineer() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'maintenance_eng';
}

bool _isSecurityAgent() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'security_agent';
}

bool _isCleaningStaff() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'cleaning_staff';
}

bool _isDriver() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'driver';
}

bool _isITSupport() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'it_support';
}

bool _isStaff() {
  if (_user == null) return false;
  final role = _user!.role.toLowerCase();
  return role == 'staff' || 
         role == 'admin_agent' || 
         role == 'secretary' || 
         role == 'accountant' || 
         role == 'librarian' || 
         role == 'lab_tech' || 
         role == 'maintenance_eng' || 
         role == 'security_agent' || 
         role == 'cleaning_staff' || 
         role == 'driver' || 
         role == 'it_support';
}

// ---------- STUDENT REPRESENTATION ROLES ----------
bool _isStudentExecutive() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'student_exec';
}

bool _isClassDelegate() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'class_delegate';
}

bool _isFacultyDelegate() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'faculty_delegate';
}

bool _isResidenceDelegate() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'residence_delegate';
}

bool _isCulturalAssociationLeader() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'cultural_assoc_leader';
}

bool _isClubPresident() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'club_president';
}

bool _isPromotionCoordinator() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'promotion_coord';
}

bool _isLeader() {
  if (_user == null) return false;
  final role = _user!.role.toLowerCase();
  return role == 'leader' || 
         role == 'student_exec' || 
         role == 'class_delegate' || 
         role == 'faculty_delegate' || 
         role == 'residence_delegate' || 
         role == 'cultural_assoc_leader' || 
         role == 'club_president' || 
         role == 'promotion_coord';
}

bool _isStudent() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'student';
}

// ---------- PARTNERS & SOCIAL ROLES ----------
bool _isEconomicPartner() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'economic_partner';
}

bool _isChamberOfCommerce() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'chamber_commerce';
}

bool _isEmployerOrganization() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'employer_org';
}

bool _isBankRepresentative() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'bank_rep';
}

bool _isInsuranceRepresentative() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'insurance_rep';
}

bool _isInternationalPartner() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'intl_partner';
}

bool _isForeignEmbassy() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'foreign_embassy';
}

bool _isInternationalOrganization() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'intl_org';
}

bool _isNGORepresentative() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'ngo_rep';
}

bool _isSyndicateRepresentative() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'syndicate_rep';
}

bool _isParentsAssociation() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'parents_assoc';
}

bool _isAlumniRepresentative() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'alumni_rep';
}

bool _isDevelopmentAssociation() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'dev_assoc';
}

bool _isCivilSocietyOrganization() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'civil_society';
}

// ---------- SUPPORT SERVICES ROLES ----------
bool _isDocumentationCenter() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'doc_center';
}

bool _isOrientationCounselor() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'orientation_counselor';
}

bool _isMedicalService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'medical_service';
}

bool _isPsychologicalService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'psycho_service';
}

bool _isRestaurantService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'restaurant_service';
}

bool _isHousingService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'housing_service';
}

bool _isSportsService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'sports_service';
}

bool _isCulturalService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'cultural_service';
}

// ---------- INFRASTRUCTURE & LOGISTICS ROLES ----------
bool _isBuildingService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'building_service';
}

bool _isTransportService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'transport_service';
}

bool _isTelecommunicationService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'telecom_service';
}

bool _isEnergyService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'energy_service';
}

bool _isFireSafetyService() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'fire_safety';
}

// ---------- LEGAL & REGULATORY ROLES ----------
bool _isParliamentMember() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'parliament_member';
}

bool _isConstitutionalCouncil() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'constitutional_council';
}

bool _isSupremeCourt() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'supreme_court';
}

bool _isAdministrativeTribunal() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'admin_tribunal';
}

bool _isAccountCommissary() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'account_commissary';
}

bool _isLegalAdvisor() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'legal_advisor';
}

// ---------- CONTROL ORGANIZATIONS ROLES ----------
bool _isStateControl() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'state_control';
}

bool _isFinanceInspection() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'finance_inspection';
}

bool _isAntiCorruptionCommission() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'anti_corruption';
}

bool _isGoodGovernanceObservatory() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'good_governance';
}

// ---------- RESEARCH & INNOVATION ROLES ----------
bool _isResearchCenterDirector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'research_center_dir';
}

bool _isResearchLaboratoryHead() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'research_lab_head';
}

bool _isSpecializedInstituteDirector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'specialized_institute_dir';
}

bool _isExcellencePoleDirector() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'excellence_pole_dir';
}

bool _isBusinessIncubatorManager() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'business_incubator';
}

bool _isTechnologyParkManager() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'tech_park_manager';
}

bool _isScientificCommunityMember() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'scientific_community';
}

bool _isAcademyMember() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'academy_member';
}

bool _isLearnedSocietyMember() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'learned_society';
}

bool _isEditorialBoardMember() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'editorial_board';
}

bool _isScientificEvaluator() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'scientific_evaluator';
}

bool _isExpertConsultant() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'expert_consultant';
}

// ---------- LEGACY/EXISTING ROLES (kept for backward compatibility) ----------
bool _isModerator() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'moderator';
}

bool _isInvite() {
  if (_user == null) {
    print('DEBUG: _user is null in _isInvite()');
    return false;
  }
  final role = _user!.role.toLowerCase();
  final isInvite = role == 'invite';
  print('DEBUG: User role: "$role", isInvite: $isInvite');
  return isInvite;
}

bool _isSuperAdmin() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'superadmin';
}

bool _isAdminNational() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'admin_national';
}

bool _isAdminLocal() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'admin_local';
}

bool _isMinistryOfficial() {
  if (_user == null) return false;
  return _user!.role.toLowerCase() == 'ministry_official';
}

// ============================================================================
// COMPOSITE ROLE CHECKING METHODS
// ============================================================================

bool _isAnyAdmin() {
  return _isSuperAdmin() || _isAdminNational() || _isAdminLocal();
}

bool _isHighLevelAdmin() {
  return _isSuperAdmin() || 
         _isAdminNational() || 
         _isRector() || 
         _isViceRector() ||
         _isMinistryOfHigherEducation() ||
         _isMinistrySecretary() ||
         _isMinistryResearchDirector();
}

bool _isUniversityLeadership() {
  return _isRector() || 
         _isViceRector() || 
         _isSecretaryGeneral() || 
         _isFacultyDean() || 
         _isSchoolDirector();
}

bool _isAcademicStaff() {
  return _isTeacher() || 
         _isDepartmentHead() || 
         _isSectionHead() || 
         _isProgramCoordinator();
}

bool _isExternalPartner() {
  return _isEconomicPartner() || 
         _isChamberOfCommerce() || 
         _isEmployerOrganization() || 
         _isBankRepresentative() || 
         _isInsuranceRepresentative() || 
         _isInternationalPartner() || 
         _isForeignEmbassy() || 
         _isInternationalOrganization() || 
         _isNGORepresentative();
}

bool _isControlAuthority() {
  return _isStateControl() || 
         _isFinanceInspection() || 
         _isAntiCorruptionCommission() || 
         _isGoodGovernanceObservatory() ||
         _isInspectorGeneral();
}

bool _isResearcher() {
  return _isResearchCenterDirector() || 
         _isResearchLaboratoryHead() || 
         _isSpecializedInstituteDirector() || 
         _isExcellencePoleDirector() || 
         _isPostdocResearcher() ||
         _isScientificCommunityMember() ||
         _isAcademyMember();
}

// ============================================================================
// ROLE DISPLAY NAME METHOD
// ============================================================================

String _getRoleDisplayName() {
  if (_user == null) return 'Utilisateur';
  
  final role = _user!.role.toLowerCase();
  switch (role) {
    // National Institutional
    case 'minesup_minister': return 'Ministre de l\'Enseignement Supérieur';
    case 'minesup_secretary': return 'Secrétaire Général MINESUP';
    case 'minresip_director': return 'Directeur MINRESI';
    case 'cnes_president': return 'Président CNES';
    case 'caaqes_director': return 'Directeur CAAQES';
    case 'inspector_general': return 'Inspecteur Général';
    
    // University Hierarchy
    case 'rector': return 'Recteur d\'Université';
    case 'univ_vice_rector': return 'Vice-Recteur';
    case 'univ_secretary': return 'Secrétaire Général';
    case 'faculty_dean': return 'Doyen de Faculté';
    case 'school_director': return 'Directeur d\'École';
    case 'department_head': return 'Chef de Département';
    case 'section_head': return 'Chef de Section';
    case 'program_coord': return 'Coordonnateur de Programme';
    
    // Teaching Staff
    case 'prof_titular': return 'Professeur Titulaire';
    case 'prof_associate': return 'Professeur Associé';
    case 'master_conf': return 'Maître de Conférences';
    case 'course_holder': return 'Chargé de Cours';
    case 'assistant': return 'Assistant';
    case 'monitor': return 'Moniteur';
    case 'temp_teacher': return 'Enseignant Vacataire';
    case 'visiting_prof': return 'Professeur Visiteur';
    case 'postdoc': return 'Chercheur Post-Doctorant';
    
    // Administrative & Technical
    case 'admin_agent': return 'Agent Administratif';
    case 'secretary': return 'Secrétaire';
    case 'accountant': return 'Comptable';
    case 'librarian': return 'Bibliothécaire';
    case 'lab_tech': return 'Technicien de Labo';
    case 'maintenance_eng': return 'Ingénieur Maintenance';
    case 'security_agent': return 'Agent de Sécurité';
    case 'cleaning_staff': return 'Agent d\'Entretien';
    case 'driver': return 'Chauffeur';
    case 'it_support': return 'Support Informatique';
    
    // Student Representation
    case 'student_exec': return 'Membre Bureau Exécutif Étudiants';
    case 'class_delegate': return 'Délégué de Classe';
    case 'faculty_delegate': return 'Délégué de Faculté';
    case 'residence_delegate': return 'Délégué de Résidence';
    case 'cultural_assoc_leader': return 'Président Association Culturelle';
    case 'club_president': return 'Président Club Étudiant';
    case 'promotion_coord': return 'Coordonnateur de Promotion';
    
    // Partners & Social
    case 'economic_partner': return 'Partenaire Économique';
    case 'chamber_commerce': return 'Chambre de Commerce';
    case 'employer_org': return 'Organisation Patronale';
    case 'bank_rep': return 'Représentant Bancaire';
    case 'insurance_rep': return 'Représentant Assurance';
    case 'intl_partner': return 'Partenaire International';
    case 'foreign_embassy': return 'Ambassade Étrangère';
    case 'intl_org': return 'Organisation Internationale';
    case 'ngo_rep': return 'Représentant ONG';
    case 'syndicate_rep': return 'Représentant Syndical';
    case 'parents_assoc': return 'Association Parents';
    case 'alumni_rep': return 'Représentant Anciens Étudiants';
    case 'dev_assoc': return 'Association Développement';
    case 'civil_society': return 'Organisation Société Civile';
    
    // Support Services
    case 'doc_center': return 'Centre Documentation';
    case 'orientation_counselor': return 'Conseiller Orientation';
    case 'medical_service': return 'Service Médical';
    case 'psycho_service': return 'Service Psychologique';
    case 'restaurant_service': return 'Service Restauration';
    case 'housing_service': return 'Service Hébergement';
    case 'sports_service': return 'Service Sportif';
    case 'cultural_service': return 'Service Culturel';
    
    // Infrastructure & Logistics
    case 'building_service': return 'Service Bâtiments';
    case 'transport_service': return 'Service Transport';
    case 'telecom_service': return 'Service Télécommunication';
    case 'energy_service': return 'Service Énergie';
    case 'fire_safety': return 'Service Sécurité Incendie';
    
    // Legal & Regulatory
    case 'parliament_member': return 'Membre Parlement';
    case 'constitutional_council': return 'Conseil Constitutionnel';
    case 'supreme_court': return 'Cour Suprême';
    case 'admin_tribunal': return 'Tribunal Administratif';
    case 'account_commissary': return 'Commissaire aux Comptes';
    case 'legal_advisor': return 'Conseiller Juridique';
    
    // Control Organizations
    case 'state_control': return 'Contrôle Supérieur État';
    case 'finance_inspection': return 'Inspection Finances';
    case 'anti_corruption': return 'Commission Anti-Corruption';
    case 'good_governance': return 'Observatoire Bonne Gouvernance';
    
    // Research & Innovation
    case 'research_center_dir': return 'Directeur Centre Recherche';
    case 'research_lab_head': return 'Chef Laboratoire';
    case 'specialized_institute_dir': return 'Directeur Institut Spécialisé';
    case 'excellence_pole_dir': return 'Directeur Pôle Excellence';
    case 'business_incubator': return 'Manager Incubateur';
    case 'tech_park_manager': return 'Manager Parc Technologique';
    case 'scientific_community': return 'Membre Communauté Scientifique';
    case 'academy_member': return 'Membre Académie';
    case 'learned_society': return 'Membre Société Savante';
    case 'editorial_board': return 'Membre Comité Éditorial';
    case 'scientific_evaluator': return 'Évaluateur Scientifique';
    case 'expert_consultant': return 'Expert Consultant';
    
    // Legacy roles
    case 'superadmin': return 'Super Administrateur';
    case 'admin_national': return 'Administrateur National';
    case 'admin_local': return 'Administrateur Local';
    case 'rector': return 'Recteur';
    case 'vice_rector': return 'Vice-Recteur';
    case 'ministry_official': return 'Responsable Ministériel';
    case 'teacher': return 'Enseignant';
    case 'leader': return 'Leader Étudiant';
    case 'student': return 'Étudiant';
    case 'moderator': return 'Modérateur';
    case 'staff': return 'Personnel';
    case 'invite': return 'Invité';
    
    default: return _user!.role;
  }
}
  @override
  Widget build(BuildContext context) {
    if (_user == null && !_loading) {
      return _buildError(_error ?? 'Aucune donnée utilisateur disponible');
    }

    return _loading
        ? _buildLoading()
        : _error != null
            ? _buildError(_error!)
            : _dashboardData != null
                ? _buildDashboard(context)
                : _buildError('Aucune donnée disponible');
  }

  Widget _buildLoading() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme 
              ? [const Color(0xFF0A0E21), const Color(0xFF1D1E33)]
              : [const Color(0xFF4A90E2), const Color(0xFF50C9C3)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.cyan.shade400, Colors.blue.shade600],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.cyan.shade200, Colors.blue.shade400],
                ).createShader(bounds),
                child: const Text(
                  'Chargement...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkTheme 
              ? [const Color(0xFF0A0E21), const Color(0xFF1D1E33)]
              : [Colors.red.shade50, Colors.orange.shade50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 80,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Oups!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  msg,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedButton(
                      onPressed: _loadDashboard,
                      icon: Icons.refresh_rounded,
                      label: 'Réessayer',
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.cyan.shade400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _AnimatedButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          _loadDashboard();
                        }
                      },
                      icon: Icons.arrow_back_rounded,
                      label: 'Retour',
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade600, Colors.grey.shade800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    final user = _user!;
    final data = _dashboardData!;

    // Si l'utilisateur est un recteur, afficher le dashboard rector
    if (_isRector()) {
      return DashboardRectorPage();
    }

    // Si l'utilisateur est un vice-recteur, afficher le dashboard vice-recteur
    if (_isViceRector()) {
      return DashboardViceRectorPage();
    }

    // Si l'utilisateur est un responsable ministériel, afficher le dashboard ministériel
    if (_isMinistryOfficial()) {
      return DashboardMinistryPage();
    }

    final List<dynamic> upcomingEvents = (data['upcoming_events'] as List?) ?? [];
    final List<dynamic> recentLogs = (data['recent_logs'] as List?) ?? [];
    final List<dynamic> recentAnnouncements = (data['recent_announcements'] as List?) ?? [];
    final List<dynamic> activeGroups = (data['active_groups'] as List?) ?? [];
    final List<dynamic> recentOpportunities = (data['recent_opportunities'] as List?) ?? [];
    
    final Map<String, dynamic> stats = data['stats'] ?? {};
    final List<dynamic> recentActivities = data['recent_activities'] ?? [];

    return Container(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme 
              ? [const Color(0xFF0A0E21), const Color(0xFF1D1E33), const Color(0xFF0A0E21)]
              : [const Color(0xFFF8F9FE), const Color(0xFFE8F5E9), const Color(0xFFF8F9FE)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          color: Colors.cyan,
          child: SafeArea(
            child: _showUniversitySelection
                ? _buildUniversitySelectionContent()
                : _showExploreView
                  ? _buildExploreContent()
                  : _showMessagesView
                    ? _buildMessagesContent()
                    : _showAdminPanel
                      ? _buildAdminPanelContent(stats, recentActivities)
                      : _showStudentPanel
                        ? _buildStudentPanelContent()
                        : _buildTabContent(
                            user: user,
                            stats: stats,
                            activities: recentActivities,
                            events: upcomingEvents,
                            logs: recentLogs,
                            announcements: recentAnnouncements,
                            groups: activeGroups,
                            opportunities: recentOpportunities,
                          ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required UserModel user,
    required Map<String, dynamic> stats,
    required List activities,
    required List events,
    required List logs,
    required List announcements,
    required List groups,
    required List opportunities,
  }) {
    return _buildHomeTab(user, stats, activities, events, groups, opportunities, announcements);
  }

  Widget _buildHomeTab(UserModel user, Map<String, dynamic> stats, List activities, List events, List groups, List opportunities, List announcements) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModernHeader(user),
          const SizedBox(height: 24),
          
          // Actions rapides selon le rôle
          
          
          if (_isTeacher()) ...[
            _buildTeacherQuickActions(),
            const SizedBox(height: 24),
          ],
          
          if (_isLeader()) ...[
            _buildLeaderQuickActions(),
            const SizedBox(height: 24),
          ],
          
          if (_isModerator()) ...[
            _buildModeratorQuickActions(),
            const SizedBox(height: 24),
          ],
          
          if (_isStaff()) ...[
            _buildStaffQuickActions(),
            const SizedBox(height: 24),
          ],
          
          if (_isInvite()) ...[
            _buildInviteQuickActions(),
            const SizedBox(height: 24),
          ],
          
          if (_isAnyAdmin()) ...[
            _buildAdminQuickActions(),
            const SizedBox(height: 24),
          ],
          
        
          _buildStorySection(groups),
          _buildHowItWorksSection(),
          const SizedBox(height: 24),
          
          // Sections spécifiques selon le rôle
          if (_isStudent()) ...[
            _buildPreinscriptionSection(),
            const SizedBox(height: 24),
          ],
          
          if (_isTeacher()) ...[
            _buildTeacherSection(),
            const SizedBox(height: 24),
          ],
          
          if (_isLeader()) ...[
            _buildLeaderSection(),
            const SizedBox(height: 24),
          ],
          
        
          
          if (_isSuperAdmin()) ...[
            _buildAdminInsights(stats),
            const SizedBox(height: 24),
          ],
          
          if (_isAnyAdmin()) ...[
            _buildPreinscriptionsManagementSection(),
            const SizedBox(height: 24),
            _buildAnnouncementsManagementSection(),
            const SizedBox(height: 24),
          ],
          
          _buildFeaturedSection(),
          const SizedBox(height: 24),
          _buildActivitiesSection(activities),
          const SizedBox(height: 24),
          _buildOpportunitiesCarousel(opportunities),
          const SizedBox(height: 24),
          _buildAnnouncementsSection(announcements),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Section de gestion des préinscriptions pour les administrateurs
  // Appelée depuis _buildHomeTab pour afficher la section de gestion des préinscriptions
  Widget _buildPreinscriptionsManagementSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.indigo.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.app_registration_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestion des Préinscriptions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gérez toutes les demandes de préinscription',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Actions rapides pour les préinscriptions
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const management.PreinscriptionHomePage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.list_rounded,
                      color: Colors.purple,
                      size: 24,
                    ),
                    label: const Text(
                      'Voir toutes les préinscriptions',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.purple,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () {
                    // Action pour voir les statistiques des préinscriptions
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Statistiques des préinscriptions bientôt disponibles'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Indicateurs rapides
          Row(
            children: [
              _buildPreinscriptionIndicator(
                'En attente',
                '12',
                Icons.pending_rounded,
                Colors.orange,
                isDarkTheme,
              ),
              const SizedBox(width: 16),
              _buildPreinscriptionIndicator(
                'Validées',
                '8',
                Icons.check_circle_rounded,
                Colors.green,
                isDarkTheme,
              ),
              const SizedBox(width: 16),
              _buildPreinscriptionIndicator(
                'Rejetées',
                '3',
                Icons.cancel_rounded,
                Colors.red,
                isDarkTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreinscriptionIndicator(String label, String value, IconData icon, Color color, bool isDarkTheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Section de gestion des annonces pour les administrateurs
  Widget _buildAnnouncementsManagementSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade400,
            Colors.orange.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestion des Annonces',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Communiquez avec votre communauté',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Actions rapides pour les annonces
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AnnouncementHomePage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.list_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                    label: const Text(
                      'Voir toutes les annonces',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AnnouncementHomePage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Créer une annonce',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Indicateurs rapides
          Row(
            children: [
              Expanded(
                child: _buildQuickIndicator(
                  icon: Icons.publish,
                  label: 'Publiées',
                  value: '8',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickIndicator(
                  icon: Icons.schedule,
                  label: 'Programmées',
                  value: '3',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickIndicator(
                  icon: Icons.drafts,
                  label: 'Brouillons',
                  value: '2',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme 
            ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F)]
            : [Colors.blue.shade50, Colors.cyan.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                    colors: [Colors.blue.shade400, Colors.cyan.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
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
                      'Comment fonctionne MyCampus ?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Votre plateforme universitaire tout-en-un',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkTheme ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Étapes explicatives
          _buildStepCard(
            '1',
            'Créez votre profil',
            'Personnalisez votre espace et ajoutez vos informations',
            Icons.person_add_rounded,
            Colors.blue,
            isDarkTheme,
          ),
          const SizedBox(height: 12),
          
          _buildStepCard(
            '2',
            'Explorez les fonctionnalités',
            'Découvrez les cours, annonces et opportunités',
            Icons.explore_rounded,
            Colors.green,
            isDarkTheme,
          ),
          const SizedBox(height: 12),
          
          _buildStepCard(
            '3',
            'Restez connecté',
            'Communiquez avec la communauté et restez informé',
            Icons.chat_rounded,
            Colors.orange,
            isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String stepNumber, String title, String description, IconData icon, Color color, bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreinscriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nouveau dans le système universitaire ?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Commencez votre parcours avec une préinscription simple',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const student.PreinscriptionHomePage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.app_registration_rounded,
                color: Colors.purple,
                size: 24,
              ),
              label: const Text(
                'Commencer ma préinscription',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.purple,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Processus simple et rapide',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Suivi en temps réel de votre dossier',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDarkTheme, {
    required VoidCallback onTap,
  }) {
    return Container(
      height: 80,
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
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminQuickActions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions Rapides Admin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAdminActionCard(
                  icon: Icons.people_rounded,
                  label: 'Gestion Utilisateurs',
                  description: 'Module complet',
                  color: Colors.blue,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementPage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.school_rounded,
                  label: 'Gestion Étudiants',
                  description: 'Module complet',
                  color: Colors.green,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentManagementPage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.person_add_rounded,
                  label: 'Ajouter Utilisateur',
                  description: 'Nouveau compte',
                  color: Colors.green,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.announcement_rounded,
                  label: 'Créer Annonce',
                  description: 'Publier une annonce',
                  color: Colors.orange,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.event_rounded,
                  label: 'Nouvel Événement',
                  description: 'Organiser un événement',
                  color: Colors.green,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.app_registration_rounded,
                  label: 'Préinscriptions',
                  description: 'Gérer les préinscriptions',
                  color: Colors.purple,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const management.PreinscriptionHomePage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.assessment_rounded,
                  label: 'Rapports',
                  description: 'Voir les statistiques',
                  color: Colors.purple,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.settings_rounded,
                  label: 'Paramètres Système',
                  description: 'Configurer le système',
                  color: Colors.red,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.school_rounded,
                  label: 'Universités',
                  description: 'Gérer les universités',
                  color: Colors.indigo,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UniversityManagementPage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.account_balance_rounded,
                  label: 'Facultés',
                  description: 'Gérer les facultés',
                  color: Colors.teal,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FacultyManagementPage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.business_rounded,
                  label: 'Départements',
                  description: 'Gérer les départements',
                  color: Colors.purple,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DepartmentManagementPage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.book_rounded,
                  label: 'Cours',
                  description: 'Gérer les cours',
                  color: Colors.indigo,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseManagementPage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Filières',
                  description: 'Gérer les filières',
                  color: Colors.deepOrange,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProgramManagementPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required bool isDarkTheme,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminInsights(Map<String, dynamic> stats) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu Administratif',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInsightRow(
                  icon: Icons.trending_up_rounded,
                  label: 'Croissance Étudiants',
                  value: '+15%',
                  color: Colors.green,
                  isDarkTheme: isDarkTheme,
                ),
                const Divider(height: 24),
                _buildInsightRow(
                  icon: Icons.event_available_rounded,
                  label: 'Événements ce mois',
                  value: '23',
                  color: Colors.blue,
                  isDarkTheme: isDarkTheme,
                ),
                const Divider(height: 24),
                _buildInsightRow(
                  icon: Icons.feedback_rounded,
                  label: 'Demandes en attente',
                  value: '8',
                  color: Colors.orange,
                  isDarkTheme: isDarkTheme,
                ),
                const Divider(height: 24),
                _buildInsightRow(
                  icon: Icons.check_circle_rounded,
                  label: 'Taux de satisfaction',
                  value: '94%',
                  color: Colors.purple,
                  isDarkTheme: isDarkTheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkTheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isDarkTheme ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminPanelContent(Map<String, dynamic> stats, List activities) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    if (_dashboardStats == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: _isLoadingStats
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger les statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vérifiez votre connexion internet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardStats,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
        ),
      );
    }
    
    return AdminDashboardWidget(
      stats: _dashboardStats!,
      isDarkTheme: isDarkTheme,
    );
  }

  
  Widget _buildAdminStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkTheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkTheme ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildStudentPanelContent() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    if (_dashboardStats == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: _isLoadingStats
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger les statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vérifiez votre connexion internet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardStats,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
        ),
      );
    }
    
    return StudentDashboardWidget(
      stats: _dashboardStats!,
      isDarkTheme: isDarkTheme,
    );
  }

  Widget _buildCourseCard({
    required String title,
    required double progress,
    required Color color,
    required bool isDarkTheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.book_rounded, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}% complété',
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkTheme ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(UserModel user) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? "Bonjour" : now.hour < 18 ? "Bonsoir" : "Bonne nuit";

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.shade400,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'userAvatar',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 35,
                color: Colors.cyan,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _getRoleDisplayName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(List groups) {
    return const SizedBox.shrink();
  }

  Widget _buildStoryCircle(Map<String, dynamic> story) {
    final isAddButton = story['isAddButton'] as bool? ?? false;
    final hasStory = story['hasStory'] as bool? ?? false;
    final gradient = story['gradient'] as List<Color>?;

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasStory && !isAddButton && gradient != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    )
                  : null,
              color: !hasStory || isAddButton ? Colors.grey.shade300 : null,
              boxShadow: hasStory && !isAddButton && gradient != null
                  ? [
                      BoxShadow(
                        color: gradient.first.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            padding: EdgeInsets.all(hasStory && !isAddButton ? 3 : 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: isAddButton ? Border.all(color: Colors.grey.shade300, width: 2) : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(37.5),
                  onTap: () {},
                  child: isAddButton
                      ? Icon(Icons.add_rounded, color: Colors.grey.shade600, size: 32)
                      : ClipOval(
                          child: story['imageUrl'] != null && story['imageUrl'] != ''
                              ? Image.network(
                                  story['imageUrl'] as String,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.person, color: Colors.grey.shade400),
                                    );
                                  },
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.person, color: Colors.grey.shade400),
                                ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 75,
            child: Text(
              story['name'] as String? ?? 'Utilisateur',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isAddButton ? FontWeight.normal : FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    final statsList = [
      {'icon': Icons.school_rounded, 'label': 'Étudiants', 'value': stats['total_students'], 'color': Colors.blue},
      {'icon': Icons.person_rounded, 'label': 'Enseignants', 'value': stats['total_teachers'], 'color': Colors.green},
      {'icon': Icons.groups_rounded, 'label': 'Groupes', 'value': stats['groups'], 'color': Colors.orange},
      {'icon': Icons.app_registration_rounded, 'label': 'Préinscriptions', 'value': stats['preinscriptions'] ?? 0, 'color': Colors.purple},
      {'icon': Icons.campaign_rounded, 'label': 'Annonces', 'value': stats['announcements'] ?? 0, 'color': Colors.red},
      {'icon': Icons.work_rounded, 'label': 'Opportunités', 'value': stats['opportunities'], 'color': Colors.teal},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: statsList.length,
            itemBuilder: (context, index) {
              final stat = statsList[index];
              return _buildStatCard(
                icon: stat['icon'] as IconData,
                label: stat['label'] as String,
                value: stat['value']?.toString() ?? '0',
                color: stat['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      constraints: const BoxConstraints(
        minWidth: 140,
        minHeight: 140,
      ),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              if (constraints.maxWidth > 100)
                Positioned(
                  right: -15,
                  top: -15,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkTheme ? Colors.white70 : Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUniversitySelectionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade400, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.school_rounded, color: Colors.white, size: 40),
                SizedBox(height: 12),
                Text(
                  'Sélectionnez votre université',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Choisissez l\'établissement où vous souhaitez vous préinscrire',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Universités disponibles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...[
            {
              'name': 'Université de Yaoundé I',
              'short': 'UY1',
              'description': 'Première université du Cameroun',
              'color': Colors.blue,
              'isUY1': true,
            },
            {
              'name': 'Université de Yaoundé II',
              'short': 'UY2',
              'description': 'Université de Soa',
              'color': Colors.green,
              'isUY1': false,
            },
            {
              'name': 'Université de Douala',
              'short': 'UD',
              'description': 'Université côtière',
              'color': Colors.orange,
              'isUY1': false,
            },
            {
              'name': 'Université de Dschang',
              'short': 'UDS',
              'description': 'Université de l\'Ouest',
              'color': Colors.purple,
              'isUY1': false,
            },
            {
              'name': 'Université de Maroua',
              'short': 'UM',
              'description': 'Université de l\'Extrême-Nord',
              'color': Colors.red,
              'isUY1': false,
            },
            {
              'name': 'Université de Buéa',
              'short': 'UB',
              'description': 'Université anglophone',
              'color': Colors.teal,
              'isUY1': false,
            },
          ].map((university) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (university['isUY1'] as bool) {
                        _showUniversitySelection = false;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const student.PreinscriptionHomePage()),
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Les préinscriptions pour ${university['name']} ne sont pas encore disponibles.'),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (university['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: university['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                university['name'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                university['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (university['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            university['short'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: university['color'] as Color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (university['isUY1'] as bool)
                          const Icon(Icons.check_circle, color: Colors.green, size: 20)
                        else
                          const Icon(Icons.lock, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExploreContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_rounded, size: 80, color: Colors.cyan),
          SizedBox(height: 20),
          Text(
            'Explorer',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Découvrez de nouveaux contenus et opportunités',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesContent() {
    return const MessagingHomePage();
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'En vedette',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            padEnds: false,
            controller: PageController(viewportFraction: 0.9),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildFeaturedCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(int index) {
    final cards = [
      {
        'title': 'Nouveau Cours',
        'subtitle': 'Intelligence Artificielle',
        'gradient': [Colors.blue.shade400, Colors.cyan.shade400],
        'image': null, // Utilisera une icône par défaut
      },
      {
        'title': 'Événement',
        'subtitle': 'Conférence Tech 2024',
        'gradient': [Colors.orange.shade400, Colors.red.shade400],
        'image': null, // Utilisera une icône par défaut
      },
      {
        'title': 'Stage',
        'subtitle': 'Opportunité Google',
        'gradient': [Colors.green.shade400, Colors.teal.shade400],
        'image': null, // Utilisera une icône par défaut
      },
    ];

    final card = cards[index];

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (card['gradient'] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: card['image'] != null 
                ? Image.network(
                    card['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: card['gradient'] as List<Color>,
                      ),
                    ),
                  );
                },
              )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: card['gradient'] as List<Color>,
                    ),
                  ),
                ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      card['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card['subtitle'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  Widget _buildActivitiesSection(List activities) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activités récentes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: activities.length < 5 ? activities.length : 5,
          itemBuilder: (context, index) {
            return _buildActivityCard(activities[index]);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade300, Colors.blue.shade500],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
                Icons.person,
                size: 25,
                color: Colors.white,
              ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activity['first_name'] ?? ''} ${activity['last_name'] ?? ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description'] ?? '',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(activity['created_at']),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inDays}j';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildOpportunitiesCarousel(List opportunities) {
    if (opportunities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Opportunités',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: opportunities.length < 10 ? opportunities.length : 10,
            itemBuilder: (context, index) {
              return _buildOpportunityCard(opportunities[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opportunity) {
    final type = opportunity['type'] ?? 'job';
    final colorMap = {
      'job': [Colors.blue.shade400, Colors.blue.shade600],
      'internship': [Colors.green.shade400, Colors.green.shade600],
      'scholarship': [Colors.orange.shade400, Colors.orange.shade600],
    };
    final colors = colorMap[type] ?? [Colors.blue.shade400, Colors.blue.shade600];

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  opportunity['title'] ?? 'Opportunité',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        opportunity['location'] ?? 'Non spécifié',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection(List announcements) {
    if (announcements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Annonces',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: announcements.length < 3 ? announcements.length : 3,
          itemBuilder: (context, index) {
            return _buildAnnouncementCard(announcements[index]);
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    colors: [Colors.red.shade400, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
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
                      announcement['title'] ?? 'Annonce',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(announcement['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement['content'] ?? '',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.black87,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTab(List groups, List opportunities, List events) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explorer',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildCategoryChips(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < groups.length) {
                  return _buildExploreGroupCard(groups[index]);
                }
                return const SizedBox.shrink();
              },
              childCount: groups.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    final categories = ['Tous', 'Groupes', 'Cours', 'Événements', 'Opportunités'];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == categories[index].toLowerCase() || (index == 0 && _selectedCategory == 'all');
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? categories[index].toLowerCase() : 'all';
                });
              },
              backgroundColor: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
              selectedColor: Colors.cyan,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDarkTheme ? Colors.white70 : Colors.black87),
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreGroupCard(Map<String, dynamic> group) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.primaries[group['name'].toString().length % Colors.primaries.length],
                  Colors.primaries[(group['name'].toString().length + 1) % Colors.primaries.length],
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Text(
                group['name'] != null && group['name'].toString().isNotEmpty
                    ? group['name'].toString()[0].toUpperCase()
                    : 'G',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'] ?? 'Groupe',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group['members_count'] ?? 0} membres',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab(List activities) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < activities.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: _buildMessageCard(activities[index]),
                );
              }
              return const SizedBox.shrink();
            },
            childCount: activities.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan.shade300, Colors.blue.shade500],
                  ),
                  shape: BoxShape.circle,
                ),
                child: message['avatar'] != null && message['avatar'] != ''
                    ? CircleAvatar(backgroundImage: NetworkImage(message['avatar']))
                    : Center(
                        child: Text(
                          message['first_name'] != null && message['first_name'].toString().isNotEmpty
                              ? message['first_name'].toString()[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${message['first_name'] ?? ''} ${message['last_name'] ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _formatTime(message['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message['description'] ?? '',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white60 : Colors.black54,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const SettingsPage();
  }

  // Actions rapides pour les enseignants
  Widget _buildTeacherQuickActions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Rapides Enseignant',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAdminActionCard(
                  icon: Icons.assignment_rounded,
                  label: 'Mes Cours',
                  description: 'Gérer les cours',
                  color: Colors.blue,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.grade_rounded,
                  label: 'Notes',
                  description: 'Saisir les notes',
                  color: Colors.green,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.groups_rounded,
                  label: 'Classes',
                  description: 'Voir les classes',
                  color: Colors.orange,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section spécifique pour les enseignants
  Widget _buildTeacherSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.indigo.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Espace Enseignant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gérez vos cours et suivez vos étudiants',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Actions rapides pour les leaders
  Widget _buildLeaderQuickActions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Rapides Leader',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAdminActionCard(
                  icon: Icons.group_work_rounded,
                  label: 'Mon Groupe',
                  description: 'Gérer le groupe',
                  color: Colors.purple,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.event_available_rounded,
                  label: 'Événements',
                  description: 'Organiser des événements',
                  color: Colors.teal,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section spécifique pour les leaders
  Widget _buildLeaderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.pink.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Espace Leader',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Menez votre groupe vers le succès',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Actions rapides pour les modérateurs
  Widget _buildModeratorQuickActions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Rapides Modérateur',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAdminActionCard(
                  icon: Icons.content_paste_rounded,
                  label: 'Modérer',
                  description: 'Contenu à modérer',
                  color: Colors.red,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.flag_rounded,
                  label: 'Signalements',
                  description: 'Voir les signaux',
                  color: Colors.orange,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Actions rapides pour le personnel
  Widget _buildStaffQuickActions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Rapides Personnel',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAdminActionCard(
                  icon: Icons.description_rounded,
                  label: 'Documents',
                  description: 'Gérer les documents',
                  color: Colors.brown,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.support_agent_rounded,
                  label: 'Support',
                  description: 'Aide aux utilisateurs',
                  color: Colors.indigo,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteQuickActions() {
    print('DEBUG: _buildInviteQuickActions() called');
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions Rapides Invité',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAdminActionCard(
                  icon: Icons.app_registration_rounded,
                  label: 'Préinscription',
                  description: 'Postuler à une faculté',
                  color: Colors.purple,
                  isDarkTheme: isDarkTheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const student.PreinscriptionHomePage(),
                      ),
                    );
                  },
                ),
                _buildAdminActionCard(
                  icon: Icons.explore_rounded,
                  label: 'Explorer',
                  description: 'Découvrir la plateforme',
                  color: Colors.teal,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.info_rounded,
                  label: 'Informations',
                  description: 'En savoir plus',
                  color: Colors.blue,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
                _buildAdminActionCard(
                  icon: Icons.contact_mail_rounded,
                  label: 'Contact',
                  description: 'Nous contacter',
                  color: Colors.purple,
                  isDarkTheme: isDarkTheme,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteSection() {
    print('DEBUG: _buildInviteSection() called');
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade400,
            Colors.blueGrey.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Espace Invité',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenue sur MyCampus !',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Actions rapides pour les invités
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const student.PreinscriptionHomePage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.app_registration_rounded,
                      color: Colors.grey,
                      size: 24,
                    ),
                    label: const Text(
                      'Postuler maintenant',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.grey,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Créez un compte pour accéder à toutes les fonctionnalités'),
                        backgroundColor: Colors.grey,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.info_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Informations pour les invités
          Text(
            'En tant qu\'invité, vous pouvez:\n• Explorer les facultés disponibles\n• Postuler à une préinscription\n• Découvrir nos programmes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Gradient gradient;

  const _AnimatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradient,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ), 
      ),
    );
  }

  }
