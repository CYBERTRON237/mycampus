import 'lib/features/preinscriptions_management/data/datasources/preinscription_remote_datasource.dart';

void main() {
  final dataSource = PreinscriptionRemoteDataSource();
  
  print('Testing URL construction:');
  print('Base URL: ${dataSource.baseUrl}');
  print('Expected list URL: http://127.0.0.1/mycampus/api/preinscriptions/list_preinscriptions.php');
  print('Expected get URL: http://127.0.0.1/mycampus/api/preinscriptions/get_preinscription.php');
  
  // Test the URLs that would be constructed
  final testListUrl = '${dataSource.baseUrl}/preinscriptions/list_preinscriptions.php';
  final testGetUrl = '${dataSource.baseUrl}/preinscriptions/get_preinscription.php';
  
  print('\nActual URLs:');
  print('List URL: $testListUrl');
  print('Get URL: $testGetUrl');
  
  // Check for double /api/
  if (testListUrl.contains('/api/api/') || testGetUrl.contains('/api/api/')) {
    print('\n❌ ERROR: Double /api/ found in URLs!');
  } else {
    print('\n✅ SUCCESS: No double /api/ in URLs');
  }
}
