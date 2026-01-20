class ProyectoReporteria {
  final int id;
  final String nombre;
  final double presupuesto;
  final double adelantos;
  final double gastos;
  final DateTime fechaInicio;

  ProyectoReporteria({
    required this.id,
    required this.nombre,
    required this.presupuesto,
    required this.adelantos,
    required this.gastos,
    required this.fechaInicio,
  });

  factory ProyectoReporteria.fromJson(Map<String, dynamic> json) {
    return ProyectoReporteria(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      presupuesto: (json['presupuesto'] is String) 
          ? double.tryParse(json['presupuesto']) ?? 0 
          : (json['presupuesto']?.toDouble() ?? 0),
      adelantos: (json['adelantos'] is String) 
          ? double.tryParse(json['adelantos']) ?? 0 
          : (json['adelantos']?.toDouble() ?? 0),
      gastos: (json['gastos'] is String) 
          ? double.tryParse(json['gastos']) ?? 0 
          : (json['gastos']?.toDouble() ?? 0),
      fechaInicio: DateTime.parse(json['fechaInicio'] ?? DateTime.now().toString()),
    );
  }

  // Métodos para cálculos
  double get rentabilidad => adelantos - gastos;
  double get ganancias => presupuesto - gastos;
  double get porCobrar => presupuesto - adelantos;
}