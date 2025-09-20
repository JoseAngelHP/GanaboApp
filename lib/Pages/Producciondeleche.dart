import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Pdf_Serviced.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Función para obtener la URL de la API
String getApiUrl(String endpoint) {
  if (kIsWeb) {
    return 'https://ganabovino.atwebpages.com/api/$endpoint.php';
  } else {
    return 'http://ganabovino.atwebpages.com/api/$endpoint.php';
  }
}

class ProducciondelechePage extends StatefulWidget {
  const ProducciondelechePage({Key? key}) : super(key: key);

  @override
  _ProducciondelechePageState createState() => _ProducciondelechePageState();
}

class _ProducciondelechePageState extends State<ProducciondelechePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _calidadController = TextEditingController();
  final TextEditingController _personaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  List<Map<String, dynamic>> _producciones = [];
  bool _isLoading = false;
  String _fechaOriginal = ''; // ← NUEVA VARIABLE PARA GUARDAR LA FECHA ORIGINAL

  // Headers para las peticiones HTTP
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Función para mostrar mensajes
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Función para limpiar campos
  void _limpiarCampos() {
    _numeroAreteController.clear();
    _fechaController.clear();
    _cantidadController.clear();
    _calidadController.clear();
    _personaController.clear();
    _observacionesController.clear();
    _fechaOriginal = ''; // ← Limpiar también la fecha original
    _mostrarMensaje('Campos limpiados');
  }

  // Función para seleccionar fecha
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  // Función para validar campos obligatorios
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _fechaController.text.isEmpty ||
        _cantidadController.text.isEmpty ||
        _calidadController.text.isEmpty ||
        _personaController.text.isEmpty) {
      _mostrarMensaje('Por favor, complete todos los campos obligatorios');
      return false;
    }
    return true;
  }

  // AGREGAR - Crear nuevo registro
  Future<void> _agregarRegistro() async {
    if (!_validarCampos()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final registro = {
        'numero_arete': _numeroAreteController.text,
        'fecha_ordeño': _fechaController.text,
        'cantidad_leche': double.parse(_cantidadController.text),
        'calidad_leche': _calidadController.text,
        'persona_cargo': _personaController.text,
        'observaciones': _observacionesController.text.isNotEmpty 
            ? _observacionesController.text 
            : '',
      };

      final url = Uri.parse(getApiUrl('produccion'));
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(registro),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _mostrarMensaje('Registro agregado correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error al agregar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // CONSULTAR - Buscar por número de arete
  Future<void> _consultarRegistro() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse("${getApiUrl('produccion')}?numero_arete=${_numeroAreteController.text}");
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          // Ordenar por fecha y mostrar el último registro
          data.sort((a, b) => b['fecha_ordeño'].compareTo(a['fecha_ordeño']));
          final ultimoRegistro = data[0];
          
          // GUARDAR LA FECHA ORIGINAL ← NUEVO
          _fechaOriginal = ultimoRegistro['fecha_ordeño'] ?? '';
          
          _fechaController.text = ultimoRegistro['fecha_ordeño'] ?? '';
          _cantidadController.text = ultimoRegistro['cantidad_leche']?.toString() ?? '';
          _calidadController.text = ultimoRegistro['calidad_leche'] ?? '';
          _personaController.text = ultimoRegistro['persona_cargo'] ?? '';
          _observacionesController.text = ultimoRegistro['observaciones'] ?? '';
          
          _mostrarMensaje('Registro cargado correctamente');
        } else {
          _mostrarMensaje('No se encontraron registros');
        }
      } else {
        _mostrarMensaje('Error en la consulta: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // MODIFICAR - Actualizar registro (CORREGIDO)
  Future<void> _modificarRegistro() async {
    if (!_validarCampos()) return;

    // Verificar que se haya consultado primero un registro
    if (_fechaOriginal.isEmpty) {
      _mostrarMensaje('Primero consulte un registro para modificar');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registro = {
        'numero_arete': _numeroAreteController.text,
        'fecha_original': _fechaOriginal, // ← FECHA ORIGINAL (la que tenía cuando consultaste)
        'fecha_ordeño': _fechaController.text, // ← NUEVA FECHA (puede ser diferente)
        'cantidad_leche': double.parse(_cantidadController.text),
        'calidad_leche': _calidadController.text,
        'persona_cargo': _personaController.text,
        'observaciones': _observacionesController.text.isNotEmpty 
            ? _observacionesController.text 
            : '',
      };

      final url = Uri.parse(getApiUrl('produccion'));
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(registro),
      );

      if (response.statusCode == 200) {
        _mostrarMensaje('Registro modificado correctamente');
        // Actualizar la fecha original por si quieres modificar again
        _fechaOriginal = _fechaController.text;
      } else {
        _mostrarMensaje('Error al modificar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ELIMINAR - Borrar registro
  Future<void> _eliminarRegistro() async {
    if (_numeroAreteController.text.isEmpty || _fechaController.text.isEmpty) {
      _mostrarMensaje('Ingrese número de arete y fecha para eliminar');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Usar parámetros GET para mejor compatibilidad
      final numeroArete = Uri.encodeComponent(_numeroAreteController.text);
      final fecha = Uri.encodeComponent(_fechaController.text);
      final url = Uri.parse("${getApiUrl('produccion')}?numero_arete=$numeroArete&fecha_ordeño=$fecha");
      
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        _mostrarMensaje('Registro eliminado correctamente');
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error al eliminar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // CARGAR PRODUCCIONES - Obtener todos los registros
  Future<void> _cargarProducciones() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(getApiUrl('produccion'));
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _producciones = List<Map<String, dynamic>>.from(data);
        });
      } else {
        _mostrarMensaje('Error al cargar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // GENERAR PDF
  Future<void> _generarPDF() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar los datos primero
      await _cargarProducciones();
      
      if (_producciones.isEmpty) {
        _mostrarMensaje('No hay registros para generar PDF');
        return;
      }
      
      // Crear instancia del servicio PDF
      final pdfService = PdfServiced();
      
      // Generar y abrir PDF
      await pdfService.guardarYAbrirPdf(
        _producciones,
        'Reporte_Produccion_Leche_${DateTime.now().millisecondsSinceEpoch}'
      );
      
      _mostrarMensaje('PDF generado exitosamente');
    } catch (e) {
      _mostrarMensaje('Error al generar PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // VER LISTA - Navegar a lista de registros
  void _verLista() {
    _cargarProducciones().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE PRODUCCIÓN'),
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
                            'FECHA ORDEÑO',
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
                            'CANTIDAD (L)',
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
                            'CALIDAD',
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
                            'PERSONA CARGO',
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
                            'OBSERVACIONES',
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
                    child: _producciones.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de producción',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _producciones.length,
                            itemBuilder: (context, index) {
                              final produccion = _producciones[index];
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
                                        produccion['numero_arete']?.toString() ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Fecha Ordeño
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        produccion['fecha_ordeño']?.toString() ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Cantidad
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        produccion['cantidad_leche']?.toString() ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Calidad
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        produccion['calidad_leche']?.toString() ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Persona a cargo
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        produccion['persona_cargo']?.toString() ?? '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Observaciones
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        produccion['observaciones']?.toString() ?? 'Sin observaciones',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: const Text("Producción de leche"),
        backgroundColor: Colors.yellow[100],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "PRODUCCIÓN DE LECHE",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Número de arete
                    TextFormField(
                      controller: _numeroAreteController,
                      decoration: InputDecoration(
                        labelText: 'Número de arete',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Fecha de ordeño
                    TextFormField(
                      controller: _fechaController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha de ordeño',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _seleccionarFecha,
                        ),
                      ),
                      onTap: _seleccionarFecha,
                    ),
                    const SizedBox(height: 15),

                    // Cantidad de leche
                    TextFormField(
                      controller: _cantidadController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad de leche (litros)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    // Calidad de leche
                    TextFormField(
                      controller: _calidadController,
                      decoration: InputDecoration(
                        labelText: 'Calidad de leche',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Persona a cargo
                    TextFormField(
                      controller: _personaController,
                      decoration: InputDecoration(
                        labelText: 'Persona a cargo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Observaciones
                    TextFormField(
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 25),

                    // Botones
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _agregarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Agregar'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _consultarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Consultar'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _modificarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Modificar'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _eliminarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Eliminar'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _limpiarCampos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Limpiar'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _verLista,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Ver Lista'),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _generarPDF,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _numeroAreteController.dispose();
    _fechaController.dispose();
    _cantidadController.dispose();
    _calidadController.dispose();
    _personaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}