class ProjectSummary {
  final int totalProyectos;
  final int totalActivos;
  final int totalSuspendidos;
  final int totalCancelados;
  final int totalTerminados;

  ProjectSummary({
    required this.totalProyectos,
    required this.totalActivos,
    required this.totalSuspendidos,
    required this.totalCancelados,
    required this.totalTerminados,
  });

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    return ProjectSummary(
      totalProyectos: json['totalProyectos'] is int ? json['totalProyectos'] : int.parse(json['totalProyectos'].toString()),
      totalActivos: json['totalActivos'] is int ? json['totalActivos'] : int.parse(json['totalActivos'].toString()),
      totalSuspendidos: json['totalSuspendidos'] is int ? json['totalSuspendidos'] : int.parse(json['totalSuspendidos'].toString()),
      totalCancelados: json['totalCancelados'] is int ? json['totalCancelados'] : int.parse(json['totalCancelados'].toString()),
      totalTerminados: json['totalTerminados'] is int ? json['totalTerminados'] : int.parse(json['totalTerminados'].toString()),
    );
  }
}
