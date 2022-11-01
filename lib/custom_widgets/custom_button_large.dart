import 'package:flutter/material.dart';
import '../utils/colors.dart';

class CustomButtonLarge extends StatelessWidget {
  final String title;
  bool hasWidth;
  Color color;
  CustomButtonLarge({
    Key? key,
    required this.title,
    this.hasWidth = false,
    this.color = primaryColorLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: hasWidth ? 100 : double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
