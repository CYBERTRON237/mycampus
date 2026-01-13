import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/core/providers/theme_provider.dart';
import 'lib/features/auth/services/auth_service.dart';
import 'lib/features/profile/providers/profile_provider.dart';
import 'lib/features/profile/data/repositories/profile_repository_impl.dart';
import 'lib/features/profile/data/datasources/profile_remote_datasource.dart';
import 'lib/features/profile/presentation/pages/professional_profile_page.dart';
import 'lib/constants/app_colors.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TestProfileApp());
}

class TestProfileApp extends StatelessWidget {
  const TestProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            repository: ProfileRepositoryImpl(
              remoteDataSource: ProfileRemoteDataSource(
                client: http.Client(),
                authService: AuthService(),
                baseUrl: 'http://localhost/mycampus/api',
              ),
            ),
            authService: AuthService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Profile Module Test',
        theme: ThemeData(
          primarySwatch: AppColors.primaryMaterial,
          useMaterial3: true,
        ),
        home: const ProfileTestPage(),
      ),
    );
  }
}

class ProfileTestPage extends StatelessWidget {
  const ProfileTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Module Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const ProfessionalProfilePage(),
    );
  }
}

// Mock HTTP Client for testing
class HttpClient {
  Future<void> get(Uri url, {Map<String, String>? headers}) async {
    // Mock implementation
  }
}
