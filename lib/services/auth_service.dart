// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/config/api_config.dart'; // Asegúrate de tener esto

/// Servicio encargado de la autenticación de usuarios y el control de flujo post-login.
///
/// Integra [Supabase] para el manejo de identidades y coordina con el backend de
/// Simboro para determinar el estado de afiliación del usuario (Onboarding).
class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  static final _logger = Logger('AuthService');

  /// Cliente de Supabase para acceso directo a operaciones de autenticación.
  static final _supabase = Supabase.instance.client;

  /// Inicia el flujo de autenticación delegada con Google (OAuth 2.0).
  ///
  /// Utiliza el flujo PKCE y requiere que el esquema de redirección
  /// (Deep Link) esté correctamente configurado tanto en la consola de Supabase
  /// como en los archivos nativos de Android e iOS.
  static Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.simboro.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // La sesión se gestiona de forma persistente a través del listener del SDK.
    } catch (e) {
      _logger.severe('Fallo crítico en signInWithGoogle: $e');
      throw e;
    }
  }

  /// Determina el estado del usuario y redirige a la vista correspondiente.
  ///
  /// Este método realiza un "Handshake" con el backend de Simboro para verificar
  /// si el usuario autenticado ya posee una institución asociada:
  /// - Si tiene institución: Redirige al `/home`.
  /// - Si es un usuario nuevo: Redirige al flujo de `/crearInstitucion`.
  ///
  /// Requiere que exista una sesión activa de Supabase para obtener el JWT.
  static Future<void> checkUserAndRedirect(BuildContext context) async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      _logger.warning('Intento de redirección sin sesión activa');
      return;
    }

    try {
      final token = session.accessToken;

      // Consulta al endpoint de control de membresía en el Backend Python
      final response = await http.get(
        Uri.parse('$baseUrl/miembros/status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool hasInstitution = data['has_institution'] ?? false;

        _logger.info(
          'Verificación de estatus exitosa. Tiene institución: $hasInstitution',
        );

        if (hasInstitution) {
          GoRouter.of(context).go('/home');
        } else {
          GoRouter.of(context).go('/crearInstitucion');
        }
      } else {
        _logger.severe(
          'Backend retornó error de estatus: ${response.statusCode}',
        );
        // Aquí se podría implementar una redirección a una pantalla de error o login
      }
    } catch (e) {
      _logger.severe('Error de red durante la verificación de estatus: $e');
    }
  }

  /// Finaliza la sesión actual del usuario y limpia los datos de autenticación.
  ///
  /// Una vez cerrado el túnel en Supabase, utiliza [GoRouter] para devolver
  /// al usuario a la pantalla de entrada.
  static Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      _logger.info('Sesión cerrada correctamente');
      GoRouter.of(context).go('/login');
    } catch (e) {
      _logger.severe('Error al ejecutar signOut: $e');
    }
  }

  /// Provee el JSON Web Token (JWT) de la sesión activa para ser utilizado
  /// en otros servicios que requieran autenticación.
  static String? get accessToken => _supabase.auth.currentSession?.accessToken;
}
