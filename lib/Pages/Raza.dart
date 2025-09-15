import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RazaPage extends StatefulWidget {
  const RazaPage({Key? key}) : super(key: key);

  @override
  _RazaPageState createState() => _RazaPageState();
}

class _RazaPageState extends State<RazaPage> {
  // Controladores para los TextFields
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _colorPelajeController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _nombreRazaController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  // URL de la API
  //final String _apiUrl = "http://192.168.1.43/api/raza.php";
  final String _apiUrl = "http://ganaboapp.infinityfreeapp.com/api/raza.php";

  // Lista para almacenar las razas
  List<dynamic> _razas = [];

  // Función para cargar razas desde la API
  Future<void> _cargarRazas() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _razas = json.decode(response.body);
        });
      } else {
        _mostrarMensaje('Error al cargar las razas');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    appBar: AppBar(
      title: const Text("Raza"),
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
              "RAZA",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Campos del formulario...
            TextField(
              controller: _numeroAreteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de arete',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _colorPelajeController,
              decoration: InputDecoration(
                labelText: 'Color de pelaje',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _regionController,
              decoration: InputDecoration(
                labelText: 'Región',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _nombreRazaController,
              decoration: InputDecoration(
                labelText: 'Nombre de la raza',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: _alturaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Altura (cm)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // Botones
            _buildButtonRow(),
          ],
        ),
      ),
    ),
  );

  Widget _buildButtonRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _agregarRaza,
          child: Text("Agregar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _consultarRaza,
          child: Text("Consultar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _modificarRaza,
          child: Text("Modificar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _eliminarRaza,
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

  // VER LISTA - Navegar a lista de registros con diseño tabular
  void _verLista() {
    _cargarRazas().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE RAZAS'),
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
                          flex: 2,
                          child: Text(
                            'NOMBRE RAZA',
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
                          flex: 2,
                          child: Text(
                            'COLOR PELAJE',
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
                            'REGIÓN',
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
                    child: _razas.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de razas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _razas.length,
                            itemBuilder: (context, index) {
                              final raza = _razas[index];
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
                                        raza['numero_arete']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Nombre Raza
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        raza['nombre_raza']?.toString() ?? 'N/A',
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
                                        raza['peso']?.toString() ?? 'N/A',
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
                                        raza['altura']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Color Pelaje
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        raza['color_pelaje']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Región
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        raza['region']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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

  // Función para agregar raza
  Future<void> _agregarRaza() async {
    if (!_validarCampos()) return;

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'peso': double.parse(_pesoController.text),
          'color_pelaje': _colorPelajeController.text,
          'region': _regionController.text,
          'nombre_raza': _nombreRazaController.text,
          'altura': double.parse(_alturaController.text),
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201) {
        _mostrarMensaje(responseData['message']);
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Función para consultar raza
  Future<void> _consultarRaza() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?numero_arete=${_numeroAreteController.text}'),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _pesoController.text = responseData['peso']?.toString() ?? '';
          _colorPelajeController.text = responseData['color_pelaje'] ?? '';
          _regionController.text = responseData['region'] ?? '';
          _nombreRazaController.text = responseData['nombre_raza'] ?? '';
          _alturaController.text = responseData['altura']?.toString() ?? '';
        });
        _mostrarMensaje('Raza encontrada');
      } else {
        _mostrarMensaje(responseData['message']);
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Función para modificar raza
  Future<void> _modificarRaza() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para modificar');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'peso': double.parse(_pesoController.text),
          'color_pelaje': _colorPelajeController.text,
          'region': _regionController.text,
          'nombre_raza': _nombreRazaController.text,
          'altura': double.parse(_alturaController.text),
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _mostrarMensaje(responseData['message']);
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Función para eliminar raza
  Future<void> _eliminarRaza() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para eliminar');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        _mostrarMensaje(responseData['message']);
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Función para limpiar campos
  void _limpiarCampos() {
    setState(() {
      _numeroAreteController.clear();
      _pesoController.clear();
      _colorPelajeController.clear();
      _regionController.clear();
      _nombreRazaController.clear();
      _alturaController.clear();
    });
  }

  // Función para validar campos
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _pesoController.text.isEmpty ||
        _colorPelajeController.text.isEmpty ||
        _regionController.text.isEmpty ||
        _nombreRazaController.text.isEmpty ||
        _alturaController.text.isEmpty) {
      _mostrarMensaje('Por favor, complete todos los campos');
      return false;
    }
    return true;
  }

  // Función para mostrar mensajes
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar los controladores
    _numeroAreteController.dispose();
    _pesoController.dispose();
    _colorPelajeController.dispose();
    _regionController.dispose();
    _nombreRazaController.dispose();
    _alturaController.dispose();
    super.dispose();
  }
}