import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpg_accounts/Provider/ProyectosProvider.dart';
import 'package:rpg_accounts/Views/Materiales.dart';
import 'package:rpg_accounts/Views/Personal/PaginaPersonal.dart';
import 'package:rpg_accounts/main.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<ProyectoProvider>(context).usuarioLogueado;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Bienvenido',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 5),
                if (usuario != null)
                  Text(
                    usuario.nombreUsuario,  // o el campo que quieras mostrar
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            text: 'Inicio',
            page: PaginaPrincipal(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.work,
            text: 'Proyectos',
            page: ProyectosPage(),
          ),
          // _buildDrawerItem(
          //   context: context,
          //   icon: Icons.inventory,
          //   text: 'Materiales',
          //   page: MaterialesPage(),
          // ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            text: 'Gestión de Usuarios',
            page: AgregarPersonalManoDeObra(),
          ),
          // _buildDrawerItem(
          //   context: context,
          //   icon: Icons.settings,
          //   text: 'Gestión',
          //   page: GestionPage(),
          // ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
