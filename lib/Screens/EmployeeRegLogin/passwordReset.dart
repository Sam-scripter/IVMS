import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordReset extends StatelessWidget {
  PasswordReset({super.key});

  TextEditingController emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  Future<void> resetPassword(BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Password Reset',
          style: GoogleFonts.lato(),
        ),
        centerTitle: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 25.0),
            child: TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                hintText: 'Enter Your Email',
              ),
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 28.0),
            child: Material(
              borderRadius: const BorderRadius.all(
                Radius.circular(30.0),
              ),
              elevation: 6.0,
              color: Colors.lightBlueAccent,
              child: MaterialButton(
                onPressed: () {
                  resetPassword(context);
                },
                minWidth: 300,
                height: 42,
                child: const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
