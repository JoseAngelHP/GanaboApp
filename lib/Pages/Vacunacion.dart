import 'package:flutter/material.dart';
import 'package:ganabo/Pages/Pdf_Servicet.dart';
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

class VacunacionPage extends StatefulWidget {
  const VacunacionPage({Key? key}) : super(key: key);

  @override
  _VacunacionPageState createState() => _VacunacionPageState();
}

class _VacunacionPageState extends State<VacunacionPage> {
  // Aqui agregamos los controladores para los textfields
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _fechaVacunacionController =
      TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _proximaVacunacionController =
      TextEditingController();
  final TextEditingController _observacionesController =
      TextEditingController();

  String? _selectedMedicamento;
  String? _selectedViaAdministracion;
  String? _selectedTrabajador;

  List<String> _medicamentos = [];
  List<String> _trabajadores = [];

  final List<String> _viasAdministracion = [
    'Subcutánea',
    'Intramuscular',
    'Intravenosa',
    'Tópica',
    'Oral',
    'Otra',
  ];

  List<Vacunacion> _vacunaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
    _cargarTrabajadores();
  }

  // Aqui cargamos los medicamentos desde la tabla de medicamentos
  Future<void> _cargarMedicamentos() async {
    try {
      final url = Uri.parse(getApiUrl('medicamentos'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> medicamentosData = responseData['data'] ?? [];
          final nombresMedicamentos =
              medicamentosData
                  .map<String>(
                    (medicamento) =>
                        medicamento['nombre_medicamento']?.toString() ?? '',
                  )
                  .where((nombre) => nombre.isNotEmpty)
                  .toList();

          nombresMedicamentos.sort();

          setState(() {
            _medicamentos = nombresMedicamentos;
          });
        }
      }
    } catch (e) {
      print('Error al cargar medicamentos: $e');
    }
  }

  // Aqui cargamos los trabajadores desde la tabla de trabajadores
  Future<void> _cargarTrabajadores() async {
    try {
      final url = Uri.parse(getApiUrl('trabajadores'));
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> trabajadoresData = responseData['data'] ?? [];
          final nombresTrabajadores =
              trabajadoresData
                  .map<String>(
                    (trabajador) =>
                        trabajador['nombre_completo']?.toString() ?? '',
                  )
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

  // Aqui mostramos los mensajes
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // Aqui limpiamos los campos
  void _limpiarCampos() {
    _numeroAreteController.clear();
    _fechaVacunacionController.clear();
    _dosisController.clear();
    _proximaVacunacionController.clear();
    _observacionesController.clear();
    setState(() {
      _selectedMedicamento = null;
      _selectedViaAdministracion = null;
      _selectedTrabajador = null;
    });
    _mostrarMensaje('Campos limpiados');
  }

  // Aqui validamos los campos obligatorios
  bool _validarCampos() {
    if (_numeroAreteController.text.isEmpty ||
        _fechaVacunacionController.text.isEmpty ||
        _selectedMedicamento == null ||
        _selectedViaAdministracion == null ||
        _dosisController.text.isEmpty ||
        _selectedTrabajador == null) {
      _mostrarMensaje('Por favor, complete todos los campos obligatorios');
      return false;
    }

    if (double.tryParse(_dosisController.text) == null) {
      _mostrarMensaje('Por favor, ingrese una dosis válida');
      return false;
    }

    return true;
  }

  // Aqui creamos un nuevo registro
  Future<void> _agregarVacunacion() async {
    if (!_validarCampos()) return;

    try {
      final url = Uri.parse(getApiUrl('vacunacion'));
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'fecha_vacunacion': _fechaVacunacionController.text,
          'vacuna_aplicada':
              _selectedMedicamento!, 
          'via_administracion':
              _selectedViaAdministracion!, 
          'dosis': double.parse(_dosisController.text),
          'aplicador':
              _selectedTrabajador!, 
          'proxima_vacunacion':
              _proximaVacunacionController.text.isNotEmpty
                  ? _proximaVacunacionController.text
                  : null,
          'observaciones':
              _observacionesController.text.isNotEmpty
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

  // Aqui consultamos los datos
  Future<void> _consultarVacunacion() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese el número de arete para consultar');
      return;
    }

    try {
      final url = Uri.parse(
        "${getApiUrl('vacunacion')}?numero_arete=${_numeroAreteController.text}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final ultimoRegistro = data[0];
          _fechaVacunacionController.text =
              ultimoRegistro['fecha_vacunacion'] ?? '';
          _dosisController.text = ultimoRegistro['dosis']?.toString() ?? '';
          _proximaVacunacionController.text =
              ultimoRegistro['proxima_vacunacion'] ?? '';
          _observacionesController.text = ultimoRegistro['observaciones'] ?? '';

          setState(() {
            _selectedMedicamento = ultimoRegistro['vacuna_aplicada'] ?? '';
            _selectedViaAdministracion =
                ultimoRegistro['via_administracion'] ?? '';
            _selectedTrabajador = ultimoRegistro['aplicador'] ?? '';
          });

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

  // Aqui modificamos los datos
  Future<void> _modificarVacunacion() async {
    if (!_validarCampos()) return;

    try {
      final url = Uri.parse(getApiUrl('vacunacion'));
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
          'fecha_vacunacion': _fechaVacunacionController.text,
          'vacuna_aplicada':
              _selectedMedicamento!, 
          'via_administracion':
              _selectedViaAdministracion!, 
          'dosis': double.parse(_dosisController.text),
          'aplicador':
              _selectedTrabajador!, 
          'proxima_vacunacion':
              _proximaVacunacionController.text.isNotEmpty
                  ? _proximaVacunacionController.text
                  : null,
          'observaciones':
              _observacionesController.text.isNotEmpty
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

  // Aqui eliminamos los datos
  Future<void> _eliminarVacunacion() async {
    if (_numeroAreteController.text.isEmpty) {
      _mostrarMensaje('Ingrese número de arete para eliminar');
      return;
    }

    try {
      // Aqui mostramos el mensaje de confirmacion de eliminacion
      final confirmar = await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('¿Eliminar vacunaciones?'),
              content: Text(
                '¿Está seguro de que desea eliminar TODAS las vacunaciones del arete ${_numeroAreteController.text}?',
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

      final url = Uri.parse(getApiUrl('vacunacion'));
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'numero_arete': _numeroAreteController.text,
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

  // Aqui cargamos todas las vacunaciones
  Future<void> _cargarVacunaciones() async {
    try {
      final url = Uri.parse(getApiUrl('vacunacion'));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _vacunaciones =
              data.map((item) => Vacunacion.fromJson(item)).toList();
        });
      } else {
        throw Exception('Error al cargar las vacunaciones');
      }
    } catch (e) {
      _mostrarMensaje('Error al cargar la lista: $e');
    }
  }

  // Aqui creamos el pdf
  Future<void> _generarPDF() async {
    try {
      // Aqui cargamos los datos
      await _cargarVacunaciones();

      final pdfService = PdfServicet();

      // Aqui generamos y abrimos el pdf
      await pdfService.guardarYAbrirPdf(
        _vacunaciones.map((v) => v.toJson()).toList(),
        'Reporte_Vacunaciones_${DateTime.now().millisecondsSinceEpoch}',
      );

      _mostrarMensaje('PDF generado exitosamente');
    } catch (e) {
      _mostrarMensaje('Error al generar PDF: $e');
    }
  }

  // Aqui vemos la lista en formato de tabla
  void _verLista() {
    _cargarVacunaciones().then((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => Scaffold(
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
                                'TRABAJADOR', 
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

                      // Aqui ponemos el contenido de la tabla
                      Expanded(
                        child:
                            _vacunaciones.isEmpty
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
                                        color:
                                            index.isEven
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
                                              vacunacion.numeroArete,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          // Aqui ponemos la Fecha de Vacunación
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
                                          // Aqui ponemos el Medicamento
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
                                          // Aqui ponemos la Vía de Administración
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
                                          // Aqui ponemos la Dosis
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
                                          // Aqui ponemos el Trabajador
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
                                          // Aqui ponemos la Próxima Vacunación
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              vacunacion.proximaVacunacion ??
                                                  '',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          // Aqui ponemos las Observaciones
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              vacunacion.observaciones ??
                                                  '',
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

                // Aqui ponemos el Número de arete
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

                // Aqui ponemos la Fecha de vacunación
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

                // Aqui ponemos el Medicamento
                DropdownButtonFormField<String>(
                  value: _selectedMedicamento,
                  decoration: InputDecoration(
                    labelText: 'Medicamento',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items:
                      _medicamentos.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMedicamento = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione un medicamento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Aqui ponemos la Via De Administracion
                DropdownButtonFormField<String>(
                  value: _selectedViaAdministracion,
                  decoration: InputDecoration(
                    labelText: 'Vía de administración',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items:
                      _viasAdministracion.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedViaAdministracion = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione una vía de administración';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Aqui ponemos la Dosis
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

                // Aqui ponemos el Trabajador 
                DropdownButtonFormField<String>(
                  value: _selectedTrabajador,
                  decoration: InputDecoration(
                    labelText: 'Trabajador',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items:
                      _trabajadores.map((String value) {
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
                const SizedBox(height: 15),

                // Aqui ponemos la Próxima vacunación
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

                // Aqui ponemos las Observaciones
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
    // Aqui limpiamos los controladores
    _numeroAreteController.dispose();
    _fechaVacunacionController.dispose();
    _dosisController.dispose();
    _proximaVacunacionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}

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
