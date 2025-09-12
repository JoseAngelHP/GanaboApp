import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: MediaQuery.of(context).size.width * 0.35,
      child: CircleAvatar(
        radius: 60, 
        backgroundColor: Colors.grey[800],
        child: ClipOval(
          child: Image.asset(
            'Icons/ganbov.png',
            width: 125,
            height: 125,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
