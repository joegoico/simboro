import 'package:flutter/material.dart';
import 'package:sistema_gym/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <--- IMPORTANTE
import 'package:logging/logging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _logger = Logger('SplashScreen');

  // Ya no necesitamos instanciar MiembrosService aquí,
  // porque AuthService.checkUserStatusAndRedirect se encarga de consultar al back.

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 1. Damos un pequeño respiro para asegurar que el SDK de Supabase
    // haya terminado de leer la sesión del almacenamiento local del celular.
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    try {
      // 2. Verificamos si hay sesión usando el SDK directamente
      // (Reemplaza a tus antiguos métodos storage.read y hasValidSession)
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        _logger.info(
          'Sesión válida encontrada. Verificando estado en backend...',
        );

        // 3. Llamamos al método nuevo que creamos en AuthService
        // Este método consulta al endpoint /auth/status y hace el context.go() correspondiente.
        await AuthService.checkUserAndRedirect(context);
      } else {
        _logger.info('No hay sesión activa. Redirigiendo a login.');
        if (!mounted) return;
        context.go('/login');
      }
    } catch (e) {
      _logger.severe('Error crítico en Splash: $e');
      if (!mounted) return;
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
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
