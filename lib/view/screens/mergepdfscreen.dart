import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';
import 'package:small_pdf_maker_/view/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/view/constants/text.dart';
import 'package:small_pdf_maker_/view_model/setting_provider.dart';
import 'package:small_pdf_maker_/view/screens/previewpdf.dart';
import 'package:small_pdf_maker_/view/widgets/customelevatedbutton.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';
import 'package:small_pdf_maker_/view_model/pdf_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:uuid/uuid.dart';

class Mergepdfscreen extends ConsumerStatefulWidget {
  final List<PlatformFile> selectedFiles;
  const Mergepdfscreen({super.key, required this.selectedFiles});

  @override
  ConsumerState<Mergepdfscreen> createState() => _MergepdfscreenState();
}

class _MergepdfscreenState extends ConsumerState<Mergepdfscreen> {
  late List<PlatformFile> selectedFiles;
  bool _isMerging = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    selectedFiles = widget.selectedFiles;
    for (var f in selectedFiles) {
      debugPrint("📂 File picked: ${f.name} | path: ${f.path}");
    }
  }

  Future<void> mergeSelectedPdfs() async {
    if (selectedFiles.isEmpty) {
      SnackbarMessage.error(context, "Please select at least one PDF");
      return;
    }

    setState(() => _isMerging = true);

    try {
      final settings = ref.read(settingsProvider);
      final baseDirPath =
          settings?.saveLocation ??
          (await getApplicationDocumentsDirectory()).path;

      final dir = Directory(baseDirPath);
      if (!dir.existsSync()) await dir.create(recursive: true);

      final prefix = settings?.defaultFileName ?? "PDF";
      final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
      final mergedPath = "${dir.path}/${prefix}_$uniqueSuffix.pdf";

      if (selectedFiles.length == 1) {
        final file = File(selectedFiles.first.path!);
        await file.copy(mergedPath);
      } else {
        await PdfCombiner.mergeMultiplePDFs(
          inputPaths: selectedFiles.map((f) => f.path!).toList(),
          outputPath: mergedPath,
        );
      }

      final mergedFile = File(mergedPath);
      if (!mergedFile.existsSync() || mergedFile.lengthSync() == 0) {
        throw Exception("Merged file is empty or missing");
      }

      int pageCount = 0;
      try {
        final pdfDoc = await PdfDocument.openFile(mergedPath);
        pageCount = pdfDoc.pagesCount;
        await pdfDoc.close(); 
      } catch (e) {
        debugPrint("⚠️ Error counting pages: $e");
      }

      final newPdf = PdfModel(
        id: _uuid.v4(),
        title: "${prefix}_$uniqueSuffix.pdf",
        filepath: mergedPath,
        pageCount: pageCount,
        createdAt: DateTime.now(),
        isFavorite: false,
      );

      ref.read(pdfListProvider.notifier).addPdf(newPdf);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Previewpdf(pdf: newPdf)),
        );
      }
    } catch (e) {
      debugPrint("❌ Error merging PDFs: $e");
      if (mounted) {
        SnackbarMessage.error(context, "Failed to merge PDFs");
      }
    } finally {
      if (mounted) setState(() => _isMerging = false);
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
                Text("Merge PDFs", style: Apptext.headingtext),
              ],
            ),
            SizedBox(height: size.height * 0.03),

            Expanded(
              child:
                  selectedFiles.isEmpty
                      ? Center(
                        child: Text(
                          "Pick multiple PDFs to merge",
                          style: Apptext.subheading,
                        ),
                      )
                      : ListView.builder(
                        itemCount: selectedFiles.length,
                        itemBuilder: (context, index) {
                          final file = selectedFiles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  height: size.height * 0.058,
                                  width: size.width * 0.14,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Appcolors.subHeadingColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      ".pdf",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Expanded(
                                  child: Text(
                                    file.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: Apptext.subheading2.copyWith(
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.06),
                                GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => selectedFiles.removeAt(index),
                                      ),
                                  child: Image.asset(
                                    "assets/images/delete.png",
                                    height: 25,
                                    width: 24,
                                    color: const Color(0xffFF4D4D),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),

            if (selectedFiles.isNotEmpty) ...[
              _isMerging
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : Customelevatedbutton(
                    title: "Merge PDF (${selectedFiles.length})",
                    onTap: mergeSelectedPdfs,
                  ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
