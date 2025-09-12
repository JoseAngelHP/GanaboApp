import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Navigation_Drawer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: const CustomNavigationDrawer(), 
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