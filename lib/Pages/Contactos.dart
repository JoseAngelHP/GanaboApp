import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactosPage extends StatelessWidget {
  const ContactosPage({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    // Aqui agregamos el texto para el correo
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'ganabodemo@gmail.com',
      query: 'subject=Consulta&body=Hola, me gustaría obtener más información',
    );
    
    // Abrimos de forma directa
    await launchUrl(emailUri);
    
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
            
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.red, size: 30),
                title: const Text(
                  "Gmail",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("ganabodemo@gmail.com"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _launchEmail,
              ),
            ),
            
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ListTile(
                leading: Icon(Icons.chat, color: Colors.green, size: 30),
                title: const Text(
                  "WhatsApp",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Grupo de la comunidad"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _launchURL('https://chat.whatsapp.com/JVjWugehqta5W7ELwbYHLF'),
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