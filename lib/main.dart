import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Inicio.dart';
import 'package:ganabo/Pages/Login.dart';
import 'package:ganabo/Pages/Signup.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GANABO',
      initialRoute: 'Login',
      routes: {
        'Login': (_) => LoginPage(), 
        'Signup': (_) => SignUpPage(),
        'Home': (_) => InicioPage(), // Agrega esta ruta
        },
    );
  }
}
