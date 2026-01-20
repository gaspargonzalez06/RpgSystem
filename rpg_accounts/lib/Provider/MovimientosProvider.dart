import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rpg_accounts/Models/MovimientosContablesProyecto.dart';
import 'dart:convert';

import 'package:rpg_accounts/Models/Proveedores.dart';



class ProveedorMovimientoProvider with ChangeNotifier {
  List<ProveedorModel> _proveedores = [];
  List<MovimientoContable> _movimientos = [];
  String? _errorMessage;

  List<ProveedorModel> get proveedores => _proveedores;
  List<MovimientoContable> get movimientos => _movimientos;
  String? get errorMessage => _errorMessage;

  // http://localhost:30002
//http://localhost:3002

// http://localhost:3002
  // Obtener todos los proveedores del servidor
Future<void> fetchProveedores() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3002/proveedores'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Convierte los datos en una lista de proveedores
      _proveedores = data.map((item) => ProveedorModel.fromJson(item)).toList();
      _errorMessage = null;
      notifyListeners();
    } else {
      _errorMessage = 'Error: ${response.statusCode}';
      notifyListeners();
    }
  } catch (e) {
    _errorMessage = 'Error al hacer la solicitud HTTP: $e';
    notifyListeners();
  }
}
List<MovimientosPorUsuario> get movimientosPorUsuario => _movimientosPorUsuario;

List<MovimientosPorUsuario> _movimientosPorUsuario = [];
Future<void> fetchMovimientos(int idProyecto) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3002/movimientosUsuario'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'idProyecto': idProyecto}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _movimientosPorUsuario = data
          .map((item) => MovimientosPorUsuario.fromJson(item))
          .toList();
      _errorMessage = null;
    } else {
      _errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  } catch (e) {
    _errorMessage = 'Error al hacer la solicitud HTTP: $e';
  }

  notifyListeners();
}

// En tu ProveedorMovimientoProvider
Future<void> actualizarComentarioProyecto(int idProyecto, String nuevoComentario) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:3002/actualizarComentarioProyecto'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'idProyecto': idProyecto,
        'comentario': nuevoComentario,
      }),
    );

    if (response.statusCode == 200) {
      // Actualizar el comentario localmente si es necesario
      await fetchMovimientos(idProyecto); // Recargar datos si es necesario
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error al actualizar comentario: $e');
  }
}

Future<void> agregarMovimientoContable({
  required int idCliente,
  required int idServicio,
  required int idTipoMovimiento,
  required double monto,
  required String comentario,
  required int idProyecto,
  required bool esPagoDirecto,
  required int idAdmin,
  int? idTrabajador,
  int? idProveedor,
}) async {
  final url = Uri.parse('http://localhost:3002/crear_movimiento');

  final Map<String, dynamic> body = {
    'Id_Cliente': idCliente,
    'Id_Servicio': idServicio,
    'Id_Tipo_Movimiento': idTipoMovimiento,
    'Monto': monto,
    'Comentario': comentario,
    'Id_Proyecto': idProyecto,
    'Id_Admin': idAdmin,
    'Pago_Directo':esPagoDirecto,
    'Id_Trabajador': idTrabajador,
    'Id_Proveedor': idProveedor,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Movimiento agregado exitosamente
      print('Movimiento creado correctamente');
    } else {
      // Error en la respuesta del servidor
      print('Error al crear el movimiento: ${response.statusCode}');
    }
  } catch (e) {
    // Error en la solicitud HTTP
    print('Error al hacer la solicitud HTTP: $e');
  }
}

Future<void> editarMovimientoContable({
  required int idMovimiento,
  required double monto,
  required String comentario,
  int? tipoMovimiento,  // Cambiado a opcional
  bool? pagoDirecto,    // Cambiado a opcional
}) async {
  final url = Uri.parse('http://localhost:3002/editar_movimiento');

  // Cuerpo base con campos obligatorios
  final Map<String, dynamic> body = {
    'Id_Movimiento': idMovimiento,
    'Monto': monto,
    'Comentario': comentario,
  };

  // Agregar campos opcionales solo si tienen valor
  if (tipoMovimiento != null) {
    body['Tipo_Movimiento'] = tipoMovimiento;
  }

  if (pagoDirecto != null) {
    body['Pago_Directo'] = pagoDirecto;
  }

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Movimiento editado correctamente');
    } else {
      print('Error al editar el movimiento: ${response.statusCode}');
      throw Exception('Error al editar movimiento');
    }
  } catch (e) {
    print('Error al hacer la solicitud HTTP: $e');
    throw e;
  }
}
Future<void> eliminarMovimientoContable({
  required int idMovimiento,
}) async {
  final url = Uri.parse('http://localhost:3002/eliminar_movimiento');

  final Map<String, dynamic> body = {
    'Id_Movimiento': idMovimiento,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Movimiento eliminado correctamente');
    } else {
      print('Error al eliminar el movimiento: ${response.statusCode}');
      throw Exception('Error al eliminar movimiento');
    }
  } catch (e) {
    print('Error al hacer la solicitud HTTP: $e');
    throw e;
  }
}

}
