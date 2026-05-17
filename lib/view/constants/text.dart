import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';

class Apptext {
  static TextStyle headingtext = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Appcolors.headingColor,
    fontFamily: GoogleFonts.poppins().fontFamily,
  );
  static TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: GoogleFonts.poppins().fontFamily,

    color: Appcolors.headingColor,
  );
  static TextStyle subheading2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,

    fontFamily: GoogleFonts.poppins().fontFamily,
    color: Appcolors.headingColor,
  );
  static const TextStyle bodygrey = TextStyle(
    fontSize: 12,
    color: Appcolors.subHeadingColor,
  );
  static const TextStyle bodygreymedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Appcolors.subHeadingColor,
  );
  static const TextStyle bodygreybold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Appcolors.subHeadingColor,
  );
}
