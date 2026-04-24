class ApiConstants {
  ApiConstants._();

  /// HTTPS avoids IIS 307 redirect from http:// (Dio often surfaces that as an error on POST).
  static const String baseUrl = 'https://manzili-app.runasp.net/';
  static const String localBaseUrl = 'https://localhost:6001'; // use port 6000 for http

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

  // Orders — POST body: OrderRequestBody (camelCase).
  static const String orderRequestPath = '/api/orders/request';

  /// Resolves to `{baseUrl without trailing slash}/api/orders/request` so Dio never misparses the path.
  static Uri get orderRequestUri {
    final b = baseUrl.trim();
    final root = b.endsWith('/') ? b.substring(0, b.length - 1) : b;
    return Uri.parse('$root/api/orders/request');
  }
}
