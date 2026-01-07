import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/providers/finanzas_provider.dart';
import 'package:sistema_gym/providers/gastos_provider.dart';

/// Pantalla de resumen financiero anual.
///
/// Presenta una vista consolidada de los ingresos y egresos agrupados por mes.
/// Realiza cálculos de agregación en tiempo real para mostrar el balance neto.
class Finanzas extends StatefulWidget {
  const Finanzas({super.key});

  @override
  State<Finanzas> createState() => _FinanzasState();
}

class _FinanzasState extends State<Finanzas> {
  @override
  Widget build(BuildContext context) {
    // Consumo de múltiples providers para correlacionar Ingresos vs Gastos
    final finanzasProvider = Provider.of<FinanzasProvider>(context).pagosPorMes;
    final gastosProvider = Provider.of<GastosProvider>(context).gastosPorMes;
    final theme = Theme.of(context);

    // Definición estática del eje temporal para garantizar el orden cronológico
    // y mostrar meses vacíos (Manejo de Sparse Data).
    final List<String> mesesFijos = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return ListView.builder(
      shrinkWrap:
          true, // Permite que el ListView se adapte si está dentro de otro scroll
      itemCount: mesesFijos.length,
      itemBuilder: (context, index) {
        final mes = mesesFijos[index];

        // Extracción de Ingresos (Pre-calculados en el Provider)
        final double montoDelMes = finanzasProvider[mes] ?? 0.0;

        // Cálculo de Gastos en tiempo de ejecución (On-the-fly aggregation)
        // Se utiliza .fold (programación funcional) para sumar los montos de la lista de gastos.
        final double gastosDelMes =
            gastosProvider[mes]?.fold(
              0.0,
              (sum, gasto) => sum! + (gasto.getMonto()),
            ) ??
            0.0;

        final double balanceNeto = montoDelMes - gastosDelMes;

        return Card(
          color: theme.colorScheme.primaryContainer,
          shadowColor: theme.colorScheme.shadow,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(),
            title: Text(
              mes,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            // Balance Neto con feedback inmediato
            subtitle: Text(
              "Balance: \$${balanceNeto.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            children: [
              // Detalle de Ingresos (Verde)
              ListTile(
                title: Text.rich(
                  TextSpan(
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    children: [
                      const TextSpan(text: "Total Ingresos: "),
                      TextSpan(
                        text: "\$ ${montoDelMes.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Detalle de Gastos (Rojo)
              ListTile(
                title: Text.rich(
                  TextSpan(
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    children: [
                      const TextSpan(text: "Total Gastos: "),
                      TextSpan(
                        text: "\$ ${gastosDelMes.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Navegación contextual al detalle de gastos
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.tertiary,
                    foregroundColor: theme.colorScheme.onTertiary,
                  ),
                  onPressed: () => context.go('/gastos'),
                  child: const Text("Ver gastos"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
