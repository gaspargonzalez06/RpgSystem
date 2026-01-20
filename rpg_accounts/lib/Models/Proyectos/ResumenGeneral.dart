// class ResumenGeneral {
//   final double ingresos;
//   final double egresos;
//   final double totalBanco;
//   final double saldo;

//   ResumenGeneral({
//     required this.ingresos,
//     required this.egresos,
//     required this.totalBanco,
//     required this.saldo,
//   });

//   factory ResumenGeneral.fromJson(Map<String, dynamic> json) {
//     double parseDouble(dynamic value) {
//       if (value == null) return 0.0;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       if (value is String) return double.tryParse(value) ?? 0.0;
//       return 0.0;
//     }

//     return ResumenGeneral(
//       ingresos: parseDouble(json['ingresos']),
//       egresos: parseDouble(json['egresos']),
//       totalBanco: parseDouble(json['totalBanco']),
//       saldo: parseDouble(json['saldo']),
//     );
//   }
// }
class ResumenGeneral {
  final double ingresosGenerales;
  final double egresosGenerales;
  final double saldoGenerales;
  final double ingresosMensuales;
  final double egresosMensuales;
  final double saldoMensuales;
  final double totalBanco;
  final double saldo;

  ResumenGeneral({
    required this.ingresosGenerales,
    required this.egresosGenerales,
    required this.saldoGenerales,
    required this.ingresosMensuales,
    required this.egresosMensuales,
    required this.saldoMensuales,
    required this.totalBanco,
    required this.saldo,
  });

  factory ResumenGeneral.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Elimina comas si están presentes como separadores de miles
        final cleanValue = value.replaceAll(',', '');
        return double.tryParse(cleanValue) ?? 0.0;
      }
      return 0.0;
    }

    // Extraer datos del objeto 'general'
    final generalData = json['general'] as Map<String, dynamic>? ?? {};
    // Extraer datos del objeto 'mensual'
    final mensualData = json['mensual'] as Map<String, dynamic>? ?? {};

    return ResumenGeneral(
      ingresosGenerales: parseDouble(generalData['ingresos']),
      egresosGenerales: parseDouble(generalData['egresos']),
      saldoGenerales: parseDouble(generalData['saldo']),
      ingresosMensuales: parseDouble(mensualData['ingresos']),
      egresosMensuales: parseDouble(mensualData['egresos']),
      saldoMensuales: parseDouble(mensualData['saldo']),
      totalBanco: parseDouble(json['totalBanco']),
      saldo: parseDouble(json['saldo']),
    );
  }

  // Método para facilitar la creación de un mapa desde la clase
  Map<String, dynamic> toJson() {
    return {
      'general': {
        'ingresos': ingresosGenerales,
        'egresos': egresosGenerales,
        'saldo': saldoGenerales,
      },
      'mensual': {
        'ingresos': ingresosMensuales,
        'egresos': egresosMensuales,
        'saldo': saldoMensuales,
      },
      'totalBanco': totalBanco,
      'saldo': saldo,
    };
  }
}