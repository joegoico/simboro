// lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/config/api_config.dart'; // Asegúrate de tener esto

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl; // Tu IP:8000
  static final _logger = Logger('AuthService');

  // Acceso rápido al cliente de Supabase
  static final _supabase = Supabase.instance.client;

  /// 1. Inicia el Login con Google usando el SDK nativo
  /// Esto maneja automáticamente PKCE y Deep Links
  static Future<void> signInWithGoogle() async {
    try {
      // Nota: Asegúrate de que 'com.simboro.app://login-callback' esté configurado
      // en tu AndroidManifest.xml y en el panel de Supabase > Auth > URL Configuration
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.simboro.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // No necesitamos hacer nada más aquí.
      // El SDK escuchará cuando la app se vuelva a abrir y detectará la sesión.
    } catch (e) {
      _logger.severe('Error iniciando sesión con Google: $e');
      throw e;
    }
  }

  /// 2. Lógica para decidir a dónde mandar al usuario
  /// Se llama automáticamente cuando Supabase detecta un inicio de sesión
  static Future<void> checkUserAndRedirect(BuildContext context) async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      _logger.warning('No hay sesión activa para verificar estado');
      return;
    }

    try {
      final token = session.accessToken;

      // Llamamos a tu endpoint del Backend que verifica si tiene institución
      final response = await http.get(
        Uri.parse(
          '$baseUrl/miembros/status',
        ), // Asegúrate que este endpoint exista en tu Back
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bool hasInstitution = data['has_institution'] ?? false;

        _logger.info('Status usuario: Tiene institución? $hasInstitution');

        if (hasInstitution) {
          // Usuario antiguo -> Va al Home
          GoRouter.of(context).go('/home');
        } else {
          // Usuario nuevo -> Va a crear institución
          GoRouter.of(context).go('/create_institution');
        }
      } else {
        _logger.severe(
          'Error del backend al verificar status: ${response.statusCode}',
        );
        // Manejo de error seguro, quizás mandarlo al login de nuevo o mostrar alerta
      }
    } catch (e) {
      _logger.severe('Error de conexión verificando usuario: $e');
    }
  }

  /// 3. Cerrar Sesión
  static Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      GoRouter.of(context).go('/login'); // O la ruta de tu login
    } catch (e) {
      _logger.severe('Error al cerrar sesión: $e');
    }
  }

  /// Getter para obtener el token actual (útil para otros servicios)
  static String? get accessToken => _supabase.auth.currentSession?.accessToken;
}
