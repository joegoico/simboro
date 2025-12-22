import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <--- IMPORTANTE
import 'rutas.dart'; 
import 'package:sistema_gym/providers/alumnos_provider.dart';
import 'package:sistema_gym/providers/gastos_provider.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:sistema_gym/providers/finanzas_provider.dart';
import 'package:sistema_gym/providers/theme_provider.dart'; 
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:sistema_gym/services/auth_service.dart'; // Ya no es estricto iniciarlo aquí

final _logger = Logger('Main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await dotenv.load(fileName: ".env");
  // --- NUEVO: INICIALIZAR SUPABASE ---
  // Reemplaza con tus datos reales de Supabase (Settings > API)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', 
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Validación de seguridad para desarrollo
  if (dotenv.env['SUPABASE_URL'] == null || dotenv.env['SUPABASE_ANON_KEY'] == null) {
    throw Exception('FATAL: No se encontraron las variables de entorno en el archivo .env');
  }
  // -----------------------------------

  // BORRADO: await AuthService.initDeepLinks(navigatorKey); 
  // El SDK de Supabase maneja los deep links automáticamente.

  // Configurar logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
      print('Stack trace: ${record.stackTrace}');
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AlumnosModel>(
          create: (_) => AlumnosModel(),
        ),
        ChangeNotifierProvider<GastosProvider>(
          create: (_) => GastosProvider(),
        ),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  // BORRADO: dispose de AuthService ya no es necesario si usamos el SDK

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<AppThemeNotifier>(context);

    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
      ),
    );

    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.primary,
      ),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Simboro App',
      theme: lightTheme,    
      darkTheme: darkTheme,  
      themeMode: themeNotifier.currentThemeMode, 
      routerConfig: router, // Asegúrate que tu router tenga la ruta '/splash'
    );
  }
}