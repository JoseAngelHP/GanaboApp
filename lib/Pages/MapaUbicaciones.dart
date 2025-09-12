import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapaUbicaciones extends StatefulWidget {
  final Function(String)? onUbicacionSeleccionada;
  
  MapaUbicaciones({this.onUbicacionSeleccionada});
  
  @override
  _MapaUbicacionesState createState() => _MapaUbicacionesState();
}

class _MapaUbicacionesState extends State<MapaUbicaciones> {
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _ubicacionSeleccionada;
  bool _cargando = false;

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 12,
  );

  void _seleccionarUbicacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Seleccionar ubicación"),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Column(
            children: [
              // Mapa para selección visual
              Container(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng location) {
                    _actualizarCoordenadas(location);
                  },
                  myLocationEnabled: true,
                ),
              ),
              SizedBox(height: 10),
              
              // Campos para coordenadas manuales
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Latitud",
                        hintText: "Ej: 19.4326077",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _actualizarDesdeCampos(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Longitud",
                        hintText: "Ej: -99.1332080",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _actualizarDesdeCampos(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              
              // Botón para obtener dirección
              ElevatedButton(
                onPressed: _obtenerDireccionDesdeCoordenadas,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _cargando
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Obtener Dirección"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => _guardarYSalir(context),
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _actualizarCoordenadas(LatLng location) {
    setState(() {
      _ubicacionSeleccionada = location;
      _latitudController.text = location.latitude.toStringAsFixed(6);
      _longitudController.text = location.longitude.toStringAsFixed(6);
    });
  }

  void _actualizarDesdeCampos() {
    final lat = double.tryParse(_latitudController.text);
    final lng = double.tryParse(_longitudController.text);
    
    if (lat != null && lng != null) {
      setState(() {
        _ubicacionSeleccionada = LatLng(lat, lng);
      });
      
      // Mover el mapa a las nuevas coordenadas
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }
  }

  Future<void> _obtenerDireccionDesdeCoordenadas() async {
    if (_latitudController.text.isEmpty || _longitudController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingresa latitud y longitud')),
      );
      return;
    }

    final lat = double.tryParse(_latitudController.text);
    final lng = double.tryParse(_longitudController.text);

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coordenadas inválidas')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final direccion = _formatearDireccion(placemark);
        
        setState(() {
          _ubicacionController.text = direccion;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dirección obtenida correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró dirección para estas coordenadas')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener dirección: $e')),
      );
    } finally {
      setState(() => _cargando = false);
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

    return parts.isNotEmpty ? parts.join(', ') : 'Ubicación seleccionada';
  }

  void _guardarYSalir(BuildContext context) {
    if (_ubicacionSeleccionada != null) {
      final coords = _ubicacionSeleccionada!;
      final textoUbicacion = _ubicacionController.text.isNotEmpty
          ? _ubicacionController.text
          : 'Lat: ${coords.latitude.toStringAsFixed(6)}, Lng: ${coords.longitude.toStringAsFixed(6)}';

      if (widget.onUbicacionSeleccionada != null) {
        widget.onUbicacionSeleccionada!(textoUbicacion);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ubicación guardada: $textoUbicacion')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona una ubicación primero')),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Ubicación"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ubicacionController,
              decoration: InputDecoration(
                labelText: "Ubicación seleccionada",
                border: OutlineInputBorder(),
              ),
              readOnly: true,  // ✅ CORRECTO
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _seleccionarUbicacion(context),
              icon: Icon(Icons.map),
              label: Text("Seleccionar Ubicación"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ubicacionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }
}