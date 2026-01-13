import 'package:mycampus/features/profile/models/profile_model.dart';

abstract class ProfileRepository {
  // Get current user's complete profile
  Future<ProfileModel> getMyProfile();
  
  // Get another user's profile (admin access)
  Future<ProfileModel> getUserProfile(int userId);
  
  // Get current user's preinscription details
  Future<PreinscriptionDetail?> getMyPreinscription();
  
  // Get academic profile information
  Future<AcademicProfile> getAcademicProfile();
  
  // Get professional profile information
  Future<ProfessionalProfile> getProfessionalProfile();
  
  // Get profile statistics
  Future<ProfileStats> getProfileStats();
  
  // Update profile information
  Future<bool> updateProfile(ProfileUpdateRequest request);
  
  // Update profile photo
  Future<bool> updateProfilePhoto(String photoPath);
}
