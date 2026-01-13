import 'package:flutter/material.dart';
import 'package:mycampus/features/department/presentation/pages/department_management_page.dart';

class DepartmentRoutes {
  static const String departmentManagement = '/department';
  static const String departmentDetails = '/department/details';
  static const String departmentCreate = '/department/create';
  static const String departmentEdit = '/department/edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      departmentManagement: (BuildContext context) => const DepartmentManagementPage(),
    };
  }

  // Route pour les détails d'un département avec paramètre ID
  static Route<dynamic> generateDepartmentDetailsRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => DepartmentManagementPage(),
      settings: settings,
    );
  }

  // Route pour créer un nouveau département
  static Route<dynamic> generateDepartmentCreateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => DepartmentManagementPage(),
      settings: settings,
    );
  }

  // Route pour éditer un département existant
  static Route<dynamic> generateDepartmentEditRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => DepartmentManagementPage(),
      settings: settings,
    );
  }
}
