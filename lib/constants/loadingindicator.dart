import 'package:flutter/material.dart';
import 'package:small_pdf_maker_/constants/colors.dart';

class JumpingDotsLoader extends StatefulWidget {
  final Color color;
  final double size;
  final int numDots;

  const JumpingDotsLoader({
    super.key,
    this.color = Appcolors.buttonColor,
    this.size = 26,
    this.numDots = 3,
  });

  @override
  State<JumpingDotsLoader> createState() => _JumpingDotsLoaderState();
}

class _JumpingDotsLoaderState extends State<JumpingDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.numDots, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double t = (_controller.value * widget.numDots - index).clamp(
              0.0,
              1.0,
            );
            double scale = 0.5 + (0.5 * (1 - (t - 0.5).abs() * 2));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
              transform: Matrix4.identity()..scale(scale, scale),
            );
          },
        );
      }),
    );
  }
}
