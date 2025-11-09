import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
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
  Future<Uint8List> generarPdfBytes(List<dynamic> pesajes) async {
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
                'Reporte de Pesajes',
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
                pw.Text('Fecha de generación: '),
                pw.Text(DateTime.now().toString().substring(0, 16)),
              ],
            ),
            pw.Row(
              children: [
                pw.Text('Total de registros: '),
                pw.Text('${pesajes.length}'),
              ],
            ),
            pw.SizedBox(height: 20),

            // Aqui ponemos la tabla de los pesajes
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
              data: [
                // Aqui ponemos los datos del encabezado
                ['Arete', 'Fecha', 'Peso (kg)', 'Rancho', 'Trabajador', 'Observaciones'],
                ...pesajes.map((pesaje) => [
                  pesaje['numero_arete']?.toString() ?? 'N/A',
                  _formatearFechaDesdeBD(pesaje['fecha_pesaje']?.toString() ?? 'N/A'),
                  pesaje['peso']?.toString() ?? 'N/A',
                  pesaje['ubicacion_direccion']?.toString() ?? 'N/A', 
                  pesaje['persona_cargo']?.toString() ?? 'N/A', 
                  pesaje['observaciones']?.toString() ?? 'N/A',
                ]).toList(),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Aqui guardamos el pdf y lo abrimos
  Future<void> guardarYAbrirPdf(List<dynamic> pesajes, String fileName) async {
    try {
      // Aqui generamos los bytes del pdf
      final bytes = await generarPdfBytes(pesajes);
      
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
      throw Exception('Error al guardar PDF: $e');
    }
  }

  // Aqui agregamos una opcion para guardar en documentos
  Future<void> guardarPdfEnDocumentos(List<dynamic> pesajes, String fileName) async {
    try {
      final bytes = await generarPdfBytes(pesajes);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }
}