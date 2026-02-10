class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://manzili-app.runasp.net/';

  // Auth
  static const String register = '/api/Auth/register';
  static const String login = '/api/Auth/login';
  static const String refresh = '/api/Auth/refresh';

  // Services
  static const String services = '/api/Services';
  static String serviceById(int id) => '/api/services/$id';
}

