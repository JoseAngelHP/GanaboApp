import 'package:flutter/material.dart';

class TextFieldCustom extends StatefulWidget {
  final IconData? icono;
  final TextInputType? type;
  final bool pass;
  final String? texto;
  final TextEditingController? controller;

  const TextFieldCustom({
    this.icono,
    this.type,
    this.pass = false,
    this.texto,
    this.controller,
  });

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.pass; // si es password empieza oculto
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.type,
      obscureText: widget.pass ? _obscureText : false,
      decoration: InputDecoration(
        hintText: widget.texto,
        filled: true,
        fillColor: Color(0xffEBDCFA),
        prefixIcon: Icon(widget.icono, color: Colors.grey),
        suffixIcon:
            widget.pass
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffebdcfa)),
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffebdcfa)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
