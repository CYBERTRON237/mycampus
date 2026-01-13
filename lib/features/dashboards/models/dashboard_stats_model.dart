import 'package:equatable/equatable.dart';

class DashboardStatsModel extends Equatable {
  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final int totalAdmins;
  final int totalStaff;
  final int totalPreinscriptions;
  final int totalInstitutions;
  final int totalFaculties;
  final int totalDepartments;
  final int totalPrograms;
  final int totalCourses;
  final int totalOpportunities;
  final int activeStudents;
  final int activeTeachers;
  final int activeCourses;
  final int activeOpportunities;
  final int newUsersThisMonth;
  final int newInstitutionsThisMonth;
  final int newCoursesThisMonth;
  final double userGrowthRate;
  final double institutionGrowthRate;
  final double courseGrowthRate;
  final List<Map<String, dynamic>> topInstitutions;
  final List<Map<String, dynamic>> topFaculties;
  final List<Map<String, dynamic>> topPrograms;
  final List<Map<String, dynamic>> recentActivities;

  const DashboardStatsModel({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.totalStaff,
    required this.totalPreinscriptions,
    required this.totalInstitutions,
    required this.totalFaculties,
    required this.totalDepartments,
    required this.totalPrograms,
    required this.totalCourses,
    required this.totalOpportunities,
    required this.activeStudents,
    required this.activeTeachers,
    required this.activeCourses,
    required this.activeOpportunities,
    required this.newUsersThisMonth,
    required this.newInstitutionsThisMonth,
    required this.newCoursesThisMonth,
    required this.userGrowthRate,
    required this.institutionGrowthRate,
    required this.courseGrowthRate,
    required this.topInstitutions,
    required this.topFaculties,
    required this.topPrograms,
    required this.recentActivities,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalStudents,
        totalTeachers,
        totalAdmins,
        totalStaff,
        totalPreinscriptions,
        totalInstitutions,
        totalFaculties,
        totalDepartments,
        totalPrograms,
        totalCourses,
        totalOpportunities,
        activeStudents,
        activeTeachers,
        activeCourses,
        activeOpportunities,
        newUsersThisMonth,
        newInstitutionsThisMonth,
        newCoursesThisMonth,
        userGrowthRate,
        institutionGrowthRate,
        courseGrowthRate,
        topInstitutions,
        topFaculties,
        topPrograms,
        recentActivities,
      ];
}
