import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 
import 'package:ganabo/Widgets/Header.dart';
import 'package:ganabo/Widgets/Logo.dart';
import 'package:ganabo/Widgets/TextFieldCustom.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override 
  State<SignUpPage> createState() => _SignUpPageState();
}

String getApiUrl(String endpoint) {
  if (kIsWeb) {
    return 'https://ganabovino.atwebpages.com/api/$endpoint.php';
  }
  else {
    return 'http://ganabovino.atwebpages.com/api/$endpoint.php';
  }
}

class _SignUpPageState extends State<SignUpPage> {
  final usuarioController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool isLoading = false;

  Future<void> registrarUsuario() async {
    final url = Uri.parse(getApiUrl('registro'));
    
    print('🌐 URL usada: $url'); 
    print('📱 Plataforma: ${kIsWeb ? 'WEB' : 'MÓVIL'}'); 

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'usuario': usuarioController.text.trim(),
          'correo': correoController.text.trim(),
          'contrasena': contrasenaController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          // Aqui mostramos el mensaje de exito del registro 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro exitoso!'))
          );
          Navigator.pushReplacementNamed(context, 'Login');
        } else {
          // Mandamos un mensaje de error por si falla 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Error en el registro'))
          );
        }
      } else {
        // Mandamos un mensaje de error por si falla con el http
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}'))
        );
      }
    } catch (e) {
      print('❌ Error completo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}'))
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: EdgeInsets.only(top: 0),
        physics: BouncingScrollPhysics(),
        children: [
          Stack(children: [HeaderSignUp(), LogoHeader()]),
          _Titulo(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                TextFieldCustom(
                  icono: Icons.person,
                  type: TextInputType.text,
                  texto: 'Usuario',
                  controller: usuarioController,
                ),
                SizedBox(height: 20),
                TextFieldCustom(
                  icono: Icons.mail_outline,
                  type: TextInputType.emailAddress,
                  texto: 'Correo',
                  controller: correoController,
                ),
                SizedBox(height: 20),
                TextFieldCustom(
                  icono: Icons.lock,
                  type: TextInputType.text,
                  pass: true,
                  texto: 'Contraseña',
                  controller: contrasenaController,
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Color(0xff575757),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton(
                    onPressed: isLoading ? null : registrarUsuario,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child:
                        isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'REGISTRATE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, 'Login'),
            child: Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Text('/', style: TextStyle(fontSize: 25, color: Colors.grey)),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, 'Signup'),
            child: Text(
              'Registrarse',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}