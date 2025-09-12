import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ganabo/Pages/Navigation_Drawer.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({Key? key}) : super(key: key);

  // Función para abrir el enlace:cite[1]:cite[4]
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
    drawer: const CustomNavigationDrawer(), // Agrega el drawer aquí
    body: Column(
      children: [
        // TextView equivalente (arriba de la imagen)
        Container(
          margin: const EdgeInsets.all(16.0), // Margen opcional
          child: const Text(
            "TIPS Y CONSEJOS", // Tu texto aquí
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        // ImageView con fitXY
        InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 4.0,
          child: Container(
            width: 580,
            height: 474,
            child: Image.asset(
              'Icons/info.png',
              fit: BoxFit.fill, // fitXY
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16.0), // Margen opcional
          child: const Text(
            "Reglamento del SINIIGA", // Tu texto aquí
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 15), // Espacio
        // Texto con enlace clickeable
        InkWell(
          onTap: _abrirEnlace,
          child: const Row(
            mainAxisSize:
                MainAxisSize
                    .min, // Para que el Row ocupe solo el espacio necesario
            children: [
              Text(
                "👉", // Emoji de mano señalando (puedes cambiarlo por cualquier otro)
                style: TextStyle(
                  fontSize: 22, // Tamaño slightly diferente si lo deseas
                ),
              ),
              SizedBox(width: 5), // Espacio pequeño entre texto e icono
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
