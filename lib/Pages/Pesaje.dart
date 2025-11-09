import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'pdf_service.dart';

String getApiUrl(String endpoint) {
  if (kIsWeb) {
    return 'https://ganabovino.atwebpages.com/api/$endpoint.php';
  } else {
    return 'http://ganabovino.atwebpages.com/api/$endpoint.php';
  }
}

class PesajePage extends StatefulWidget {
  const PesajePage({Key? key}) : super(key: key);

  @override
  State<PesajePage> createState() => _PesajePageState();
}

class _PesajePageState extends State<PesajePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _areteController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  String? _selectedRancho;
  String? _selectedTrabajador;

  bool _guardando = false;
  bool _buscando = false;

  List<String> _ranchos = [];
  List<String> _trabajadores = [];

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  void initState() {
    super.initState();
    _cargarRanchos();
    _cargarTrabajadores();
  }

  // Aqui cargamos los ranchos desde nuestra tabla origen
  Future<void> _cargarRanchos() async {
    try {
      final url = Uri.parse(getApiUrl('origen'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> origenes = responseData['data'] ?? [];
          final nombresFincas = origenes
              .map<String>((origen) => origen['nombre_finca']?.toString() ?? '')
              .where((nombre) => nombre.isNotEmpty)
              .toSet() 
              .toList();
          
          nombresFincas.sort();
          
          setState(() {
            _ranchos = nombresFincas;
          });
        }
      }
    } catch (e) {
      print('Error al cargar ranchos: $e');
    }
  }

  // Aqui cargamos a los trabajadores desde la tabla trabajadores
  Future<void> _cargarTrabajadores() async {
    try {
      final url = Uri.parse(getApiUrl('trabajadores'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> trabajadoresData = responseData['data'] ?? [];
          final nombresTrabajadores = trabajadoresData
              .map<String>((trabajador) => trabajador['nombre_completo']?.toString() ?? '')
              .where((nombre) => nombre.isNotEmpty)
              .toList();
          
          nombresTrabajadores.sort();
          
          setState(() {
            _trabajadores = nombresTrabajadores;
          });
        }
      }
    } catch (e) {
      print('Error al cargar trabajadores: $e');
    }
  }

  // Aqui guardamos el nuevo pesaje
  Future<Map<String, dynamic>> _guardarPesajeAPI(Map<String, dynamic> pesajeData) async {
    try {
      final url = Uri.parse(getApiUrl('pesaje'));
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(pesajeData),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Aqui obtenemos el pesaje por numero de arete
  Future<Map<String, dynamic>?> _obtenerUltimoPesajePorArete(String numeroArete) async {
    try {
      final url = Uri.parse("${getApiUrl('pesaje')}?numero_arete=$numeroArete");
      final response = await http.get(url, headers: _headers);
      final responseData = json.decode(response.body);

      if (responseData['success'] == true && responseData['data'] is List) {
        final List<dynamic> pesajes = responseData['data'];
        if (pesajes.isNotEmpty) {
          return pesajes.first;
        }
      }
      return null;
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
                
                // Aqui ponemos el Número de arete
                TextFormField(
                  controller: _areteController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Número de arete",
                  ),
                ),
                const SizedBox(height: 20),

                // Aqui ponemos la Fecha de pesaje
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                
                // Aqui ponemos el Peso
                TextFormField(
                  controller: _pesoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Peso",
                  ),
                ),
                const SizedBox(height: 20),

                // Aqui ponemos el Rancho
                DropdownButtonFormField<String>(
                  value: _selectedRancho,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Rancho',
                  ),
                  items: _ranchos.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRancho = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un rancho';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Aqui ponemos a el Trabajador
                DropdownButtonFormField<String>(
                  value: _selectedTrabajador,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Persona a cargo',
                  ),
                  items: _trabajadores.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTrabajador = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un trabajador';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Aqui ponemos las Observaciones
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Observaciones",
                  ),
                ),
                const SizedBox(height: 30),

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

  Future<void> _guardarPesaje() async {
    if (_formKey.currentState!.validate()) {
      if (_areteController.text.isEmpty ||
          _pesoController.text.isEmpty ||
          _selectedRancho == null ||
          _selectedTrabajador == null ||
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
          'ubicacion_direccion': _selectedRancho!, 
          'persona_cargo': _selectedTrabajador!, 
          'observaciones': _observacionesController.text.isEmpty
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
      final ultimoPesaje = await _obtenerUltimoPesajePorArete(_areteController.text);
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

  // Aqui mostramos los datos en los campos
  void _mostrarPesajeEnCampos(Map<String, dynamic> pesaje) {
    setState(() {
      // Aqui mostramos el Peso
      if (pesaje['peso'] != null) {
        _pesoController.text = pesaje['peso'].toString();
      } else {
        _pesoController.text = '';
      }

      // Aqui mostramos la Fecha
      if (pesaje['fecha_pesaje'] != null) {
        _fechaController.text = _formatearFechaDesdeBD(pesaje['fecha_pesaje']);
      } else {
        _fechaController.text = '';
      }

      // Aqui mostramos el Rancho
      _selectedRancho = pesaje['ubicacion_direccion']?.toString();

      // Aqui mostramos al Trabajador 
      _selectedTrabajador = pesaje['persona_cargo']?.toString();

      // Aqui mostramos las Observaciones
      _observacionesController.text = pesaje['observaciones']?.toString() ?? '';
    });
  }

  // Agregamos el método para convertir la fecha
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

  // Aqui modificamos el pesaje
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
        'ubicacion_direccion': _selectedRancho,
        'persona_cargo': _selectedTrabajador,
        'observaciones': _observacionesController.text,
      };

      // Buscamos el pesaje con ese arete
      final pesajes = await _obtenerTodosPesajesPorArete(_areteController.text);
      if (pesajes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró pesaje para modificar')),
        );
        return;
      }

      final ultimoPesaje = pesajes.first;
      final id = ultimoPesaje['id'];

      // Llamamos a la api para modificar
      final url = Uri.parse("${getApiUrl('pesaje')}?id=$id");
      final response = await http.put(
        url,
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

  // Aqui eliminamos el pesaje
  Future<void> _eliminarPesaje() async {
    if (_areteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrese un número de arete para eliminar')),
      );
      return;
    }

    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
      // Buscamos el pesaje con ese arete
      final pesajes = await _obtenerTodosPesajesPorArete(_areteController.text);
      if (pesajes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró pesaje para eliminar')),
        );
        return;
      }

      final ultimoPesaje = pesajes.first;
      final id = ultimoPesaje['id'];

      // Llamamos a la api para eliminar
      final url = Uri.parse("${getApiUrl('pesaje')}?id=$id");
      final response = await http.delete(url, headers: _headers);

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

  Future<List<dynamic>> _obtenerTodosPesajesPorArete(String numeroArete) async {
    try {
      final url = Uri.parse("${getApiUrl('pesaje')}?numero_arete=$numeroArete");
      final response = await http.get(url, headers: _headers);
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) return responseData['data'];
      return [];
    } catch (e) {
      return [];
    }
  }

  // Aqui obtenemos todos los pesajes
  Future<List<dynamic>> _obtenerTodosPesajes() async {
    try {
      final url = Uri.parse(getApiUrl('pesaje'));
      final response = await http.get(url, headers: _headers);
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
        _generarPdf();
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
      _observacionesController.clear();
      _fechaController.clear();
      _selectedRancho = null;
      _selectedTrabajador = null;
    });
  }

  @override
  void dispose() {
    _areteController.dispose();
    _pesoController.dispose();
    _observacionesController.dispose();
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
            // Aqui ponemos los encabezados de la tabla
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
                      'RANCHO', 
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
                      'TRABAJADOR', 
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

            // Aqui ponemos el contenido de la tabla
            Expanded(
              child: pesajes.isEmpty
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
                            color: index.isEven ? Colors.grey[50] : Colors.white,
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
                              //Aqui ponemos el N° Arete
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
                              // Aqui ponemos la Fecha
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
                              // Aqui ponemos el Peso
                              Expanded(
                                flex: 2,
                                child: Text(
                                  pesaje['peso']?.toString() ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              // Aqui ponemos el Rancho
                              Expanded(
                                flex: 3,
                                child: Text(
                                  pesaje['ubicacion_direccion']?.toString() ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Aqui ponemos el Trabajador 
                              Expanded(
                                flex: 2,
                                child: Text(
                                  pesaje['persona_cargo']?.toString() ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Aqui ponemos las Observaciones
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