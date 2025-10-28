import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/permission_utils.dart';
import 'package:small_pdf_maker_/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/constants/text.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';
import 'package:small_pdf_maker_/provider/pdf_provider.dart';
import 'package:small_pdf_maker_/screens/imagepdf.dart';
import 'package:small_pdf_maker_/screens/mergepdfscreen.dart';
import 'package:small_pdf_maker_/screens/previewpdf.dart';
import 'package:small_pdf_maker_/screens/settingscreen.dart';
import 'package:small_pdf_maker_/screens/textpdf.dart';
import 'package:small_pdf_maker_/widgets/custompdflist.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  String _sortOrder = "descending";
  PdfModel? _selectedPdf;

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, List<PdfModel>> groupPdfs(List<PdfModel> pdfs) {
    final Map<String, List<PdfModel>> grouped = {
      "Today": [],
      "Last Week": [],
      "Older": [],
    };

    final now = DateTime.now();
    final sorted = [...pdfs]..sort(
      (a, b) =>
          _sortOrder == "Ascending"
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt),
    );

    for (var pdf in sorted) {
      if (isSameDate(pdf.createdAt, now)) {
        grouped["Today"]!.add(pdf);
      } else if (now.difference(pdf.createdAt).inDays <= 7) {
        grouped["Last Week"]!.add(pdf);
      } else {
        grouped["Older"]!.add(pdf);
      }
    }
    return grouped;
  }

  Future<void> _showCustomDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title, style: Apptext.headingtext),
          content: Text(message, style: Apptext.bodygrey),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfs = ref.watch(pdfListProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Appcolors.secondaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Appcolors.secondaryColor,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Small PDF Maker", style: Apptext.headingtext),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Settingscreen()),
                );
              },
              icon: const Icon(
                Icons.settings,
                size: 30,
                color: Appcolors.headingColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.06),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Textpdf()),
                  );
                },
                child: _buildCreatorCard(
                  size,
                  color: const Color(0xff57CAEB),
                  borderColor: Appcolors.buttonColor,
                  image: "assets/images/text.png",
                  title: "Text to PDF",
                  subtitle:
                      "Convert notes or plain text into professional PDF documents",
                ),
              ),
              SizedBox(height: size.height * 0.024),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const ImagePdf(
                            initialFiles: [],
                            selectedFiles: [],
                          ),
                    ),
                  );
                },
                child: _buildCreatorCard(
                  size,
                  color: const Color(0xffFF7976),
                  borderColor: const Color(0xffFF4D4D),
                  image: "assets/images/image.png",
                  title: "Image to PDF",
                  subtitle:
                      "Combine multiple images (JPG, PNG) into a single PDF file",
                ),
              ),
              SizedBox(height: size.height * 0.024),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  bool granted =
                      await QuickPermissionUtils.checkStoragePermission(
                        context,
                      );

                  if (!granted) {
                    _showCustomDialog(
                      "Permission Required",
                      "Storage permission is needed to merge PDFs. Please allow it.",
                    );
                    return;
                  }

                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                        allowMultiple: true,
                      );

                  if (result != null && result.files.isNotEmpty) {
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => Mergepdfscreen(selectedFiles: result.files),
                      ),
                    );
                  }
                },
                child: _buildCreatorCard(
                  size,
                  color: const Color(0xff28C76F),
                  borderColor: const Color(0xff28C76F),
                  image: "assets/images/image.png",
                  title: "Merge PDFs",
                  subtitle: "Convert Multiple PDFs in one File",
                ),
              ),
              SizedBox(height: size.height * 0.03),

              Row(
                children: [
                  Text("Recents", style: Apptext.bodygrey),
                  const Spacer(),
                  SortDropdown(
                    currentSort: _sortOrder,
                    onChanged: (val) {
                      setState(() {
                        _sortOrder = val;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.025),

              if (pdfs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      "Create your first PDF",
                      style: Apptext.subheading.copyWith(
                        color: const Color(0xff2C3D7A),
                      ),
                    ),
                  ),
                )
              else
                ..._buildGroupedPdfs(groupPdfs(pdfs)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedPdfs(Map<String, List<PdfModel>> grouped) {
    final List<Widget> sections = [];

    grouped.forEach((label, pdfs) {
      if (pdfs.isNotEmpty) {
        sections.add(Text(label, style: Apptext.subheading));
        sections.add(const SizedBox(height: 12));
        sections.addAll(pdfs.map(_buildPdfItem));
        sections.add(const SizedBox(height: 20));
      }
    });

    return sections;
  }

  Widget _buildCreatorCard(
    Size size, {
    required Color color,
    required Color borderColor,
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: size.height * 0.15,
      width: size.width,
      decoration: BoxDecoration(
        color: Appcolors.lightgreyColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.02),
            Row(
              children: [
                Container(
                  height: size.height * 0.05,
                  width: size.width * 0.11,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      image,
                      height: 26,
                      width: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Text(title, style: Apptext.headingtext),
              ],
            ),
            SizedBox(height: size.height * 0.015),
            Text(subtitle, style: Apptext.bodygrey),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfItem(PdfModel pdf) {
    final isSelected = _selectedPdf == pdf;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Appcolors.lightgreyColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Custompdflist(
          title: pdf.title,
          pages: "${pdf.pageCount} ${pdf.pageCount > 1 ? 'Pages' : 'Page'}",
          isFavorite: pdf.isFavorite,
          onTap: () {
            setState(() => _selectedPdf = pdf);

            if (pdf.filepath.isEmpty) {
              SnackbarMessage.error(context, "File not found!");
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Previewpdf(pdf: pdf)),
            );
          },
          onFavoriteToggle: () {
            setState(() {
              pdf.isFavorite = !pdf.isFavorite;
              pdf.save();
            });
          },
        ),
      ),
    );
  }
}

class SortDropdown extends StatefulWidget {
  final String currentSort;
  final void Function(String) onChanged;

  const SortDropdown({
    super.key,
    required this.currentSort,
    required this.onChanged,
  });

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  final GlobalKey _key = GlobalKey();

  Future<void> openMenu() async {
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) {
      return;
    }
    final RenderBox renderBox = renderObject;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final result = await showMenu<String>(
      context: context,
      color: Appcolors.secondaryColor,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 6,
        offset.dx + size.width,
        0,
      ),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 250),
      items: [
        PopupMenuItem<String>(
          value: "Ascending",
          child: Text("Ascending", style: Apptext.subheading2),
        ),
        PopupMenuDivider(height: 2),
        PopupMenuItem<String>(
          value: "Descending",
          child: Text("Descending", style: Apptext.subheading2),
        ),
      ],
    );
    if (result != null) {
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData sortIcon =
        widget.currentSort == "Ascending"
            ? Icons.keyboard_arrow_up
            : Icons.keyboard_arrow_down;
    return GestureDetector(
      key: _key,
      onTap: openMenu,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Sort by date", style: Apptext.bodygrey),
          const SizedBox(width: 6),
          Icon(sortIcon, size: 20, color: Appcolors.buttonColor),
        ],
      ),
    );
  }
}
