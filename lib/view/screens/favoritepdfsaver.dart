import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';
import 'package:small_pdf_maker_/view/constants/text.dart';
import 'package:small_pdf_maker_/model/pdf_model.dart';
import 'package:small_pdf_maker_/view_model/pdf_provider.dart';
import 'package:small_pdf_maker_/view/screens/previewpdf.dart';
import 'package:small_pdf_maker_/view/widgets/custompdflist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import

class Favoritepdfsaver extends ConsumerStatefulWidget {
  const Favoritepdfsaver({super.key});

  @override
  ConsumerState<Favoritepdfsaver> createState() => _FavoritepdfsaverState();
}

class _FavoritepdfsaverState extends ConsumerState<Favoritepdfsaver> {
  String _sortOrder = "Descending";
  PdfModel? _selectedPdf;

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, List<PdfModel>> groupFavoritePdfs(Box<PdfModel> pdfBox) {
    final Map<String, List<PdfModel>> grouped = {
      "Today": [],
      "Last Week": [],
      "Older": [],
    };
    final now = DateTime.now();
    final sorted =
        pdfBox.values.where((pdf) => pdf.isFavorite).toList()..sort(
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

  // Fixed delete function - now takes the specific PDF to delete
  Future<void> _deletePdf(PdfModel pdfToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete PDF"),
            content: const Text("Are you sure you want to delete this PDF?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      // Use the ref from ConsumerState to access the provider
      await ref.read(pdfListProvider.notifier).deletePdf(pdfToDelete);

      if (mounted) {
        setState(() {
          // Clear selection if the deleted PDF was selected
          if (_selectedPdf == pdfToDelete) {
            _selectedPdf = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error deleting PDF: $e")));
      }
    }
  }

  // Function to remove from favorites only (without deleting the file)
  Future<void> _removeFromFavorites(PdfModel pdf) async {
    try {
      setState(() {
        pdf.isFavorite = false;
        pdf.save(); 
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error removing from favorites: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.075),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text("Favorite PDFs", style: Apptext.headingtext)],
          ),
          SizedBox(height: size.height * 0.05),
          Row(
            children: [
              Text("Favorites", style: Apptext.bodygrey),
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
              final grouped = groupFavoritePdfs(box);

              final hasFavorites = grouped.values.any(
                (list) => list.isNotEmpty,
              );

              if (!hasFavorites) {
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 60,
                            color: Appcolors.subHeadingColor,
                          ),
                          SizedBox(height: 10),
                          Text("No favorites yet", style: Apptext.subheading),
                          SizedBox(height: 5),
                          Text(
                            "Tap the star icon on any PDF to add it to favorites",
                            style: TextStyle(
                              color: Appcolors.subHeadingColor,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
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
                        ...grouped["Last Week"]!.map(
                          (pdf) => _buildPdfItem(pdf),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (grouped["Older"]!.isNotEmpty) ...[
                        Text("Older", style: Apptext.subheading),
                        const SizedBox(height: 12),
                        ...grouped["Older"]!.map((pdf) => _buildPdfItem(pdf)),
                      ],
                    ],
                  ),
                ),
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
        child: Row(
          children: [
            Expanded(
              child: Custompdflist(
                title: pdf.title,
                pages:
                    "${pdf.pageCount} ${pdf.pageCount > 1 ? 'Pages' : 'Page'}",
                showFavoriteIcon: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Previewpdf(pdf: pdf),
                    ),
                  );
                },
              ),
            ),

            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                if (value == 'remove') {
                  _removeFromFavorites(pdf);
                } else if (value == 'delete') {
                  _deletePdf(pdf); // Pass the specific PDF to delete
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text("Remove From Favorites"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text(
                            "Delete PDF",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
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
