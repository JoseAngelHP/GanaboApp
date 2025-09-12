import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pdf_service.dart';

class PesajePage extends StatefulWidget {
  const PesajePage({Key? key}) : super(key: key);

  @override
  State<PesajePage> createState() => _PesajePageState();
}

class _PesajePageState extends State<PesajePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _areteController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _personaController = TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  bool _guardando = false;
  bool _buscando = false;

  // Servicio de API
  static const String _baseUrl = 'http://192.168.1.43/api/pesaje.php';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Guardar nuevo pesaje
  Future<Map<String, dynamic>> _guardarPesajeAPI(
    Map<String, dynamic> pesajeData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: json.encode(pesajeData),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener el ÚLTIMO pesaje por número de arete
  Future<Map<String, dynamic>?> _obtenerUltimoPesajePorArete(
    String numeroArete,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?numero_arete=$numeroArete'),
        headers: _headers,
      );
      final responseData = json.decode(response.body);

      print('Respuesta de la API: $responseData'); // Debug

      if (responseData['success'] == true && responseData['data'] is List) {
        final List<dynamic> pesajes = responseData['data'];

        print('Pesajes encontrados: ${pesajes.length}'); // Debug

        // Si hay pesajes, devolver el primero (asumiendo que la API ya los devuelve ordenados)
        if (pesajes.isNotEmpty) {
          return pesajes.first;
        }
      }
      return null; // No se encontraron pesajes
    } catch (e) {
      print('Error al obtener pesaje: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: const Text("Pesaje"),
        backgroundColor: Colors.yellow[100],
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "PESAJE",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _areteController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Número de arete",
                  ),
                ),
                const SizedBox(height: 20),

                // Fecha de pesaje
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Fecha de pesaje",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _seleccionarFecha(context),
                    ),
                  ),
                  onTap: () => _seleccionarFecha(context),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pesoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Peso",
                  ),
                ),
                const SizedBox(height: 20),

                // Ubicación
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _personaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Persona a cargo",
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Observaciones",
                  ),
                ),
                const SizedBox(height: 30),

                // Botones de acción
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionButton("Agregar", Colors.green, !_guardando),
                    _buildActionButton("Consultar", Colors.blue, !_buscando),
                    _buildActionButton("Modificar", Colors.orange, true),
                    _buildActionButton("Eliminar", Colors.red, true),
                    _buildActionButton("Limpiar", Colors.grey, true),
                    _buildActionButton("Ver Lista", Colors.purple, true),
                    _buildActionButton("PDF", Colors.redAccent, true),
                  ],
                ),

                // Indicadores de carga
                if (_guardando)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Guardando en la base de datos...'),
                      ],
                    ),
                  ),

                if (_buscando)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Buscando pesajes...'),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, bool habilitado) {
    return ElevatedButton(
      onPressed: habilitado ? () => _accionBoton(text.toLowerCase()) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }

  void _seleccionarFecha(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((fechaSeleccionada) {
      if (fechaSeleccionada != null) {
        setState(() {
          _fechaController.text =
              "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}";
        });
      }
    });
  }

  void _seleccionarUbicacion(BuildContext context) {
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      labelText: "Longitud",
                      hintText: "Ej: -99.1332080",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        () => _obtenerDireccionDesdeCoordenadas(
                          double.tryParse(latController.text),
                          double.tryParse(lngController.text),
                          context,
                        ),
                    child: Text("Obtener Dirección"),
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
                child: Text("Cancelar"),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ingresa coordenadas válidas')));
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
              "Coordenadas: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _ubicacionController.text =
            "Coordenadas: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
      });
    }
  }

  String _formatearDireccion(Placemark placemark) {
    final parts =
        [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.administrativeArea,
          placemark.postalCode,
          placemark.country,
        ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.isNotEmpty ? parts.join(', ') : 'Ubicación no disponible';
  }

  Future<void> _guardarPesaje() async {
    if (_formKey.currentState!.validate()) {
      if (_areteController.text.isEmpty ||
          _pesoController.text.isEmpty ||
          _personaController.text.isEmpty ||
          _fechaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complete todos los campos obligatorios')),
        );
        return;
      }

      setState(() => _guardando = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text('Guardando pesaje...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      try {
        final pesajeData = {
          'numero_arete': _areteController.text,
          'fecha_pesaje': _formatearFechaParaBD(_fechaController.text),
          'peso': double.parse(_pesoController.text),
          'ubicacion_direccion':
              _ubicacionController.text.isNotEmpty
                  ? _ubicacionController.text
                  : 'Ubicación no especificada',
          'persona_cargo': _personaController.text,
          'observaciones':
              _observacionesController.text.isEmpty
                  ? null
                  : _observacionesController.text,
        };

        final resultado = await _guardarPesajeAPI(pesajeData);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (resultado['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pesaje guardado correctamente')),
          );
          _limpiarCampos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: ${resultado['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error al guardar: $e')));
      } finally {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _buscarPorArete() async {
    if (_areteController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ingrese un número de arete')));
      return;
    }

    print('Buscando arete: ${_areteController.text}'); // Debug

    setState(() => _buscando = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text('Buscando último pesaje...'),
          ],
        ),
      ),
    );

    try {
      final ultimoPesaje = await _obtenerUltimoPesajePorArete(
        _areteController.text,
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (ultimoPesaje == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se encontraron pesajes para el arete ${_areteController.text}',
            ),
          ),
        );
      } else {
        // Mostrar el último pesaje en los campos
        _mostrarPesajeEnCampos(ultimoPesaje);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Pesaje encontrado')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al buscar: $e')));
    } finally {
      setState(() => _buscando = false);
    }
  }

  // Método para mostrar los datos en los campos
  void _mostrarPesajeEnCampos(Map<String, dynamic> pesaje) {
    setState(() {
      // Peso
      if (pesaje['peso'] != null) {
        _pesoController.text = pesaje['peso'].toString();
      } else {
        _pesoController.text = '';
      }

      // Fecha
      if (pesaje['fecha_pesaje'] != null) {
        _fechaController.text = _formatearFechaDesdeBD(pesaje['fecha_pesaje']);
      } else {
        _fechaController.text = '';
      }

      // Persona a cargo
      _personaController.text = pesaje['persona_cargo']?.toString() ?? '';

      // Ubicación
      _ubicacionController.text =
          pesaje['ubicacion_direccion']?.toString() ?? '';

      // Observaciones
      _observacionesController.text = pesaje['observaciones']?.toString() ?? '';
    });
  }

  // Método para formatear fecha desde BD a formato visual
  String _formatearFechaDesdeBD(String fechaBD) {
    try {
      if (fechaBD.contains(' ')) {
        final parts = fechaBD.split(' ')[0].split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      } else {
        final parts = fechaBD.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      }
      return fechaBD;
    } catch (e) {
      return fechaBD;
    }
  }

  String _formatearFechaParaBD(String fecha) {
    final parts = fecha.split('/');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    }
    return DateTime.now().toIso8601String();
  }

  // Modificar pesaje (versión simple)
  Future<void> _modificarPesaje() async {
    if (_areteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrese un número de arete para modificar')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final pesajeData = {
        'numero_arete': _areteController.text,
        'fecha_pesaje': _formatearFechaParaBD(_fechaController.text),
        'peso': double.parse(_pesoController.text),
        'ubicacion_direccion': _ubicacionController.text,
        'persona_cargo': _personaController.text,
        'observaciones': _observacionesController.text,
      };

      // Buscar el ID del último pesaje de este arete
      final pesajes = await _obtenerTodosPesajesPorArete(_areteController.text);
      if (pesajes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró pesaje para modificar')),
        );
        return;
      }

      final ultimoPesaje = pesajes.first;
      final id = ultimoPesaje['id'];

      // Llamar a la API para modificar
      final response = await http.put(
        Uri.parse('$_baseUrl?id=$id'),
        headers: _headers,
        body: json.encode(pesajeData),
      );

      final resultado = json.decode(response.body);

      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesaje modificado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${resultado['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error al modificar: $e')));
    } finally {
      setState(() => _guardando = false);
    }
  }

  // Eliminar pesaje (versión simple)
  Future<void> _eliminarPesaje() async {
    if (_areteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrese un número de arete para eliminar')),
      );
      return;
    }

    // Confirmación simple
    final confirmar = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('¿Eliminar pesaje?'),
            content: Text(
              '¿Eliminar el último pesaje del arete ${_areteController.text}?',
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

    setState(() => _guardando = true);

    try {
      // Buscar el ID del último pesaje de este arete
      final pesajes = await _obtenerTodosPesajesPorArete(_areteController.text);
      if (pesajes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró pesaje para eliminar')),
        );
        return;
      }

      final ultimoPesaje = pesajes.first;
      final id = ultimoPesaje['id'];

      // Llamar a la API para eliminar
      final response = await http.delete(
        Uri.parse('$_baseUrl?id=$id'),
        headers: _headers,
      );

      final resultado = json.decode(response.body);

      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pesaje eliminado correctamente')),
        );
        _limpiarCampos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${resultado['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error al eliminar: $e')));
    } finally {
      setState(() => _guardando = false);
    }
  }

  // Función auxiliar para obtener todos los pesajes de un arete
  Future<List<dynamic>> _obtenerTodosPesajesPorArete(String numeroArete) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?numero_arete=$numeroArete'),
        headers: _headers,
      );
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) return responseData['data'];
      return [];
    } catch (e) {
      return [];
    }
  }

  // Función para obtener todos los pesajes
  Future<List<dynamic>> _obtenerTodosPesajes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) return responseData['data'];
      return [];
    } catch (e) {
      print('Error al obtener todos los pesajes: $e');
      return [];
    }
  }

  Future<void> _verListaComoTabla() async {
    setState(() => _buscando = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text('Cargando todos los pesajes...'),
          ],
        ),
      ),
    );

    try {
      final todosPesajes = await _obtenerTodosPesajes();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (todosPesajes.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No hay pesajes registrados')));
      } else {
        // Navegar a la nueva pantalla con la tabla completa
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TablaPesajesScreen(pesajes: todosPesajes),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar la lista: $e')));
    } finally {
      setState(() => _buscando = false);
    }
  }

  void _accionBoton(String accion) {
    switch (accion) {
      case 'agregar':
        _guardarPesaje();
        break;
      case 'consultar':
        _buscarPorArete();
        break;
      case 'modificar':
        _modificarPesaje();
        break;
      case 'eliminar':
        _eliminarPesaje();
        break;
      case 'limpiar':
        _limpiarCampos();
        break;
      case 'ver lista':
        _verListaComoTabla();
        break;
      case 'pdf':
        _generarPdf(); // Nuevo método para PDF
        break;
    }
  }

  Future<void> _generarPdf() async {
    setState(() => _buscando = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text('Generando PDF...'),
          ],
        ),
      ),
    );

    try {
      final todosPesajes = await _obtenerTodosPesajes();

      if (todosPesajes.isEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No hay pesajes para generar PDF')),
        );
      } else {
        final pdfService = PdfService();
        final fecha = DateTime.now()
            .toString()
            .replaceAll(' ', '_')
            .replaceAll(':', '-');
        final fileName = 'pesajes_$fecha';

        // Guardar y abrir PDF
        await pdfService.guardarYAbrirPdf(todosPesajes, fileName);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF guardado exitosamente')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    } finally {
      setState(() => _buscando = false);
    }
  }

  void _limpiarCampos() {
    setState(() {
      _areteController.clear();
      _pesoController.clear();
      _personaController.clear();
      _observacionesController.clear();
      _ubicacionController.clear();
      _fechaController.clear();
    });
  }

  @override
  void dispose() {
    _areteController.dispose();
    _pesoController.dispose();
    _personaController.dispose();
    _observacionesController.dispose();
    _ubicacionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}

