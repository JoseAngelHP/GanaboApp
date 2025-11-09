import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfServicet {
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
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            // Aqui ponemos el encabezado de la hoja
            pw.Header(
              level: 0,
              child: pw.Text(
                'REPORTE DE VACUNACIONES',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 15),
            
            // Aqui ponemos la informacion del reporte
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Fecha de generación: ${DateTime.now().toString().substring(0, 16)}',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('Total de registros: ${registros.length}',
                        style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // Aqui ponemos la tabla de las vacunaciones
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
              columnWidths: {
                0: pw.FlexColumnWidth(2), // N° Arete
                1: pw.FlexColumnWidth(2), // Fecha Vac.
                2: pw.FlexColumnWidth(2), // Medicamento
                3: pw.FlexColumnWidth(2), // Vía Admin.
                4: pw.FlexColumnWidth(1), // Dosis
                5: pw.FlexColumnWidth(2), // Trabajador
                6: pw.FlexColumnWidth(2), // Próxima Vac.
                7: pw.FlexColumnWidth(2), // Observaciones
              },
              children: [
                // // Aqui ponemos los datos del encabezado
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF37474F)), 
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('N° ARETE',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('FECHA VAC.',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('MEDICAMENTO', 
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('VÍA ADMIN.',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('DOSIS',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('TRABAJADOR', 
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('PRÓXIMA VAC.',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('OBSERVACIONES',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center),
                    ),
                  ],
                ),
                ...registros.asMap().entries.map((entry) {
                  final index = entry.key;
                  final registro = entry.value;
                  final bgColor = index.isEven 
                      ? PdfColor.fromInt(0xFFFAFAFA) 
                      : PdfColors.white; 
                  
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bgColor),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          registro['numero_arete']?.toString() ?? 'N/A',
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          _formatearFechaDesdeBD(registro['fecha_vacunacion']?.toString() ?? 'N/A'),
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          registro['vacuna_aplicada']?.toString() ?? 'N/A', 
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          registro['via_administracion']?.toString() ?? 'N/A', 
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          registro['dosis']?.toString() ?? 'N/A',
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          registro['aplicador']?.toString() ?? 'N/A', 
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          registro['proxima_vacunacion'] != null 
                              ? _formatearFechaDesdeBD(registro['proxima_vacunacion'].toString())
                              : 'N/A',
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          registro['observaciones']?.toString() ?? 'Sin observaciones',
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
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
      
      // Abrir archivo
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }
}