import 'package:flutter/material.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/text.dart';

class Custompdflist extends StatelessWidget {
  final String title;
  final String pages;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteIcon;

  const Custompdflist({
    super.key,
    required this.title,
    required this.pages,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
    this.showFavoriteIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: size.height * 0.058,
            width: size.width * 0.14,
            decoration: BoxDecoration(
              border: Border.all(color: Appcolors.subHeadingColor, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                ".pdf",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Appcolors.subHeadingColor,
                ),
              ),
            ),
          ),

          SizedBox(width: size.width * 0.02),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Apptext.subheading2.copyWith(
                    fontSize: size.height * 0.018,
                  ),
                ),
                Text(pages, style: Apptext.bodygrey),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.06),
          if (showFavoriteIcon)
            IconButton(
              onPressed: onFavoriteToggle,
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color:
                    isFavorite
                        ? Appcolors.buttonColor
                        : Appcolors.subHeadingColor,
              ),
            ),
        ],
      ),
    );
  }
}
