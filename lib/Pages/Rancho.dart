import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

String getApiUrl(String endpoint) {
  if (kIsWeb) {
    return 'https://ganabovino.atwebpages.com/api/$endpoint.php';
  } else {
    return 'http://ganabovino.atwebpages.com/api/$endpoint.php';
  }
}

class RanchoPage extends StatefulWidget {
  const RanchoPage({Key? key}) : super(key: key);

  @override
  _RanchoPageState createState() => _RanchoPageState();
}

class _RanchoPageState extends State<RanchoPage> {
  // Aqui agregamos los controladores para los textfields
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _nombreDuenoController = TextEditingController();
  final TextEditingController _nombreFincaController = TextEditingController();
  final TextEditingController _extensionController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();

  List<dynamic> _origenes = [];

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Aqui cargamos el origen de rancho desde la api
  Future<void> _cargarOrigenes() async {
    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _origenes = responseData['data'] ?? [];
          });
        } else {
          _mostrarMensaje('Error al cargar los orígenes');
        }
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
      title: const Text("Ranchos"),
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
              "RANCHOS",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Aqui agregamos el campo de Número de arete
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
            
            // Aqui agregamos el campo del Nombre del propietario
            TextField(
              controller: _nombreDuenoController,
              decoration: InputDecoration(
                labelText: 'Nombre del propietario',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            
            // Aqui agregamos el campo del Nombre del rancho
            TextField(
              controller: _nombreFincaController,
              decoration: InputDecoration(
                labelText: 'Nombre del rancho',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Aqui agregamos el campo de la Extensión de hectáreas
            TextField(
              controller: _extensionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Extensión (hectáreas)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Aqui agregamos el campo de la Ubicación
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ubicación:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _seleccionarUbicacion(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              label: Text(
                _ubicacionController.text.isEmpty
                    ? "Seleccionar ubicación"
                    : _ubicacionController.text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  overflow: TextOverflow.ellipsis,
                ),
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

  // Aqui agregamos los datos referentes a la ubicacion

  void _seleccionarUbicacion(BuildContext context) {
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ingresar coordenadas"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              TextField(
                controller: latController,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Latitud",
                  hintText: "Ej: 19.4326077",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: lngController,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Longitud',
                  hintText: 'Ej: -99.1332080',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _obtenerDireccionDesdeCoordenadas(
                  double.tryParse(latController.text),
                  double.tryParse(lngController.text),
                  context,
                ),
                child: Text('Obtener Dirección'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _obtenerDireccionDesdeCoordenadas(
    double? lat,
    double? lng,
    BuildContext context,
  ) async {
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingresa coordenadas válidas'))
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text('Obteniendo dirección...'),
          ],
        ),
      ),
    );

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final direccion = _formatearDireccion(placemark);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pop(context);

        setState(() {
          _ubicacionController.text = direccion;
        });
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        setState(() {
          _ubicacionController.text =
              'Coordenadas: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _ubicacionController.text =
            'Coordenadas: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
      });
    }
  }

  String _formatearDireccion(Placemark placemark) {
    final parts = [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.postalCode,
      placemark.country,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join(', ') : 'Ubicación no disponible';
  }

  // Aqui ponemos la funcion para agregar el origen
  Future<void> _agregarOrigen() async {
    if (!_validarCampos()) return;

    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'nombre_dueno': _nombreDuenoController.text,
          'nombre_finca': _nombreFincaController.text,
          'ext_hecta': _extensionController.text.isNotEmpty 
              ? double.parse(_extensionController.text) 
              : null,
          'ubicacion_direccion': _ubicacionController.text.isNotEmpty
              ? _ubicacionController.text
              : 'Ubicación no especificada',
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        _mostrarMensaje('Rancho agregado correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui ponemos la funcion para consultar el origen
  Future<void> _consultarOrigen() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    try {
      final url = Uri.parse("${getApiUrl('origen')}?numero_arete=${_numeroAreteController.text}");
      final response = await http.get(url);

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final origen = responseData['data'];
        if (origen != null) {
          setState(() {
            _nombreDuenoController.text = origen['nombre_dueno'] ?? '';
            _nombreFincaController.text = origen['nombre_finca'] ?? '';
            _extensionController.text = origen['ext_hecta']?.toString() ?? '';
            _ubicacionController.text = origen['ubicacion_direccion'] ?? '';
          });
          _mostrarMensaje('Rancho encontrado');
        } else {
          _mostrarMensaje('No se encontró el rancho');
        }
      } else {
        _mostrarMensaje(responseData['message'] ?? 'Error al consultar');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui ponemos la funcion para modificar el origen
  Future<void> _modificarOrigen() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para modificar');
      return;
    }

    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'nombre_dueno': _nombreDuenoController.text,
          'nombre_finca': _nombreFincaController.text,
          'ext_hecta': _extensionController.text.isNotEmpty 
              ? double.parse(_extensionController.text) 
              : null,
          'ubicacion_direccion': _ubicacionController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        _mostrarMensaje('Rancho modificado correctamente');
      } else {
        _mostrarMensaje('Error: ${responseData['message']}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // Aqui ponemos la funcion para eliminar el origen
  Future<void> _eliminarOrigen() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para eliminar');
      return;
    }

    // Confirmación de eliminación
    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar rancho?'),
        content: Text(
          '¿Eliminar el rancho ${_numeroAreteController.text}?',
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
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.delete(
        url,
        headers: _headers,
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        _mostrarMensaje('Rancho eliminado correctamente');
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
    _cargarOrigenes().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE RANCHOS'),
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
                            'NOMBRE DEL PROPIETARIO',
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
                            'NOMBRE DEL RANCHO',
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
                            'EXTENSIÓN',
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
                            'UBICACIÓN',
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
                    child: _origenes.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de ranchos',
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
                                    // Aqui ponemos el N° Arete
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
                                    // Aqui ponemos el Nombre del Dueño
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        origen['nombre_dueno']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos el Nombre de la Finca
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        origen['nombre_finca']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos la Extensión
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        origen['ext_hecta']?.toString() ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aqui ponemos la Ubicación
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        origen['ubicacion_direccion']?.toString() ?? 'N/A',
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
      _numeroAreteController.clear();
      _nombreDuenoController.clear();
      _nombreFincaController.clear();
      _extensionController.clear();
      _ubicacionController.clear();
    });
  }

  // Aqui validamos los campos
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _nombreDuenoController.text.isEmpty ||
        _nombreFincaController.text.isEmpty ) {
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
    _numeroAreteController.dispose();
    _nombreDuenoController.dispose();
    _nombreFincaController.dispose();
    _extensionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}