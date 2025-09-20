import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // ← AÑADE ESTA IMPORTACIÓN

// ← AÑADE ESTA FUNCIÓN FUERA DE LA CLASE
String getApiUrl(String endpoint) {
  // Para WEB: Usar HTTPS
  if (kIsWeb) {
    return 'https://ganabovino.atwebpages.com/api/$endpoint.php';
  }
  // Para MÓVIL: Usar HTTP
  else {
    return 'http://ganabovino.atwebpages.com/api/$endpoint.php';
  }
}

class OrigenPage extends StatefulWidget {
  const OrigenPage({Key? key}) : super(key: key);

  @override
  _OrigenPageState createState() => _OrigenPageState();
}

class _OrigenPageState extends State<OrigenPage> {
  // Controladores para los TextFields
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _nombreDuenoController = TextEditingController();
  final TextEditingController _nombreFincaController = TextEditingController();
  final TextEditingController _colorGanadoController = TextEditingController();

  // Lista para almacenar los orígenes
  List<dynamic> _origenes = [];

  // Función para cargar orígenes desde la API
  Future<void> _cargarOrigenes() async {
    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _origenes = json.decode(response.body);
        });
      } else {
        _mostrarMensaje('Error al cargar los orígenes');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    appBar: AppBar(
      title: const Text("Origen"),
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
              "ORIGEN",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Campo: Número de arete
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
            
            // Campo: Nombre del dueño
            TextField(
              controller: _nombreDuenoController,
              decoration: InputDecoration(
                labelText: 'Nombre del dueño',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // Campo: Nombre de la finca
            TextField(
              controller: _nombreFincaController,
              decoration: InputDecoration(
                labelText: 'Nombre de la finca',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // Campo: Color del ganado
            TextField(
              controller: _colorGanadoController,
              decoration: InputDecoration(
                labelText: 'Color del ganado',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            
            // Botones en Wrap
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
          onPressed: _agregarOrigen,
          child: Text("Agregar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _consultarOrigen,
          child: Text("Consultar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _modificarOrigen,
          child: Text("Modificar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _eliminarOrigen,
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
    _cargarOrigenes().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE ORÍGENES'),
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
                            'NOMBRE DUEÑO',
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
                            'NOMBRE FINCA',
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
                            'COLOR GANADO',
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
                    child: _origenes.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de orígenes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _origenes.length,
                            itemBuilder: (context, index) {
                              final origen = _origenes[index];
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
                                        origen['numero_arete']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Nombre Dueño
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        origen['nombre_dueno']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Nombre Finca
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        origen['nombre_finca']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Color Ganado
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        origen['color_ganado']?.toString() ?? 'N/A',
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

  // Función para agregar origen
  Future<void> _agregarOrigen() async {
    if (!_validarCampos()) return;

    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'nombre_dueno': _nombreDuenoController.text,
          'nombre_finca': _nombreFincaController.text,
          'color_ganado': _colorGanadoController.text,
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

  // Función para consultar origen
  Future<void> _consultarOrigen() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    try {
      final url = Uri.parse("${getApiUrl('origen')}?numero_arete=${_numeroAreteController.text}");
      final response = await http.get(url);

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _nombreDuenoController.text = responseData['nombre_dueno'] ?? '';
          _nombreFincaController.text = responseData['nombre_finca'] ?? '';
          _colorGanadoController.text = responseData['color_ganado'] ?? '';
        });
        _mostrarMensaje('Origen encontrado');
      } else {
        _mostrarMensaje(responseData['message']);
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Función para modificar origen
  Future<void> _modificarOrigen() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para modificar');
      return;
    }

    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'nombre_dueno': _nombreDuenoController.text,
          'nombre_finca': _nombreFincaController.text,
          'color_ganado': _colorGanadoController.text,
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

  // Función para eliminar origen
  Future<void> _eliminarOrigen() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para eliminar');
      return;
    }

    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.delete(
        url,
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
      _nombreDuenoController.clear();
      _nombreFincaController.clear();
      _colorGanadoController.clear();
    });
  }

  // Función para validar campos
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _nombreDuenoController.text.isEmpty ||
        _nombreFincaController.text.isEmpty ||
        _colorGanadoController.text.isEmpty) {
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
    _nombreDuenoController.dispose();
    _nombreFincaController.dispose();
    _colorGanadoController.dispose();
    super.dispose();
  }
}