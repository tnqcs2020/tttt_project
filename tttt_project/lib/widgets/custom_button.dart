import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final double height, width, borderRadius;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color,
    this.height = 60,
    this.width = double.infinity,
    this.borderRadius = 20,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        backgroundColor: backgroundColor ?? Colors.blue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
