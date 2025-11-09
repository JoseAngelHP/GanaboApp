import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfServiced {
  // Aqui ponemos el formato de la fecha
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

  // Aqui generamos el pdf y obtenemos los bytes
  Future<Uint8List> generarPdfBytes(List<dynamic> registros) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Aqui ponemos el encabezado de la hoja
            pw.Header(
              level: 0,
              child: pw.Text(
                'Reporte de Producción de Leche',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Aqui ponemos la informacion del reporte
            pw.Row(
              children: [
                pw.Text('Fecha de generación: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(DateTime.now().toString().substring(0, 16)),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Text('Total de registros: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${registros.length}'),
              ],
            ),
            pw.SizedBox(height: 20),

            // Aqui ponemos la tabla de producción de leche
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
              data: [
                ['N° Arete', 'Fecha Ordeño', 'Cantidad (L)', 'Rancho', 'Persona a Cargo', 'Observaciones'],
                ...registros.map((registro) => [
                  registro['numero_arete']?.toString() ?? 'N/A',
                  _formatearFechaDesdeBD(registro['fecha_ordeño']?.toString() ?? 'N/A'),
                  registro['cantidad_leche']?.toString() ?? 'N/A',
                  registro['rancho_asig']?.toString() ?? 'N/A',
                  registro['persona_cargo']?.toString() ?? 'N/A',
                  registro['observaciones']?.toString() ?? 'N/A',
                ]).toList(),
              ],
            ),
            _crearResumenEstadistico(registros),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _crearResumenEstadistico(List<dynamic> registros) {

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
    );
  }

  // Aqui guardamos el pdf y lo abrimos
  Future<void> guardarYAbrirPdf(List<dynamic> registros, String fileName) async {
    try {
      // Aqui generamos los bytes del pdf
      final bytes = await generarPdfBytes(registros);
      
      // Aqui agregamos el directorio de descargas
      final directory = await getExternalStorageDirectory();
      final path = directory?.path;
      
      if (path == null) {
        throw Exception('No se pudo acceder al almacenamiento');
      }
      
      // Aqui creamos el archivo
      final file = File('$path/$fileName.pdf');
      await file.writeAsBytes(bytes);
      
      // Aqui abrimos el archivo
      await OpenFile.open(file.path);
      
    } catch (e) {
      await guardarPdfEnDocumentos(registros, fileName);
    }
  }

  // Aqui agregamos una opcion para guardar en documentos
  Future<void> guardarPdfEnDocumentos(List<dynamic> registros, String fileName) async {
    try {
      final bytes = await generarPdfBytes(registros);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }
}