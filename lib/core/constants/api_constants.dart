/// API Constants for MyCampus Application
class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://127.0.0.1/mycampus/api';
  
  // API Endpoints
  static const String auth = 'auth';
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String me = 'auth/me';
  
  // Institutions
  static const String institutions = 'institutions';
  
  // Dashboard
  static const String dashboard = 'dashboards/dashboard.php';
  
  // User Management
  static const String users = 'user_management/users';
  
  // Notifications
  static const String notifications = 'notifications';
  
  // Messaging
  static const String messaging = 'messaging';
  
  // Preinscriptions
  static const String preinscriptions = 'preinscriptions';
  
  // Preinscription Validation
  static const String preinscriptionValidation = 'preinscription_validation/preinscriptions/validation';
  static const String preinscriptionValidationStats = 'preinscription_validation/preinscriptions/validation/stats';
  
  // Announcements
  static const String announcements = 'announcements';
  
  // Courses
  static const String courses = 'courses';
  
  // Programs
  static const String programs = 'programs';
  
  // Departments
  static const String departments = 'departments';
  
  // Faculties
  static const String faculties = 'faculties';
  
  // Universities
  static const String universities = 'universities';
  
  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // Timeout durations
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
