import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class EngordaPage extends StatefulWidget {
  const EngordaPage({Key? key}) : super(key: key);

  @override
  _EngordaPageState createState() => _EngordaPageState();
}

class _EngordaPageState extends State<EngordaPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _animales = [];
  bool _isLoading = true;

  // Controladores para los campos de texto
  final TextEditingController _areteController = TextEditingController();
  final TextEditingController _fechaIngresoController = TextEditingController();
  final TextEditingController _pesoIngresoController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _grupoController = TextEditingController();
  final TextEditingController _dietaController = TextEditingController();
  final TextEditingController _gananciaController = TextEditingController();
  final TextEditingController _fechaSalidaController = TextEditingController();
  final TextEditingController _pesoSalidaController = TextEditingController();

  int? _selectedIndex;
  final String _apiUrl = 'http://192.168.1.43/api/engorda.php';

  @override
  void initState() {
    super.initState();
    _cargarAnimales();
  }

  // Método para convertir fecha de formato dd/MM/yyyy a yyyy-MM-dd
  String _convertirFechaFormato(String fecha) {
    if (fecha.isEmpty) return '';

    try {
      // Intentar parsear la fecha en formato dd/MM/yyyy
      final parts = fecha.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        // Formatear a yyyy-MM-dd
        return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('Error al convertir fecha: $e');
    }

    return fecha; // Si no se puede convertir, devolver la fecha original
  }

  // Método para formatear fecha de yyyy-MM-dd to dd/MM/yyyy para mostrar
  String _formatearFechaParaMostrar(String fecha) {
    if (fecha.isEmpty || fecha == '0000-00-00') return '';

    try {
      final parts = fecha.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
      print('Error al formatear fecha: $e');
    }

    return fecha;
  }

  // Método para cargar animales desde la API
  Future<void> _cargarAnimales() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> animales = jsonDecode(response.body);
        setState(() {
          _animales = List<Map<String, dynamic>>.from(animales);
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar los animales');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _mostrarMensaje("Error al cargar los animales: $e");
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[350],
    appBar: AppBar(
      title: const Text("Engorda"),
      backgroundColor: Colors.yellow[100],
    ),
    body:
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "ENGORDA",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _areteController,
                        "Número de arete",
                        TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildDateField(
                        _fechaIngresoController,
                        "Fecha de ingreso",
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        _pesoIngresoController,
                        "Peso de ingreso (kg)",
                        TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        _costoController,
                        "Costo de adquisición",
                        TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        _grupoController,
                        "Grupo de engorda",
                        TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        _dietaController,
                        "Dieta",
                        TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        _gananciaController,
                        "Ganancia de peso (kg)",
                        TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildDateField(
                        _fechaSalidaController,
                        "Fecha de salida",
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        _pesoSalidaController,
                        "Peso de salida (kg)",
                        TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildButtonRow(),
                    ],
                  ),
                ),
              ),
            ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
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
          // Formatear la fecha como dd/MM/yyyy para mostrar
          controller.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }

  Widget _buildButtonRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _agregarAnimal,
          child: Text("Agregar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _consultarAnimal,
          child: Text("Consultar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _modificarAnimal,
          child: Text("Modificar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton(
          onPressed: _eliminarAnimal,
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

  void _agregarAnimal() async {
    if (_areteController.text.isEmpty) {
      _mostrarMensaje("El número de arete es obligatorio");
      return;
    }

    final nuevoAnimal = {
      'numero_arete': _areteController.text,
      'fecha_ingreso': _convertirFechaFormato(_fechaIngresoController.text),
      'peso_ingreso': _pesoIngresoController.text,
      'costo_adquisicion': _costoController.text,
      'grupo_engorda': _grupoController.text,
      'dieta': _dietaController.text,
      'ganancia_peso': _gananciaController.text,
      'fecha_salida': _convertirFechaFormato(_fechaSalidaController.text),
      'peso_salida': _pesoSalidaController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(nuevoAnimal),
      );

      if (response.statusCode == 200) {
        _mostrarMensaje("Animal agregado correctamente");
        _limpiarCampos();
        _cargarAnimales(); // Recargar la lista
      } else {
        _mostrarMensaje("Error al agregar animal: ${response.body}");
      }
    } catch (e) {
      _mostrarMensaje("Error al agregar animal: $e");
    }
  }

  void _consultarAnimal() {
    if (_areteController.text.isEmpty) {
      _mostrarMensaje("Ingrese un número de arete para consultar");
      return;
    }

    final arete = _areteController.text;
    final animal = _animales.firstWhere(
      (a) => a['numero_arete'] == arete,
      orElse: () => {},
    );

    if (animal.isEmpty) {
      _mostrarMensaje("No se encontró un animal con ese número de arete");
      return;
    }

    setState(() {
      _selectedIndex = _animales.indexWhere((a) => a['numero_arete'] == arete);
      _cargarDatosAnimal(animal);
    });
  }

  void _modificarAnimal() async {
    if (_selectedIndex == null) {
      _mostrarMensaje("Seleccione un animal de la lista para modificar");
      return;
    }

    final animalId = _animales[_selectedIndex!]['id'];
    final animalModificado = {
      'id': animalId,
      'numero_arete': _areteController.text,
      'fecha_ingreso': _convertirFechaFormato(_fechaIngresoController.text),
      'peso_ingreso': _pesoIngresoController.text,
      'costo_adquisicion': _costoController.text,
      'grupo_engorda': _grupoController.text,
      'dieta': _dietaController.text,
      'ganancia_peso': _gananciaController.text,
      'fecha_salida': _convertirFechaFormato(_fechaSalidaController.text),
      'peso_salida': _pesoSalidaController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(animalModificado),
      );

      if (response.statusCode == 200) {
        _mostrarMensaje("Animal modificado correctamente");
        _cargarAnimales(); // Recargar la lista
      } else {
        _mostrarMensaje("Error al modificar animal: ${response.body}");
      }
    } catch (e) {
      _mostrarMensaje("Error al modificar animal: $e");
    }
  }

  void _eliminarAnimal() async {
    if (_selectedIndex == null) {
      _mostrarMensaje("Seleccione un animal de la lista para eliminar");
      return;
    }

    final animalId = _animales[_selectedIndex!]['id'];

    try {
      final response = await http.delete(
        Uri.parse(_apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'id': animalId}),
      );

      if (response.statusCode == 200) {
        _mostrarMensaje("Animal eliminado correctamente");
        _limpiarCampos();
        _cargarAnimales(); // Recargar la lista
      } else {
        _mostrarMensaje("Error al eliminar animal: ${response.body}");
      }
    } catch (e) {
      _mostrarMensaje("Error al eliminar animal: $e");
    }
  }

  void _limpiarCampos() {
    setState(() {
      _areteController.clear();
      _fechaIngresoController.clear();
      _pesoIngresoController.clear();
      _costoController.clear();
      _grupoController.clear();
      _dietaController.clear();
      _gananciaController.clear();
      _fechaSalidaController.clear();
      _pesoSalidaController.clear();
      _selectedIndex = null;
    });
  }

  void _verLista() {
    if (_animales.isEmpty) {
      _mostrarMensaje("No hay animales registrados");
      return;
    }

    // Navegar a la pantalla completa de tabla
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TablaEngordaScreen(animales: _animales),
      ),
    );
  }

  // ignore: unused_element
  String _formatearCosto(dynamic valorCosto) {
    if (valorCosto == null) return '\$0.00';

    try {
      // Si es String, convertirlo a double
      if (valorCosto is String) {
        final costo = double.tryParse(valorCosto) ?? 0.0;
        return '\$${costo.toStringAsFixed(2)}';
      }
      // Si ya es num (int o double)
      else if (valorCosto is num) {
        return '\$${valorCosto.toStringAsFixed(2)}';
      }
      // Para cualquier otro tipo
      else {
        return '\$0.00';
      }
    } catch (e) {
      return '\$0.00';
    }
  }

  // ignore: unused_element
  String _formatearPeso(dynamic valorPeso) {
    if (valorPeso == null) return 'N/A';

    try {
      // Si es String, convertirlo a double
      if (valorPeso is String) {
        final peso = double.tryParse(valorPeso) ?? 0.0;
        return peso.toStringAsFixed(1);
      }
      // Si ya es num (int o double)
      else if (valorPeso is num) {
        return valorPeso.toStringAsFixed(1);
      }
      // Para cualquier otro tipo
      else {
        return 'N/A';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  // Función para generar reporte en texto
  // ignore: unused_element
  void _generarReporteTexto() {
    String reporte =
        "REPORTE DE ENGORDA - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}\n\n";

    reporte += "Total de animales: ${_animales.length}\n";

    for (var animal in _animales) {
      reporte += "N° Arete: ${animal['numero_arete'] ?? 'N/A'}\n";
      reporte +=
          "Fecha Ingreso: ${_formatearFechaParaMostrar(animal['fecha_ingreso']?.toString() ?? '')}\n";
      reporte += "Peso Ingreso: ${animal['peso_ingreso'] ?? 'N/A'} kg\n";
      reporte +=
          "Costo: \$${animal['costo_adquisicion']?.toStringAsFixed(2) ?? '0.00'}\n";
      reporte += "Grupo: ${animal['grupo_engorda'] ?? 'N/A'}\n";
      reporte += "Dieta: ${animal['dieta'] ?? 'N/A'}\n";
      reporte += "Ganancia Peso: ${animal['ganancia_peso'] ?? 'N/A'} kg\n";
      reporte +=
          "Fecha Salida: ${_formatearFechaParaMostrar(animal['fecha_salida']?.toString() ?? '')}\n";
      reporte += "Peso Salida: ${animal['peso_salida'] ?? 'N/A'} kg\n";
    }

    // Mostrar el reporte en un nuevo diálogo
    _mostrarReporteTexto(reporte);
  }

  void _mostrarReporteTexto(String reporte) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Text(
                  "REPORTE DE ENGORDA",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      reporte,
                      style: TextStyle(fontFamily: 'Courier', fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cerrar"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cargarDatosAnimal(Map<String, dynamic> animal) {
    _areteController.text = animal['numero_arete'] ?? '';
    _fechaIngresoController.text = _formatearFechaParaMostrar(
      animal['fecha_ingreso'] ?? '',
    );
    _pesoIngresoController.text = animal['peso_ingreso']?.toString() ?? '';
    _costoController.text = animal['costo_adquisicion']?.toString() ?? '';
    _grupoController.text = animal['grupo_engorda'] ?? '';
    _dietaController.text = animal['dieta'] ?? '';
    _gananciaController.text = animal['ganancia_peso']?.toString() ?? '';
    _fechaSalidaController.text = _formatearFechaParaMostrar(
      animal['fecha_salida'] ?? '',
    );
    _pesoSalidaController.text = animal['peso_salida']?.toString() ?? '';
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    // Limpiar los controladores cuando el widget se desmonte
    _areteController.dispose();
    _fechaIngresoController.dispose();
    _pesoIngresoController.dispose();
    _costoController.dispose();
    _grupoController.dispose();
    _dietaController.dispose();
    _gananciaController.dispose();
    _fechaSalidaController.dispose();
    _pesoSalidaController.dispose();
    super.dispose();
  }
}

// Nueva pantalla para mostrar la tabla completa
class TablaEngordaScreen extends StatelessWidget {
  final List<Map<String, dynamic>> animales;

  const TablaEngordaScreen({Key? key, required this.animales}) : super(key: key);

  String _formatearFechaParaMostrar(String fecha) {
    if (fecha.isEmpty || fecha == '0000-00-00') return '';

    try {
      final parts = fecha.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
      print('Error al formatear fecha: $e');
    }

    return fecha;
  }

  String _formatearCosto(dynamic valorCosto) {
    if (valorCosto == null) return '\$0.00';

    try {
      if (valorCosto is String) {
        final costo = double.tryParse(valorCosto) ?? 0.0;
        return '\$${costo.toStringAsFixed(2)}';
      } else if (valorCosto is num) {
        return '\$${valorCosto.toStringAsFixed(2)}';
      } else {
        return '\$0.00';
      }
    } catch (e) {
      return '\$0.00';
    }
  }

  String _formatearPeso(dynamic valorPeso) {
    if (valorPeso == null) return 'N/A';

    try {
      if (valorPeso is String) {
        final peso = double.tryParse(valorPeso) ?? 0.0;
        return peso.toStringAsFixed(1);
      } else if (valorPeso is num) {
        return valorPeso.toStringAsFixed(1);
      } else {
        return 'N/A';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTRO COMPLETO DE ENGORDA'),
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
                      'F. INGRESO',
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
                      'P. INGRESO',
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
                      'COSTO',
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
                      'GRUPO',
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
                      'DIETA',
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
                      'GANANCIA',
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
                      'F. SALIDA',
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
                      'P. SALIDA',
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
              child: animales.isEmpty
                  ? Center(
                      child: Text(
                        'No hay animales registrados',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: animales.length,
                      itemBuilder: (context, index) {
                        final animal = animales[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: index.isEven ? Colors.grey[50] : Colors.white,
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
                                  animal['numero_arete']?.toString() ?? 'N/A',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Fecha Ingreso
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatearFechaParaMostrar(
                                    animal['fecha_ingreso']?.toString() ?? '',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Peso Ingreso
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatearPeso(animal['peso_ingreso']),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Costo
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatearCosto(animal['costo_adquisicion']),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Grupo
                              Expanded(
                                flex: 2,
                                child: Text(
                                  animal['grupo_engorda']?.toString() ?? 'N/A',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Dieta
                              Expanded(
                                flex: 2,
                                child: Text(
                                  animal['dieta']?.toString() ?? 'N/A',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Ganancia
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatearPeso(animal['ganancia_peso']),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Fecha Salida
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatearFechaParaMostrar(
                                    animal['fecha_salida']?.toString() ?? '',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              // Peso Salida
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatearPeso(animal['peso_salida']),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
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