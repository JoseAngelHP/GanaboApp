import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Navigation_Drawer.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic>? userData; // Aqui pasamos los parametros de usuario
  
  const HomePage({Key? key, this.userData}) : super(key: key); // Aqui agregamos su constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: CustomNavigationDrawer(userData: userData), // Aqui pasamos los datos al drawer
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}