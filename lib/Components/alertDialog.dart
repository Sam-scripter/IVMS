import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AlertDialog buildAlertDialog(
    String title, String message, BuildContext context) {
  return AlertDialog(
    title: Text(
      title,
      style: GoogleFonts.lato(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    ),
    content: Text(
      message,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 18,
      ),
    ),
    backgroundColor: const Color(0xFF111328),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          'OK',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          backgroundColor:
              Colors.blue.withOpacity(0.1), // button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    ],
  );
}

AlertDialog buildAlertDialog1(
    String title, String message, BuildContext context) {
  return AlertDialog(
    title: Text(
      title,
      style: GoogleFonts.lato(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    ),
    content: Text(
      message,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 18,
      ),
    ),
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: Text(
          'OK',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          backgroundColor:
              Colors.blue.withOpacity(0.1), // button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    ],
  );
}
