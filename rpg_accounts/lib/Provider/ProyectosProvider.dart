import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rpg_accounts/Models/ProyectosModel.dart';
import 'dart:convert';

class ProyectoProvider with ChangeNotifier {
  List<Proyecto> _proyectos = [];
  String? _errorMessage;

  List<Proyecto> get proyectos => _proyectos;
  String? get errorMessage => _errorMessage;

  // Obtener todos los proyectos del servidor
  Future<void> fetchProyectos() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3002/proyectos'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _proyectos = data.map((item) => Proyecto.fromJson(item)).toList();

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
  Proyecto getProjectById(int id) {
    return _proyectos.firstWhere((project) => project.id == id);
  }

}


// import 'package:flutter/material.dart';
// import 'package:mysql1/mysql1.dart';

// class ProyectoProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _proyectos = [];

//   List<Map<String, dynamic>> get proyectos => _proyectos;

//   Future<void> fetchProyectos() async {
//     final settings = ConnectionSettings(
//       host: 'tu-host', // ej: 127.0.0.1 o IP del servidor
//       port: 3306,
//       user: 'tu_usuario',
//       password: 'tu_password',
//       db: 'rpgdatabase',
//     );

//     final query = '''
//       SELECT p.Id_Proyecto, p.Nombre_Proyecto, p.Ubicacion, 
//              p.Presupuesto, p.Adelantos, p.Fecha_Inicio, p.Fecha_Fin,
//              u.Nombre_Usuario AS Cliente_Nombre
//       FROM proyectos p
//       JOIN usuarios_sistema u ON p.Id_Cliente = u.Id_Usuario_Sistema;
//     ''';

//     try {
//       final conn = await MySqlConnection.connect(settings);
//       final results = await conn.query(query);

//       _proyectos = results.map((row) {
//         final map = <String, dynamic>{};
//         for (final col in row.fields.keys) {
//           map[col] = row[col];
//         }
//         return map;
//       }).toList();

//       await conn.close();
//       notifyListeners();
//     } catch (e) {
//       print('Error al conectar o consultar la base de datos: $e');
//     }
//   }
// }



// SELECT 
//   p.Id_Proyecto,
//   p.Nombre_Proyecto,
//   p.Ubicacion,
//   p.Presupuesto,
//   p.Adelantos,
//   p.Fecha_Inicio,
//   p.Fecha_Fin,
//   p.Estado,

//   -- Cliente
//   c.Id_Usuario_Sistema AS Cliente_Id,
//   c.Nombre_Usuario AS Cliente_Nombre,

//   -- Movimiento contable
//   m.Id_Movimiento,
//   m.Monto,
//   m.Comentario,
//   m.Fecha_Movimiento,

//   -- Tipo de movimiento
//   tm.Descripcion_Movimiento,

//   -- Servicio
//   s.Descripcion_Servicio,

//   -- Admin
//   a.Nombre_Usuario AS Admin_Nombre,

//   -- Trabajador
//   t.Nombre_Usuario AS Trabajador_Nombre,

//   -- Proveedor
//   pr.Nombre_Usuario AS Proveedor_Nombre

// FROM proyectos p

// -- Cliente
// JOIN usuarios_sistema c ON p.Id_Cliente = c.Id_Usuario_Sistema

// -- Movimientos contables relacionados al proyecto
// LEFT JOIN movimientos_contables m ON p.Id_Proyecto = m.Id_Proyecto

// -- Tipo de movimiento
// LEFT JOIN tipo_movimiento tm ON m.Id_Tipo_Movimiento = tm.Id_Tipo_Movimiento

// -- Servicio
// LEFT JOIN servicios_construccion s ON m.Id_Servicio = s.Id_Servicio

// -- Admin
// LEFT JOIN usuarios_sistema a ON m.Id_Admin = a.Id_Usuario_Sistema

// -- Trabajador (si aplica)
// LEFT JOIN usuarios_sistema t ON m.Id_Trabajador = t.Id_Usuario_Sistema

// -- Proveedor (si aplica)
// LEFT JOIN usuarios_sistema pr ON m.Id_Proveedor = pr.Id_Usuario_Sistema

// ORDER BY p.Id_Proyecto, m.Fecha_Movimiento;
