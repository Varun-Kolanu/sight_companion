import 'package:flutter/material.dart';

class MediumButton extends StatelessWidget {
  final Color color;
  final String text;
  final VoidCallback onTap;

  const MediumButton({
    super.key,
    required this.color,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        color: color,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
