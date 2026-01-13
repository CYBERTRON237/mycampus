import 'package:flutter/material.dart';
import '../presentation/pages/student_management_page.dart';

class StudentManagementRoutes {
  static const String studentManagement = '/student-management';
  static const String studentDetails = '/student-management/details';
  static const String studentCreate = '/student-management/create';
  static const String studentEdit = '/student-management/edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      studentManagement: (context) => const StudentManagementPage(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case studentManagement:
        return MaterialPageRoute(
          builder: (context) => const StudentManagementPage(),
          settings: settings,
        );
        
      case studentDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('studentId')) {
          return MaterialPageRoute(
            builder: (context) => StudentManagementPage(
              // TODO: Implémenter la page de détails avec l'ID de l'étudiant
            ),
            settings: settings,
          );
        }
        break;
        
      case studentEdit:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('studentId')) {
          return MaterialPageRoute(
            builder: (context) => StudentManagementPage(
              // TODO: Implémenter la page d'édition avec l'ID de l'étudiant
            ),
            settings: settings,
          );
        }
        break;
    }
    
    return null;
  }
}
