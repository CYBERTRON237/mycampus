import 'dart:async';
import 'dart:math';

class ViceRectorDashboardService {
  static Future<Map<String, int>> getQuickStats() async {
    // Simuler un appel API
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      'preinscriptions': 156,
      'students': 12500,
      'staff': 1800,
      'faculties': 6,
      'programs': 45,
      'courses': 320,
    };
  }

  static Future<Map<String, dynamic>> getAcademicStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    return {
      'admission_rate': 78.5,
      'success_rate': 85.2,
      'average_grade': 14.3,
      'international_students': 1250,
      'research_projects': 89,
      'publications': 234,
    };
  }

  static Future<List<Map<String, dynamic>>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      {
        'title': 'Nouvelle préinscription',
        'description': '45 nouvelles préinscriptions en attente de validation',
        'time': 'Il y a 2 heures',
        'type': 'preinscription',
        'priority': 'high'
      },
      {
        'title': 'Réunion facultaire',
        'description': 'Réunion trimestrielle des doyens de facultés',
        'time': 'Il y a 4 heures',
        'type': 'meeting',
        'priority': 'medium'
      },
      {
        'title': 'Rapport académique',
        'description': 'Rapport mensuel des performances académiques disponible',
        'time': 'Il y a 1 jour',
        'type': 'report',
        'priority': 'low'
      },
      {
        'title': 'Audit pédagogique',
        'description': 'Audit de qualité des programmes en cours',
        'time': 'Il y a 2 jours',
        'type': 'audit',
        'priority': 'medium'
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getFacultyPerformance() async {
    await Future.delayed(const Duration(milliseconds: 700));
    
    final random = Random();
    final faculties = ['FALSH', 'FS', 'FSE', 'IUT', 'ENSPY', 'FSEG'];
    
    return faculties.map((faculty) => {
      'name': faculty,
      'students': 1500 + random.nextInt(3000),
      'success_rate': 75.0 + random.nextDouble() * 20,
      'satisfaction': 3.5 + random.nextDouble() * 1.5,
      'programs': 8 + random.nextInt(12),
    }).toList();
  }

  static Future<Map<String, dynamic>> getInstitutionalOverview() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      'total_students': 12500,
      'total_staff': 1800,
      'total_programs': 45,
      'total_courses': 320,
      'budget_utilization': 78.5,
      'research_grants': 12,
      'partnerships': 25,
      'international_exchange': 156,
    };
  }
}
