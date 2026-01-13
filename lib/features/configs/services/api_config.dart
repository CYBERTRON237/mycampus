class ApiConfig {
  // URL de base de l'API (le slash final est important pour la construction des URLs)
  static const String baseUrl = 'http://127.0.0.1/mycampus/api/';
  
  // Timeout pour les requêtes HTTP
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration connectTimeout = Duration(seconds: 10);
  
  // Endpoints
  static const String me = '/auth/me.php';
  static const String login = '/auth/login.php';
  static const String register = '/auth/register.php';
  static const String logout = '/auth/logout.php';
  static const String dashboard = '/auth/dashboard.php';
  
  // Headers
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // Méthode pour ajouter l'authentification aux headers
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }
}
