import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Contactos.dart';
import 'package:ganabo/Pages/Engorda.dart';
import 'package:ganabo/Pages/Inicio.dart';
import 'package:ganabo/Pages/Madre.dart';
import 'package:ganabo/Pages/Origen.dart';
import 'package:ganabo/Pages/Padre.dart';
import 'package:ganabo/Pages/Pesaje.dart';
import 'package:ganabo/Pages/Producciondeleche.dart';
import 'package:ganabo/Pages/Quienesomos.dart';
import 'package:ganabo/Pages/Raza.dart';
import 'package:ganabo/Pages/Registro.dart';
import 'package:ganabo/Pages/UserPage.dart';
import 'package:ganabo/Pages/Vacunacion.dart';

class CustomNavigationDrawer extends StatelessWidget {
  const CustomNavigationDrawer({Key? key}) : super(key: key);

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
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserPage()));
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 24 + MediaQuery.of(context).padding.top,
          bottom: 24,
        ),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 52,
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1546464677-c25cd52c470b?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Frank',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            Text(
              'frank@gmail.com',
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => InicioPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('Registro'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegistroPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.workspaces_outline),
          title: const Text('Pesaje'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PesajePage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('Producción de leche'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProducciondelechePage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_tree_outlined),
          title: const Text('Engorda'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => EngordaPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Vacunación'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => VacunacionPage()));
          },
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(Icons.account_balance),
          title: const Text('Raza'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RazaPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.yard_outlined),
          title: const Text('Origen'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrigenPage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Padre'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PadrePage()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_a_photo_rounded),
          title: const Text('Madre'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => MadrePage()));
          },
        ),
        const Divider(color: Colors.black54),
        ListTile(
          leading: const Icon(Icons.wrong_location_outlined),
          title: const Text('¿Quienes Somos?'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuienesomosPage()));
          },
        ),  
        ListTile(
          leading: const Icon(Icons.work_outline_sharp),
          title: const Text('Contactos'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ContactosPage()));
          },
        ),
      ],
    ),
  );
}