import 'package:flutter/foundation.dart';
import '../../auth/services/auth_service.dart';
import 'package:mycampus/features/profile/models/profile_model.dart';
import 'package:mycampus/features/profile/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  final AuthService _authService;

  // State variables
  ProfileModel? _profile;
  PreinscriptionDetail? _preinscription;
  AcademicProfile? _academicProfile;
  ProfessionalProfile? _professionalProfile;
  ProfileStats? _stats;
  
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;

  // Getters
  ProfileModel? get profile => _profile;
  PreinscriptionDetail? get preinscription => _preinscription;
  AcademicProfile? get academicProfile => _academicProfile;
  ProfessionalProfile? get professionalProfile => _professionalProfile;
  ProfileStats? get stats => _stats;
  
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  
  // Computed properties
  bool get hasProfile => _profile != null;
  bool get hasPreinscription => _preinscription != null;
  bool get isStudent => _profile?.academicInfo.role == 'student';
  bool get isUser => _profile?.academicInfo.role == 'user';
  bool get isInvite => _profile?.academicInfo.role == 'invite';
  bool get isTeacher => ['teacher', 'professor', 'professor_titular'].contains(_profile?.academicInfo.role);
  bool get isAdmin => ['admin', 'superadmin', 'admin_local', 'admin_national'].contains(_profile?.academicInfo.role);
  bool get isSuperAdmin => _profile?.academicInfo.role == 'superadmin';
  bool get isAdminLocal => _profile?.academicInfo.role == 'admin_local';
  bool get isAdminNational => _profile?.academicInfo.role == 'admin_national';
  bool get isRector => ['recteur', 'rector'].contains(_profile?.academicInfo.role);
  bool get hasValidPreinscription => _preinscription?.isAccepted ?? false;
  bool get isPreinscriptionPending => _preinscription?.isPending ?? false;
  bool get isPreinscriptionAccepted => _preinscription?.isAccepted ?? false;
  
  // LOGIQUE SIMPLE : Si préinscription trouvée = étudiant/user avec profil complet
  bool get hasStudentProfile => hasPreinscription && (isStudent || isUser);
  
  String get userDisplayName => _profile?.displayName ?? 'Utilisateur';
  String get userRole => _profile?.academicInfo.role ?? 'unknown';
  String? get profilePhotoUrl => _profile?.basicInfo.profilePhotoUrl;

  // Debug method to check current state
  void debugProfileState() {
    debugPrint('=== PROFILE DEBUG STATE ===');
    debugPrint('hasProfile: $hasProfile');
    debugPrint('hasPreinscription: $hasPreinscription');
    debugPrint('isStudent: $isStudent');
    debugPrint('isUser: $isUser');
    debugPrint('isInvite: $isInvite');
    debugPrint('hasStudentProfile: $hasStudentProfile');
    debugPrint('userRole: $userRole');
    debugPrint('userDisplayName: $userDisplayName');
    debugPrint('preinscription status: ${_preinscription?.status}');
    debugPrint('preinscription isAccepted: ${_preinscription?.isAccepted}');
    debugPrint('============================');
  }

  ProfileProvider({
    required ProfileRepository repository,
    required AuthService authService,
  }) : _repository = repository, _authService = authService;

  // Initialize profile data
  Future<void> initializeProfile() async {
    debugPrint('=== INITIALIZE PROFILE START ===');
    
    // Check if user is authenticated first
    final currentUser = _authService.currentUser;
    debugPrint('Current user: ${currentUser?.toJson()}');
    
    if (currentUser == null) {
      debugPrint('ERROR: Utilisateur non connecté');
      _setError('Utilisateur non connecté');
      _setLoading(false);
      return;
    }
    
    debugPrint('Loading profile...');
    await loadProfile();
    
    debugPrint('Loading preinscription...');
    await loadPreinscription();
    
    debugPrint('Loading academic profile...');
    await loadAcademicProfile();
    
    debugPrint('Loading professional profile...');
    await loadProfessionalProfile();
    
    // Debug current state
    debugProfileState();
    
    debugPrint('=== INITIALIZE PROFILE END ===');
  }

  // Load complete profile
  Future<void> loadProfile() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Get profile from API instead of just using AuthService data
      final currentUser = _authService.currentUser;
      debugPrint('Current user in loadProfile: ${currentUser?.toJson()}');
      
      if (currentUser != null) {
        // Call the profile API to get complete user data
        try {
          debugPrint('Attempting to load profile from API...');
          final profileData = await _repository.getMyProfile();
          _profile = profileData;
          debugPrint('Profile loaded from API successfully');
          debugPrint('Profile data: ${_profile?.toJson()}');
        } catch (e) {
          debugPrint('API failed, creating fallback profile: ${e.toString()}');
          // Create fallback profile from AuthService data
          _profile = _createFallbackProfile(currentUser);
          debugPrint('Fallback profile created: ${_profile?.toJson()}');
        }
      } else {
        debugPrint('ERROR: currentUser is null in loadProfile');
      }
      
      // Final fallback: if we still don't have a profile, create one anyway
      if (_profile == null && currentUser != null) {
        debugPrint('FINAL FALLBACK: Creating profile as last resort');
        _profile = _createFallbackProfile(currentUser);
        debugPrint('Final fallback profile created: ${_profile?.toJson()}');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load profile: ${e.toString()}');
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create fallback profile from AuthService user data
  ProfileModel _createFallbackProfile(dynamic currentUser) {
    debugPrint('Creating fallback profile for user: ${currentUser.toJson()}');
    debugPrint('User role field: ${currentUser.runtimeType}');
    debugPrint('User role value: ${currentUser.role}');
    debugPrint('User role via map: ${currentUser is Map ? (currentUser as Map)['role'] : 'Not a map'}');
    
    final userRole = currentUser.role ?? 'user';
    debugPrint('Final role to use: $userRole');
    
    // Handle type conversion for ID field
    final userId = currentUser.id is String 
        ? int.tryParse(currentUser.id.toString()) ?? 0
        : (currentUser.id as int?) ?? 0;
    
    debugPrint('Converted user ID: $userId');
    
    final profile = ProfileModel(
      basicInfo: BasicInfo(
        id: userId,
        uuid: currentUser.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), // Use id as uuid fallback
        firstName: currentUser.firstName?.toString() ?? 'Prénom',
        lastName: currentUser.lastName?.toString() ?? 'Nom',
        email: currentUser.email?.toString() ?? '',
        middleName: null,
        phone: currentUser.phone?.toString() ?? '',
        dateOfBirth: null,
        placeOfBirth: null,
        gender: null,
        profilePhotoUrl: currentUser.avatarUrl?.toString(), // Use avatarUrl if available
      ),
      academicInfo: AcademicInfo(
        role: userRole,
        institutionName: currentUser.institutionName?.toString() ?? 'Université de Yaoundé I', // Use user's institution
        departmentName: null,
        matricule: null,
        studentId: null,
        level: null,
        academicYear: DateTime.now().year.toString(),
        preinscriptionCode: null,
        preinscriptionStatus: null,
        faculty: null,
        studyLevel: null,
        desiredProgram: null,
      ),
      professionalInfo: ProfessionalInfo(
        bio: currentUser.bio?.toString(), // Use user's bio if available
        address: currentUser.address?.toString(), // Use user's address if available
        city: null,
        region: null,
        country: null,
        postalCode: null,
        emergencyContact: null,
      ),
      accountInfo: AccountInfo(
        accountStatus: 'active',
        isVerified: true,
        isActive: currentUser.isActive, // Use user's active status
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        lastLoginAt: currentUser.lastLogin?.toIso8601String(), // Use user's last login if available
      ),
    );
    
    debugPrint('Fallback profile created successfully with role: ${profile.academicInfo.role}');
    return profile;
  }

  // Load preinscription details with full data
  Future<void> loadPreinscription() async {
    _clearError();
    
    try {
      _preinscription = await _repository.getMyPreinscription();
      
      debugPrint('Préinscription chargée: ${_preinscription?.status}');
      
      // LOGIQUE CORRIGÉE : Vérifier le statut de la préinscription
      if (_preinscription != null && _profile != null) {
        if (_preinscription!.isAccepted) {
          debugPrint('Préinscription ACCEPTÉE - Construction du profil académique');

          // Déterminer le rôle effectif à utiliser :
          // - si l'utilisateur était encore "invite" ou "user", on le promeut en "student"
          // - sinon on conserve son rôle actif (admin, teacher, rector, etc.)
          final currentRole = _profile!.academicInfo.role;
          final effectiveRole =
              (currentRole == 'invite' || currentRole == 'user') ? 'student' : currentRole;

          // Construire le profil complet avec les données de préinscription acceptée
          _profile = ProfileModel(
            basicInfo: _profile!.basicInfo,
            academicInfo: AcademicInfo(
              role: effectiveRole,
              institutionName: 'Université de Yaoundé I',
              departmentName: _preinscription!.specialization ?? _preinscription!.desiredProgram,
              matricule: _preinscription!.admissionNumber ?? _preinscription!.uniqueCode,
              studentId: _preinscription!.admissionNumber ?? _preinscription!.uniqueCode,
              level: _preinscription!.studyLevel,
              academicYear: DateTime.now().year.toString(),
              preinscriptionCode: _preinscription!.uniqueCode,
              preinscriptionStatus: _preinscription!.status, // 'accepted'
              faculty: _preinscription!.faculty,
              studyLevel: _preinscription!.studyLevel,
              desiredProgram: _preinscription!.desiredProgram,
            ),
            professionalInfo: ProfessionalInfo(
              bio: 'Étudiant en ${_preinscription!.desiredProgram}',
              address: _preinscription!.residenceAddress,
              city: 'Yaoundé',
              region: 'Centre',
              country: 'Cameroun',
              postalCode: null,
              emergencyContact: EmergencyContact(
                name: _preinscription!.parentName,
                relationship: _preinscription!.parentRelationship,
                phone: _preinscription!.parentPhone,
              ),
            ),
            accountInfo: _profile!.accountInfo,
          );
          notifyListeners();

          debugPrint('Profil avec préinscription acceptée construit avec rôle: ${_profile!.academicInfo.role}');
          debugPrint('Profil complet construit avec ${_preinscription!.faculty} - ${_preinscription!.desiredProgram}');
        } else if (_preinscription!.isPending) {
          debugPrint('Préinscription EN ATTENTE - Mise à jour du profil avec statut pending');
          
          // Garder le rôle existant mais mettre à jour les informations académiques
          _profile = ProfileModel(
            basicInfo: _profile!.basicInfo,
            academicInfo: AcademicInfo(
              role: _profile!.academicInfo.role, // Garder le rôle existant (invite/student)
              institutionName: 'Université de Yaoundé I',
              departmentName: _preinscription!.specialization ?? _preinscription!.desiredProgram,
              matricule: _preinscription!.uniqueCode, // Utiliser le code unique pas le numéro d'admission
              studentId: _preinscription!.uniqueCode,
              level: _preinscription!.studyLevel,
              academicYear: DateTime.now().year.toString(),
              preinscriptionCode: _preinscription!.uniqueCode,
              preinscriptionStatus: _preinscription!.status, // 'pending'
              faculty: _preinscription!.faculty,
              studyLevel: _preinscription!.studyLevel,
              desiredProgram: _preinscription!.desiredProgram,
            ),
            professionalInfo: ProfessionalInfo(
              bio: 'Candidat en ${_preinscription!.desiredProgram}',
              address: _preinscription!.residenceAddress,
              city: 'Yaoundé',
              region: 'Centre',
              country: 'Cameroun',
              postalCode: null,
              emergencyContact: EmergencyContact(
                name: _preinscription!.parentName,
                relationship: _preinscription!.parentRelationship,
                phone: _preinscription!.parentPhone,
              ),
            ),
            accountInfo: _profile!.accountInfo,
          );
          notifyListeners();
          
          debugPrint('Profil pending construit avec rôle: ${_profile!.academicInfo.role}');
          debugPrint('Profil pending construit avec ${_preinscription!.faculty} - ${_preinscription!.desiredProgram}');
        } else {
          debugPrint('Préinscription avec statut inconnu: ${_preinscription!.status}');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la préinscription: ${e.toString()}');
    }
  }

  // Load academic profile
  Future<void> loadAcademicProfile() async {
    _clearError();
    
    try {
      // If we have preinscription data, create academic profile from it
      if (_preinscription != null) {
        _academicProfile = AcademicProfile.fromPreinscription(_preinscription!);
        notifyListeners();
      } else {
        // Try to load from API
        _academicProfile = await _repository.getAcademicProfile();
        notifyListeners();
      }
    } catch (e) {
      // Don't set error for missing academic info (expected for some users)
      debugPrint('No academic profile found: ${e.toString()}');
    }
  }

  // Load professional profile
  Future<void> loadProfessionalProfile() async {
    _clearError();
    
    try {
      // If we have preinscription data, create professional profile from it
      if (_preinscription != null) {
        _professionalProfile = ProfessionalProfile.fromPreinscription(_preinscription!);
        notifyListeners();
      } else {
        // Try to load from API
        _professionalProfile = await _repository.getProfessionalProfile();
        notifyListeners();
      }
    } catch (e) {
      // Don't set error for missing professional info (expected for some users)
      debugPrint('No professional profile found: ${e.toString()}');
    }
  }

  // Load profile statistics
  Future<void> loadStats() async {
    _clearError();
    
    try {
      _stats = await _repository.getProfileStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load stats: ${e.toString()}');
    }
  }

  // Update profile information
  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    if (!request.hasChanges) {
      return true; // No changes to make
    }

    _setUpdating(true);
    _clearError();
    
    try {
      final success = await _repository.updateProfile(request);
      
      if (success) {
        // Refresh profile data after successful update
        await loadProfile();
        await loadProfessionalProfile(); // Refresh professional info as it might be updated
      }
      
      return success;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Update profile photo
  Future<bool> updateProfilePhoto(String photoPath) async {
    _setUpdating(true);
    _clearError();
    
    try {
      final success = await _repository.updateProfilePhoto(photoPath);
      
      if (success) {
        // Refresh profile data after successful photo update
        await loadProfile();
      }
      
      return success;
    } catch (e) {
      _setError('Failed to update profile photo: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Get another user's profile (admin access)
  Future<ProfileModel?> getUserProfile(int userId) async {
    _clearError();
    
    try {
      return await _repository.getUserProfile(userId);
    } catch (e) {
      _setError('Failed to load user profile: ${e.toString()}');
      return null;
    }
  }

  // Refresh all profile data
  Future<void> refreshAllData() async {
    await initializeProfile();
  }

  // Clear profile data (useful for logout)
  void clearProfileData() {
    _profile = null;
    _preinscription = null;
    _academicProfile = null;
    _professionalProfile = null;
    _stats = null;
    _error = null;
    _isLoading = false;
    _isUpdating = false;
    notifyListeners();
  }

  // Helper methods for specific profile actions

  // Check if user needs to complete preinscription
  bool get needsPreinscription => isInvite && !hasPreinscription;

  // Check if user can view full profile
  bool get canViewFullProfile => hasValidPreinscription || !isStudent;

  // Calculate profile completion percentage
  double get profileCompletionPercentage {
    if (_profile == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 0;
    
    // Basic info fields
    totalFields += 5; // firstName, lastName, email, phone, dateOfBirth
    if (_profile!.basicInfo.firstName.isNotEmpty) completedFields++;
    if (_profile!.basicInfo.lastName.isNotEmpty) completedFields++;
    if (_profile!.basicInfo.email.isNotEmpty) completedFields++;
    if (_profile!.basicInfo.phone?.isNotEmpty == true) completedFields++;
    if (_profile!.basicInfo.dateOfBirth?.isNotEmpty == true) completedFields++;
    
    // Academic info fields (for students)
    if (isStudent && _preinscription != null) {
      totalFields += 4; // faculty, studyLevel, desiredProgram, admissionNumber
      if (_preinscription!.faculty.isNotEmpty) completedFields++;
      if (_preinscription!.studyLevel?.isNotEmpty == true) completedFields++;
      if (_preinscription!.desiredProgram?.isNotEmpty == true) completedFields++;
      if (_preinscription!.admissionNumber?.isNotEmpty == true) completedFields++;
    }
    
    // Professional info fields
    if (_professionalProfile != null) {
      totalFields += 3; // bio, address, phone
      if (_professionalProfile!.bio?.isNotEmpty == true) completedFields++;
      if (_professionalProfile!.fullAddress.isNotEmpty) completedFields++;
      if (_professionalProfile!.phone?.isNotEmpty == true) completedFields++;
    }
    
    return totalFields > 0 ? completedFields / totalFields : 0.0;
  }

  // Get preinscription status message
  String get preinscriptionStatusMessage {
    if (!hasPreinscription) return '';
    
    switch (_preinscription?.status) {
      case 'pending':
        return 'Votre préinscription est en attente de validation';
      case 'under_review':
        return 'Votre préinscription est en cours de révision';
      case 'accepted':
        return 'Félicitations ! Votre préinscription a été acceptée';
      case 'rejected':
        return 'Votre préinscription a été rejetée';
      case 'confirmed':
        return 'Votre admission est confirmée';
      case 'cancelled':
        return 'Votre préinscription a été annulée';
      case 'deferred':
        return 'Votre préinscription a été reportée';
      case 'waitlisted':
        return 'Vous êtes sur la liste d\'attente';
      default:
        return 'Statut inconnu';
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
