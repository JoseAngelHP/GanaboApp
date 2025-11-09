import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

String getApiUrl(String endpoint) {
  if (kIsWeb) {
    return 'https://ganabovino.atwebpages.com/api/$endpoint.php';
  } else {
    return 'http://ganabovino.atwebpages.com/api/$endpoint.php';
  }
}

class TrabajadoresPage extends StatefulWidget {
  const TrabajadoresPage({Key? key}) : super(key: key);

  @override
  _TrabajadoresPageState createState() => _TrabajadoresPageState();
}

class _TrabajadoresPageState extends State<TrabajadoresPage> {
  // Aqui agregamos los controladores para los textfields
  final TextEditingController _numeroTrabajadorController = TextEditingController();
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _puestoController = TextEditingController();
  final TextEditingController _ranchoController = TextEditingController();

  final List<String> _puestos = [
    'Vaquero',
    'Caporal',
    'Mayordomo',
    'Administrador',
    'Veterinario',
    'Inseminador',
    'Ordeñador',
    'Alimentador',
    'Otro'
  ];

  List<dynamic> _trabajadores = [];
  
  List<dynamic> _fincas = [];
  String? _selectedFinca;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  void initState() {
    super.initState();
    _cargarFincas(); 
  }

  // Aqui cargamos los ranchos desde la api de origen
  Future<void> _cargarFincas() async {
    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _fincas = responseData['data'] ?? [];
          });
        } else {
          _mostrarMensaje('Error al cargar las fincas');
        }
      } else {
        _mostrarMensaje('Error al cargar las fincas');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión al cargar fincas: $e');
    }
  }

  List<String> _obtenerFincasUnicas() {
    final nombresFincas = _fincas
        .map<String>((finca) => finca['nombre_finca']?.toString() ?? '')
        .where((nombre) => nombre.isNotEmpty)
        .toSet() 
        .toList();
    
    nombresFincas.sort();
    return nombresFincas;
  }

  // Aqui cargamos los trabajadores desde la api de trabajadores
  Future<void> _cargarTrabajadores() async {
    try {
      final url = Uri.parse(getApiUrl('trabajadores'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _trabajadores = responseData['data'] ?? [];
          });
        } else {
          _mostrarMensaje('Error al cargar los trabajadores');
        }
      } else {
        _mostrarMensaje('Error al cargar los trabajadores');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    appBar: AppBar(
      title: const Text("Trabajadores"),
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
              "TRABAJADORES",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Aqui ponemos el campo de Número de trabajador
            TextField(
              controller: _numeroTrabajadorController,
              decoration: InputDecoration(
                labelText: 'Número de trabajador',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // Aqui ponemos el campo del Nombre completo
            TextField(
              controller: _nombreCompletoController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // Aqui ponemos el campo de Puesto 
            DropdownButtonFormField<String>(
              value: _puestoController.text.isEmpty ? null : _puestoController.text,
              decoration: InputDecoration(
                labelText: 'Puesto',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _puestos.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _puestoController.text = newValue ?? '';
                });
              },
            ),
            const SizedBox(height: 15),
            
            // Aqui ponemos el campo de Rancho 
            DropdownButtonFormField<String>(
              value: _selectedFinca,
              decoration: InputDecoration(
                labelText: 'Rancho',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _obtenerFincasUnicas().map<DropdownMenuItem<String>>((finca) {
                return DropdownMenuItem<String>(
                  value: finca,
                  child: Text(finca),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFinca = newValue;
                  _ranchoController.text = newValue ?? '';
                });
              },
            ),
            const SizedBox(height: 30),
            
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
          onPressed: _agregarTrabajador,
          child: Text("Agregar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _consultarTrabajador,
          child: Text("Consultar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _modificarTrabajador,
          child: Text("Modificar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _eliminarTrabajador,
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

  // Aqui agregamos al trabajador
  Future<void> _agregarTrabajador() async {
    if (!_validarCampos()) return;

    try {
      final url = Uri.parse(getApiUrl('trabajadores'));
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'numero_trabajador': _numeroTrabajadorController.text,
          'nombre_completo': _nombreCompletoController.text,
          'puesto': _puestoController.text,
          'rancho': _ranchoController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        _mostrarMensaje('Trabajador registrado correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui consultamos al trabajador
  Future<void> _consultarTrabajador() async {
    if (_numeroTrabajadorController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de trabajador para consultar');
      return;
    }

    try {
      final url = Uri.parse("${getApiUrl('trabajadores')}?numero_trabajador=${_numeroTrabajadorController.text}");
      final response = await http.get(url);

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final trabajador = responseData['data'];
        if (trabajador != null) {
          setState(() {
            _nombreCompletoController.text = trabajador['nombre_completo'] ?? '';
            _puestoController.text = trabajador['puesto'] ?? '';
            _ranchoController.text = trabajador['rancho'] ?? '';
            _selectedFinca = trabajador['rancho'] ?? '';
          });
          _mostrarMensaje('Trabajador encontrado');
        } else {
          _mostrarMensaje('No se encontró el trabajador');
        }
      } else {
        _mostrarMensaje(responseData['message'] ?? 'Error al consultar');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui modificamos al trabajador
  Future<void> _modificarTrabajador() async {
    if (_numeroTrabajadorController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de trabajador para modificar');
      return;
    }

    try {
      final url = Uri.parse(getApiUrl('trabajadores'));
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode({
          'numero_trabajador': _numeroTrabajadorController.text,
          'nombre_completo': _nombreCompletoController.text,
          'puesto': _puestoController.text,
          'rancho': _ranchoController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        _mostrarMensaje('Trabajador modificado correctamente');
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui eliminamos al trabajador
  Future<void> _eliminarTrabajador() async {
    if (_numeroTrabajadorController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de trabajador para eliminar');
      return;
    }

    // Aqui mostramos un mensaje de confirmacion de aliminacion
    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar trabajador?'),
        content: Text(
          '¿Eliminar al trabajador ${_nombreCompletoController.text}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final url = Uri.parse(getApiUrl('trabajadores'));
      final response = await http.delete(
        url,
        headers: _headers,
        body: json.encode({
          'numero_trabajador': _numeroTrabajadorController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        _mostrarMensaje('Trabajador eliminado correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui vemos la lista en formato de tabla
  void _verLista() {
    _cargarTrabajadores().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE TRABAJADORES'),
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
                  // Aqui ponemos los encabezados de la tabla
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
                            'N° TRABAJADOR',
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
                            'NOMBRE COMPLETO',
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
                            'PUESTO',
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
                            'RANCHO',
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

                  // Aqui ponemos el contenido de la tabla
                  Expanded(
                    child: _trabajadores.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de trabajadores',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _trabajadores.length,
                            itemBuilder: (context, index) {
                              final trabajador = _trabajadores[index];
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
                                    // Aqui ponemos el N° Trabajador
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        trabajador['numero_trabajador']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos el Nombre Completo
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        trabajador['nombre_completo']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos el Puesto
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        trabajador['puesto']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos el Rancho
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        trabajador['rancho']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
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

  // Aqui limpiamos los campos
  void _limpiarCampos() {
    setState(() {
      _numeroTrabajadorController.clear();
      _nombreCompletoController.clear();
      _puestoController.clear();
      _ranchoController.clear();
      _selectedFinca = null;
    });
  }

  // Aqui validamos los campos
  bool _validarCampos() {
    if (_numeroTrabajadorController.text.isEmpty ||
        _nombreCompletoController.text.isEmpty ||
        _puestoController.text.isEmpty ||
        _ranchoController.text.isEmpty) {
      _mostrarMensaje('Por favor, complete todos los campos obligatorios');
      return false;
    }
    return true;
  }

  // Aqui mostramos los mensajes
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
    // Aqui limpiamos los controladores
    _numeroTrabajadorController.dispose();
    _nombreCompletoController.dispose();
    _puestoController.dispose();
    _ranchoController.dispose();
    super.dispose();
  }
}