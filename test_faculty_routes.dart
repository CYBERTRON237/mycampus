import 'package:flutter/material.dart';
import 'lib/features/faculty/presentation/faculty_routes.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Faculty Routes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestHomePage(),
      routes: FacultyRoutes.getRoutes(),
    );
  }
}

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Routes Facultés')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test des routes du module de facultés',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          ListTile(
            title: const Text('Gestion des facultés'),
            subtitle: const Text(FacultyRoutes.facultyManagement),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pushNamed(context, FacultyRoutes.facultyManagement);
            },
          ),
          
          const Divider(),
          
          ListTile(
            title: const Text('Détails faculté'),
            subtitle: const Text('${FacultyRoutes.facultyDetails}/:id'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pushNamed(context, '${FacultyRoutes.facultyDetails}/123');
            },
          ),
          
          ListTile(
            title: const Text('Créer une faculté'),
            subtitle: const Text(FacultyRoutes.facultyCreate),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pushNamed(context, FacultyRoutes.facultyCreate);
            },
          ),
          
          ListTile(
            title: const Text('Modifier une faculté'),
            subtitle: const Text('${FacultyRoutes.facultyEdit}/:id'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.pushNamed(context, '${FacultyRoutes.facultyEdit}/123');
            },
          ),
        ],
      ),
    );
  }
}
