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
  });

  factory MovimientoContable.fromJson(Map<String, dynamic> json) {
    return MovimientoContable(
      id: json['Id_Movimiento'],
      idCliente: json['Id_Ciente'],
      idServicio: json['Id_Servicio'],
      tipoMovimiento: json['Id_Tipo_Movimiento'],
      monto: double.tryParse(json['Monto'] ?? '0') ?? 0.0,
      comentario: json['Comentario'] ?? '',
      fecha: json['Fecha_Movimiento'] ?? '',
      idProyecto: json['Id_Proyecto'],
      idAdmin: json['Id_Admin'],
      idTrabajador: json['Id_Trabajador'],
      idProveedor: json['Id_Proveedor'],
    );
  }
}
