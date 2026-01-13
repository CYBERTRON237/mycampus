import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats_model.dart';
import '../../../features/auth/services/auth_service.dart';

class DashboardService {
  final http.Client client;
  final AuthService authService;
  final String baseUrl = 'http://localhost/mycampus/api';

  DashboardService({
    required this.client,
    required this.authService,
  });

  Future<Either<String, DashboardStatsModel>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      
      // Utiliser l'endpoint unifié
      final response = await client.get(
        Uri.parse('$baseUrl/dashboard/test_data.php'), // Temporairement: test_data.php
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = _parseJsonResponse(response.body);
        
        if (data['success'] == true) {
          final statsData = data['data'];
          
          final stats = DashboardStatsModel(
            totalUsers: statsData['total_users'] ?? 0,
            totalStudents: statsData['students'] ?? 0,
            totalTeachers: statsData['teachers'] ?? 0,
            totalAdmins: statsData['admins'] ?? 0,
            totalStaff: statsData['staff'] ?? 0,
            totalPreinscriptions: statsData['preinscriptions'] ?? 0,
            totalInstitutions: statsData['total'] ?? 0,
            totalFaculties: statsData['total'] ?? 0,
            totalDepartments: statsData['total'] ?? 0,
            totalPrograms: statsData['total'] ?? 0,
            totalCourses: statsData['total'] ?? 0,
            totalOpportunities: statsData['total'] ?? 0,
            activeStudents: statsData['active_students'] ?? 0,
            activeTeachers: statsData['active_teachers'] ?? 0,
            activeCourses: statsData['active_courses'] ?? 0,
            activeOpportunities: statsData['active_opportunities'] ?? 0,
            newUsersThisMonth: statsData['new_this_month'] ?? 0,
            newInstitutionsThisMonth: statsData['new_this_month'] ?? 0,
            newCoursesThisMonth: statsData['new_this_month'] ?? 0,
            userGrowthRate: (statsData['growth_rate'] ?? 0.0).toDouble(),
            institutionGrowthRate: (statsData['growth_rate'] ?? 0.0).toDouble(),
            courseGrowthRate: (statsData['growth_rate'] ?? 0.0).toDouble(),
            topInstitutions: statsData['top_institutions'] ?? [],
            topFaculties: statsData['top_faculties'] ?? [],
            topPrograms: statsData['top_programs'] ?? [],
            recentActivities: statsData['recent_activities'] ?? [],
          );

          return Right(stats);
        }
      }

      return Left('Failed to load dashboard statistics');
    } catch (e) {
      return Left('Error loading dashboard statistics: $e');
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> getRecentActivities() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/activities/recent.php'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = _parseJsonResponse(response.body);
        if (data['success']) {
          final activities = List<Map<String, dynamic>>.from(data['data'] ?? []);
          return Right(activities);
        }
      }
      return Left('Failed to load recent activities');
    } catch (e) {
      return Left('Error loading recent activities: $e');
    }
  }

  Future<Either<String, Map<String, dynamic>>> getDashboardData() async {
    try {
      final headers = await _getHeaders();
      
      // Utiliser l'endpoint unifié pour les données du dashboard
      final response = await client.get(
        Uri.parse('$baseUrl/dashboard/test_data.php'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = _parseJsonResponse(response.body);
        
        if (data['success'] == true) {
          return Right(data['data'] ?? {});
        }
      }

      return Left('Failed to load dashboard data');
    } catch (e) {
      return Left('Error loading dashboard data: $e');
    }
  }

  Future<Either<String, List<Map<String, dynamic>>>> getUpcomingEvents() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl/events/upcoming.php'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = _parseJsonResponse(response.body);
        if (data['success']) {
          final events = List<Map<String, dynamic>>.from(data['data'] ?? []);
          return Right(events);
        }
      }
      return Left('Failed to load upcoming events');
    } catch (e) {
      return Left('Error loading upcoming events: $e');
    }
  }

  Map<String, dynamic> _parseJsonResponse(String responseBody) {
    try {
      return json.decode(responseBody.trim());
    } catch (e) {
      return {'success': false, 'message': 'Invalid JSON response'};
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await authService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
