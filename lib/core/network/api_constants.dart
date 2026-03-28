class ApiConstants {
  ApiConstants._();

  /// HTTPS avoids IIS 307 redirect from http:// (Dio often surfaces that as an error on POST).
  static const String baseUrl = 'https://manzili-app.runasp.net/';

  /// When the API returns a bare filename (e.g. `cakes_1.jpg`), it is loaded from this path under [baseUrl].
  /// Change to match your static files (e.g. `uploads/`, `ServiceImages/`, or `''` if files sit at site root).
  static const String serviceImageFolder = 'images/';

  // Auth
  static const String register = '/api/Auth/register';
  static const String login = '/api/Auth/login';
  static const String refresh = '/api/Auth/refresh';

  // Services (spec uses lowercase paths; ASP.NET routing is usually case-insensitive)
  static const String services = '/api/services';
  static String serviceById(int id) => '/api/services/$id';
  static String serviceByName(String name) => '/api/services/name/$name';
  static String homeServices(int no) => '/api/services/home/$no';

  // Orders
  static const String orderRequest = '/api/orders/request';
}

