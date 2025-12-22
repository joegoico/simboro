import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/services/auth_service.dart'; // Agregar import

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro que deseas cerrar sesión?'),
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
                Navigator.pop(dialogContext); // Cerrar diálogo
                Navigator.of(context).pop(); // Cerrar drawer

                // Mostrar indicador de carga
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
                  // Hacer logout
                  await AuthService.logout(context);

                  // Navegar al login
                  if (context.mounted) {
                    Navigator.pop(context); // Cerrar loading
                    context.go('/login');
                  }
                } catch (e) {
                  // En caso de error, cerrar el loading
                  if (context.mounted) {
                    Navigator.pop(context);

                    // Mostrar error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al cerrar sesión'),
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
    final themeNotifier = Provider.of<AppThemeNotifier>(context);
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      elevation: 16,
      child: Column(
        // Cambiar de ListView a Column
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
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

          // Expanded con ListView para las opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.query_stats_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    'Finanzas',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(); // Cierra el Drawer antes de navegar
                    context.go('/finanzas', extra: 'Finanzas');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.sports_gymnastics,
                    color: theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    'Disciplinas',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(); // Cierra el Drawer antes de navegar
                    context.go('/disciplinas', extra: 'Disciplinas');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.payments_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    'Gastos',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(); // Cierra el Drawer antes de navegar
                    context.go('/gastos', extra: 'Gastos');
                  },
                ),
                Divider(height: 5.0, color: theme.colorScheme.outlineVariant),
                ListTile(
                  leading: Icon(
                    Icons.payment_outlined,
                    color: theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    'Pagar suscripcion',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pop(); // Cierra el Drawer antes de navegar
                    context.go('/metodoDePago', extra: 'Suscripcion');
                  },
                ),
                Divider(height: 5.0, color: theme.colorScheme.outlineVariant),
                SwitchListTile(
                  title: Text(
                    'Tema oscuro',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  value: themeNotifier.isDarkTheme,
                  onChanged: (value) {
                    themeNotifier.toggleTheme(value);
                  },
                ),
              ],
            ),
          ),

          // Divider antes del logout
          Divider(height: 5.0, color: theme.colorScheme.outlineVariant),

          // Botón de logout al fondo
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showLogoutDialog(context),
          ),

          // Padding inferior
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
