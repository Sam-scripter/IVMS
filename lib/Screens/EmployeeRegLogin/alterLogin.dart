import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Screens/changePassword.dart';
import 'package:integrated_vehicle_management_system/Screens/homeScreen.dart';

class AlterLogin extends StatefulWidget {
  const AlterLogin({super.key});

  @override
  State<AlterLogin> createState() => _AlterLoginState();
}

class _AlterLoginState extends State<AlterLogin> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'HELLO',
              style:
                  GoogleFonts.lato(textStyle: const TextStyle(fontSize: 43.0)),
            ),
            const SizedBox(
              height: 22.0,
            ),
            const Text(
              'Welcome, please login',
              style: TextStyle(fontSize: 21.0),
            ),
            const SizedBox(
              height: 30.0,
            ),
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 25.0),
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
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
                    hintText: 'Enter your Password'),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                textAlign: TextAlign.center,
              ),
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
                  onPressed: () async {
                    await _auth.signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ChangePasswordScreen()));
                  },
                  minWidth: 300,
                  height: 42,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/passwordReset');
              },
              child: Text(
                'Forgot Password',
                style: GoogleFonts.lato(
                  textStyle:
                      const TextStyle(fontSize: 16.0, color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
