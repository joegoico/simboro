import 'dart:convert';
import 'package:sistema_gym/services/api_service.dart';
import 'package:sistema_gym/objetos/miembro.dart';
import 'package:logging/logging.dart';

/// Servicio encargado de gestionar la relación entre los usuarios y las instituciones.
///
/// Administra los perfiles de los [Miembro], permitiendo la vinculación,
/// consulta y actualización de datos de pertenencia al sistema.
class MiembrosService {
  static const String _endpoint = '/miembros';
  final Logger logger = Logger('MiembrosService');

  /// Recupera los datos de membresía asociados a una [institucionId].
  ///
  /// Retorna un objeto [Miembro] si existe la vinculación, o `null` si
  /// la operación falla o no se encuentran registros.
  Future<List<Miembro>> getMiembrosByInstitucion(int institucionId) async {
    try {
      final response = await ApiService.get('$_endpoint/$institucionId');

      if (response != null) {
        return response.map((json) => Miembro.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      logger.severe(
        'Fallo al obtener miembros de la institución $institucionId: $e',
      );
      return [];
    }
  }

  /// Obtiene un miembro específico mediante su identificador único de usuario [id].
  ///
  /// Implementa un manejo específico para el error 404: si el backend no encuentra
  /// al miembro, se registra como una advertencia (warning) y se retorna `null`
  /// de forma segura para que la UI gestione el estado "no registrado".
  Future<Miembro?> getMiembroById(String id) async {
    try {
      final data = await ApiService.get('$_endpoint/$id');

      if (data != null) {
        logger.info('Miembro recuperado exitosamente para el ID: $id');
        return Miembro.fromJson(data);
      }
      return null;
    } on Exception catch (e) {
      // Lógica de ingeniería: Diferenciamos un error de red de un "Not Found"
      if (e.toString().contains('404')) {
        logger.warning(
          'Miembro no encontrado (404). El usuario podría no estar vinculado aún.',
        );
        return null;
      }
      logger.severe('Error crítico al consultar miembro por ID: $e');
      return null;
    }
  }

  /// Crea un nuevo registro de [miembro] en el sistema.
  ///
  /// Este paso suele ser parte del flujo de onboarding una vez que el usuario
  /// se ha autenticado con Google/Supabase.
  Future<Miembro?> createMiembro(Miembro miembro) async {
    try {
      final jsonMiembro = miembro.toJson();
      final response = await ApiService.post(_endpoint, body: jsonMiembro);

      if (response != null) {
        return Miembro.fromJson(response);
      }
      return null;
    } catch (e) {
      logger.severe('Error en la creación del perfil de miembro: $e');
      return null;
    }
  }

  /// Actualiza la información de perfil de un [miembro].
  ///
  /// Utiliza el [userId] (generalmente el UUID de Supabase) para identificar
  /// el recurso en el backend.
  Future<Miembro?> updateMiembro(Miembro miembro) async {
    try {
      final jsonMiembro = miembro.toJson();
      final response = await ApiService.put(
        '$_endpoint/${miembro.userId}',
        body: jsonMiembro,
      );

      if (response != null) {
        return Miembro.fromJson(response);
      }
      return null;
    } catch (e) {
      logger.severe(
        'Error al actualizar datos del miembro ${miembro.userId}: $e',
      );
      return null;
    }
  }

  /// Elimina el registro de un miembro del sistema.
  ///
  /// Retorna `true` si la confirmación de borrado es positiva por parte del servidor.
  Future<bool> deleteMiembro(String id) async {
    try {
      final response = await ApiService.delete('$_endpoint/$id');

      if (response != null) {
        logger.info('Registro de miembro $id eliminado correctamente');
        return true;
      }
      return false;
    } catch (e) {
      logger.severe('Error al intentar eliminar el miembro $id: $e');
      return false;
    }
  }
}
