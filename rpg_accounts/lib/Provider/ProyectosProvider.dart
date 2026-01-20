import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rpg_accounts/Models/GraphModels/PieChartModel.dart';
import 'package:rpg_accounts/Models/MovimientosContablesProyecto.dart';
import 'package:rpg_accounts/Models/Proyectos/NewProject.dart';
import 'package:rpg_accounts/Models/Proyectos/ProjectSummary.dart';
import 'package:rpg_accounts/Models/Proyectos/ResumenGeneral.dart';
import 'package:rpg_accounts/Models/ProyectosModel.dart';
import 'package:rpg_accounts/Models/ProyectosReporteria.dart';
import 'dart:convert';

import 'package:rpg_accounts/Models/Usuarios/USistema.dart';

class ProyectoProvider with ChangeNotifier {
  // 🔹 Proyectos generales
  List<Proyecto> _proyectos = [];
  String? _errorMessage;

  List<Proyecto> get proyectos => _proyectos;
  String? get errorMessage => _errorMessage;

  // 🔹 Datos para gráfico de barras
  List<ProjectData> _projectData = [];
  List<ProjectData> get projectData => _projectData;

  // 🔹 Datos para gráfico de pastel
  PieChartData? _pieChartData;
  PieChartData? get pieChartData => _pieChartData;

  // total de banco 
   ResumenGeneral? _resumen;
   ResumenGeneral? get resumen => _resumen;
  // 🔹 Obtener todos los proyectos del servidor
  Future<void> fetchProyectos() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3002/proyectos'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _proyectos = data.map((item) => Proyecto.fromJson(item)).toList();
           notifyListeners();
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


Future<List<UsuarioSistema>> fetchClientes() async {
  final url = Uri.parse('http://localhost:3002/usuarios_sistema/clientes');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => UsuarioSistema.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar clientes');
  }
}

Future<int> agregarProyecto(NuevoProyecto nuevoProyecto) async {
  final url = Uri.parse('http://localhost:3002/crear_proyecto');

  try {
    print('🔸 Enviando datos del proyecto: ${json.encode(nuevoProyecto.toJson())}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(nuevoProyecto.toJson()),
    );

    print('🔹 Código de respuesta: ${response.statusCode}');
    print('🔹 Respuesta del servidor: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final int idProyecto = data['id'];

      await fetchProyectos(); // si necesitas actualizar la lista
      print('✅ Proyecto creado con ID: $idProyecto');

      return idProyecto;
    } else {
      _errorMessage = 'Error al crear el proyecto: ${response.statusCode}';
      print('❌ $_errorMessage');
      notifyListeners();
      throw Exception(_errorMessage);
    }
  } catch (e) {
    _errorMessage = 'Error al conectar con el servidor: $e';
    print('❌ $_errorMessage');
    notifyListeners();
    throw Exception(_errorMessage);
  }
}

  UsuarioSistemaRPG? _usuarioLogueado;

  UsuarioSistemaRPG? get usuarioLogueado => _usuarioLogueado;


 Future<UsuarioSistemaRPG> login(String usuario, String contrasena) async {
    final url = Uri.parse('http://localhost:3002/usuarios_sistema/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'Usuario': usuario, 'Contrasena': contrasena}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final usuario = UsuarioSistemaRPG.fromJson(data['usuario']);

      // Guardamos usuario logueado en la variable del provider
      _usuarioLogueado = usuario;
      notifyListeners();

      return usuario;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Error al iniciar sesión');
    }
  }


Future<void> modificarEstadoProyecto(int idProyecto, String nuevoEstado) async {
  final url = Uri.parse('http://localhost:3002/ModificarEstadoProyecto');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'idProyecto': idProyecto,
      'nuevoEstado': nuevoEstado,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('✅ ${data['message']}');
    notifyListeners();
  } else {
    final errorData = json.decode(response.body);
    throw Exception(errorData['error'] ?? 'Error al cambiar el estado del proyecto');
  }
}



  void logout() {
    _usuarioLogueado = null;
    notifyListeners();
  }

// Future<int> agregarProyecto(NuevoProyecto nuevoProyecto) async {
//   final url = Uri.parse('http://localhost:3002/crear_proyecto');

//   try {
//     print('🔸 Enviando datos del proyecto: ${json.encode(nuevoProyecto.toJson())}');

//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(nuevoProyecto.toJson()),
//     );

//     print('🔹 Código de respuesta: ${response.statusCode}');
//     print('🔹 Respuesta del servidor: ${response.body}');

//     if (response.statusCode == 200) {
//       await fetchProyectos();
//       print('✅ Proyecto creado y lista de proyectos actualizada.');
//     } else {
//       _errorMessage = 'Error al crear el proyecto: ${response.statusCode}';
//       print('❌ $_errorMessage');
//       notifyListeners();
//     }
//   } catch (e) {
//     _errorMessage = 'Error al conectar con el servidor: $e';
//     print('❌ $_errorMessage');
//     notifyListeners();
//   }
// }

