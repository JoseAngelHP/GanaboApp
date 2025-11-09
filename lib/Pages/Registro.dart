import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

String getApiUrl(String endpoint) {
  if (kIsWeb) {
    return 'https://ganabovino.atwebpages.com/api/$endpoint.php';
  } else {
    return 'http://ganabovino.atwebpages.com/api/$endpoint.php';
  }
}

class Animal {
  int? id;
  String numeroArete;
  String raza;
  String sexo;
  String fechaNacimiento;
  String origen;
  String? padre;
  String? madre;
  String? adquisicion; 
  String? fotoPath;

  Animal({
    this.id,
    required this.numeroArete,
    required this.raza,
    required this.sexo,
    required this.fechaNacimiento,
    required this.origen,
    this.padre,
    this.madre,
    this.adquisicion, 
    this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero_arete': numeroArete,
      'raza': raza,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento,
      'origen': origen,
      'padre': padre ?? '',
      'madre': madre ?? '',
      'adquisicion': adquisicion ?? '', 
      'foto_path': fotoPath,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      numeroArete: map['numero_arete'],
      raza: map['raza'],
      sexo: map['sexo'],
      fechaNacimiento: map['fecha_nacimiento'],
      origen: map['origen'],
      padre: map['padre']?.isEmpty ?? true ? null : map['padre'],
      madre: map['madre']?.isEmpty ?? true ? null : map['madre'],
      adquisicion:
          map['adquisicion']?.isEmpty ?? true
              ? null
              : map['adquisicion'], 
      fotoPath: map['foto_path'],
    );
  }
}

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroAreteController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _adquisicionController =
      TextEditingController(); 

  String? _selectedRaza;
  String? _selectedSexo;
  String? _selectedOrigen;
  String? _selectedPadre;
  String? _selectedMadre;

  File? _foto;
  final ImagePicker _picker = ImagePicker();

  List<Animal> _animales = [];
  Animal? _animalSeleccionado;

  List<String> _numerosAretePadres = [];
  List<String> _numerosAreteMadres = [];

  List<String> _padresTemporales = [];
  List<String> _madresTemporales = [];

  Future<void> _cargarRazasDesdeBD() async {
    try {
      final url = Uri.parse(getApiUrl('todos'));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _razas = data.cast<String>();
        });
      } else {
        print('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      setState(() {
        _razas = [
          'Angus',
          'Hereford',
          'Holstein',
          'Brahman',
          'Simmental',
          'Charolais',
          'Limousin',
          'Otra',
        ];
      });
    }
  }

  List<String> _razas = [];

  final List<String> _sexos = ['Macho', 'Hembra'];

  Future<void> _cargarOrigenesDesdeBD() async {
    try {
      final url = Uri.parse(getApiUrl('todost'));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _origenes = data.cast<String>();
        });
      } else {
        print('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      setState(() {
        _origenes = ['Compra', 'Nacimiento en la finca', 'Donación', 'Trueque'];
      });
    }
  }

  List<String> _origenes = [];

  void _cargarNumerosAreteParaPadres() {
    List<String> padres =
        _animales
            .where((animal) => animal.sexo == 'Macho')
            .map((animal) => animal.numeroArete)
            .toList();

    setState(() {
      _numerosAretePadres = padres;
    });
  }

  void _cargarNumerosAreteParaMadres() {
    List<String> madres =
        _animales
            .where((animal) => animal.sexo == 'Hembra')
            .map((animal) => animal.numeroArete)
            .toList();

    setState(() {
      _numerosAreteMadres = madres;
    });
  }

  // Aqui mandamos a llamar a la lista de los padres 
  List<String> _obtenerPadresCompletos() {
    Set<String> padresCompletos = {};
    padresCompletos.addAll(_numerosAretePadres);
    padresCompletos.addAll(_padresTemporales);
    if (_selectedPadre != null && _selectedPadre!.isNotEmpty) {
      padresCompletos.add(_selectedPadre!);
    }
    return padresCompletos.toList();
  }

  // Aqui mandamos a llamar a la lista de las madres 
  List<String> _obtenerMadresCompletas() {
    Set<String> madresCompletas = {};
    madresCompletas.addAll(_numerosAreteMadres);
    madresCompletas.addAll(_madresTemporales);
    if (_selectedMadre != null && _selectedMadre!.isNotEmpty) {
      madresCompletas.add(_selectedMadre!);
    }
    return madresCompletas.toList();
  }

  @override
  void initState() {
    super.initState();
    _cargarAnimales();
    _cargarRazasDesdeBD();
    _cargarOrigenesDesdeBD();
  }

  Future<void> _cargarAnimales() async {
    try {
      final url = Uri.parse(getApiUrl('animales'));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _animales = data.map((item) => Animal.fromMap(item)).toList();
          _cargarNumerosAreteParaPadres();
          _cargarNumerosAreteParaMadres();
        });
      } else {
        throw Exception('Error al cargar los animales');
      }
    } catch (e) {
      ScaffoldMessenger.of(context);
    }
  }

  Future<void> _seleccionarFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _foto = File(image.path);
      });
    }
  }

  Future<void> _tomarFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _foto = File(image.path);
      });
    }
  }

  void _mostrarDialogoFoto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar foto'),
          content: const Text('¿Cómo desea agregar la foto?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _tomarFoto();
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _seleccionarFoto();
              },
              child: const Text('Galería'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _agregarAnimal() async {
    if (_formKey.currentState!.validate()) {
      try {
        Animal nuevoAnimal = Animal(
          numeroArete: _numeroAreteController.text,
          raza: _selectedRaza!,
          sexo: _selectedSexo!,
          fechaNacimiento: _fechaNacimientoController.text,
          origen: _selectedOrigen!,
          padre: _selectedPadre,
          madre: _selectedMadre,
          adquisicion:
              _adquisicionController.text.isNotEmpty
                  ? _adquisicionController.text
                  : null, 
          fotoPath: _foto?.path,
        );

        final url = Uri.parse(getApiUrl('animales'));
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(nuevoAnimal.toMap()),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal agregado correctamente')),
          );
          _limpiarCampos();
          _cargarAnimales();
        } else {
          throw Exception('Error al agregar animal');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _consultarAnimal() async {
    String numeroArete = _numeroAreteController.text.trim();

    if (numeroArete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese un número de arete para consultar'),
        ),
      );
      return;
    }

    try {
      final url = Uri.parse(
        "${getApiUrl('animales')}?numero_arete=$numeroArete",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          Animal animal = Animal.fromMap(data[0]);

          // Aqui verificamos si los valores de padre/madre existen en la lista
          if (animal.padre != null &&
              animal.padre!.isNotEmpty &&
              !_numerosAretePadres.contains(animal.padre)) {
            _padresTemporales.add(animal.padre!);
          }

          if (animal.madre != null &&
              animal.madre!.isNotEmpty &&
              !_numerosAreteMadres.contains(animal.madre)) {
            _madresTemporales.add(animal.madre!);
          }

          setState(() {
            _animalSeleccionado = animal;
            _numeroAreteController.text = animal.numeroArete;
            _selectedRaza = animal.raza;
            _selectedSexo = animal.sexo;
            _fechaNacimientoController.text = animal.fechaNacimiento;
            _selectedOrigen = animal.origen;
            _selectedPadre = animal.padre;
            _selectedMadre = animal.madre;
            _adquisicionController.text =
                animal.adquisicion ?? ''; 

            if (animal.fotoPath != null && animal.fotoPath!.isNotEmpty) {
              _foto = File(animal.fotoPath!);
            } else {
              _foto = null;
            }
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Animal encontrado')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Animal no encontrado')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al consultar: $e')));
    }
  }

  Future<void> _modificarAnimal() async {
    if (_animalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero consulte un animal para modificar'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        Animal animalModificado = Animal(
          id: _animalSeleccionado!.id,
          numeroArete: _numeroAreteController.text,
          raza: _selectedRaza!,
          sexo: _selectedSexo!,
          fechaNacimiento: _fechaNacimientoController.text,
          origen: _selectedOrigen!,
          padre: _selectedPadre,
          madre: _selectedMadre,
          adquisicion:
              _adquisicionController.text.isNotEmpty
                  ? _adquisicionController.text
                  : null, 
          fotoPath: _foto?.path,
        );

        final url = Uri.parse(getApiUrl('animales'));
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(animalModificado.toMap()),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal modificado correctamente')),
          );
          _limpiarCampos();
          _cargarAnimales();
          _animalSeleccionado = null;
        } else {
          throw Exception('Error al modificar animal');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _eliminarAnimal() async {
    if (_animalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero consulte un animal para eliminar'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Está seguro de que desea eliminar este animal?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final dialogContext = context;

                try {
                  final url = Uri.parse(getApiUrl('animales'));
                  final response = await http.delete(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({'id': _animalSeleccionado!.id}),
                  );

                  Navigator.of(dialogContext).pop();

                  if (response.statusCode == 200) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Animal eliminado correctamente'),
                        ),
                      );
                      _limpiarCampos();
                      _cargarAnimales();
                      _animalSeleccionado = null;
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al eliminar animal'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  Navigator.of(dialogContext).pop();

                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _limpiarCampos() {
    setState(() {
      _numeroAreteController.clear();
      _selectedRaza = null;
      _selectedSexo = null;
      _fechaNacimientoController.clear();
      _selectedOrigen = null;
      _selectedPadre = null;
      _selectedMadre = null;
      _adquisicionController.clear(); 
      _foto = null;
      _animalSeleccionado = null;
      _padresTemporales.clear();
      _madresTemporales.clear();
    });
  }

  void _verListaAnimales() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('LISTA COMPLETA DE ANIMALES'),
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
                              'RAZA',
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
                              'SEXO',
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
                              'FECHA NAC.',
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
                              'PADRE',
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
                              'MADRE',
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
                              'ADQUISICION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'FOTO',
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

                    Expanded(
                      child:
                          _animales.isEmpty
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
                                itemCount: _animales.length,
                                itemBuilder: (context, index) {
                                  final animal = _animales[index];
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
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            animal.numeroArete,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            animal.raza,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            animal.sexo,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            animal.fechaNacimiento,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            animal.origen,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            animal.padre ?? '',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            animal.madre ?? '',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            animal.adquisicion ?? '',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: _buildTableImageWidget(
                                              animal.fotoPath,
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
            ),
      ),
    );
  }

  Widget _buildTableImageWidget(String? fotoPath) {
    if (fotoPath != null && fotoPath.isNotEmpty) {
      try {
        return Image.file(
          File(fotoPath),
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, size: 25, color: Colors.red);
          },
        );
      } catch (e) {
        return const Icon(Icons.pets, size: 25);
      }
    } else {
      return const Icon(Icons.pets, size: 25);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Colors.yellow[100],
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "REGISTRO DE GANADO",
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
                decoration: const InputDecoration(
                  labelText: 'Número de arete',
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 16),

              // Aqui ponemos la Raza 
              DropdownButtonFormField<String>(
                value: _selectedRaza,
                decoration: const InputDecoration(
                  labelText: 'Raza',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items:
                    _razas.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRaza = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una raza';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Aqui ponemos el Sexo 
              DropdownButtonFormField<String>(
                value: _selectedSexo,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items:
                    _sexos.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSexo = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione el sexo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Aqui ponemos la Fecha de Nacimiento
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _fechaNacimientoController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione la fecha de nacimiento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Aqui ponemos el Rancho
              DropdownButtonFormField<String>(
                value: _selectedOrigen,
                decoration: const InputDecoration(
                  labelText: 'Rancho',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items:
                    _origenes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedOrigen = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione el origen';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Aqui ponemos el Padre 
              DropdownButtonFormField<String>(
                value: _selectedPadre,
                decoration: const InputDecoration(
                  labelText: 'Padre (Opcional)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items:
                    _obtenerPadresCompletos().map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPadre = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Aqui ponemos la Madre 
              DropdownButtonFormField<String>(
                value: _selectedMadre,
                decoration: const InputDecoration(
                  labelText: 'Madre (Opcional)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items:
                    _obtenerMadresCompletas().map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedMadre = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adquisicionController,
                decoration: const InputDecoration(
                  labelText: 'Adquisicion (Opcional)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ej: Compra, Trueque, Donacion...',
                ),
              ),
              const SizedBox(height: 16),

              // Aqui Insertamos la Foto
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Insertar Foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _mostrarDialogoFoto,
                        child: const Text('Seleccionar Foto'),
                      ),
                      const SizedBox(width: 16),
                      if (_foto != null)
                        Image.file(
                          _foto!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: _agregarAnimal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Agregar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _consultarAnimal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Consultar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _modificarAnimal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Modificar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _eliminarAnimal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _limpiarCampos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Limpiar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _verListaAnimales,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text(
                      'Ver Lista',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
