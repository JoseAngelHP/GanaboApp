import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Pdf_Servicet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VacunacionPage extends StatefulWidget {
  const VacunacionPage({Key? key}) : super(key: key);

  @override
  _VacunacionPageState createState() => _VacunacionPageState();
}

class _VacunacionPageState extends State<VacunacionPage> {
  // URL de tu API
  //final String apiUrl = "http://192.168.1.43/api/vacunacion.php";
  final String apiUrl = "http://ganabovino.atwebpages.com/api/vacunacion.php";
  
  // Controladores para los TextFields
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _fechaVacunacionController = TextEditingController();
  final TextEditingController _vacunaAplicadaController = TextEditingController();
  final TextEditingController _viaAdministracionController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _aplicadorController = TextEditingController();
  final TextEditingController _proximaVacunacionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  // Lista para almacenar las vacunaciones
  List<Vacunacion> _vacunaciones = [];

  // Función para mostrar mensajes
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Función para limpiar campos
  void _limpiarCampos() {
    _numeroAreteController.clear();
    _fechaVacunacionController.clear();
    _vacunaAplicadaController.clear();
    _viaAdministracionController.clear();
    _dosisController.clear();
    _aplicadorController.clear();
    _proximaVacunacionController.clear();
    _observacionesController.clear();
    _mostrarMensaje('Campos limpiados');
  }

