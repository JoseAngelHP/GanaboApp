import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Función para obtener la URL de la API según la plataforma
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

  bool _isLoading = false;
  bool _generandoPDF = false;

  // Headers para las peticiones HTTP
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Función para seleccionar fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  // Convertir fecha de formato dd/mm/yyyy a yyyy-mm-dd
  String _convertirFecha(String fecha) {
    final parts = fecha.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return fecha;
  }

  // Función auxiliar para convertir fecha de yyyy-mm-dd a dd/mm/yyyy
  String _convertirFechaParaMostrar(String fecha) {
    final partes = fecha.split('-');
    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
    return fecha;
  }

  // AGREGAR REGISTRO
  void _agregarRegistro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final registro = {
          'numero_arete': _numeroAreteController.text,
          'fecha_ordeño': _convertirFecha(_fechaController.text),
          'cantidad_leche': double.parse(_cantidadController.text),
          'calidad_leche': _calidadController.text,
          'persona_cargo': _personaController.text,
          'observaciones': _observacionesController.text,
        };

        final url = Uri.parse(getApiUrl('produccion'));
        final response = await http.post(
          url,
          headers: headers,
          body: json.encode(registro),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro agregado correctamente')),
          );
          _limpiarCampos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // CONSULTAR REGISTRO por número de arete - CORREGIDO
  void _consultarRegistro() async {
    if (_numeroAreteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un número de arete para consultar')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse("${getApiUrl('produccion')}?numero_arete=${_numeroAreteController.text}");
      final response = await http.get(url, headers: headers);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        List<dynamic> data = [];
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'] ?? [];
        } else if (responseData is Map && responseData.containsKey('success')) {
          data = responseData['data'] ?? [];
        }

        if (data.isNotEmpty) {
          // Ordenar por fecha para obtener el registro más reciente
          data.sort((a, b) => b['fecha_ordeño'].compareTo(a['fecha_ordeño']));
          final registroMasReciente = data[0];

          // Llenar los campos automáticamente
          setState(() {
            _fechaController.text = _convertirFechaParaMostrar(
              registroMasReciente['fecha_ordeño'].toString(),
            );
            _cantidadController.text = registroMasReciente['cantidad_leche']?.toString() ?? '';
            _calidadController.text = registroMasReciente['calidad_leche']?.toString() ?? '';
            _personaController.text = registroMasReciente['persona_cargo']?.toString() ?? '';
            _observacionesController.text = registroMasReciente['observaciones']?.toString() ?? '';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro cargado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron registros')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // MODIFICAR REGISTRO
  void _modificarRegistro() async {
    if (_formKey.currentState!.validate()) {
      if (_numeroAreteController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese un número de arete')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final registro = {
          'numero_arete': _numeroAreteController.text,
          'fecha_ordeño': _convertirFecha(_fechaController.text),
          'cantidad_leche': double.parse(_cantidadController.text),
          'calidad_leche': _calidadController.text,
          'persona_cargo': _personaController.text,
          'observaciones': _observacionesController.text,
        };

        final url = Uri.parse(getApiUrl('produccion'));
        final response = await http.put(
          url,
          headers: headers,
          body: json.encode(registro),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro modificado correctamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ELIMINAR REGISTRO
  void _eliminarRegistro() async {
    if (_numeroAreteController.text.isEmpty || _fechaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese número de arete y fecha')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Está seguro de eliminar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }

              try {
                final data = {
                  'numero_arete': _numeroAreteController.text,
                  'fecha_ordeño': _convertirFecha(_fechaController.text),
                };

                final url = Uri.parse(getApiUrl('produccion'));
                final response = await http.delete(
                  url,
                  headers: headers,
                  body: json.encode(data),
                );

                if (!mounted) return;

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registro eliminado')),
                  );
                  _limpiarCampos();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${response.body}')),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error de conexión: $e')),
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _limpiarCampos() {
    setState(() {
      _numeroAreteController.clear();
      _fechaController.clear();
      _observacionesController.clear();
      _cantidadController.clear();
      _calidadController.clear();
      _personaController.clear();
    });
  }

  // VER LISTA - CORREGIDO
  void _verLista() async {
    try {
      final url = Uri.parse(getApiUrl('produccion'));
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        List<dynamic> data = [];
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'] ?? [];
        } else if (responseData is Map && responseData.containsKey('success')) {
          data = responseData['data'] ?? [];
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('LISTA COMPLETA DE REGISTROS'),
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
                        horizontal: 10,
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
                                fontSize: 14,
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
                                fontSize: 14,
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
                                fontSize: 14,
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
                            flex: 3,
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
                      child: data.isEmpty
                          ? Center(
                              child: Text(
                                'No hay registros de ordeño',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final registro = data[index];
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
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      // N° Arete
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          registro['numero_arete']?.toString() ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      // Fecha Ordeño
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          registro['fecha_ordeño']?.toString() ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      // Cantidad
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          registro['cantidad_leche']?.toString() ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      // Calidad
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          registro['calidad_leche']?.toString() ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      // Persona a cargo
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          registro['persona_cargo']?.toString() ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      // Observaciones
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          registro['observaciones']?.toString() ?? 'Sin observaciones',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar registros: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  // GENERAR PDF - CORREGIDO
  void _generarPDF() async {
    setState(() => _generandoPDF = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 10),
            const Text('Generando PDF...'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final url = Uri.parse(getApiUrl('produccion'));
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        List<dynamic> registros = [];
        if (responseData is List) {
          registros = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          registros = responseData['data'] ?? [];
        } else if (responseData is Map && responseData.containsKey('success')) {
          registros = responseData['data'] ?? [];
        }

        if (registros.isEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay registros para generar PDF')),
          );
        } else {
          // Nota: Necesitarías implementar PdfServiced o usar otra solución para PDF
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidad PDF no implementada')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener datos: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    } finally {
      setState(() => _generandoPDF = false);
    }
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

                    // Campo: Número de arete
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el número de arete';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Fecha de ordeño
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
                          onPressed: () => _seleccionarFecha(context),
                        ),
                      ),
                      onTap: () => _seleccionarFecha(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione la fecha de ordeño';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Cantidad de leche
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la cantidad';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Calidad de leche
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la calidad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Persona a cargo
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese la persona a cargo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Campo: Observaciones
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
                      textAlignVertical: TextAlignVertical.top,
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