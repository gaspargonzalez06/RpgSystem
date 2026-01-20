import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rpg_accounts/Models/Proyectos/Comentarios.dart';

class ComentarioProvider with ChangeNotifier {
  List<Comentario> _comentarios = [];
  bool _cargando = false;
  String? _error;

  List<Comentario> get comentarios => _comentarios;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarComentarios(int idProyecto) async {
    _cargando = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3002/comentarios/obtener'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'Id_Proyecto': idProyecto}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _comentarios = data.map((json) => Comentario.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Error al cargar comentarios: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    }

    _cargando = false;
    notifyListeners();
  }

  Future<bool> agregarComentario(Comentario comentario) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3002/comentarios/crear'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(comentario.toJson()),
      );

      if (response.statusCode == 201) {
        await cargarComentarios(comentario.idProyecto);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al agregar comentario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarComentario(Comentario comentario) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3002/comentarios/actualizar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Id_Comentario': comentario.idComentario,
          ...comentario.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        await cargarComentarios(comentario.idProyecto);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al actualizar comentario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarComentario(int idComentario, int idProyecto) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3002/comentarios/eliminar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'Id_Comentario': idComentario}),
      );

      if (response.statusCode == 200) {
        await cargarComentarios(idProyecto);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error al eliminar comentario: $e';
      notifyListeners();
      return false;
    }
  }
}