import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Screens/changePassword.dart';
import 'package:integrated_vehicle_management_system/Screens/homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<bool> isPasswordSet() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return false;
    }

    try {
      await currentUser.reload();
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(currentUser.email)
          .get();
      bool passwordSet = userDoc.get('passwordSet') ?? false;
      return passwordSet;
    } catch (e) {
      print('Error here: $e');
      return false;
    }
  }

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

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .update({'isOnline': isOnline});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'HELLO AGAIN',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(fontSize: 43.0),
                  ),
                ),
                const SizedBox(
                  height: 22.0,
                ),
                const Text(
                  'Welcome back, please login',
                  style: TextStyle(fontSize: 21.0),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 25.0,
                  ),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      hintText: 'Enter Your Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill in this field';
                      }

                      String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                      RegExp regExp = RegExp(emailPattern);

                      if (!regExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }

                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 25.0,
                  ),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.lightBlueAccent, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.lightBlueAccent, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        hintText: 'Enter your Password'),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill in this field';
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 28.0,
                  ),
                  child: Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                    elevation: 6.0,
                    color: Colors.lightBlueAccent,
                    child: MaterialButton(
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            await _auth.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);

                            final passwordCheck = await isPasswordSet();
                            final userId =
                                await FirebaseAuth.instance.currentUser?.email;
                            updateOnlineStatus(userId!, true);
                            if (passwordCheck == true) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen()));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChangePasswordScreen()));
                            }
                          } on FirebaseAuthException catch (e) {
                            String message =
                                'An error occurred, please check your credentials and try again.';

                            if (e.code == 'user-not-found' ||
                                e.code == 'wrong-password') {
                              message = 'Invalid password or email';
                            }
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Login Failed'),
                                  content: Text(message),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } catch (e) {
                            print('Error: $e');
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
