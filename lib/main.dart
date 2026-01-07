import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rutas.dart';
import 'package:sistema_gym/providers/alumnos_provider.dart';
import 'package:sistema_gym/providers/gastos_provider.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:sistema_gym/providers/finanzas_provider.dart';
import 'package:sistema_gym/providers/theme_provider.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final _logger = Logger('Main');

/// Punto de entrada principal de la aplicación.
///
/// Realiza el arranque asíncrono de servicios esenciales:
/// 1. Enlace de Widgets (Binding).
/// 2. Localización de fechas (i18n).
/// 3. Carga de variables de entorno (.env).
/// 4. Inicialización del Singleton de Supabase.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localización: Garantiza que el formateo de moneda y fechas sea 'es_ES'.
  await initializeDateFormatting('es_ES', null);

  // Seguridad: Carga de secretos y URLs de API desde el entorno.
  await dotenv.load(fileName: ".env");

  // --- Inicialización de Supabase ---
  // Establece la conexión persistente con el Backend-as-a-Service.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['ANON_KEY'] ?? '',
  );

  // Validación de pre-vuelo: Falla rápido si falta configuración crítica.
  if (dotenv.env['SUPABASE_URL'] == null || dotenv.env['ANON_KEY'] == null) {
    throw Exception('FATAL: Variables de entorno no encontradas.');
  }

  // Configuración de Observabilidad (Logging):
  // Centraliza la salida de errores y eventos de red en la consola.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(
    /// Inyección de Dependencias Global:
    /// Envuelve la aplicación en un MultiProvider para que los estados
    /// financieros y de gestión estén disponibles en cualquier rama del árbol.
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AlumnosModel>(create: (_) => AlumnosModel()),
        ChangeNotifierProvider<GastosProvider>(create: (_) => GastosProvider()),
        ChangeNotifierProvider<DisciplinasProvider>(
          create: (_) => DisciplinasProvider(),
        ),
        ChangeNotifierProvider<FinanzasProvider>(
          create: (_) => FinanzasProvider(),
        ),
        ChangeNotifierProvider<AppThemeNotifier>(
          create: (_) => AppThemeNotifier(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Widget raíz que define la configuración global de la aplicación.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Escucha el estado del tema para redibujar la app instantáneamente.
    final themeNotifier = Provider.of<AppThemeNotifier>(context);

    // --- Definición de Material 3 Design System ---

    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );

    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Simboro App',

      // Tematización Dinámica
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: themeNotifier.currentThemeMode,

      // Configuración de Enrutamiento Declarativo
      routerConfig: router,
    );
  }
}
