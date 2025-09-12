import 'package:flutter/material.dart';
//import 'package:ganabo/Pages/Home.dart';
//import 'package:ganabo/main.dart';

class QuienesomosPage extends StatelessWidget {
  const QuienesomosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    //drawer: NavigationDrawer(),
    appBar: AppBar(
      title: const Text("¿Quienes Somos?"),
      backgroundColor: Colors.yellow[100],
    ),
    body: Column(
      children: [
        // TextView equivalente (arriba de la imagen)
        Container(
          margin: const EdgeInsets.all(16.0), // Margen opcional
          child: const Text(
            "HISTORIA GANADERA", // Tu texto aquí
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
            width: 550,
            height: 574,
            child: Image.asset(
              'Icons/histogana.png',
              fit: BoxFit.fill, // fitXY
            ),
          ),
        ),
      ],
    ),
  );
}
