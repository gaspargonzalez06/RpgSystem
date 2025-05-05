class Proyecto {
  final int id;
  final String nombre;
  final String ubicacion;
  final double presupuesto;
  final double adelantos;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final int clienteId;
  final String clienteNombre;

  Proyecto({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.presupuesto,
    required this.adelantos,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.clienteId,
    required this.clienteNombre,
  });

  factory Proyecto.fromJson(Map<String, dynamic> json) {
    return Proyecto(
      id: json['Id_Proyecto'],
      nombre: json['Nombre_Proyecto'],
      ubicacion: json['Ubicacion'],
      presupuesto: double.parse(json['Presupuesto']),
      adelantos: double.parse(json['Adelantos']),
      fechaInicio: DateTime.parse(json['Fecha_Inicio']),
      fechaFin: DateTime.parse(json['Fecha_Fin']),
      estado: json['Estado'],
      clienteId: json['Cliente_Id'],
      clienteNombre: json['Cliente_Nombre'],
    );
  }
}
