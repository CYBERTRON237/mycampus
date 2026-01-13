import 'package:flutter/material.dart';
import 'package:mycampus/features/faculty/presentation/pages/faculty_management_page.dart';

class FacultyRoutes {
  static const String facultyManagement = '/faculty';
  static const String facultyDetails = '/faculty/details';
  static const String facultyCreate = '/faculty/create';
  static const String facultyEdit = '/faculty/edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      facultyManagement: (BuildContext context) => const FacultyManagementPage(),
    };
  }

  // Route pour les détails d'une faculté avec paramètre ID
  static Route<dynamic> generateFacultyDetailsRoute(RouteSettings settings) {
    final String? facultyId = settings.arguments as String?;
    
    return MaterialPageRoute(
      builder: (context) => FacultyManagementPage(),
      settings: settings,
    );
  }

  // Route pour créer une nouvelle faculté
  static Route<dynamic> generateFacultyCreateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => FacultyManagementPage(),
      settings: settings,
    );
  }

  // Route pour éditer une faculté existante
  static Route<dynamic> generateFacultyEditRoute(RouteSettings settings) {
    final String? facultyId = settings.arguments as String?;
    
    return MaterialPageRoute(
      builder: (context) => FacultyManagementPage(),
      settings: settings,
    );
  }
}
