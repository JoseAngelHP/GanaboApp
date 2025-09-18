import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MadrePage extends StatefulWidget {
  const MadrePage({Key? key}) : super(key: key);

  @override
  _MadrePageState createState() => _MadrePageState();
}

class _MadrePageState extends State<MadrePage> {
  // Controladores para los TextFields
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  // URL base de tu API
  //final String baseUrl = "http://192.168.1.43/api/madre.php";
  final String baseUrl = "http://ganabovino.atwebpages.com/api/madre.php";

  // Lista para almacenar las madres
  List<dynamic> _madres = [];

  // Función para mostrar mensajes
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // AGREGAR MADRE
  Future<void> _agregarMadre() async {
    if (_validarCampos()) {
      try {
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'numero_arete': _numeroAreteController.text,
            'nombre_madre': _nombreController.text,
            'peso': double.parse(_pesoController.text),
            'edad': int.parse(_edadController.text),
            'altura': double.parse(_alturaController.text),
            'fecha_apareamiento': _fechaController.text,
          }),
        );

        final data = json.decode(response.body);
        if (data['success']) {
          _mostrarMensaje('Madre agregada correctamente');
          _limpiarCampos();
        } else {
          _mostrarMensaje('Error: ${data['message']}');
        }
      } catch (e) {
        _mostrarMensaje('Error de conexión: $e');
      }
    }
  }

  // CONSULTAR MADRE
  Future<void> _consultarMadre() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?numero_arete=${_numeroAreteController.text}'),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        final madre = data['data'];
        _nombreController.text = madre['nombre_madre'];
        _pesoController.text = madre['peso'].toString();
        _edadController.text = madre['edad'].toString();
        _alturaController.text = madre['altura'].toString();
        _fechaController.text = madre['fecha_apareamiento'];
        _mostrarMensaje('Madre encontrada');
      } else {
        _mostrarMensaje('Madre no encontrada');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // MODIFICAR MADRE
  Future<void> _modificarMadre() async {
    if (_validarCampos()) {
      try {
        final response = await http.put(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'numero_arete': _numeroAreteController.text,
            'nombre_madre': _nombreController.text,
            'peso': double.parse(_pesoController.text),
            'edad': int.parse(_edadController.text),
            'altura': double.parse(_alturaController.text),
            'fecha_apareamiento': _fechaController.text,
          }),
        );

        final data = json.decode(response.body);
        if (data['success']) {
          _mostrarMensaje('Madre modificada correctamente');
        } else {
          _mostrarMensaje('Error: ${data['message']}');
        }
      } catch (e) {
        _mostrarMensaje('Error de conexión: $e');
      }
    }
  }

  // ELIMINAR MADRE
  Future<void> _eliminarMadre() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para eliminar');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
        }),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        _mostrarMensaje('Madre eliminada correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error: ${data['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // LIMPIAR CAMPOS
  void _limpiarCampos() {
    _numeroAreteController.clear();
    _nombreController.clear();
    _pesoController.clear();
    _edadController.clear();
    _alturaController.clear();
    _fechaController.clear();
  }

  // FUNCIÓN PARA CARGAR LAS MADRES
  Future<void> _cargarMadres() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      final data = json.decode(response.body);
      
      if (data['success']) {
        setState(() {
          _madres = data['data'];
        });
      } else {
        _mostrarMensaje('Error al cargar la lista: ${data['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // VER LISTA - Navegar a lista de registros con diseño tabular
  void _verLista() {
    _cargarMadres().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE MADRES'),
              backgroundColor: Colors.blueGrey[800],
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Encabezados de la tabla
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 8,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'N° ARETE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'NOMBRE MADRE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'PESO (kg)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'EDAD',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'ALTURA (cm)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'FECHA APAREAMIENTO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Contenido de la tabla
                  Expanded(
                    child: _madres.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de madres',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _madres.length,
                            itemBuilder: (context, index) {
                              final madre = _madres[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? Colors.grey[50]
                                      : Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  children: [
                                    // N° Arete
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        madre['numero_arete']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Nombre Madre
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        madre['nombre_madre']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Peso
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        madre['peso']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Edad
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        madre['edad']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Altura
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        madre['altura']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Fecha Apareamiento
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        madre['fecha_apareamiento']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // VALIDAR CAMPOS
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _pesoController.text.isEmpty ||
        _edadController.text.isEmpty ||
        _alturaController.text.isEmpty ||
        _fechaController.text.isEmpty) {
      _mostrarMensaje('Todos los campos son obligatorios');
      return false;
    }
    return true;
  }

  // Función para construir los botones
  Widget _buildButtonRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _agregarMadre,
          child: Text("Agregar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _consultarMadre,
          child: Text("Consultar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _modificarMadre,
          child: Text("Modificar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _eliminarMadre,
          child: Text("Eliminar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _limpiarCampos,
          child: Text("Limpiar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _verLista,
          child: Text("Ver Lista"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: const Text("Madre"),
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
                "MADRE",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo: Número de arete
              TextFormField(
                controller: _numeroAreteController,
                decoration: InputDecoration(
                  labelText: 'Número de arete',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              
              // Campo: Nombre de la madre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la madre',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              
              // Campo: Peso
              TextFormField(
                controller: _pesoController,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 15),
              
              // Campo: Edad
              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(
                  labelText: 'Edad',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              
              // Campo: Altura
              TextFormField(
                controller: _alturaController,
                decoration: InputDecoration(
                  labelText: 'Altura (cm)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 15),
              
              // Campo: Fecha de apareamiento
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha de apareamiento',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _fechaController.text = "${picked.toLocal()}".split(' ')[0];
                  }
                },
              ),
              const SizedBox(height: 30),
              
              // Botones
              _buildButtonRow(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar controladores
    _numeroAreteController.dispose();
    _nombreController.dispose();
    _pesoController.dispose();
    _edadController.dispose();
    _alturaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}