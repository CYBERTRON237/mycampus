import 'package:flutter/material.dart';
import 'package:mycampus/features/course/presentation/pages/course_management_page.dart';

class CourseRoutes {
  static const String courseManagement = '/course';
  static const String courseDetails = '/course/details';
  static const String courseCreate = '/course/create';
  static const String courseEdit = '/course/edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      courseManagement: (BuildContext context) => const CourseManagementPage(),
    };
  }

  // Route pour les détails d'un cours avec paramètre ID
  static Route<dynamic> generateCourseDetailsRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => CourseManagementPage(),
      settings: settings,
    );
  }

  // Route pour créer un nouveau cours
  static Route<dynamic> generateCourseCreateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => CourseManagementPage(),
      settings: settings,
    );
  }

  // Route pour éditer un cours existant
  static Route<dynamic> generateCourseEditRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => CourseManagementPage(),
      settings: settings,
    );
  }
}
