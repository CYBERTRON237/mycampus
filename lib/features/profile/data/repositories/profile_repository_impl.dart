import 'package:mycampus/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mycampus/features/profile/models/profile_model.dart';
import 'package:mycampus/features/profile/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileModel> getMyProfile() async {
    final data = await remoteDataSource.getMyProfile();
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> getUserProfile(int userId) async {
    final data = await remoteDataSource.getUserProfile(userId);
    return ProfileModel.fromJson(data);
  }

  @override
  Future<PreinscriptionDetail?> getMyPreinscription() async {
    final data = await remoteDataSource.getMyPreinscription();
    return data != null ? PreinscriptionDetail.fromJson(data) : null;
  }

  @override
  Future<AcademicProfile> getAcademicProfile() async {
    final data = await remoteDataSource.getAcademicProfile();
    return AcademicProfile.fromJson(data);
  }

  @override
  Future<ProfessionalProfile> getProfessionalProfile() async {
    final data = await remoteDataSource.getProfessionalProfile();
    return ProfessionalProfile.fromJson(data);
  }

  @override
  Future<ProfileStats> getProfileStats() async {
    final data = await remoteDataSource.getProfileStats();
    return ProfileStats.fromJson(data);
  }

  @override
  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    return await remoteDataSource.updateProfile(request);
  }

  @override
  Future<bool> updateProfilePhoto(String photoPath) async {
    return await remoteDataSource.updateProfilePhoto(photoPath);
  }
}
