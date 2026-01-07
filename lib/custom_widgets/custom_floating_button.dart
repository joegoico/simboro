import 'package:flutter/material.dart';

/// Un botón de acción circular personalizado y altamente configurable.
///
/// Diseñado para ser utilizado como disparador de acciones primarias (como agregar
/// alumnos o registrar pagos) manteniendo la consistencia visual del sistema.
/// Utiliza [RawMaterialButton] para un control preciso sobre la forma y elevación.
class FloatingCircleButton extends StatelessWidget {
  /// Callback que se ejecuta cuando el usuario presiona el botón.
  final VoidCallback onPressed;

  /// El glifo del ícono que se renderizará en el centro del botón.
  /// Por defecto utiliza [Icons.add].
  final IconData icon;

  /// Dimensión física del ícono en pixeles lógicos.
  final double iconSize;

  /// La magnitud de la sombra proyectada por el botón.
  final double elevation;

  /// Color de fondo del botón. Si es nulo, utiliza [colorScheme.primaryContainer].
  final Color? fillColor;

  /// Color del glifo del ícono. Si es nulo, utiliza [colorScheme.onPrimaryContainer].
  final Color? iconColor;

  /// Espacio interno entre el borde circular y el ícono central.
  final EdgeInsets padding;

  const FloatingCircleButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.iconSize = 25.0,
    this.elevation = 2.0,
    this.fillColor,
    this.iconColor,
    this.padding = const EdgeInsets.all(15.0),
  });

  @override
  Widget build(BuildContext context) {
    // Implementación de diseño adaptativo basado en el tema global de la aplicación.
    final theme = Theme.of(context);

    return RawMaterialButton(
      onPressed: onPressed,
      elevation: elevation,
      // Aplicación de lógica de colores con fallbacks al esquema de colores del tema.
      fillColor: fillColor ?? theme.colorScheme.primaryContainer,
      padding: padding,
      // Definición geométrica del botón como un círculo perfecto.
      shape: const CircleBorder(),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
