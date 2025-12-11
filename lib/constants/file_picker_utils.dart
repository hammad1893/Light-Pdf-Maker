import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:small_pdf_maker_/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/screens/imagepdf.dart';
import 'package:small_pdf_maker_/screens/mergepdfscreen.dart';
import 'package:small_pdf_maker_/screens/previewpdf.dart';
import '../constants/loadingindicator.dart';

class FilePickerUtils {
  /// ✅ Central permission checker with custom dialog
  static Future<bool> _checkPermission(
    BuildContext context,
    Permission permission,
    String rationale,
  ) async {
    var status = await permission.status;

    if (status.isGranted) return true;

    // Request once
    status = await permission.request();
    if (status.isGranted) return true;

    if (status.isDenied) {
      // Ask again once
      status = await permission.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Permission Required"),
              content: Text(
                "$rationale\n\nPlease enable it from settings to continue.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: const Text("Open Settings"),
                ),
              ],
            ),
      );
    }

    return false;
  }

  /// ✅ FAB call
  static Future<void> openFilePicker(BuildContext context) async {
    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: JumpingDotsLoader()),
    );

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        int sdkInt = androidInfo.version.sdkInt;

        bool granted = false;

        if (sdkInt >= 30) {
          granted = await _checkPermission(
            context,
            Permission.manageExternalStorage,
            "Storage permission is needed to pick files.",
          );
        } else {
          granted = await _checkPermission(
            context,
            Permission.storage,
            "Storage permission is needed to pick files.",
          );
        }

        Navigator.pop(context); // remove loader

        if (granted) {
          await _openFileManager(context);
        } else {
          SnackbarMessage.error(context, "Storage permission is required!");
        }
      } else if (Platform.isIOS) {
        Navigator.pop(context); // remove loader
        bool granted = await _checkPermission(
          context,
          Permission.photos,
          "Photo library access is needed to pick images.",
        );

        if (granted) {
          await _openFileManager(context);
        } else {
          SnackbarMessage.error(context, "Photo permission is required!");
        }
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarMessage.error(context, "Error: $e");
    }
  }

  /// ✅ System file manager
  static Future<void> _openFileManager(BuildContext context) async {
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

    if (result == null || result.files.isEmpty) {
      return;
    }

    final files = result.files;

    // Detect file types
    final hasImages = files.any(
      (f) =>
          f.extension?.toLowerCase() == "jpg" ||
          f.extension?.toLowerCase() == "jpeg" ||
          f.extension?.toLowerCase() == "png",
    );
    final hasPdfs = files.any((f) => f.extension?.toLowerCase() == "pdf");
    final hasDocs = files.any(
      (f) =>
          ["doc", "docx", "xls", "xlsx"].contains(f.extension?.toLowerCase()),
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
            builder:
                (_) => Previewpdf(
                  platformFile: result.files.single,
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
  }

  static requestStoragePermission() {}
}
