/// Configuration de l'API Backend
class ApiConfig {
  // Base URL - À modifier selon l'environnement
  static const String baseUrl = 'http://localhost:8080/api';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  // Search Endpoints
  static const String searchTextEndpoint = '/search/text';
  static const String searchImageEndpoint = '/search/image';
  static const String searchMultimodalEndpoint = '/search/multimodal';

  // Product Endpoints
  static const String productsEndpoint = '/products';
  static String productDetailEndpoint(String id) => '/product/$id';
  static const String categoriesEndpoint = '/categories';

  // Cart Endpoints
  static const String cartEndpoint = '/cart';
  static const String cartAddEndpoint = '/cart/add';
  static const String cartListEndpoint = '/cart/list';
  static const String cartUpdateEndpoint = '/cart/update';
  static const String cartRemoveEndpoint = '/cart/remove';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Image Upload Headers
  static Map<String, String> getMultipartHeaders({String? token}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
