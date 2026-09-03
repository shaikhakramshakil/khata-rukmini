import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PrintingService {
  /// Resolves the default directory for saving invoices: ~/Documents/Khata_Invoices
  static Future<Directory> getDefaultInvoicesDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory(p.join(docsDir.path, 'Khata_Invoices'));
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }
    return invoicesDir;
  }

  /// Prints PDF bytes using system print dialog with document name
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

  /// Automatically saves PDF directly into the dedicated Invoices folder
  /// without opening a file prompt, and returns the saved File.
  static Future<File> savePdfDirectly(
    Uint8List bytes, {
    required String fileName,
    String? customTargetDirectory,
  }) async {
    final targetDir = customTargetDirectory != null &&
            customTargetDirectory.trim().isNotEmpty
        ? Directory(customTargetDirectory.trim())
        : await getDefaultInvoicesDirectory();

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    // Sanitize filename for Windows/Linux filesystems
    var cleanName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (!cleanName.toLowerCase().endsWith('.pdf')) {
      cleanName = '$cleanName.pdf';
    }

    final destination = File(p.join(targetDir.path, cleanName));
    await destination.writeAsBytes(bytes);
    return destination;
  }

  /// Manual save dialog with file picker (fallback option)
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
