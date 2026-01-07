import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Clase de configuración centralizada para la comunicación con el Backend.
///
/// Administra las variables de entorno y define los puntos de acceso (endpoints)
/// globales del sistema, asegurando la consistencia de las rutas en todos los servicios.
class ApiConfig {
  /// Retorna la URL base del servidor de API.
  ///
  /// Intenta obtener el valor de la clave 'FRONTEND_URL' desde el archivo `.env`.
  /// Si la variable no está definida, utiliza por defecto la IP `10.0.2.2:8000`,
  /// que corresponde al host local accesible desde el emulador de Android.
  static String get baseUrl {
    // Nota: Es una buena práctica que el nombre coincida con el propósito (ej: BACKEND_URL)
    return dotenv.env['FRONTEND_URL'] ?? 'http://10.0.2.2:8000';
  }

  // --- Endpoints del Sistema ---
  // Se definen como constantes estáticas para evitar errores de tipeo en los Services.

  /// Ruta para la gestión de disciplinas deportivas.
  static const String disciplina = '/disciplina';

  /// Ruta para la administración de aranceles y tarifas.
  static const String precios = '/precios';

  /// Ruta para el registro de egresos y gastos institucionales.
  static const String gastos = '/gastos';

  /// Ruta para la gestión de sedes o gimnasios físicos.
  static const String gimnasios = '/gimnasios';

  /// Ruta para la gestión de datos maestros de alumnos.
  static const String alumnos = '/alumnos';

  /// Ruta para el procesamiento de cobros y pagos.
  static const String pagos = '/pagos';
}
