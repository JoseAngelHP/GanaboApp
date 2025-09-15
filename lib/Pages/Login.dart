import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ganabo/Widgets/Header.dart';
import 'package:ganabo/Widgets/Logo.dart';
import 'package:ganabo/Widgets/TextFieldCustom.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool isLoading = false;
 
  Future<void> iniciarSesion() async { 
    // Validar campos
    if (correoController.text.isEmpty || contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    //final url = Uri.parse('http://192.168.1.43/api/login.php');
    // URL CORRECTA para InfinityFree:
    final url = Uri.parse('https://ganaboapp.infinityfreeapp.com/api/login.php');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'correo': correoController.text.trim(),
          'contrasena': contrasenaController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          // Login exitoso
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Inicio de sesión exitoso!'))
          );
          // Navegar a la pantalla principal
          Navigator.pushReplacementNamed(context, 'Home');
        } else {
          // Error del servidor (credenciales incorrectas)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Error en el login'))
          );
        }
      } else if (response.statusCode == 401) {
        // No autorizado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Credenciales incorrectas'))
        );
      } else {
        // Error HTTP
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}'))
        );
      }
    } catch (e) {
      print('Error completo: $e');
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
          Stack(children: [HeaderLogin(), LogoHeader()]),
          _Titulo(),
          SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
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
                _ForgotPassword(),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Color(0xff575757),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton(
                    onPressed: isLoading ? null : iniciarSesion,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'INICIAR SESIÓN',
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

class _ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 25, top: 10),
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Aquí puedes agregar la funcionalidad de "Olvidé mi contraseña"
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Funcionalidad de recuperación de contraseña')),
          );
        },
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
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
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Text('/', style: TextStyle(fontSize: 25, color: Colors.grey)),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, 'Signup'),
            child: Text(
              'Registrarse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}