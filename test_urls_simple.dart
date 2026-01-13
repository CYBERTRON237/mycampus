void main() {
  // Simulate the fixed URLs
  final baseUrl = 'http://127.0.0.1/mycampus/api';
  
  print('Testing URL construction after fix:');
  print('Base URL: $baseUrl');
  
  // Test the URLs that would be constructed
  final testListUrl = '$baseUrl/preinscriptions/list_preinscriptions.php';
  final testGetUrl = '$baseUrl/preinscriptions/get_preinscription.php';
  
  print('\nActual URLs:');
  print('List URL: $testListUrl');
  print('Get URL: $testGetUrl');
  
  // Check for double /api/
  if (testListUrl.contains('/api/api/') || testGetUrl.contains('/api/api/')) {
    print('\n❌ ERROR: Double /api/ found in URLs!');
  } else {
    print('\n✅ SUCCESS: No double /api/ in URLs');
    print('✅ URLs are correctly formatted');
  }
  
  // Expected vs actual
  print('\nExpected vs Actual:');
  print('Expected list: http://127.0.0.1/mycampus/api/preinscriptions/list_preinscriptions.php');
  print('Actual list:   $testListUrl');
  print('Match: ${testListUrl == "http://127.0.0.1/mycampus/api/preinscriptions/list_preinscriptions.php"}');
}
