import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Contactos.dart';
import 'package:ganabo/Pages/Engorda.dart';
import 'package:ganabo/Pages/Rancho.dart';
import 'package:ganabo/Pages/Medicamento.dart';
import 'package:ganabo/Pages/Trabajador.dart';
import 'package:ganabo/Pages/Pesaje.dart';
import 'package:ganabo/Pages/Producciondeleche.dart';
import 'package:ganabo/Pages/Quienesomos.dart';
import 'package:ganabo/Pages/Raza.dart';
import 'package:ganabo/Pages/Registro.dart';
import 'package:ganabo/Pages/UserPage.dart';
import 'package:ganabo/Pages/Vacunacion.dart';

class Usuario {
  final String usuario;
  final String correo;

  Usuario({required this.usuario, required this.correo});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuario: json['usuario'] ?? 'Usuario',
      correo: json['correo'] ?? 'correo@ejemplo.com',
    );
  }
}

class CustomNavigationDrawer extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const CustomNavigationDrawer({Key? key, this.userData}) : super(key: key);

  @override
  State<CustomNavigationDrawer> createState() => _CustomNavigationDrawerState();
}

class _CustomNavigationDrawerState extends State<CustomNavigationDrawer> {
  Usuario _usuarioActual = Usuario(usuario: 'Usuario', correo: 'correo@ejemplo.com');

  @override
  void initState() {
    super.initState();
    _cargarUsuarioDesdeLogin();
  }

  void _cargarUsuarioDesdeLogin() {
    print('Cargando usuario desde login...');
    
    if (widget.userData != null) {
      print('Datos recibidos: ${widget.userData}');
      
      setState(() {
        _usuarioActual = Usuario(
          usuario: widget.userData!['usuario'] ?? 'Usuario',
          correo: widget.userData!['correo'] ?? 'correo@ejemplo.com',
        );
      });
      print('Usuario cargado: ${_usuarioActual.usuario} - ${_usuarioActual.correo}');
    } else {
      print('No hay datos de usuario');
    }
  }

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: Colors.green,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeader(context), buildMenuItems(context)],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Material(
    color: Colors.blue.shade400,
    child: InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserPage(usuario: _usuarioActual),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage(
                "https://plus.unsplash.com/premium_vector-1722668647008-43d787e8cc17?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=880",
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _usuarioActual.usuario,
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _usuarioActual.correo,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );

  Widget buildMenuItems(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      runSpacing: 16,
      children: [
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Inicio'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('Registro'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RegistroPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.workspaces_outline),
          title: const Text('Pesaje'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PesajePage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('Producción de leche'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProducciondelechePage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_tree_outlined),
          title: const Text('Engorda'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EngordaPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Vacunación'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => VacunacionPage()),
            );
          },
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(Icons.account_balance),
          title: const Text('Razas'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RazaPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.yard_outlined),
          title: const Text('Ranchos'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RanchoPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Medicamentos'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MedicamentosPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_a_photo_rounded),
          title: const Text('Trabajadores'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TrabajadoresPage()),
            );
          },
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(Icons.wrong_location_outlined),
          title: const Text('¿Quienes Somos?'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => QuienesomosPage()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.work_outline_sharp),
          title: const Text('Contactos'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ContactosPage()),
            );
          },
        ),
      ],
    ),
  );
}