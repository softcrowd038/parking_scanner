import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gaushala_scanner1/pages/scanner_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        navigationWidget();
      }
    });
  }

  void navigationWidget() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const ScannerPage()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.white),
        child: Image(
          image: const AssetImage('assets/images/logo1.jpg'),
          height: MediaQuery.of(context).size.height * 0.0120,
          width: MediaQuery.of(context).size.width * 0.005120,
        ),
      ),
    );
  }
}
