import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:integrated_vehicle_management_system/Screens/EmployeeRegLogin/login.dart';
import 'package:integrated_vehicle_management_system/Screens/EmployeeRegLogin/registration.dart';
import 'package:integrated_vehicle_management_system/Screens/Profiles/userProfile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nextPage();
  }

  _nextPage() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Horizon',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 250,
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'Agne'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'IVMS',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                    ),
                    ColorizeAnimatedText(
                      'Easy Operations',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                    ),
                    // WavyAnimatedText(
                    //   'IVMS',
                    //   textStyle: const TextStyle(
                    //       fontWeight: FontWeight.bold, fontSize: 40.0),
                    //   speed: const Duration(milliseconds: 200),
                    // ),
                    // TypewriterAnimatedText(
                    //   'easy operations',
                    //   textStyle: const TextStyle(fontSize: 20.0),
                    //   speed: const Duration(milliseconds: 120),
                    // ),
                  ],
                  totalRepeatCount: 2,
                  pause: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
