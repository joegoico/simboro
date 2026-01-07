// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:sistema_gym/services/miembros_service.dart';
import 'package:logging/logging.dart';

/// Pantalla de inicio de sesión de la aplicación.
///
/// Implementa autenticación federada mediante Google Sign-In.
/// Actúa como el 'Gatekeeper', impidiendo el acceso a la navegación
/// principal hasta obtener un token de sesión válido.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Estado local para gestionar el feedback visual durante la negociación de red.
  bool _isLoading = false;

  // Servicio para recuperar el perfil del miembro una vez autenticado (preparación).
  final miembroService = MiembrosService();

  /// Inicia el flujo de OAuth con Google.
  ///
  /// Gestiona el ciclo de vida de la petición:
  /// 1. Bloquea la UI (_isLoading = true).
  /// 2. Delega la autenticación al AuthService.
  /// 3. Maneja errores con feedback visual (SnackBar).
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Llamada asíncrona al SDK de Supabase/Google
      await AuthService.signInWithGoogle();

      // Nota: La navegación post-login suele manejarse mediante un
      // StreamBuilder escuchando el estado de autenticación en el widget raíz,
      // por eso no hay un Navigator.push explícito aquí.
    } catch (e) {
      // Restauramos el estado del botón si falla
      setState(() {
        _isLoading = false;
      });

      // Safety Check: Patrón crucial en Flutter.
      // Si el usuario cerró la app mientras cargaba, 'mounted' será false
      // y evitaremos usar un contexto que ya no existe.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de autenticación: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Identidad de Marca
                Icon(
                  Icons.fitness_center,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 48),

                Text(
                  'Simboro App',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),

                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 48),

                // Botón de Acción Principal (Call to Action)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    // Deshabilita el botón si ya está cargando para evitar doble submit
                    onPressed: _isLoading ? null : _handleGoogleSignIn,

                    // Feedback visual condicional (Spinner vs Icono)
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                            : const Icon(Icons.login, color: Colors.black87),

                    label: Text(
                      _isLoading ? 'Conectando...' : 'Continuar con Google',
                      style: const TextStyle(fontSize: 16),
                    ),

                    // Estilo acorde a las guías de diseño de identidad de Google (Fondo blanco)
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Texto legal (Compliance)
                Text(
                  'Al continuar, aceptas nuestros términos y condiciones',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
