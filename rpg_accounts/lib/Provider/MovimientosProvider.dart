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

  // Obtener todos los proveedores del servidor
  Future<void> fetchProveedores() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/proveedores'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

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

  // Obtener movimientos contables por Id de proyecto
  Future<void> fetchMovimientosPorProyecto(int idProyecto) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/movimientosProyecto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idProyecto': idProyecto}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _movimientos = data.map((item) => MovimientoContable.fromJson(item)).toList();
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
}
