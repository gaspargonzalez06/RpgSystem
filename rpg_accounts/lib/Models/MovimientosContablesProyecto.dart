class MovimientosPorUsuario {
  final UsuarioSistema usuario;
  final List<MovimientoContable> movimientos;

  MovimientosPorUsuario({
    required this.usuario,
    required this.movimientos,
  });

  factory MovimientosPorUsuario.fromJson(Map<String, dynamic> json) {
    return MovimientosPorUsuario(
      usuario: UsuarioSistema.fromJson(json['usuario'] ?? {}),
      movimientos: (json['movimientos'] as List?)
              ?.map((item) => MovimientoContable.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class MovimientoContable {
  final int id;
  final int idCliente;
  final int idServicio;
  final int tipoMovimiento;
  final double monto;
  final String comentario;
  final String fecha;
  final int idProyecto;
  final int idAdmin;
  final int? idTrabajador;
  final int? idProveedor;
  final int tipoUsuario;

  MovimientoContable({
    required this.id,
    required this.idCliente,
    required this.idServicio,
    required this.tipoMovimiento,
    required this.monto,
    required this.comentario,
    required this.fecha,
    required this.idProyecto,
    required this.idAdmin,
    this.idTrabajador,
    this.idProveedor,
    required this.tipoUsuario,
  });

  factory MovimientoContable.fromJson(Map<String, dynamic> json) {
    return MovimientoContable(
      id: json['Id_Movimiento'] ?? 0,  // Default to 0 if null
      idCliente: json['Id_Ciente'] ?? 0,  // Default to 0 if null
      idServicio: json['Id_Servicio'] ?? 0,  // Default to 0 if null
      tipoMovimiento: json['Id_Tipo_Movimiento'] ?? 0,  // Default to 0 if null
      monto: (json['Monto'] is String)
          ? double.tryParse(json['Monto']) ?? 0.0
          : (json['Monto'] as num?)?.toDouble() ?? 0.0,
      comentario: json['Comentario'] ?? '',
      fecha: json['Fecha_Movimiento'] ?? '',
      idProyecto: json['Id_Proyecto'] ?? 0,  // Default to 0 if null
      idAdmin: json['Id_Admin'] ?? 0,  // Default to 0 if null
      idTrabajador: json['Id_Trabajador'],
      idProveedor: json['Id_Proveedor'],
      tipoUsuario: json['Id_Tipo_Usuario'] ?? 0,  // Default to 0 if null
    );
  }
}

class UsuarioSistema {
  final int id;
  final String nombre;
  final int tipo;

  UsuarioSistema({
    required this.id,
    required this.nombre,
    required this.tipo,
  });

  factory UsuarioSistema.fromJson(Map<String, dynamic> json) {
    return UsuarioSistema(
      id: json['Id_Usuario_Sistema'] ?? 0,  // Default to 0 if null
      nombre: json['Nombre_Usuario'] ?? 'Unknown',  // Default to 'Unknown' if null
      tipo: json['Id_Tipo_Usuario'] ?? 0,  // Default to 0 if null
    );
  }
}
