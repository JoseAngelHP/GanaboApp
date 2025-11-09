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

class MedicamentosPage extends StatefulWidget {
  const MedicamentosPage({Key? key}) : super(key: key);

  @override
  _MedicamentosPageState createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  // Aqui agregamos los controladores para los textfields
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _nombreMedicamentoController = TextEditingController();
  final TextEditingController _tipoMedicamentoController = TextEditingController();
  final TextEditingController _presentacionController = TextEditingController();
  final TextEditingController _indicacionesController = TextEditingController();

  // Aqui agregamos la lista de los dropdown del tipo de medicamento y su presentacion
  final List<String> _tiposMedicamento = [
    'Antibiótico',
    'Vacuna',
    'Desparasitante',
    'Vitaminas',
    'Antiinflamatorio',
    'Hormonal',
    'Otro'
  ];

  final List<String> _presentaciones = [
    'Inyectable',
    'Oral',
    'Tabletas',
    'Polvo',
    'Pomada',
    'Spray',
    'Otro'
  ];

  // Aqui almacenamos la lista del medicamento
  List<dynamic> _medicamentos = [];

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Aqui agregamos la funcion para cargar los medicamentos desde la api
  Future<void> _cargarMedicamentos() async {
    try {
      final url = Uri.parse(getApiUrl('medicamentos'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _medicamentos = responseData['data'] ?? [];
          });
        } else {
          _mostrarMensaje('Error al cargar los medicamentos');
        }
      } else {
        _mostrarMensaje('Error al cargar los medicamentos');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    appBar: AppBar(
      title: const Text("Medicamentos"),
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
              "MEDICAMENTOS",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Aqui agregamos el campo del número de medicamento
            TextField(
              controller: _numeroAreteController,
              decoration: InputDecoration(
                labelText: 'Número de medicamento',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // Aqui agregamos el campo del nombre del medicamento
            TextField(
              controller: _nombreMedicamentoController,
              decoration: InputDecoration(
                labelText: 'Nombre del medicamento',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // Aqui agregamos el campo del tipo de medicamento 
            DropdownButtonFormField<String>(
              value: _tipoMedicamentoController.text.isEmpty ? null : _tipoMedicamentoController.text,
              decoration: InputDecoration(
                labelText: 'Tipo de medicamento',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _tiposMedicamento.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _tipoMedicamentoController.text = newValue ?? '';
                });
              },
            ),
            const SizedBox(height: 15),
            
            // Aqui agregamos el campo de la presentación 
            DropdownButtonFormField<String>(
              value: _presentacionController.text.isEmpty ? null : _presentacionController.text,
              decoration: InputDecoration(
                labelText: 'Presentación',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _presentaciones.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _presentacionController.text = newValue ?? '';
                });
              },
            ),
            const SizedBox(height: 15),

            // Aqui agregamos el campo de las indicaciones 
            TextField(
              controller: _indicacionesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Indicaciones (Opcional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
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
          onPressed: _agregarMedicamento,
          child: Text("Agregar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _consultarMedicamento,
          child: Text("Consultar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _modificarMedicamento,
          child: Text("Modificar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _eliminarMedicamento,
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
  // Aqui agregamos la funcion para agregar los medicamentos
  Future<void> _agregarMedicamento() async {
    if (!_validarCampos()) return;

    try {
      final url = Uri.parse(getApiUrl('medicamentos'));
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'nombre_medicamento': _nombreMedicamentoController.text,
          'tipo_medicamento': _tipoMedicamentoController.text,
          'presentacion': _presentacionController.text,
          'indicaciones': _indicacionesController.text.isNotEmpty ? _indicacionesController.text : null,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        _mostrarMensaje('Medicamento registrado correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui agregamos la funcion para consultar los medicamentos
  Future<void> _consultarMedicamento() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    try {
      final url = Uri.parse("${getApiUrl('medicamentos')}?numero_arete=${_numeroAreteController.text}");
      final response = await http.get(url);

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final medicamento = responseData['data'];
        if (medicamento != null) {
          setState(() {
            _nombreMedicamentoController.text = medicamento['nombre_medicamento'] ?? '';
            _tipoMedicamentoController.text = medicamento['tipo_medicamento'] ?? '';
            _presentacionController.text = medicamento['presentacion'] ?? '';
            _indicacionesController.text = medicamento['indicaciones'] ?? '';
          });
          _mostrarMensaje('Medicamento encontrado');
        } else {
          _mostrarMensaje('No se encontró el medicamento');
        }
      } else {
        _mostrarMensaje(responseData['message'] ?? 'Error al consultar');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui agregamos la funcion para modificar los medicamentos
  Future<void> _modificarMedicamento() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para modificar');
      return;
    }

    try {
      final url = Uri.parse(getApiUrl('medicamentos'));
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'nombre_medicamento': _nombreMedicamentoController.text,
          'tipo_medicamento': _tipoMedicamentoController.text,
          'presentacion': _presentacionController.text,
          'indicaciones': _indicacionesController.text.isNotEmpty ? _indicacionesController.text : null,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        _mostrarMensaje('Medicamento modificado correctamente');
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui agregamos la funcion para eliminar los medicamentos
  Future<void> _eliminarMedicamento() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para eliminar');
      return;
    }

    // Aqui mostramos un mensaje de confirmacion de la eliminacion
    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar medicamento?'),
        content: Text(
          '¿Eliminar el medicamento del arete ${_numeroAreteController.text}?',
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
      final url = Uri.parse(getApiUrl('medicamentos'));
      final response = await http.delete(
        url,
        headers: _headers,
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        _mostrarMensaje('Medicamento eliminado correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui agregamos la funcion para ver la lista en una tabla
  void _verLista() {
    _cargarMedicamentos().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE MEDICAMENTOS'),
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
                            'N° MEDICAMENTO',
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
                            'MEDICAMENTO',
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
                            'TIPO',
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
                            'PRESENTACIÓN',
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
                            'INDICACIONES',
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
                    child: _medicamentos.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de medicamentos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _medicamentos.length,
                            itemBuilder: (context, index) {
                              final medicamento = _medicamentos[index];
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
                                    // Aqui ponemos el N° Arete
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        medicamento['numero_arete']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos el Nombre  del Medicamento
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        medicamento['nombre_medicamento']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos el Tipo de Medicamento
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        medicamento['tipo_medicamento']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos la presentación
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        medicamento['presentacion']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos las indicaciones
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        medicamento['indicaciones']?.toString() ?? 'N/A',
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

  // Aqui ponemos la funcion para limpiar los campos
  void _limpiarCampos() {
    setState(() {
      _numeroAreteController.clear();
      _nombreMedicamentoController.clear();
      _tipoMedicamentoController.clear();
      _presentacionController.clear();
      _indicacionesController.clear();
    });
  }

  // Aqui ponemos la funcion paa validar los campos
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _nombreMedicamentoController.text.isEmpty ||
        _tipoMedicamentoController.text.isEmpty ||
        _presentacionController.text.isEmpty) {
      _mostrarMensaje('Por favor, complete todos los campos obligatorios');
      return false;
    }
    return true;
  }

  // Aqui ponemos la funcion para mostrar los mensajes
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
    _numeroAreteController.dispose();
    _nombreMedicamentoController.dispose();
    _tipoMedicamentoController.dispose();
    _presentacionController.dispose();
    _indicacionesController.dispose();
    super.dispose();
  }
}