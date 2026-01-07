import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'; // <--- EL CAMBIO IMPORTANTE
import 'package:sistema_gym/config/api_config.dart';
import 'package:logging/logging.dart';

/// Servicio centralizado para la comunicación con la API del backend.
///
/// Esta clase encapsula las peticiones HTTP, gestionando automáticamente
/// la inyección de tokens de autenticación y el procesamiento de respuestas.
class ApiService {
  static final String baseUrl = ApiConfig.baseUrl;
  static final Logger logger = Logger('ApiService');

  /// Genera los encabezados necesarios para las peticiones autenticadas.
  ///
  /// Obtiene el `accessToken` de la sesión actual de [Supabase].
  /// Lanza una [Exception] si no hay una sesión activa, evitando peticiones
  /// que fallarían por falta de permisos.
  ///
  /// Retorna un [Map] con el 'Content-Type' y el 'Authorization' Bearer token.
  static Future<Map<String, String>> getAuthHeaders() async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    if (token == null) {
      logger.warning('Intento de petición sin sesión activa');
      throw Exception('No hay sesión activa');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Realiza una petición de tipo GET al [endpoint] especificado.
  ///
  /// Utiliza [getAuthHeaders] para la autenticación y procesa la respuesta
  /// a través de [_processResponse].
  ///
  /// Lanza una [Exception] si ocurre un error durante la petición.
  static Future<dynamic> get(String endpoint) async {
    ///Get request
    try {
      // logger.info('GET request a $endpoint'); // Descomenta si quieres mucho log
      final headers = await getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      logger.severe('Error en GET request: $e');
      rethrow;
    }
  }

  /// Realiza una petición de tipo POST al [endpoint] enviando un [body] opcional.
  ///
  /// El [body] se codifica automáticamente a formato JSON antes del envío.
  ///
  /// Utiliza [getAuthHeaders] para la autenticación y procesa la respuesta
  /// a través de [_processResponse].
  ///
  /// Lanza una [Exception] si ocurre un error durante la petición.
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      logger.info('POST a $endpoint');
      final headers = await getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _processResponse(response);
    } catch (e) {
      logger.severe('Error en POST request: $e');
      rethrow;
    }
  }

  /// Realiza una petición de tipo PUT al [endpoint] para actualizar recursos.
  ///
  /// Requiere un [body] con los datos a actualizar que será codificado a JSON.
  ///
  /// Utiliza [getAuthHeaders] para la autenticación y procesa la respuesta
  /// a través de [_processResponse].
  ///
  /// Lanza una [Exception] si ocurre un error durante la petición.
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _processResponse(response);
    } catch (e) {
      logger.severe('Error en PUT request: $e');
      rethrow;
    }
  }

  /// Realiza una petición de tipo DELETE al [endpoint] para eliminar recursos.
  ///
  /// Utiliza [getAuthHeaders] para la autenticación y procesa la respuesta
  /// a través de [_processResponse].
  ///
  /// Lanza una [Exception] si ocurre un error durante la petición.
  static Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await getAuthHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      logger.severe('Error en DELETE request: $e');
      rethrow;
    }
  }

  // --- PROCESAMIENTO DE RESPUESTA CENTRALIZADO ---
  static dynamic _processResponse(http.Response response) {
    /// Analiza la respuesta HTTP del servidor y decodifica el cuerpo según el código de estado.
    ///
    /// Si el código está en el rango 200-299:
    /// - Retorna el JSON decodificado si hay contenido.
    /// - Retorna el cuerpo como texto plano si no es un JSON válido.
    /// - Retorna `null` si el cuerpo está vacío.
    ///
    /// Si el código indica un error (>= 300):
    /// - Extrae el mensaje de error usando [_parseError].
    /// - Maneja casos específicos como el error 401 (No autorizado) para loguear
    ///   problemas críticos de autenticación.
    /// - Lanza una [Exception] con el mensaje obtenido.
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } catch (e) {
        // Si no es JSON, devolvemos el body tal cual o null
        return response.body;
      }
    } else {
      // Manejo de errores
      final errorMsg = _parseError(response);

      // Si recibimos 401 aquí, es porque el token es inválido REALMENTE
      // (Supabase no pudo refrescarlo o el usuario fue baneado).
      if (response.statusCode == 401) {
        logger.warning('Token inválido o expirado definitivamente.');
        // Opcional: Podrías forzar logout aquí: Supabase.instance.client.auth.signOut();
      }

      throw Exception(errorMsg);
    }
  }

  static String _parseError(http.Response response) {
    /// Extrae un mensaje de error legible desde el cuerpo de una respuesta fallida.
    ///
    /// Intenta buscar las claves 'detail' o 'message' dentro del JSON de error enviado
    /// por el backend. Si el cuerpo no es un JSON válido, retorna un mensaje genérico
    /// con el código de estado HTTP.
    try {
      final body = json.decode(response.body);
      return body['detail'] ??
          body['message'] ??
          'Error ${response.statusCode}';
    } catch (e) {
      return 'Error del servidor: ${response.statusCode}';
    }
  }
}
