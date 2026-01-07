import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/screens/login.dart';
import 'screens/alumnos.dart';
import 'screens/finanzas.dart';
import 'screens/gastos.dart';
import 'screens/deudores.dart';
import 'package:sistema_gym/screens/precios.dart';
import 'package:sistema_gym/screens/fechas_de_pago.dart';
import 'package:sistema_gym/screens/disciplinas.dart';
import 'package:sistema_gym/custom_widgets/custom_shell_route.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_gym/screens/splashScreen.dart';
import 'package:sistema_gym/screens/new_institución.dart';
import 'package:sistema_gym/screens/crear_disciplinas.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Router');

/// Clave global para acceder al estado del navegador desde cualquier lugar del código.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Configuración centralizada de rutas.
///
/// Implementa Deep Linking para OAuth y una estructura de Shell para
/// mantener componentes de UI persistentes (AppBars/Drawers).
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  navigatorKey: navigatorKey,
  routes: [
    // --- Ruta de Callback para Autenticación Externa ---
    GoRoute(
      path: '/oauth-callback',
      builder: (BuildContext context, GoRouterState state) {
        // Captura de parámetros de URL tras redirección de Supabase
        final String? code = state.uri.queryParameters['code'];
        final String? accessToken = state.uri.queryParameters['access_token'];
        final String? error = state.uri.queryParameters['error'];

        if (error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error de Autenticación')),
            body: Center(child: Text('Error: $error')),
          );
        }

        // Lógica de redirección post-verificación de sesión
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Supabase.instance.client.auth.currentSession != null) {
            context.go('/alumnos');
          } else {
            _logger.info('Callback incompleto - Code: $code');
            context.go('/login');
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),

    // --- Estructura de Navegación Principal (Shell) ---
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        // Enuelve todas las rutas hijas en un Scaffold base persistente
        return ShellScaffoldWrapper(state: state, child: child);
      },
      routes: [
        // Redirecciones lógicas
        GoRoute(path: '/', redirect: (context, state) => '/alumnos'),
        GoRoute(path: '/home', redirect: (context, state) => '/alumnos'),

        // Pantallas Críticas
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Módulos de Gestión
        GoRoute(
          path: '/alumnos',
          builder: (context, state) => const Alumnos(title: 'Alumnos'),
        ),
        GoRoute(
          path: '/finanzas',
          builder: (context, state) => const Finanzas(),
        ),
        GoRoute(path: '/gastos', builder: (context, state) => const Gastos()),
        GoRoute(
          path: '/deudores',
          builder: (context, state) => const Deudores(),
        ),
        GoRoute(
          path: '/disciplinas',
          builder:
              (context, state) => const DiscplinasPage(title: 'Disciplinas'),
        ),

        // Flujos de Onboarding y Configuración
        GoRoute(
          path: '/crearInstitucion',
          builder:
              (context, state) => CreateInstitutionScreen(
                user: state.extra as Map<String, dynamic>?,
              ),
        ),
        GoRoute(
          path: '/crearDisciplina',
          builder: (context, state) => const CreateDisciplineScreen(),
        ),

        // Vistas de Detalle (Pasaje de objetos complejos vía 'extra')
        GoRoute(
          path: '/pagos',
          builder:
              (context, state) => FechasDePago(alumno: state.extra as Alumno),
        ),
        GoRoute(
          path: '/precios',
          builder:
              (context, state) =>
                  PreciosPage(disciplina: state.extra as Disciplina),
        ),
      ],
    ),
  ],
);
