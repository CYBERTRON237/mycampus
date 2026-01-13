import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class RectorDashboardService {
  static final Map<String, dynamic> _cache = {};
  static DateTime? _lastFetch;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  /// Récupère toutes les données du dashboard rector
  static Future<Map<String, dynamic>> getDashboardStats() async {
    // Vérifier le cache
    if (_lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheTimeout && 
        _cache.isNotEmpty) {
      return _cache;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/rector'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          _cache['totalPreinscriptions'] = data['data']['preinscriptions']['total'] ?? 0;
          _cache['totalStudents'] = data['data']['students']['total'] ?? 0;
          _cache['totalStaff'] = data['data']['staff']['total'] ?? 0;
          _cache['totalFaculties'] = data['data']['faculties']['total'] ?? 0;
          _cache['totalDepartments'] = data['data']['departments']['total'] ?? 0;
          _cache['totalPrograms'] = data['data']['programs']['total'] ?? 0;
          _cache['totalCourses'] = data['data']['courses']['total'] ?? 0;
          _cache['totalInstitutions'] = data['data']['institutions']['total'] ?? 0;
          
          // Données détaillées pour les graphiques
          _cache['preinscriptionsByFaculty'] = data['data']['preinscriptions']['by_faculty'] ?? [];
          _cache['studentsByLevel'] = data['data']['students']['by_level'] ?? [];
          _cache['staffByRole'] = data['data']['staff']['by_role'] ?? [];
          _cache['programsByType'] = data['data']['programs'] ?? [];
          _cache['facultiesDetails'] = data['data']['faculties']['faculties_details'] ?? [];
          _cache['recentActivities'] = data['data']['recent_activities'] ?? [];
          _cache['complianceReports'] = data['data']['compliance_reports'] ?? [];
          _cache['academicOversight'] = data['data']['academic_oversight'] ?? [];
          
          _lastFetch = DateTime.now();
          return _cache;
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de la récupération des données');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur, retourner les données du cache si disponible
      if (_cache.isNotEmpty) {
        return _cache;
      }
      throw Exception('Impossible de récupérer les données du dashboard: $e');
    }
  }

  /// Récupère uniquement les statistiques principales
  static Future<Map<String, int>> getQuickStats() async {
    try {
      final data = await getDashboardStats();
      return {
        'preinscriptions': data['totalPreinscriptions'] ?? 0,
        'students': data['totalStudents'] ?? 0,
        'staff': data['totalStaff'] ?? 0,
        'faculties': data['totalFaculties'] ?? 0,
        'departments': data['totalDepartments'] ?? 0,
        'programs': data['totalPrograms'] ?? 0,
        'courses': data['totalCourses'] ?? 0,
        'institutions': data['totalInstitutions'] ?? 0,
      };
    } catch (e) {
      // Retourner des valeurs par défaut en cas d'erreur
      return {
        'preinscriptions': 0,
        'students': 0,
        'staff': 0,
        'faculties': 0,
        'departments': 0,
        'programs': 0,
        'courses': 0,
        'institutions': 0,
      };
    }
  }

  /// Récupère les données des préinscriptions par faculté
  static Future<List<Map<String, dynamic>>> getPreinscriptionsByFaculty() async {
    try {
      final data = await getDashboardStats();
      return List<Map<String, dynamic>>.from(data['preinscriptionsByFaculty'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// Récupère les données des étudiants par niveau
  static Future<List<Map<String, dynamic>>> getStudentsByLevel() async {
    try {
      final data = await getDashboardStats();
      return List<Map<String, dynamic>>.from(data['studentsByLevel'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// Récupère les activités récentes
  static Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final data = await getDashboardStats();
      return List<Map<String, dynamic>>.from(data['recentActivities'] ?? []);
    } catch (e) {
      return [];
    }
  }

  /// Récupère les données de supervision académique
  static Future<Map<String, dynamic>> getAcademicOversight() async {
    try {
      final data = await getDashboardStats();
      return Map<String, dynamic>.from(data['academicOversight'] ?? {});
    } catch (e) {
      return {
        'active_programs': 15,
        'research_projects': 42,
        'international_partnerships': 28,
        'accreditations': 12,
      };
    }
  }

  /// Vide le cache pour forcer une nouvelle récupération
  static void clearCache() {
    _cache.clear();
    _lastFetch = null;
  }

  /// Vérifie si les données sont fraîches
  static bool isDataFresh() {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheTimeout;
  }
}
