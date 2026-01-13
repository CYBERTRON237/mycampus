import 'package:dartz/dartz.dart';
import '../models/preinscription_model.dart';

abstract class PreinscriptionRepository {
  Future<Either<String, List<PreinscriptionModel>>> getPreinscriptions({
    int page = 1,
    int limit = 20,
    String? faculty,
    String? status,
    String? paymentStatus,
    String? search,
  });

  Future<Either<String, PreinscriptionModel>> getPreinscriptionById(int id);

  Future<Either<String, PreinscriptionModel>> getPreinscriptionByCode(String uniqueCode);

  Future<Either<String, PreinscriptionModel>> createPreinscription(PreinscriptionModel preinscription);

  Future<Either<String, PreinscriptionModel>> updatePreinscription(int id, PreinscriptionModel preinscription);

  Future<Either<String, bool>> deletePreinscription(int id);

  Future<Either<String, bool>> updatePreinscriptionStatus(int id, String status, {String? comments, String? rejectionReason});

  Future<Either<String, bool>> updatePaymentStatus(int id, String paymentStatus, {String? paymentReference, double? paymentAmount});

  Future<Either<String, bool>> scheduleInterview(int id, {
    required DateTime interviewDate,
    required String interviewLocation,
    required String interviewType,
  });

  Future<Either<String, bool>> updateInterviewResult(int id, String result, {String? notes});

  Future<Either<String, bool>> acceptPreinscription(int id, {
    required String admissionNumber,
    required DateTime registrationDeadline,
  });

  Future<Either<String, Map<String, int>>> getPreinscriptionsStats();

  Future<Either<String, List<Map<String, dynamic>>>> getPreinscriptionsByFaculty();

  Future<Either<String, List<Map<String, dynamic>>>> getRecentPreinscriptions({int days = 7});

  Future<Either<String, bool>> exportPreinscriptions({String? format = 'csv', String? faculty, String? status});
}
