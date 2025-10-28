
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/loadingindicator.dart';
import 'package:small_pdf_maker_/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/constants/text.dart';
import 'package:small_pdf_maker_/provider/setting_provider.dart';
import 'package:small_pdf_maker_/screens/previewpdf.dart';
import 'package:small_pdf_maker_/widgets/customelevatedbutton.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';
import 'package:small_pdf_maker_/provider/pdf_provider.dart';
import 'package:small_pdf_maker_/constants/permission_utils.dart'; 
import 'package:uuid/uuid.dart';

class ImagePdf extends ConsumerStatefulWidget {
  final List<PlatformFile> selectedFiles;
  final List<PlatformFile> initialFiles;

  const ImagePdf({
    super.key,
    required this.selectedFiles,
    required this.initialFiles,
  });

  @override
  ConsumerState<ImagePdf> createState() => _ImagePdfState();
}

class _ImagePdfState extends ConsumerState<ImagePdf> {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = Uuid();

  List<File> imageList = [];

  @override
  void initState() {
    super.initState();
    // take initial files from FAB
    imageList =
        widget.selectedFiles
            .map((f) => File(f.path!))
            .where((file) => file.existsSync())
            .toList();
  }

  Future<void> pickImagesFromGallery() async {
    final granted = await QuickPermissionUtils.checkGalleryPermission(context);
    if (!granted) {
      SnackbarMessage.error(context, "Gallery permission denied");
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        imageList.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final granted = await QuickPermissionUtils.checkCameraPermission(context);
    if (!granted) {
      SnackbarMessage.error(context, "Camera permission denied");
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        imageList.add(File(pickedFile.path));
      });
    }
  }

  Future<void> createPdf() async {
    if (imageList.isEmpty) {
      SnackbarMessage.error(context, "Please select at least one image");
      return;
    }
    // Check storage permission before creating PDF
    final storageGranted = await QuickPermissionUtils.checkStoragePermission(
      context,
    );
    if (!storageGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Storage permission required to store PDF"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: JumpingDotsLoader()),
    );

    final pdf = pw.Document();
    int pageCount = 0;
    try {
      for (var img in imageList) {
        final image = pw.MemoryImage(await img.readAsBytes());

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4, // standard A4 page
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain, // make sure it fits without cutting
                ),
              );
            },
          ),
        );
        pageCount++;
      }

      final settings = ref.read(settingsProvider);
      final baseDirPath =
          settings?.saveLocation ??
          (await getApplicationDocumentsDirectory()).path;
      final dir = Directory(baseDirPath);
      if (!dir.existsSync()) await dir.create(recursive: true);

      final baseName = (settings?.defaultFileName ?? 'ImagePDF').replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '',
      );
      final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
      final fileName = "${baseName}_$uniqueSuffix.pdf";
      final filePath = "${dir.path}/$fileName";

      final out = File(filePath);
      await out.writeAsBytes(await pdf.save());

      final newPdf = PdfModel(
        id: _uuid.v4(),
        title: fileName,
        createdAt: DateTime.now(),
        filepath: filePath,
        pageCount: pageCount,
        isFavorite: false,
      );

      ref.read(pdfListProvider.notifier).addPdf(newPdf);

      if (mounted) Navigator.pop(context); 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Previewpdf(pdf: newPdf)),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      SnackbarMessage.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Appcolors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.06),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: Appcolors.headingColor,
                    size: 30,
                  ),
                ),
                SizedBox(width: size.width * 0.05),
                Text("Image to PDF", style: Apptext.headingtext),
              ],
            ),
            SizedBox(height: size.height * 0.05),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: pickImagesFromGallery,
                  child: Container(
                    height: size.height * 0.06,
                    width: size.width * 0.474,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Appcolors.headingColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: size.width * 0.02),
                        Icon(
                          Icons.photo,
                          size: 24,
                          color: Appcolors.headingColor,
                        ),
                        SizedBox(width: size.width * 0.01),
                        Text(
                          "Select from Gallery",
                          style: TextStyle(
                            fontSize: 14,
                            color: Appcolors.headingColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: pickImageFromCamera,
                  child: Container(
                    height: size.height * 0.06,
                    width: size.width * 0.34,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Appcolors.headingColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: size.width * 0.02),
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 24,
                          color: Appcolors.headingColor,
                        ),
                        SizedBox(width: size.width * 0.01),
                        Text(
                          "Take photo",
                          style: TextStyle(
                            fontSize: 14,
                            color: Appcolors.headingColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.03),

            Row(
              children: [
                Text(
                  "Selected Images (${imageList.length})",
                  style: Apptext.subheading,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff2f8ff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: imageList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    final file = imageList[index];
                    return Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xffdadfe6),
                        border: Border.all(
                          color: Appcolors.subHeadingColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                          ),
                          _badge("${index + 1}"),
                          _deleteBtn(() {
                            setState(() => imageList.removeAt(index));
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: size.height * 0.05),

            Customelevatedbutton(
              title: "Create PDF (${imageList.length})",
              onTap: createPdf,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) => Positioned(
    top: 10,
    left: 10,
    child: Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: Appcolors.buttonColor,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _deleteBtn(VoidCallback onTap) => Positioned(
    top: 10,
    right: 10,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 20,
        width: 20,
        decoration: const BoxDecoration(
          color: Color(0xffFF4D4D),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 14, color: Colors.white),
      ),
    ),
  );
}