  // Función para validar campos obligatorios
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _fechaVacunacionController.text.isEmpty ||
        _vacunaAplicadaController.text.isEmpty ||
        _viaAdministracionController.text.isEmpty ||
        _dosisController.text.isEmpty ||
        _aplicadorController.text.isEmpty) {
      _mostrarMensaje('Por favor, complete todos los campos obligatorios');
      return false;
    }
    return true;
  }

  // AGREGAR - Crear nuevo registro
  Future<void> _agregarVacunacion() async {
    if (!_validarCampos()) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'fecha_vacunacion': _fechaVacunacionController.text,
          'vacuna_aplicada': _vacunaAplicadaController.text,
          'via_administracion': _viaAdministracionController.text,
          'dosis': double.parse(_dosisController.text),
          'aplicador': _aplicadorController.text,
          'proxima_vacunacion': _proximaVacunacionController.text.isNotEmpty 
              ? _proximaVacunacionController.text 
              : null,
          'observaciones': _observacionesController.text.isNotEmpty 
              ? _observacionesController.text 
              : null,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _mostrarMensaje(data['message']);
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error al agregar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // CONSULTAR - Buscar por número de arete
  Future<void> _consultarVacunacion() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl?numero_arete=${_numeroAreteController.text}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          // Mostrar el último registro
          final ultimoRegistro = data[0];
          _fechaVacunacionController.text = ultimoRegistro['fecha_vacunacion'] ?? '';
          _vacunaAplicadaController.text = ultimoRegistro['vacuna_aplicada'] ?? '';
          _viaAdministracionController.text = ultimoRegistro['via_administracion'] ?? '';
          _dosisController.text = ultimoRegistro['dosis']?.toString() ?? '';
          _aplicadorController.text = ultimoRegistro['aplicador'] ?? '';
          _proximaVacunacionController.text = ultimoRegistro['proxima_vacunacion'] ?? '';
          _observacionesController.text = ultimoRegistro['observaciones'] ?? '';
          
          _mostrarMensaje('${data.length} registros encontrados');
        } else {
          _mostrarMensaje('No se encontraron registros');
        }
      } else {
        _mostrarMensaje('Error en la consulta: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // MODIFICAR - Actualizar registro
  Future<void> _modificarVacunacion() async {
    if (!_validarCampos()) return;

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'fecha_vacunacion': _fechaVacunacionController.text,
          'vacuna_aplicada': _vacunaAplicadaController.text,
          'via_administracion': _viaAdministracionController.text,
          'dosis': double.parse(_dosisController.text),
          'aplicador': _aplicadorController.text,
          'proxima_vacunacion': _proximaVacunacionController.text.isNotEmpty 
              ? _proximaVacunacionController.text 
              : null,
          'observaciones': _observacionesController.text.isNotEmpty 
              ? _observacionesController.text 
              : null,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _mostrarMensaje(data['message']);
      } else {
        _mostrarMensaje('Error al modificar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // ELIMINAR - Borrar registro
  Future<void> _eliminarVacunacion() async {
    if (_numeroAreteController.text.isEmpty || _fechaVacunacionController.text.isEmpty) {
      _mostrarMensaje('Ingrese número de arete y fecha para eliminar');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'fecha_vacunacion': _fechaVacunacionController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _mostrarMensaje(data['message']);
        _limpiarCampos();
      } else {
        _mostrarMensaje('Error al eliminar: ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión: $e');
    }
  }

  // CARGAR VACUNACIONES - Obtener todos los registros
  Future<void> _cargarVacunaciones() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _vacunaciones = data.map((item) => Vacunacion.fromJson(item)).toList();
        });
      } else {
        throw Exception('Error al cargar las vacunaciones');
      }
    } catch (e) {
      _mostrarMensaje('Error al cargar la lista: $e');
    }
  }

  // GENERAR PDF
  Future<void> _generarPDF() async {
    try {
      // Cargar los datos primero
      await _cargarVacunaciones();
      
      // Crear instancia del servicio PDF
      final pdfService = PdfServicet();
      
      // Generar y abrir PDF
      await pdfService.guardarYAbrirPdf(
        _vacunaciones.map((v) => v.toJson()).toList(),
        'Reporte_Vacunaciones_${DateTime.now().millisecondsSinceEpoch}'
      );
      
      _mostrarMensaje('PDF generado exitosamente');
    } catch (e) {
      _mostrarMensaje('Error al generar PDF: $e');
    }
  }

  // VER LISTA - Navegar a lista de registros
  void _verLista() {
    _cargarVacunaciones().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('LISTA COMPLETA DE VACUNACIONES'),
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
                            'FECHA VAC.',
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
                            'VACUNA',
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
                            'VÍA ADMIN.',
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
                            'DOSIS',
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
                            'APLICADOR',
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
                            'PRÓXIMA VAC.',
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
                    child: _vacunaciones.isEmpty
                        ? Center(
                            child: Text(
                              'No hay registros de vacunación',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _vacunaciones.length,
                            itemBuilder: (context, index) {
                              final vacunacion = _vacunaciones[index];
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
                                        vacunacion.numeroArete,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Fecha Vacunación
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        vacunacion.fechaVacunacion,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Vacuna Aplicada
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        vacunacion.vacunaAplicada,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Vía Administración
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        vacunacion.viaAdministracion,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Dosis
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        vacunacion.dosis.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Aplicador
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        vacunacion.aplicador,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Próxima Vacunación
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        vacunacion.proximaVacunacion ?? 'N/A',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    // Observaciones
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        vacunacion.observaciones ?? 'Sin obs.',
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
        title: const Text("Vacunación"),
        backgroundColor: Colors.yellow[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "VACUNACIÓN",
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
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                
                // Fecha de vacunación
                TextFormField(
                  controller: _fechaVacunacionController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de vacunación',
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
                      _fechaVacunacionController.text = 
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 15),
                
                // Vacuna aplicada
                TextFormField(
                  controller: _vacunaAplicadaController,
                  decoration: InputDecoration(
                    labelText: 'Vacuna aplicada',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Vía de administración
                TextFormField(
                  controller: _viaAdministracionController,
                  decoration: InputDecoration(
                    labelText: 'Vía de administración',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Dosis
                TextFormField(
                  controller: _dosisController,
                  decoration: InputDecoration(
                    labelText: 'Dosis',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 15),
                
                // Aplicador
                TextFormField(
                  controller: _aplicadorController,
                  decoration: InputDecoration(
                    labelText: 'Aplicador',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Próxima vacunación
                TextFormField(
                  controller: _proximaVacunacionController,
                  decoration: InputDecoration(
                    labelText: 'Próxima vacunación',
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
                      _proximaVacunacionController.text = 
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 15),
                
                // Observaciones
                TextFormField(
                  controller: _observacionesController,
                  decoration: InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 30),
                
                // Botones
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _agregarVacunacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Agregar'),
                    ),
                    ElevatedButton(
                      onPressed: _consultarVacunacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Consultar'),
                    ),
                    ElevatedButton(
                      onPressed: _modificarVacunacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Modificar'),
                    ),
                    ElevatedButton(
                      onPressed: _eliminarVacunacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Eliminar'),
                    ),
                    ElevatedButton(
                      onPressed: _limpiarCampos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Limpiar'),
                    ),
                    ElevatedButton(
                      onPressed: _verLista,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Ver Lista'),
                    ),
                    ElevatedButton(
                      onPressed: _generarPDF,
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
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar controladores
    _numeroAreteController.dispose();
    _fechaVacunacionController.dispose();
    _vacunaAplicadaController.dispose();
    _viaAdministracionController.dispose();
    _dosisController.dispose();
    _aplicadorController.dispose();
    _proximaVacunacionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}

// Modelo Vacunacion
class Vacunacion {
  final String numeroArete;
  final String fechaVacunacion;
  final String vacunaAplicada;
  final String viaAdministracion;
  final double dosis;
  final String aplicador;
  final String? proximaVacunacion;
  final String? observaciones;

  Vacunacion({
    required this.numeroArete,
    required this.fechaVacunacion,
    required this.vacunaAplicada,
    required this.viaAdministracion,
    required this.dosis,
    required this.aplicador,
    this.proximaVacunacion,
    this.observaciones,
  });

  factory Vacunacion.fromJson(Map<String, dynamic> json) {
    return Vacunacion(
      numeroArete: json['numero_arete'] ?? '',
      fechaVacunacion: json['fecha_vacunacion'] ?? '',
      vacunaAplicada: json['vacuna_aplicada'] ?? '',
      viaAdministracion: json['via_administracion'] ?? '',
      dosis: double.tryParse(json['dosis'].toString()) ?? 0.0,
      aplicador: json['aplicador'] ?? '',
      proximaVacunacion: json['proxima_vacunacion'],
      observaciones: json['observaciones'],
    );
  }

  // Método toJson para convertir a Map
  Map<String, dynamic> toJson() {
    return {
      'numero_arete': numeroArete,
      'fecha_vacunacion': fechaVacunacion,
      'vacuna_aplicada': vacunaAplicada,
      'via_administracion': viaAdministracion,
      'dosis': dosis,
      'aplicador': aplicador,
      'proxima_vacunacion': proximaVacunacion,
      'observaciones': observaciones,
    };
  }
}