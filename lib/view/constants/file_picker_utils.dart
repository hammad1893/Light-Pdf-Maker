import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:small_pdf_maker_/view/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/view/screens/imagepdf.dart';
import 'package:small_pdf_maker_/view/screens/mergepdfscreen.dart';
import 'package:small_pdf_maker_/view/screens/previewpdf.dart';
import 'loadingindicator.dart';

class FilePickerUtils {
  /// ✅ FAB call – NO PERMISSION REQUIRED (SAF)
  static Future<void> openFilePicker(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: JumpingDotsLoader()),
    );

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
        ],
      );

      Navigator.pop(context); // remove loader

      if (result == null || result.files.isEmpty) return;

      final files = result.files;

      final hasImages = files.any(
        (f) => ['jpg', 'jpeg', 'png'].contains(f.extension?.toLowerCase()),
      );
      final hasPdfs = files.any((f) => f.extension?.toLowerCase() == 'pdf');
      final hasDocs = files.any(
        (f) =>
            ['doc', 'docx', 'xls', 'xlsx'].contains(f.extension?.toLowerCase()),
      );

      int typeCount = [hasImages, hasPdfs, hasDocs].where((e) => e).length;
      if (typeCount > 1) {
        SnackbarMessage.error(context, "Please select only one file type!");
        return;
      }

      if (hasImages) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImagePdf(selectedFiles: files, initialFiles: files),
          ),
        );
      } else if (hasPdfs) {
        if (files.length == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Previewpdf(
                platformFile: files.single,
                savePlatformFileToProvider: true,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Mergepdfscreen(selectedFiles: files),
            ),
          );
        }
      } else if (hasDocs) {
        SnackbarMessage.info(context, "Word/Excel to PDF coming soon!");
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarMessage.error(context, "Error: $e");
    }
  }
}
