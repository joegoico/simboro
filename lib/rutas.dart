// go_router/router.dart
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
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoRouter router = GoRouter(
  initialLocation: '/splash',
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      //host en el androidManifest.xml
      path: '/oauth-callback',
      builder: (BuildContext context, GoRouterState state) {
        // Aquí puedes obtener los parámetros de la URL, como el 'code' o el 'access_token'
        // que Supabase te devuelve.
        final String? code = state.uri.queryParameters['code'];
        final String? accessToken = state.uri.queryParameters['access_token'];
        final String? error =
            state
                .uri
                .queryParameters['error']; // Por si hay un error en el callback

        if (error != null) {
          // Manejar el error de autenticación, quizás mostrar un mensaje
          return Scaffold(
            appBar: AppBar(title: const Text('Error de Autenticación')),
            body: Center(child: Text('Error: $error')),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Supabase.instance.client.auth.currentSession != null) {
            context.go(
              '/alumnos',
            ); // O la pantalla a la que quieras ir después del login
          } else {
            _logger.info('Callback code: $code');
            _logger.info('Callback access_token: $accessToken');
            // En un caso real, aquí iría la lógica de signInWithOAuth o la espera
            // del listener de Supabase.
            context.go(
              '/login',
            ); // O una pantalla de error/reintento si la sesión no se establece
          }
        });

        // Mientras esperamos la redirección (o si hay un breve retraso), podemos mostrar un loader
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ShellScaffoldWrapper(state: state, child: child);
      },
      routes: [
        GoRoute(path: '/', redirect: (context, state) => '/alumnos'),
        GoRoute(path: '/home', redirect: (context, state) => '/alumnos'),
        GoRoute(
          path: '/alumnos',
          builder: (context, state) => const Alumnos(title: 'Alumnos'),
        ),
        GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
        GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
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
        GoRoute(
          path: '/crearInstitucion',
          builder: (context, state) {
            return CreateInstitutionScreen(
              user: state.extra as Map<String, dynamic>?,
            );
          },
        ),
        GoRoute(
          path: '/crearDisciplina',
          builder: (context, state) => const CreateDisciplineScreen(),
        ),
        GoRoute(
          path: '/pagos',
          builder: (context, state) {
            // Aquí extraemos la lista de pagos que se pasó en extra.
            final Alumno alumno = state.extra as Alumno;
            return FechasDePago(alumno: alumno);
          },
        ),
        GoRoute(
          path: '/precios',
          builder: (context, state) {
            final Disciplina disciplina = state.extra as Disciplina;
            return PreciosPage(disciplina: disciplina);
          },
        ),
      ],
    ),
  ],
);
