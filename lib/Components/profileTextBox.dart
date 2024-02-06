import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTextBox extends StatelessWidget {
  final String title;
  final String titleValue;
  final void Function()? function;
  const ProfileTextBox(
      {super.key,
      required this.title,
      required this.titleValue,
      this.function});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF111328),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title:',
                  style: GoogleFonts.lato(
                    textStyle:
                        const TextStyle(fontSize: 16.5, color: Colors.white54),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  titleValue,
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.5,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: function,
              icon: const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTextBox1 extends StatelessWidget {
  final String title;
  final String titleValue;
  const ProfileTextBox1({
    super.key,
    required this.title,
    required this.titleValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF111328),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title:',
                  style: GoogleFonts.lato(
                    textStyle:
                        const TextStyle(fontSize: 16.5, color: Colors.white54),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  titleValue,
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 16.5,
                    ),
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
