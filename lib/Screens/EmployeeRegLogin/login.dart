import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integrated_vehicle_management_system/Screens/changePassword.dart';
import 'package:integrated_vehicle_management_system/Screens/homeScreen.dart';
import '../../Components/alertDialog.dart';

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
  String error = "";

  late OverlayEntry _overlayEntry;

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

  Future<String?> getSmsCodeFromUser(BuildContext context) async {
    String? smsCode;

    // Update the UI - wait for the user to enter the SMS code
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter SMS code:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(smsCode);
                _showOverlay();
                setState(() {
                  _isLoading = true;
                });
              },
              child: const Text('Submit'),
            ),
            OutlinedButton(
              onPressed: () {
                smsCode = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
          content: Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                smsCode = value;
              },
              textAlign: TextAlign.center,
              autofocus: true,
            ),
          ),
        );
      },
    );

    return smsCode;
  }

  Future<void> sendOtp(String phoneNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check if email is verified
    if (!user.emailVerified) {
      await user.sendEmailVerification();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Email Verification'),
          content: Text('Please verify your email and then log in again.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final session = await user.multiFactor.getSession();
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      multiFactorSession: session,
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically handle the OTP verification
        try {
          await user.multiFactor.enroll(
            PhoneMultiFactorGenerator.getAssertion(
              credential,
            ),
          );
          // Navigate to home screen after successful verification
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } on FirebaseAuthException catch (e) {
          setState(() {
            _isLoading = false;
          });
          buildAlertDialog("Error!", '${e.message}', context);
          print(e.message);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });
        buildAlertDialog("Error!", '${e.message}', context);
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          _isLoading = false;
        });
        final smsCode = await getSmsCodeFromUser(context);

        if (smsCode != null) {
          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );

          try {
            setState(() {
              _isLoading = true;
            });
            await user.multiFactor.enroll(
              PhoneMultiFactorGenerator.getAssertion(
                credential,
              ),
            );
            // Navigate to home screen after successful verification
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } on FirebaseAuthException catch (e) {
            setState(() {
              _isLoading = false;
            });
            if (e.code == 'invalid-verification-code') {
              buildAlertDialog(
                  "Error!", 'The code you entered is incorrect.', context);
              await sendOtp(phoneNumber);
            } else {
              print(e.message);
            }
          }
        }
      },
      codeAutoRetrievalTimeout: (_) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Code Expired'),
            content: Text('The time to enter the code has elapsed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  sendOtp(phoneNumber);
                },
                child: Text('Request another code'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      },
      timeout: const Duration(minutes: 2),
    );
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry);
  }

  void _hideOverlay() {
    _overlayEntry.remove();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _focusNode.dispose();
    _focusNode1.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode1 = FocusNode();

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
                  child: GestureDetector(
                    onTap: () {
                      _focusNode.requestFocus();
                    },
                    child: TextFormField(
                      focusNode: _focusNode,
                      controller: emailController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
                      textAlign: TextAlign.center, // Centered text
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in this field';
                        }

                        String emailPattern =
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                        RegExp regExp = RegExp(emailPattern);

                        if (!regExp.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }

                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 25.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _focusNode1.requestFocus();
                    },
                    child: TextFormField(
                      focusNode: _focusNode1,
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
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
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : Padding(
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
                                _showOverlay();
                                setState(() {
                                  _isLoading = true;
                                  error = '';
                                });

                                try {
                                  UserCredential userCredential =
                                      await _auth.signInWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text);

                                  User? user = userCredential.user;
                                  if (user == null) {
                                    throw FirebaseAuthException(
                                        code: 'user-not-found',
                                        message: 'User not found');
                                  }

                                  final passwordCheck = await isPasswordSet();
                                  if (!passwordCheck) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ChangePasswordScreen()));
                                    return;
                                  }

                                  // Retrieve user's phone number from Firestore and format it
                                  DocumentSnapshot userDoc =
                                      await FirebaseFirestore.instance
                                          .collection('employees')
                                          .doc(emailController.text)
                                          .get();

                                  String rawPhoneNumber =
                                      userDoc.get('mobileNumber');
                                  String formattedPhoneNumber =
                                      "+254${rawPhoneNumber.substring(1)}";
                                  print(formattedPhoneNumber);

                                  await sendOtp(formattedPhoneNumber);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  _hideOverlay();
                                } on FirebaseAuthMultiFactorException catch (e) {
                                  final firstHint = e.resolver.hints.first;
                                  if (firstHint is! PhoneMultiFactorInfo) {
                                    return;
                                  }
                                  await FirebaseAuth.instance.verifyPhoneNumber(
                                    multiFactorSession: e.resolver.session,
                                    multiFactorInfo: firstHint,
                                    verificationCompleted: (_) {},
                                    verificationFailed: (_) {
                                      buildAlertDialog('Error!',
                                          'An Error occurred', context);
                                    },
                                    codeSent: (String verificationId,
                                        int? resendToken) async {
                                      setState(() {
                                        error = '${e.message}';
                                        _isLoading = false;
                                      });
                                      _hideOverlay();
                                      final smsCode =
                                          await getSmsCodeFromUser(context);

                                      if (smsCode != null) {
                                        final credential =
                                            PhoneAuthProvider.credential(
                                          verificationId: verificationId,
                                          smsCode: smsCode,
                                        );

                                        try {
                                          await e.resolver.resolveSignIn(
                                            PhoneMultiFactorGenerator
                                                .getAssertion(
                                              credential,
                                            ),
                                          );
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          _hideOverlay();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen()));
                                        } on FirebaseAuthException catch (e) {
                                          setState(() {
                                            error = e.message!;
                                          });
                                          print(e.message);
                                        }
                                      }
                                    },
                                    codeAutoRetrievalTimeout: (_) {},
                                  );
                                } on FirebaseAuthException catch (e) {
                                  String message =
                                      'An error occurred, please check your credentials and try again.';

                                  if (e.code == 'user-not-found' ||
                                      e.code == 'wrong-password') {
                                    message = 'Invalid password or email';
                                  } else {
                                    message = 'An error occurred';
                                  }
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  _hideOverlay();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return buildAlertDialog(
                                          'Login Failed', message, context);
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
