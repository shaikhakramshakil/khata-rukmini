import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';

class PrintingService {
  static Future<bool> printPdfBytes(Uint8List bytes, {String? docName}) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: docName ?? 'Document.pdf',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> savePdfToFile(
    Uint8List bytes, {
    required String suggestedFileName,
  }) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Save PDF Document',
      fileName: suggestedFileName,
      bytes: bytes,
      mimeType: 'application/pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (uri != null) {
      return uri.toFilePath();
    }
    return null;
  }
}
