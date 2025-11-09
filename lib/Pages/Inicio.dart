import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ganabo/Pages/Navigation_Drawer.dart';

class InicioPage extends StatelessWidget {
  final Map<String, dynamic>? userData; // Aqui agregamos el parametro de usuarios
  
  const InicioPage({Key? key, this.userData}) : super(key: key); // Aqui agregamos su constructor

  // Aqui agregamos la funcion para acceder al enlace
  Future<void> _abrirEnlace() async {
    final Uri url = Uri.parse('https://www.siniiga.org.mx/manuales.html');
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    appBar: AppBar(
      title: const Text("Inicio"),
      backgroundColor: Colors.yellow[100],
    ),
    drawer: CustomNavigationDrawer(userData: userData), 
    body: Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16.0),
          child: const Text(
            "TIPS Y CONSEJOS",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 4.0,
          child: Container(
            width: 580,
            height: 474,
            child: Image.asset(
              'Icons/info.png',
              fit: BoxFit.fill, 
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16.0),
          child: const Text(
            "Reglamento del SINIIGA",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Aqui ponemos el texto con el link para dar click en el
        InkWell(
          onTap: _abrirEnlace,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "👉",
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              SizedBox(width: 5),
              Text(
                "Click Aquí ",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}