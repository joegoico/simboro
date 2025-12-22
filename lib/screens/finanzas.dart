import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/providers/finanzas_provider.dart';
import 'package:sistema_gym/providers/gastos_provider.dart';


class Finanzas extends StatefulWidget {
  const Finanzas({super.key});

  @override
  State<Finanzas> createState() => _FinanzasState();
}
class _FinanzasState extends State<Finanzas> {
  @override
  Widget build(BuildContext context) {
  final finanzasProvider = Provider.of<FinanzasProvider>(context).pagosPorMes; 
  final gastosProvider = Provider.of<GastosProvider>(context).gastosPorMes;
  final theme = Theme.of(context);

    // Mapa para convertir nombres de meses a números.
    // Esto es útil para ordenar los meses correctamente.

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

    return  ListView.builder(
      shrinkWrap: true,
      itemCount: mesesFijos.length,
      itemBuilder: (context, index) {
        final mes = mesesFijos[index];
        final double montoDelMes = finanzasProvider[mes] ?? 0.0;
        final double gastosDelMes = gastosProvider[mes]
          ?.fold(0.0, (sum, gasto) => sum! + (gasto.getMonto() ?? 0.0)) ?? 0.0;
        
        return Card(
          color: theme.colorScheme.primaryContainer,
          shadowColor: theme.colorScheme.shadow,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(),
            title: Text(
              mes,
              style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: theme.colorScheme.onSurface),
            ),
            subtitle: Text(
              "Balance del mes de $mes : \$${(montoDelMes - gastosDelMes).toStringAsFixed(2)}",
              style:  TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
            ),
            children: [
              ListTile(
              title: Text.rich(
                TextSpan(
                  style:  TextStyle(color: theme.colorScheme.onSurface), // Estilo por defecto
                  children: [
                  const TextSpan(text: "Total Ingresos: "),
                  TextSpan(
                    text: "\$ ${montoDelMes.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.green), // Solo el monto en verde
                  ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text.rich(
                TextSpan(
                  style:  TextStyle(color: theme.colorScheme.onSurface), // Estilo por defecto
                  children: [
                    const TextSpan(text: "Total Gastos: "),
                    TextSpan(
                      text: "\$ ${gastosDelMes.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.red), // Solo el monto en rojo
                    ),
                  ],
                ),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
              ),
                onPressed: () => context.go('/gastos'),
                child: Text(
                  "Ver gastos",
                  style: TextStyle(color: theme.colorScheme.onTertiary),
                ),
              ),
            ),
          ],
        ),);
      },
    );
  }
}