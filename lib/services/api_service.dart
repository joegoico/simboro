import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sistema_gym/config/api_config.dart';
import 'package:logging/logging.dart';

class ApiService {
  static final String baseUrl = ApiConfig.baseUrl;
  static const storage = FlutterSecureStorage();
  static final Logger logger = Logger('ApiService');

  // Headers con autenticación - HACER PÚBLICO
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await storage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener access token
  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  // Obtener refresh token
  static Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refresh_token');
  }

  // Refrescar token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await storage.write(key: 'access_token', value: data['access_token']);
        if (data['refresh_token'] != null) {
          await storage.write(
            key: 'refresh_token',
            value: data['refresh_token'],
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      logger.severe('Error refrescando token: $e');
      return false;
    }
  }

  // Guardar tokens
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await storage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  // Limpiar todos los tokens
  static Future<void> clearTokens() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    await storage.delete(key: 'user_data');
  }

  // GET request con manejo automático de 401
  static Future<dynamic> get(String endpoint) async {
    try {
      print('GET request a $endpoint');
      var response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getAuthHeaders(),
      );

      // Si el token expiró, intentar refrescar
      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          // Reintentar con el nuevo token
          response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: await getAuthHeaders(),
          );
        } else {
          throw 'Sesión expirada';
        }
      }

      if (response.statusCode == 200) {
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print('Error en GET request: $e');
      throw 'Error de conexión: $e';
    }
  }

  // POST request con manejo automático de 401
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      logger.info('POST request a $endpoint con body: $body');
      logger.info('URL completa: $baseUrl$endpoint');
      logger.info('Headers: ${await getAuthHeaders()}');

      var response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getAuthHeaders(),
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          response = await http.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await getAuthHeaders(),
            body: body != null ? json.encode(body) : null,
          );
        } else {
          throw 'Sesión expirada';
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // PUT request con manejo automático de 401
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      var response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getAuthHeaders(),
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          response = await http.put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await getAuthHeaders(),
            body: body != null ? json.encode(body) : null,
          );
        } else {
          throw 'Sesión expirada';
        }
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // DELETE request con manejo automático de 401
  static Future<dynamic> delete(String endpoint) async {
    try {
      var response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          response = await http.delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: await getAuthHeaders(),
          );
        } else {
          throw 'Sesión expirada';
        }
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw 'Error de conexión: $e';
    }
  }

  // Manejo de errores
  static String _handleError(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['detail'] ?? body['message'] ?? 'Error desconocido';
    } catch (e) {
      return 'Error del servidor: ${response.statusCode}';
    }
  }

  // Obtener datos del usuario guardados
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataStr = await storage.read(key: 'user_data');
      if (userDataStr != null) {
        return json.decode(userDataStr);
      }
      return null;
    } catch (e) {
      logger.severe('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  // Guardar datos del usuario
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await storage.write(key: 'user_data', value: json.encode(userData));
  }
}
