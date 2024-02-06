import 'package:flutter/material.dart';

class CardContents extends StatelessWidget {
  IconData icon;
  String label;
  // String? label2;
  // String? label2Cont;
  Color? colour;
  CardContents({
    super.key,
    required this.icon,
    required this.label,
    this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 50.0,
          color: colour,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
      ],
    );
  }
}
