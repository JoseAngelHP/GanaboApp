import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Navigation_Drawer.dart';

class UserPage extends StatelessWidget {
  final Usuario usuario;
  
  const UserPage({Key? key, required this.usuario}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                "https://plus.unsplash.com/premium_vector-1722668647008-43d787e8cc17?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=880",
              ),
            ),
            SizedBox(height: 20),
            Text(
              usuario.usuario,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              usuario.correo,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
