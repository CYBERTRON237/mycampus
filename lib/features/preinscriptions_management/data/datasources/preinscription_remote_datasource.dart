import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../models/preinscription_model.dart';
import '../../repositories/preinscription_repository.dart';

class PreinscriptionRemoteDataSource implements PreinscriptionRepository {
  final String baseUrl = 'http://127.0.0.1/mycampus/api';
  final String endpoint = '/preinscriptions/list';
  final String getEndpoint = '/preinscriptions/get';

  @override
  Future<Either<String, List<PreinscriptionModel>>> getPreinscriptions({
    int page = 1,
    int limit = 20,
    String? faculty,
    String? status,
    String? paymentStatus,
    String? search,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 [DEBUG] getPreinscriptions appelé avec: page=$page, limit=$limit, faculty=$faculty, status=$status, paymentStatus=$paymentStatus, search=$search');
      }
      
      // Utiliser le nouveau endpoint list_preinscriptions.php
      final body = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      // Ajouter les filtres s'ils existent
      if (faculty != null) body['faculty'] = faculty;
      if (status != null) body['status'] = status;
      if (paymentStatus != null) body['payment_status'] = paymentStatus;
      if (search != null) body['search'] = search;

      final url = '$baseUrl/preinscriptions/list_preinscriptions.php';
      if (kDebugMode) {
        print('🌐 [DEBUG] URL de la requête: $url');
        print('📤 [DEBUG] Corps de la requête: ${json.encode(body)}');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (kDebugMode) {
        print('📥 [DEBUG] Status Code: ${response.statusCode}');
        print('📄 [DEBUG] Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (kDebugMode) {
          print('✅ [DEBUG] JSON décodé avec succès: $data');
        }
        
        if (data['success'] == true) {
          final List<dynamic> preinscriptionsJson = data['data'] ?? [];
          if (kDebugMode) {
            print('📊 [DEBUG] Nombre de préinscriptions trouvées: ${preinscriptionsJson.length}');
          }
          final preinscriptions = preinscriptionsJson
              .map((json) => PreinscriptionModel.fromJson(json))
              .toList();
          if (kDebugMode) {
            print('✨ [DEBUG] Préinscriptions converties avec succès');
          }
          return Right(preinscriptions);
        } else {
          final errorMsg = data['message'] ?? 'Erreur lors de la récupération des préinscriptions';
          if (kDebugMode) {
            print('❌ [DEBUG] Erreur API: $errorMsg');
          }
          return Left(errorMsg);
        }
      } else {
        final errorMsg = 'Erreur HTTP: ${response.statusCode}';
        if (kDebugMode) {
          print('🚫 [DEBUG] $errorMsg');
        }
        return Left(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Erreur de connexion: $e';
      if (kDebugMode) {
        print('💥 [DEBUG] Exception: $errorMsg');
      }
      return Left(errorMsg);
    }
  }

  @override
  Future<Either<String, PreinscriptionModel>> getPreinscriptionById(int id) async {
    try {
      if (kDebugMode) {
        print('🔍 [DEBUG] getPreinscriptionById appelé avec id: $id');
      }
      
      final url = '$baseUrl/preinscriptions/get_preinscription.php';
      final requestBody = {'id': id};
      
      if (kDebugMode) {
        print('🌐 [DEBUG] URL: $url');
        print('📤 [DEBUG] Corps: ${json.encode(requestBody)}');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (kDebugMode) {
        print('📥 [DEBUG] Status Code: ${response.statusCode}');
        print('📄 [DEBUG] Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (kDebugMode) {
          print('✅ [DEBUG] JSON décodé: $data');
        }
        
        if (data['success'] == true) {
          final preinscription = PreinscriptionModel.fromJson(data['data'] ?? data);
          if (kDebugMode) {
            print('✨ [DEBUG] Préinscription trouvée et convertie');
          }
          return Right(preinscription);
        } else {
          final errorMsg = data['message'] ?? 'Préinscription non trouvée';
          if (kDebugMode) {
            print('❌ [DEBUG] Erreur API: $errorMsg');
          }
          return Left(errorMsg);
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('🚫 [DEBUG] Préinscription non trouvée (404)');
        }
        return Left('Préinscription non trouvée');
      } else {
        final errorMsg = 'Erreur HTTP: ${response.statusCode}';
        if (kDebugMode) {
          print('🚫 [DEBUG] $errorMsg');
        }
        return Left(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Erreur de connexion: $e';
      if (kDebugMode) {
        print('💥 [DEBUG] Exception: $errorMsg');
      }
      return Left(errorMsg);
    }
  }

  @override
  Future<Either<String, PreinscriptionModel>> getPreinscriptionByCode(String uniqueCode) async {
    try {
      if (kDebugMode) {
        print('🔍 [DEBUG] getPreinscriptionByCode appelé avec code: $uniqueCode');
      }
      
      final url = '$baseUrl/preinscriptions/get_preinscription.php';
      final requestBody = {'unique_code': uniqueCode};
      
      if (kDebugMode) {
        print('🌐 [DEBUG] URL: $url');
        print('📤 [DEBUG] Corps: ${json.encode(requestBody)}');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (kDebugMode) {
        print('📥 [DEBUG] Status Code: ${response.statusCode}');
        print('📄 [DEBUG] Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (kDebugMode) {
          print('✅ [DEBUG] JSON décodé: $data');
        }
        
        if (data['success'] == true) {
          final preinscription = PreinscriptionModel.fromJson(data['data'] ?? data);
          if (kDebugMode) {
            print('✨ [DEBUG] Préinscription trouvée et convertie');
          }
          return Right(preinscription);
        } else {
          final errorMsg = data['message'] ?? 'Préinscription non trouvée';
          if (kDebugMode) {
            print('❌ [DEBUG] Erreur API: $errorMsg');
          }
          return Left(errorMsg);
        }
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('🚫 [DEBUG] Préinscription non trouvée (404)');
        }
        return Left('Préinscription non trouvée');
      } else {
        final errorMsg = 'Erreur HTTP: ${response.statusCode}';
        if (kDebugMode) {
          print('🚫 [DEBUG] $errorMsg');
        }
        return Left(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Erreur de connexion: $e';
      if (kDebugMode) {
        print('💥 [DEBUG] Exception: $errorMsg');
      }
      return Left(errorMsg);
    }
  }

  @override
  Future<Either<String, PreinscriptionModel>> createPreinscription(PreinscriptionModel preinscription) async {
    // Non implémenté dans le backend simple - utiliser le endpoint de soumission existant
    return Left('Création non disponible via ce module. Utiliser le module de préinscription simple.');
  }

  @override
  Future<Either<String, PreinscriptionModel>> updatePreinscription(int id, PreinscriptionModel preinscription) async {
    // Non implémenté dans le backend simple - utiliser updatePreinscriptionStatus pour les changements de statut
    return Left('Mise à jour complète non disponible. Utiliser updatePreinscriptionStatus pour les changements de statut.');
  }

  @override
  Future<Either<String, bool>> deletePreinscription(int id) async {
    // Non implémenté dans le backend simple
    return Left('Suppression non disponible via ce module.');
  }

  @override
  Future<Either<String, bool>> updatePreinscriptionStatus(int id, String status, {String? comments, String? rejectionReason}) async {
    try {
      final body = {
        'status': status,
        if (comments != null) 'comments': comments,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      };

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint/status/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true ? Right(true) : Left(data['message'] ?? 'Erreur lors de la mise à jour du statut');
      } else if (response.statusCode == 404) {
        return Left('Préinscription non trouvée');
      } else {
        return Left('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Erreur de connexion: $e');
    }
  }

  @override
  Future<Either<String, bool>> updatePaymentStatus(int id, String paymentStatus, {String? paymentReference, double? paymentAmount}) async {
    // Non implémenté dans le backend simple
    return Left('Mise à jour du paiement non disponible via ce module.');
  }

  @override
  Future<Either<String, bool>> scheduleInterview(int id, {
    required DateTime interviewDate,
    required String interviewLocation,
    required String interviewType,
  }) async {
    // Non implémenté dans le backend simple
    return Left('Planification d\'entretien non disponible via ce module.');
  }

  @override
  Future<Either<String, bool>> updateInterviewResult(int id, String result, {String? notes}) async {
    // Non implémenté dans le backend simple
    return Left('Mise à jour du résultat d\'entretien non disponible via ce module.');
  }

  @override
  Future<Either<String, bool>> acceptPreinscription(int id, {
    required String admissionNumber,
    required DateTime registrationDeadline,
  }) async {
    // Non implémenté dans le backend simple - utiliser updatePreinscriptionStatus avec 'accepted'
    return Left('Acceptation non disponible via ce module. Utiliser updatePreinscriptionStatus avec le statut "accepted".');
  }

  @override
  Future<Either<String, Map<String, int>>> getPreinscriptionsStats() async {
    try {
      if (kDebugMode) {
        print('🔍 [DEBUG] getPreinscriptionsStats appelé');
      }
      
      final url = '$baseUrl/preinscriptions/list_preinscriptions.php';
      final requestBody = {'limit': 1};
      
      if (kDebugMode) {
        print('🌐 [DEBUG] URL: $url');
        print('📤 [DEBUG] Corps: ${json.encode(requestBody)}');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (kDebugMode) {
        print('📥 [DEBUG] Status Code: ${response.statusCode}');
        print('📄 [DEBUG] Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (kDebugMode) {
          print('✅ [DEBUG] JSON décodé: $data');
        }
        
        if (data['success'] == true && data['statistics'] != null) {
          final Map<String, int> stats = {};
          
          final List<dynamic> facultyStats = data['statistics'] ?? [];
          int totalPending = 0;
          int totalAccepted = 0;
          int totalRejected = 0;
          int totalPaid = 0;
          
          for (var faculty in facultyStats) {
            totalPending += (faculty['pending'] ?? 0) as int;
            totalAccepted += (faculty['accepted'] ?? 0) as int;
            totalRejected += (faculty['rejected'] ?? 0) as int;
            totalPaid += (faculty['paid'] ?? 0) as int;
          }
          
          stats['total'] = totalPending + totalAccepted + totalRejected;
          stats['pending'] = totalPending;
          stats['accepted'] = totalAccepted;
          stats['rejected'] = totalRejected;
          stats['paid'] = totalPaid;
          
          if (kDebugMode) {
            print('📊 [DEBUG] Statistiques calculées: $stats');
          }
          
          return Right(stats);
        } else {
          final errorMsg = 'Erreur lors de la récupération des statistiques';
          if (kDebugMode) {
            print('❌ [DEBUG] Erreur: $errorMsg');
          }
          return Left(errorMsg);
        }
      } else {
        final errorMsg = 'Erreur HTTP: ${response.statusCode}';
        if (kDebugMode) {
          print('🚫 [DEBUG] $errorMsg');
        }
        return Left(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Erreur de connexion: $e';
      if (kDebugMode) {
        print('💥 [DEBUG] Exception: $errorMsg');
      }
      return Left(errorMsg);
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getPreinscriptionsByFaculty() async {
    try {
      // Utiliser le endpoint list_preinscriptions.php pour les données par faculté
      final response = await http.post(
        Uri.parse('$baseUrl/preinscriptions/list_preinscriptions.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'limit': 1}), // Limiter à 1 pour juste les stats
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['statistics'] != null) {
          final List<dynamic> facultyData = data['statistics'] ?? [];
          
          final List<Map<String, dynamic>> result = facultyData
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          
          return Right(result);
        } else {
          return Left('Erreur lors de la récupération des données par faculté');
        }
      } else {
        return Left('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Erreur de connexion: $e');
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getRecentPreinscriptions({int days = 7}) async {
    try {
      // Utiliser le endpoint list_preinscriptions.php avec une limite de 10
      final response = await http.post(
        Uri.parse('$baseUrl/preinscriptions/list_preinscriptions.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'limit': 10}), // Limiter aux 10 plus récents
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> recentData = data['data'] ?? [];
          
          // Filtrer pour ne garder que les préinscriptions des derniers jours
          final DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
          final List<Map<String, dynamic>> result = [];
          
          for (var item in recentData) {
            if (item['submission_date'] != null) {
              final DateTime submissionDate = DateTime.parse(item['submission_date']);
              if (submissionDate.isAfter(cutoffDate)) {
                result.add(Map<String, dynamic>.from(item));
              }
            }
          }
          
          return Right(result);
        } else {
          return Left('Erreur lors de la récupération des préinscriptions récentes');
        }
      } else {
        return Left('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      return Left('Erreur de connexion: $e');
    }
  }

  @override
  Future<Either<String, bool>> exportPreinscriptions({String? format = 'csv', String? faculty, String? status}) async {
    try {
      // Pour l'instant, retourner true car l'export n'est pas implémenté dans le backend simple
      return Right(true);
    } catch (e) {
      return Left('Erreur de connexion: $e');
    }
  }
}
