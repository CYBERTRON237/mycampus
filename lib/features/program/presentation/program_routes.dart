import 'package:flutter/material.dart';
import 'package:mycampus/features/program/presentation/pages/program_management_page.dart';

class ProgramRoutes {
  static const String programManagement = '/program';
  static const String programDetails = '/program/details';
  static const String programCreate = '/program/create';
  static const String programEdit = '/program/edit';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      programManagement: (BuildContext context) => const ProgramManagementPage(),
    };
  }

  // Route pour les détails d'un programme avec paramètre ID
  static Route<dynamic> generateProgramDetailsRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => ProgramManagementPage(),
      settings: settings,
    );
  }

  // Route pour créer un nouveau programme
  static Route<dynamic> generateProgramCreateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => ProgramManagementPage(),
      settings: settings,
    );
  }

  // Route pour éditer un programme existant
  static Route<dynamic> generateProgramEditRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => ProgramManagementPage(),
      settings: settings,
    );
  }
}
