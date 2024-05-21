import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integrated_vehicle_management_system/Screens/EmployeeRegLogin/login.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isPasswordVisible = false;
  String enteredPassword = '';
  bool _isLoading = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Function to determine the password strength
  String determinePasswordStrength() {
    if (enteredPassword.length < 8) {
      return 'Weak';
    } else if (enteredPassword.length < 10) {
      return 'Strong';
    } else {
      return 'Very Strong';
    }
  }

  // Function to check if the password meets the criteria
  bool isPasswordValid() {
    // Check for at least one uppercase letter
    bool hasUppercase = enteredPassword.contains(RegExp(r'[A-Z]'));

    // Check for at least one lowercase letter
    bool hasLowercase = enteredPassword.contains(RegExp(r'[a-z]'));

    // Check for at least one digit
    bool hasDigit = enteredPassword.contains(RegExp(r'[0-9]'));

    // Check for at least one special character
    bool hasSpecialChar = enteredPassword.contains(RegExp(r'[!@#$%&*?:|<>]'));

    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter a new password'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        enteredPassword = value;
                      });
                    },
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Enter Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill in this field';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (enteredPassword.isNotEmpty)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: enteredPassword.length /
                              16, // Adjust based on your strength criteria
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Weak'),
                            Text('Strong'),
                            Text('Very Strong'),
                          ],
                        ),
                      ],
                    ),
                  if (enteredPassword.length < 8 || !isPasswordValid())
                    const Text(
                      'Password must be at least 8 characters and include a capital letter, a small letter, a number, and a special character',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  Material(
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    elevation: 6.0,
                    color: Colors.lightBlueAccent,
                    child: MaterialButton(
                      height: 45,
                      minWidth: 327,
                      child: const Text(
                        'Update Password',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            isPasswordValid()) {
                          // Dismiss the keyboard
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await user.updatePassword(enteredPassword);

                              // Update the Firestore document
                              await FirebaseFirestore.instance
                                  .collection('employees')
                                  .doc(user.email)
                                  .update({
                                'passwordSet': true,
                              });

                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content:
                                        const Text('User is not logged in.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content:
                                      Text('Failed to update password: $e'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          // Password is not valid, show an error message
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Cannot Proceed'),
                                content: const Text('Invalid Password'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
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