class TablaPesajesScreen extends StatelessWidget {
  final List<dynamic> pesajes;

  const TablaPesajesScreen({Key? key, required this.pesajes}) : super(key: key);

  String _formatearFechaDesdeBD(String fechaBD) {
    try {
      if (fechaBD.contains(' ')) {
        final parts = fechaBD.split(' ')[0].split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      } else {
        final parts = fechaBD.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      }
      return fechaBD;
    } catch (e) {
      return fechaBD;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LISTA COMPLETA DE PESAJES'),
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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'N° ARETE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'FECHA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
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
                        fontSize: 14,
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
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'PERSONA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'OBSERVACIONES',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
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
              child:
                  pesajes.isEmpty
                      ? Center(
                        child: Text(
                          'No hay pesajes registrados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: pesajes.length,
                        itemBuilder: (context, index) {
                          final pesaje = pesajes[index];
                          return Container(
                            decoration: BoxDecoration(
                              color:
                                  index.isEven ? Colors.grey[50] : Colors.white,
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 10,
                            ),
                            child: Row(
                              children: [
                                // N° Arete
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    pesaje['numero_arete']?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                // Fecha
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatearFechaDesdeBD(
                                      pesaje['fecha_pesaje']?.toString() ?? '',
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                // Peso
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    pesaje['peso']?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                // Ubicación
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    pesaje['ubicacion_direccion']?.toString() ??
                                        '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Persona
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    pesaje['persona_cargo']?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Observaciones
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    pesaje['observaciones']?.toString() ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
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
    );
  }
}
