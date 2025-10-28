import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';

/// Box provider
final pdfBoxProvider = Provider<Box<PdfModel>>((ref) {
  return Hive.box<PdfModel>('pdfs');
});

/// State notifier provider exposing list of PdfModel
final pdfListProvider = StateNotifierProvider<PdfNotifier, List<PdfModel>>((
  ref,
) {
  final box = ref.watch(pdfBoxProvider);
  return PdfNotifier(box);
});

class PdfNotifier extends StateNotifier<List<PdfModel>> {
  final Box<PdfModel> box;
  PdfNotifier(this.box) : super(List.from(box.values));

  /// Add a PDF using its id as the Hive key (ensures stable keys)
  void addPdf(PdfModel pdf) {
    box.put(pdf.id, pdf);
    // create a new list instance to force UI updates
    state = List.from(box.values.toList());
  }

  /// Delete PDF by model (removes physical file if exists, then deletes Hive entry)
  Future<void> deletePdf(PdfModel pdf) async {
    try {
      final file = File(pdf.filepath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete Hive entry by key (id)
      await box.delete(pdf.id);

      state = List.from(box.values.toList());
    } catch (e) {
      // still refresh state to keep UI consistent
      state = List.from(box.values.toList());
      print("Error deleting PDF: $e");
    }
  }

  /// Delete by id convenience
  Future<void> deleteById(String id) async {
    final pdf = box.get(id);
    if (pdf != null) await deletePdf(pdf);
  }

  /// Refresh state from box
  void refresh() {
    state = List.from(box.values.toList());
  }

  /// Clear everything (deletes files on disk where possible)
  Future<void> clearAllPdfs() async {
    try {
      for (var pdf in box.values) {
        final file = File(pdf.filepath);
        if (await file.exists()) await file.delete();
      }
      await box.clear();
      state = [];
    } catch (e) {
      print("Error clearing PDFs: $e");
      state = List.from(box.values.toList());
    }
  }

  Future<void> downloadPdf(PdfModel pdf) async {
    try {
      final file = File(pdf.filepath);
      if (!await file.exists()) {
        print("Original PDF file not found");
        return;
      }

      // Get Downloads directory (Android only)
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory("/storage/emulated/0/Download");
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        print("Could not resolve downloads directory");
        return;
      }

      final newPath = "${downloadsDir.path}/${pdf.title}";
      await file.copy(newPath);

      print("PDF saved to $newPath ✅");
    } catch (e) {
      print("Error downloading PDF: $e");
    }
  }
}
