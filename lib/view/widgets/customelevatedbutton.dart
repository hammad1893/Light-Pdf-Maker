import 'package:flutter/material.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';

class Customelevatedbutton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  const Customelevatedbutton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<Customelevatedbutton> createState() => _CustomelevatedbuttonState();
}

class _CustomelevatedbuttonState extends State<Customelevatedbutton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Appcolors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: Size(double.infinity, 50),
        elevation: 0,
      ),

      child: Text(
        widget.title,
        style: TextStyle(
          color: Appcolors.secondaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
