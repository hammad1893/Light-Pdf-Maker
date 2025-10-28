import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/text.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';
import 'package:small_pdf_maker_/screens/previewpdf.dart';
import 'package:small_pdf_maker_/widgets/custompdflist.dart';

class Recentpdfsaver extends StatefulWidget {
  const Recentpdfsaver({super.key});

  @override
  State<Recentpdfsaver> createState() => _RecentpdfsaverState();
}

class _RecentpdfsaverState extends State<Recentpdfsaver> {
  String _sortOrder = "Descending"; 
  PdfModel? _selectedPdf;

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, List<PdfModel>> groupPdfs(Box<PdfModel> pdfBox) {
    final Map<String, List<PdfModel>> grouped = {
      "Today": [],
      "Last Week": [],
      "Older": [],
    };

    final now = DateTime.now();
    final sorted =
        pdfBox.values.toList()..sort(
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.07),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text("Small PDF Maker", style: Apptext.headingtext)],
          ),
          SizedBox(height: size.height * 0.05),
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

          ValueListenableBuilder(
            valueListenable: Hive.box<PdfModel>("pdfs").listenable(),
            builder: (context, Box<PdfModel> box, _) {
              if (box.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      "Create your first PDF",
                      style: Apptext.subheading,
                    ),
                  ),
                );
              }

              final grouped = groupPdfs(box);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (grouped["Today"]!.isNotEmpty) ...[
                    Text("Today", style: Apptext.subheading),
                    const SizedBox(height: 12),
                    ...grouped["Today"]!.map((pdf) => _buildPdfItem(pdf)),
                    const SizedBox(height: 20),
                  ],
                  if (grouped["Last Week"]!.isNotEmpty) ...[
                    Text("Last Week", style: Apptext.subheading),
                    const SizedBox(height: 12),
                    ...grouped["Last Week"]!.map((pdf) => _buildPdfItem(pdf)),
                    const SizedBox(height: 20),
                  ],
                  if (grouped["Older"]!.isNotEmpty) ...[
                    Text("Older", style: Apptext.subheading),
                    const SizedBox(height: 12),
                    ...grouped["Older"]!.map((pdf) => _buildPdfItem(pdf)),
                  ],
                ],
              );
            },
          ),
        ],
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
            setState(() {
              _selectedPdf = pdf;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Previewpdf(pdf: pdf)),
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

  Future<void> _openMenu() async {
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) {
      return;
    }
    final RenderBox renderBox = renderObject;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final result = await showMenu<String>(
      color: Appcolors.secondaryColor,
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 6,
        offset.dx + size.width,
        0,
      ),
      constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
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
      elevation: 8,
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
      onTap: _openMenu,
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