Future<void> modificarSaldoBanco(double nuevoSaldo) async {
  final url = Uri.parse('http://localhost:3002/ModificarSaldoBanco');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'nuevoSaldo': nuevoSaldo}),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al modificar el saldo del banco');
  }
}





  Future<void> fetchResumenGeneral() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3002/resumen-general-proyectos'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _resumen = ResumenGeneral.fromJson(data);
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
  // 🔹 Obtener datos para gráfico de barras
  Future<void> fetchProjectDataBarChart() async {
    print('✅ fetchProjectDataBarChart() fue llamada');

    try {
      final response = await http.get(Uri.parse('http://localhost:3002/resumen-mensual'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _projectData = data.map((item) => ProjectData.fromJson(item)).toList();
        print('✅ Datos recibidos correctamente: ${_projectData.length} registros');
        notifyListeners();
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en la solicitud HTTP: $e');
    }
  }

 ProjectSummary? _projectSummary;

  ProjectSummary? get projectSummary => _projectSummary;

  Future<void> fetchProjectSummary() async {
    print('✅ fetchProjectSummary() fue llamada');

    try {
      final response = await http.get(Uri.parse('http://localhost:3002/resumen-proyectos'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _projectSummary = ProjectSummary.fromJson(data);
        print('✅ Resumen proyectos cargado: Total ${_projectSummary!.totalProyectos}');
        notifyListeners();
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en la solicitud HTTP: $e');
    }
  }


  // 🔹 Obtener datos para gráfico de pastel (pie chart)
  Future<void> fetchPieChartData() async {
    print('✅ fetchPieChartData() fue llamada');

    try {
      final response = await http.get(Uri.parse('http://localhost:3002/resumen-mensual-actual'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _pieChartData = PieChartData.fromJson(data);
        print('✅ PieChart data: total=${_pieChartData!.total}, cost=${_pieChartData!.cost}, profit=${_pieChartData!.profit}');
        notifyListeners();
      } else {
        print('❌ Error HTTP al obtener pie chart: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en la solicitud pie chart: $e');
    }
  }

  // 🔹 Obtener proyecto por ID
  Proyecto getProjectById(int id) {
    print('🔍 Buscando proyecto con ID: $id');
    return _proyectos.firstWhere((project) => project.id == id);
  }


  List<ProyectoReporteria> _proyectosReporteria = [];
  String? _errorMessageReporteria;
  bool _loadingReporteria = false;

  List<ProyectoReporteria> get proyectosReporteria => _proyectosReporteria;
  String? get errorMessageReporteria => _errorMessageReporteria;
  bool get loadingReporteria => _loadingReporteria;

  // 🔹 Obtener proyectos para reportería
  Future<void> fetchProyectosReporteria() async {
    _loadingReporteria = true;
    _errorMessageReporteria = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://localhost:3002/proyectos/reporteria'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _proyectosReporteria = data.map((item) => ProyectoReporteria.fromJson(item)).toList();
        _errorMessageReporteria = null;
      } else {
        _errorMessageReporteria = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessageReporteria = 'Error al hacer la solicitud HTTP: $e';
    } finally {
      _loadingReporteria = false;
      notifyListeners();
    }
  }

Future<void> fetchProyectosReporteriaFiltrados({
  DateTime? fechaInicio,
  DateTime? fechaFin,
}) async {
  _loadingReporteria = true;
  _errorMessageReporteria = null;
  notifyListeners();

  try {
    // Preparar el cuerpo de la solicitud
    final Map<String, dynamic> requestBody = {};
    
    if (fechaInicio != null) {
      requestBody['fechaInicio'] = DateFormat('yyyy-MM-dd').format(fechaInicio);
    }
    
    if (fechaFin != null) {
      requestBody['fechaFin'] = DateFormat('yyyy-MM-dd').format(fechaFin);
    }

    final response = await http.post(
      Uri.parse('http://localhost:3002/proyectos/reporteria-filtrada'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _proyectosReporteria = data.map((item) => ProyectoReporteria.fromJson(item)).toList();
      _errorMessageReporteria = null;
      
      print('✅ Proyectos filtrados cargados: ${_proyectosReporteria.length}');
    } else { 
      _errorMessageReporteria = 'Error: ${response.statusCode} - ${response.body}';
      print('❌ Error en la respuesta: ${response.body}');
    }
  } catch (e) {
    _errorMessageReporteria = 'Error al hacer la solicitud HTTP: $e';
    print('❌ Error en fetchProyectosReporteriaFiltrados: $e');
  } finally {
    _loadingReporteria = false;
    notifyListeners();
  }
}

  // 🔹 Reiniciar estado de reportería
  void resetReporteria() {
    _proyectosReporteria = [];
    _errorMessageReporteria = null;
    _loadingReporteria = false;
    notifyListeners();
  }


}

class ProjectData {
  final String projectName;
  final double totalPrice;
  final double projectCost;
  final double profit;

  ProjectData({
    required this.projectName,
    required this.totalPrice,
    required this.projectCost,
    required this.profit,
  });

factory ProjectData.fromJson(Map<String, dynamic> json) {
  return ProjectData(
    projectName: json['mes'],
    totalPrice: double.parse(json['totalIngresos']),
    projectCost: double.parse(json['totalCostos']),
    profit: double.parse(json['ganancia']),
  );
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
