import 'package:flutter/cupertino.dart';
import 'package:sistema_gym/objetos/deudor.dart';

class DeudoresProvider extends ChangeNotifier{
  List<Deudor> _deudores = [];

  List<Deudor> get deudores => _deudores;

  void agregarDeudor(Deudor deudor) {
    _deudores.add(deudor);
    notifyListeners();
  }

  void eliminarDeudor(Deudor deudor) {
    _deudores.remove(deudor);
    notifyListeners();
  }

  void eliminarDeuda(Deudor deudor, String mes, double monto){
    deudor.eliminarMes(mes, monto);
    notifyListeners();
  }
}