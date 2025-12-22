import 'package:flutter/material.dart';

class FloatingCircleButton extends StatelessWidget {
  /// Callback que se ejecuta cuando se presiona el botón.
  final VoidCallback onPressed;

  /// Ícono a mostrar en el botón.
  final IconData icon;

  /// Tamaño del ícono.
  final double iconSize;

  /// Elevación del botón.
  final double elevation;

  /// Color de fondo del botón.
  final Color? fillColor;

  /// Color del ícono.
  final Color? iconColor;

  /// Padding interno del botón.
  final EdgeInsets padding;

  const FloatingCircleButton({
    Key? key,
    required this.onPressed,
    this.icon = Icons.add,
    this.iconSize = 25.0,
    this.elevation = 2.0,
    this.fillColor,
    this.iconColor,
    this.padding = const EdgeInsets.all(15.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos los colores del tema si no se proporcionan
    final theme = Theme.of(context);
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: elevation,
      fillColor: fillColor ?? theme.colorScheme.primaryContainer,
      padding: padding,
      shape: const CircleBorder(),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? theme.colorScheme.onPrimaryContainer,
      ),
    );
  }
}