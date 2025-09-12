import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactosPage extends StatelessWidget {
  const ContactosPage({Key? key}) : super(key: key);

  // Función para abrir enlaces
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir $url';
    }
  }

  // Función para abrir correo electrónico
  Future<void> _launchEmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'ganabodemo@gmail.com',
      query: 'subject=Consulta&body=Hola, me gustaría obtener más información', // Parámetros opcionales
    );

    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el cliente de correo';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    appBar: AppBar(
      title: const Text("Contactos"),
      backgroundColor: Colors.yellow[100],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "REDES SOCIALES",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            
            // Tarjeta para Gmail
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.red, size: 30), // Icono de Gmail
                title: const Text(
                  "Gmail",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("ganabodemo@gmail.com"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _launchEmail(), // Abre cliente de correo
              ),
            ),
            
            // Tarjeta para WhatsApp
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListTile(
                leading: Icon(Icons.chat, color: Colors.green, size: 30), // Icono de WhatsApp
                title: const Text(
                  "WhatsApp",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Grupo de la comunidad"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _launchURL('https://chat.whatsapp.com/JVjWugehqta5W7ELwbYHLF'), // Abre enlace de WhatsApp
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              "¡Contáctanos por cualquiera de estos medios!",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}