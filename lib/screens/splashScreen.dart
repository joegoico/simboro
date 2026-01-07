import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'package:sistema_gym/services/auth_service.dart';

/// Punto de entrada lógico de la aplicación.
///
/// Realiza la verificación de persistencia de sesión y gestiona la redirección
/// hacia el flujo de Login o el Dashboard principal basándose en el estado
/// del usuario en el servidor.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _logger = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();
    // Inicio del flujo de autenticación al montar el widget.
    _checkAuth();
  }

  /// Gestiona la lógica de verificación y redirección.
  ///
  /// Utiliza una estrategia de tres pasos:
  /// 1. Delay de cortesía para estabilización del SDK.
  /// 2. Verificación de sesión local (Persistence).
  /// 3. Validación de estatus en Backend (Consistencia).
  Future<void> _checkAuth() async {
    // Latencia técnica: Permite que el SDK recupere el token del almacenamiento seguro (Secure Storage).
    await Future.delayed(const Duration(milliseconds: 200));

    // Verificación de Montaje: Previene fugas de memoria y errores de contexto asíncronos.
    if (!mounted) return;

    try {
      // Paso 1: Verificación de Sesión a nivel SDK.
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        _logger.info('Sesión válida detectada. Consultando backend...');

        // Paso 2: Delegación al AuthService para validación lógica profunda.
        // Este método maneja el context.go() interno basado en la respuesta de la API.
        await AuthService.checkUserAndRedirect(context);
      } else {
        _logger.info('Sesión inexistente. Redirigiendo a Login.');
        if (!mounted) return;
        context.go('/login');
      }
    } catch (e) {
      _logger.severe('Fallo crítico en el proceso de Splash: $e');
      if (!mounted) return;
      // Ante cualquier fallo de red o servidor, priorizamos la seguridad volviendo a Login.
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Identidad Visual
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            // Feedback Visual de Proceso Asíncrono
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
