import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/loadingindicator.dart';
import 'package:small_pdf_maker_/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/constants/text.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';
import 'package:small_pdf_maker_/provider/pdf_provider.dart';
import 'package:small_pdf_maker_/provider/setting_provider.dart';
import 'package:small_pdf_maker_/screens/previewpdf.dart';
import 'package:small_pdf_maker_/widgets/customelevatedbutton.dart';
import 'package:uuid/uuid.dart';

class Textpdf extends ConsumerStatefulWidget {
  const Textpdf({super.key});

  @override
  ConsumerState<Textpdf> createState() => _TextpdfState();
}

class _TextpdfState extends ConsumerState<Textpdf> {
  final TextEditingController _controller = TextEditingController();
  int wordCount = 0;
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> createPdf(String text) async {
    final pdf = pw.Document();
    final words = text.split(RegExp(r"\s+"));
    const chunkSize = 500;
    int pageCount = 0;

    for (var i = 0; i < words.length; i += chunkSize) {
      final chunk = words.skip(i).take(chunkSize).join(" ");
      pdf.addPage(pw.Page(build: (_) => pw.Text(chunk)));
      pageCount++;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: JumpingDotsLoader()),
    );

    try {
      final settings = ref.read(settingsProvider);
      String baseDirPath;
      if (settings != null && settings.saveLocation.isNotEmpty) {
        baseDirPath = settings.saveLocation;
      } else {
        baseDirPath = (await getApplicationDocumentsDirectory()).path;
      }

      final dir = Directory(baseDirPath);
      if (!dir.existsSync()) await dir.create(recursive: true);

      final baseName = (settings?.defaultFileName ?? 'TextPDF').replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '',
      );
      final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
      final fileName = "${baseName}_$uniqueSuffix.pdf";
      final filePath = "${dir.path}/$fileName";

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      final newPdf = PdfModel(
        id: _uuid.v4(),
        title: fileName,
        createdAt: DateTime.now(),
        filepath: filePath,
        isFavorite: false,
        pageCount: pageCount,
      );

      ref.read(pdfListProvider.notifier).addPdf(newPdf);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Previewpdf(pdf: newPdf)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        SnackbarMessage.error(context, "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Appcolors.secondaryColor,
      body: SingleChildScrollView(
        child: Padding(
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
                  Text("Text to PDF", style: Apptext.headingtext),
                ],
              ),
              SizedBox(height: size.height * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Enter your text here", style: Apptext.bodygreybold),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Container(
                height: size.height * 0.43,
                decoration: BoxDecoration(
                  color: Appcolors.lightgreyColor,
                  border: Border.all(
                    color: Appcolors.subHeadingColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    maxLines: null,
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    onChanged: (value) {
                      final words =
                          value.trim().isEmpty
                              ? 0
                              : value.trim().split(RegExp(r"\s+")).length;
                      setState(() => wordCount = words);
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("$wordCount/5000 words", style: Apptext.bodygrey),
                ],
              ),
              SizedBox(height: size.height * 0.07),
              Customelevatedbutton(
                title: "Create PDF",
                onTap: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) {
                    SnackbarMessage.error(context, "Please enter text");
                    return;
                  }
                  if (wordCount > 5000) {
                    SnackbarMessage.error(
                      context,
                      "Word limit exceeded (max 5000)",
                    );
                    return;
                  }
                  createPdf(text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
