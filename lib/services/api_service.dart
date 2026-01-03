import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smartsearch/config/api_config.dart';

/// Service de base pour les appels API
class ApiService {
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Définir le token d'authentification
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      final response = await _client
          .get(
            uri,
            headers: ApiConfig.getHeaders(token: _authToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await _client
          .post(
            uri,
            headers: ApiConfig.getHeaders(token: _authToken),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await _client
          .put(
            uri,
            headers: ApiConfig.getHeaders(token: _authToken),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await _client
          .delete(
            uri,
            headers: ApiConfig.getHeaders(token: _authToken),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload multipart (pour images)
  Future<Map<String, dynamic>> uploadMultipart(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? additionalFields,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers.addAll(ApiConfig.getMultipartHeaders(token: _authToken));

      // Ajouter le fichier
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      // Ajouter les champs additionnels
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Gestion de la réponse
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response),
      );
    }
  }

  /// Extraire le message d'erreur de la réponse
  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Erreur inconnue';
    } catch (_) {
      return 'Erreur HTTP ${response.statusCode}';
    }
  }

  /// Gestion des erreurs
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return const ApiException(
        statusCode: 0,
        message: 'Pas de connexion internet',
      );
    } else if (error is FormatException) {
      return const ApiException(
        statusCode: 0,
        message: 'Format de réponse invalide',
      );
    } else {
      return ApiException(
        statusCode: 0,
        message: error.toString(),
      );
    }
  }

  /// Fermer le client
  void dispose() {
    _client.close();
  }
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}
