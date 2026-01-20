
class UsuarioSistemaRPG {
  final int idUsuarioSistema;
  final String nombreUsuario;
  final String usuario;
  final int? idTipoUsuario;
  final String? telefono;
  final String? cedula;
  final String? licencia;
  final String? direccion;

  UsuarioSistemaRPG({
    required this.idUsuarioSistema,
    required this.nombreUsuario,
    required this.usuario,
    this.idTipoUsuario,
    this.telefono,
    this.cedula,
    this.licencia,
    this.direccion,
  });

  factory UsuarioSistemaRPG.fromJson(Map<String, dynamic> json) {
    return UsuarioSistemaRPG(
      idUsuarioSistema: json['Id_Usuario_Sistema'],
      nombreUsuario: json['Nombre_Usuario'],
      usuario: json['Usuario'],
      idTipoUsuario: json['Id_Tipo_Usuario'],
      telefono: json['Telefono'],
      cedula: json['Cedula'],
      licencia: json['Licencia'],
      direccion: json['Direccion'],
    );
  }
}
