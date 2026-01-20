class Proyecto {
  final int id;
  final String nombre;
  final String ubicacion;
  final double presupuesto;
  final double adelantos;
  final double gastos;
  final double dineroBanco;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final String comentario;
  final String telefono;
    final String cedula;
  final String licencia;
  final int clienteId;
  final String clienteNombre;
  final int? diasDesdeUltimoAdelanto;

  Proyecto({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.presupuesto,
    required this.adelantos,
       required this.gastos,
       required this.comentario,  
          required this.cedula,
       required this.licencia,
    required this.dineroBanco,
    required this.fechaInicio,
    required this.telefono,
    required this.fechaFin,
    required this.estado,
    required this.clienteId,
    required this.clienteNombre,
    this.diasDesdeUltimoAdelanto,
  });

  factory Proyecto.fromJson(Map<String, dynamic> json) {
    return Proyecto(
      id: json['Id_Proyecto'],
      nombre: json['Nombre_Proyecto'],
      ubicacion: json['Ubicacion'],
      presupuesto: double.tryParse(json['Presupuesto'].toString()) ?? 0.0,
      adelantos: double.tryParse(json['Adelantos'].toString()) ?? 0.0,
       gastos: double.tryParse(json['Gastos'].toString()) ?? 0.0,
      dineroBanco: double.tryParse(json['dinero_banco'].toString()) ?? 0.0,
      fechaInicio: DateTime.parse(json['Fecha_Inicio']),
      fechaFin: DateTime.parse(json['Fecha_Fin']),
      telefono: json['telefono'] ?? '', 
      cedula: json['Cedula'] ?? '', 
      comentario: json['Comentario'] ?? ''    ,
      licencia: json['Licencia'] ?? '', 
      estado: json['Estado'],
      clienteId: json['Cliente_Id'],
      clienteNombre: json['Cliente_Nombre'],
      diasDesdeUltimoAdelanto: json['Dias_Desde_Ultimo_Adelanto'] != null
          ? int.tryParse(json['Dias_Desde_Ultimo_Adelanto'].toString())
          : null,
    );
  }
}
