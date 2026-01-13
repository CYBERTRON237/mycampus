import 'package:flutter/material.dart';
import 'package:mycampus/features/auth/services/auth_service.dart';

/// Test pour vérifier l'isolation des sessions entre instances
class SessionIsolationTest extends StatefulWidget {
  const SessionIsolationTest({super.key});

  @override
  State<SessionIsolationTest> createState() => _SessionIsolationTestState();
}

class _SessionIsolationTestState extends State<SessionIsolationTest> {
  final AuthService _authService = AuthService();
  String _currentUserEmail = 'Non connecté';
  String _currentUserId = 'Non défini';
  String _testResult = 'En attente...';

  @override
  void initState() {
    super.initState();
    _checkCurrentSession();
  }

  Future<void> _checkCurrentSession() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      final token = await _authService.getToken();
      
      setState(() {
        if (currentUser != null) {
          _currentUserEmail = currentUser.email ?? 'Email non trouvé';
          _currentUserId = currentUser.id.toString();
          _testResult = '✅ Session active détectée';
        } else {
          _currentUserEmail = 'Aucun utilisateur';
          _currentUserId = 'Aucun ID';
          _testResult = '❌ Aucune session active';
        }
      });
      
      print('=== TEST ISOLATION SESSION ===');
      print('Email: $_currentUserEmail');
      print('ID: $_currentUserId');
      print('Token: ${token?.substring(0, 20) ?? 'Aucun'}');
      print('============================');
      
    } catch (e) {
      setState(() {
        _testResult = '❌ Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Isolation Session'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations Session Actuelle:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Email: $_currentUserEmail'),
                    Text('ID Utilisateur: $_currentUserId'),
                    Text('Résultat Test: $_testResult'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions de Test:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text('1. Ouvrez cette application 2 fois'),
                    Text('2. Connectez-vous avec 2 comptes différents'),
                    Text('3. Envoyez des messages entre les comptes'),
                    Text('4. Vérifiez que chaque instance garde son propre utilisateur'),
                    Text('5. Les sessions ne doivent pas se mélanger'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkCurrentSession,
              child: const Text('Vérifier Session'),
            ),
          ],
        ),
      ),
    );
  }
}
