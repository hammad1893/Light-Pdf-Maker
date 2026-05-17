import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:small_pdf_maker_/view/constants/back_button_handler.dart';
import 'package:small_pdf_maker_/view/widgets/customelevatedbutton.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';
import 'package:small_pdf_maker_/view/constants/loadingindicator.dart';
import 'package:small_pdf_maker_/view/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/view/constants/text.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';
import 'package:small_pdf_maker_/view_model/pdf_provider.dart';
import 'package:small_pdf_maker_/view/screens/bottomnavigation.dart';

class Previewpdf extends ConsumerStatefulWidget {
  final PdfModel? pdf;
  final PlatformFile? platformFile;
  final bool savePlatformFileToProvider;

  const Previewpdf({
    super.key,
    this.pdf,
    this.platformFile,
    this.savePlatformFileToProvider = false,
  }) : assert(
          pdf != null || platformFile != null,
          'Either pdf or platformFile must be provided',
        );

  @override
  ConsumerState<Previewpdf> createState() => _PreviewpdfState();
}

class _PreviewpdfState extends ConsumerState<Previewpdf> {
  PdfControllerPinch? _pdfController;
  int currentPage = 1;
  int totalPages = 1;
  bool _isLoading = true;
  PdfModel? _resolvedPdf;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _initFlow();
  }

  Future<void> _initFlow() async {
    setState(() => _isLoading = true);

    try {
      if (widget.pdf != null) {
        _resolvedPdf = widget.pdf;
        totalPages = _resolvedPdf!.pageCount;
        await _initControllerForPath(_resolvedPdf!.filepath);
      } else if (widget.platformFile != null) {
        final pf = widget.platformFile!;
        final path = pf.path;

        if (path == null) {
          SnackbarMessage.error(context, "File path is null");
          if (mounted) Navigator.pop(context);
          return;
        }

        final file = File(path);
        if (!await file.exists()) {
          SnackbarMessage.error(context, "File not found");
          if (mounted) Navigator.pop(context);
          return;
        }

        await _initControllerForPath(path);

        final newPdf = PdfModel(
          id: _uuid.v4(),
          title: pf.name,
          filepath: path,
          pageCount: totalPages,
          createdAt: DateTime.now(),
          isFavorite: false,
        );

        if (widget.savePlatformFileToProvider) {
          ref.read(pdfListProvider.notifier).addPdf(newPdf);
        }

        _resolvedPdf = newPdf;
      }
    } catch (e) {
      SnackbarMessage.error(context, "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initControllerForPath(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        SnackbarMessage.error(context, "PDF file does not exist");
        return;
      }

      // Dispose old controller safely
      _pdfController?.dispose();

      // Open document first
      final doc = await PdfDocument.openFile(path);

      // Setup controller after document loaded
      _pdfController = PdfControllerPinch(document: PdfDocument.openFile(path));

      if (mounted) {
        setState(() {
          totalPages = doc.pagesCount;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarMessage.error(context, "Error loading PDF: $e");
      }
    }
  }

  Future<void> _deletePdf() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete PDF", style: Apptext.headingtext),
        content: Text(
          "Are you sure you want to delete this PDF?",
          style: Apptext.subheading2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Appcolors.subHeadingColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: TextStyle(color: Appcolors.buttonColor),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (_resolvedPdf != null) {
        await ref.read(pdfListProvider.notifier).deletePdf(_resolvedPdf!);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) SnackbarMessage.error(context, "Error deleting PDF: $e");
    }
  }

  void _goToNextPage() {
    if (currentPage < totalPages) {
      _pdfController?.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      _pdfController?.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => BackButtonHandler.handleBackButton(context),
      child: Scaffold(
        backgroundColor: Appcolors.secondaryColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainHome()),
                        );
                      },
                      child: const Icon(Icons.arrow_back, size: 28),
                    ),
                    const SizedBox(width: 10),
                    Text("PDF Preview", style: Apptext.headingtext),
                    const Spacer(),
                    GestureDetector(
                      onTap: _deletePdf,
                      child: Image.asset(
                        "assets/images/delete.png",
                        height: 22,
                        width: 22,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          if (_resolvedPdf == null) {
                            SnackbarMessage.error(context, "PDF not found");
                            return;
                          }

                          final file = File(_resolvedPdf!.filepath);

                          if (!await file.exists()) {
                            SnackbarMessage.error(context, "File not found");
                            return;
                          }

                          await Share.shareXFiles(
                            [XFile(file.path)],
                            text: _resolvedPdf!.title,
                          );
                        } catch (e) {
                          SnackbarMessage.error(context, "Share failed: $e");
                          print("Error sharing PDF: $e");
                        }
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 29,
                        color: Appcolors.headingColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: JumpingDotsLoader())
                    : Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _pdfController != null
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  width: double.infinity,
                                  child: PdfViewPinch(
                                    controller: _pdfController!,
                                    onPageChanged: (page) {
                                      if (mounted) {
                                        setState(() => currentPage = page);
                                      }
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Text("Error loading PDF"),
                                ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: currentPage > 1
                          ? Appcolors.subHeadingColor
                          : Colors.grey,
                      onPressed: currentPage > 1 ? _goToPreviousPage : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Page $currentPage of $totalPages",
                      style: Apptext.bodygreybold,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      color: currentPage < totalPages
                          ? Appcolors.subHeadingColor
                          : Colors.grey,
                      onPressed:
                          currentPage < totalPages ? _goToNextPage : null,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: SizedBox(
                  height: size.height * 0.07,
                  width: size.width,
                  child: Customelevatedbutton(
                      title: "Download PDF",
                      onTap: () {
                        if (_resolvedPdf != null) {
                          ref
                              .read(pdfListProvider.notifier)
                              .downloadPdf(_resolvedPdf!, context);
                        } else {
                          SnackbarMessage.error(context, "PDF not found");
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
