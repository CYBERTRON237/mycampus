import 'package:flutter/material.dart';
import 'lib/features/user_management/presentation/pages/user_management_page.dart';
import 'lib/features/user_management/providers/user_management_provider.dart';
import 'lib/features/user_management/data/repositories/user_management_repository.dart';
import 'lib/features/user_management/data/datasources/user_management_remote_datasource.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const UserManagementTestApp());
}

class UserManagementTestApp extends StatelessWidget {
  const UserManagementTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserManagementProvider(
        repository: UserManagementRepositoryImpl(
          remoteDataSource: UserManagementRemoteDataSourceImpl(
            client: http.Client(),
          ),
        ),
      ),
      child: MaterialApp(
        title: 'User Management Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const UserManagementPage(),
      ),
    );
  }
}
