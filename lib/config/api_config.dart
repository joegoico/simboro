class ApiConfig {
  // En Android emulador usa 10.0.2.2, en iOS usa localhost
  static const String baseUrl = 'http://10.0.2.2:8000';  // URL de tu backend
  
  // Endpoints
  static const String disciplina = '/disciplina';
  static const String precios = '/precios';
  static const String gastos = '/gastos';
  static const String gimnasios = '/gimnasios';
  static const String alumnos = '/alumnos';
  static const String pagos = '/pagos';

}
