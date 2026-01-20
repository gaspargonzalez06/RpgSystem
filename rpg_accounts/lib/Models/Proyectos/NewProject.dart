class NuevoProyecto {
  final String nombreProyecto;
  final String ubicacion;
  final int idCliente;
  final double presupuesto;
  final double adelantos;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
   final String comentario;
  final int idAdmin;

  NuevoProyecto({
    required this.nombreProyecto,
    required this.ubicacion,
    required this.idCliente,
    required this.comentario,
    required this.presupuesto,
    required this.adelantos,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.idAdmin,
  });

  Map<String, dynamic> toJson() {
    return {
      'Nombre_Proyecto': nombreProyecto,
      'Ubicacion': ubicacion,
      'Id_Cliente': idCliente,
      'Presupuesto': presupuesto,
      'Adelantos': adelantos,
      'Fecha_Inicio': fechaInicio.toIso8601String(),
      'Fecha_Fin': fechaFin.toIso8601String(),
      'Estado': estado,
      'Comentario': comentario,
      'Id_Admin': idAdmin,
    };
  }
}
