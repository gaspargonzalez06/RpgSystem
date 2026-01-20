class UsuarioSistema {
  final int id;
  final int id_tipo_usuario;
  final String nombre;
  final int tipo;
  final String? telefono;
  final String? cedula;
  final dynamic licencia; // Puede ser int o null
  final String? direccion;
  final String? placaAuto;
  final String? cuentaBanco;
  final String? comentario;

  UsuarioSistema({
    required this.id,
    required this.id_tipo_usuario,
    required this.nombre,
    required this.tipo,
    this.telefono,
    this.cedula,
    this.licencia,
    this.direccion,
    this.placaAuto,
    this.cuentaBanco,
    this.comentario,
  });

  factory UsuarioSistema.fromJson(Map<String, dynamic> json) {
    return UsuarioSistema(
      id: json['Id_Usuario_Sistema'],
      nombre: json['Nombre_Usuario'],
      id_tipo_usuario: json['Id_Tipo_Usuario'],
      tipo: json['Id_Tipo_Usuario'],
      telefono: json['Telefono'],
      cedula: json['Cedula'],
      licencia: json['Licencia'],
      direccion: json['Direccion'],
      placaAuto: json['placa_auto'],
      cuentaBanco: json['cuenta_banco'],
      comentario: json['comentario'],
    );
  }
}