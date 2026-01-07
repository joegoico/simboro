import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/services/auth_service.dart'; // Agregar import

/// Menú lateral dinámico que centraliza la navegación y ajustes de la app.
///
/// Integra [GoRouter] para el movimiento entre pantallas, [Provider] para
/// la gestión del tema visual y [AuthService] para el control de sesión.
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  /// Despliega un diálogo de confirmación para el cierre de sesión.
  ///
  /// Este método gestiona un flujo complejo de UX:
  /// 1. Solicita confirmación al usuario.
  /// 2. Muestra un indicador de progreso (Loading) mientras se comunica con el backend.
  /// 3. Maneja errores mediante [SnackBar] y asegura la redirección segura al login.
  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Cierra el diálogo de pregunta
                Navigator.of(context).pop(); // Cierra el Drawer lateral

                // Implementación de Loading Overlay para feedback visual
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                );

                try {
                  await AuthService.logout(context);

                  if (context.mounted) {
                    Navigator.pop(context); // Remueve el overlay de carga
                    context.go('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(
                      context,
                    ); // Remueve el overlay en caso de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Error al cerrar sesión'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el tema para actualizar el switch en tiempo real
    final themeNotifier = Provider.of<AppThemeNotifier>(context);
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      elevation: 16,
      child: Column(
        children: [
          // Cabecera con branding de la institución
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Le Groupe Gym',
                  style: TextStyle(
                    color: theme.colorScheme.onTertiary,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),

          // Área de navegación con scroll independiente
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.query_stats_rounded,
                  title: 'Finanzas',
                  onTap: () => _navigate(context, '/finanzas', 'Finanzas'),
                  theme: theme,
                ),
                _buildMenuItem(
                  icon: Icons.sports_gymnastics,
                  title: 'Disciplinas',
                  onTap:
                      () => _navigate(context, '/disciplinas', 'Disciplinas'),
                  theme: theme,
                ),
                _buildMenuItem(
                  icon: Icons.payments_rounded,
                  title: 'Gastos',
                  onTap: () => _navigate(context, '/gastos', 'Gastos'),
                  theme: theme,
                ),
                Divider(color: theme.colorScheme.outlineVariant),
                _buildMenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Pagar suscripción',
                  onTap:
                      () => _navigate(context, '/metodoDePago', 'Suscripción'),
                  theme: theme,
                ),
                Divider(color: theme.colorScheme.outlineVariant),

                // Switch funcional para cambio dinámico de tema (Dark/Light Mode)
                SwitchListTile(
                  title: Text(
                    'Tema oscuro',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  value: themeNotifier.isDarkTheme,
                  onChanged: (value) => themeNotifier.toggleTheme(value),
                ),
              ],
            ),
          ),

          // Sección de pie de página: Logout (anclado al fondo por el Column/Expanded)
          Divider(color: theme.colorScheme.outlineVariant),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Helper para estandarizar la navegación desde el Drawer
  void _navigate(BuildContext context, String route, String extra) {
    Navigator.of(context).pop(); // Cierre preventivo del Drawer
    context.go(route, extra: extra);
  }

  /// Helper para construir los ítems del menú con estilo consistente
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface)),
      onTap: onTap,
    );
  }
}
