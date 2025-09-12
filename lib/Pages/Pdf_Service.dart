import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  // Método para formatear fecha desde BD
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

  // Generar PDF y obtener bytes
  Future<Uint8List> generarPdfBytes(List<dynamic> pesajes) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Encabezado
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
            
            // Información del reporte
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

            // Tabla de pesajes
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
              data: [
                ['Arete', 'Fecha', 'Peso (kg)', 'Ubicación', 'Persona', 'Observaciones'],
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

  // Guardar PDF en dispositivo y abrirlo
  Future<void> guardarYAbrirPdf(List<dynamic> pesajes, String fileName) async {
    try {
      // Generar bytes del PDF
      final bytes = await generarPdfBytes(pesajes);
      
      // Obtener directorio de descargas
      final directory = await getExternalStorageDirectory();
      final path = directory?.path;
      
      if (path == null) {
        throw Exception('No se pudo acceder al almacenamiento');
      }
      
      // Crear archivo
      final file = File('$path/$fileName.pdf');
      await file.writeAsBytes(bytes);
      
      // Abrir archivo
      await OpenFile.open(file.path);
      
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }

  // Alternativa para guardar en directorio de documentos
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