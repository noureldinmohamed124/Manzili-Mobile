class ApiConstants {
  ApiConstants._();

  /// HTTPS avoids IIS 307 redirect from http:// (Dio often surfaces that as an error on POST).
  static const String baseUrl = 'https://manzili-app.runasp.net/';
  static const String localBaseUrl = 'https://localhost:6001'; // use port 6000 for http

  /// When the API returns a bare filename (e.g. `cakes_1.jpg`), it is loaded from this path under [baseUrl].
  /// Change to match your static files (e.g. `uploads/`, `ServiceImages/`, or `''` if files sit at site root).
  static const String serviceImageFolder = 'images/';

  // Auth
  // New API paths (without /api). We keep old constants as fallbacks in repositories/providers.
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';

  // Some hosts use capitalized Auth segment.
  static const String registerLegacy = '/Auth/register';
  static const String loginLegacy = '/Auth/login';
  static const String refreshLegacy = '/Auth/refresh';

  // Old `/api/...` prefix.
  static const String registerApiLegacy = '/api/Auth/register';
  static const String loginApiLegacy = '/api/Auth/login';
  static const String refreshApiLegacy = '/api/Auth/refresh';

  // Services (spec uses lowercase paths; ASP.NET routing is usually case-insensitive)
  static const String services = '/services';
  static String serviceById(int id) => '/services/$id';
  static String serviceByName(String name) => '/services/name/$name';
  static String homeServices(int no) => '/services/home/$no';

  static const String servicesLegacy = '/api/services';
  static String serviceByIdLegacy(int id) => '/api/services/$id';
  static String serviceByNameLegacy(String name) => '/api/services/name/$name';
  static String homeServicesLegacy(int no) => '/api/services/home/$no';

  // Orders — POST body: OrderRequestBody (camelCase).
  static const String orderRequestPath = '/orders/request';
  static const String orders = '/orders';
  static const String orderPaymentSummary = '/order/payment-summary';
  static const String submitPaymentProof = '/orders/submit-payment';

  static const String orderRequestPathLegacy = '/api/orders/request';
  static const String ordersLegacy = '/api/orders';
  static const String orderPaymentSummaryLegacy = '/api/orders/payment-summary';

  /// Resolves to `{baseUrl without trailing slash}/api/orders/request` so Dio never misparses the path.
  static Uri get orderRequestUri {
    final b = baseUrl.trim();
    final root = b.endsWith('/') ? b.substring(0, b.length - 1) : b;
    return Uri.parse('$root/orders/request');
  }

  static Uri get orderRequestUriLegacy {
    final b = baseUrl.trim();
    final root = b.endsWith('/') ? b.substring(0, b.length - 1) : b;
    return Uri.parse('$root/api/orders/request');
  }

  // Seller
  static const String sellerServices = '/seller/services';
  static String sellerServiceById(int id) => '/seller/services/$id';
  static const String sellerDashboard = '/seller/dashboard';
}
