import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearchBar;
  final String title;
  final Widget? customLeading;

  const CustomAppBar({
    super.key,
    required this.showSearchBar,
    required this.title,
    required this.customLeading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      shadowColor: theme.colorScheme.shadow,
      elevation: 2,
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onPrimary),
      ),
      leading: customLeading,

      // Si en el futuro usas showSearchBar para agregar un widget al bottom:
      // bottom: showSearchBar
      //     ? PreferredSize(
      //         preferredSize: const Size.fromHeight(kToolbarHeight),
      //         child: <TU_WIDGET_DE_SEARCH>,
      //       )
      //     : null,
    );
  }

  /// Define el tamaño de la appBar, si o si tiene que estar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}