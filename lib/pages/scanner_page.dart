// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String qrResult = "";
  bool isClicked = false;
  double turns = 0.0;
  String checkInOutStatus = "check_out";
  int scanCounter = -1;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> scanQRCode() async {
    try {
      String qrCode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.QR,
      );

      if (qrCode == '-1') {
        print("QR scan canceled");
      } else {
        if (qrCode.isNotEmpty) {
          print("Valid QR Code: $qrCode");
          _processScanResult(qrCode);
        } else {
          print("Invalid QR Code: $qrCode");
          _showErrorDialog("Invalid QR Code!");
        }
      }
    } on PlatformException catch (e) {
      print("Error during QR scan: $e");
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> setCheckInStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkInStatus', status);
    setState(() {
      checkInOutStatus = status;
    });
  }

  Future<void> _processScanResult(String url) async {
    String apiUrl =
        'https://exilance.com/parking-management/public/api/verify-qr';

    final action = checkInOutStatus == 'check_in' ? 'check_out' : 'check_in';

    try {
      Map<String, dynamic> requestData = {
        'qr_code': url,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestData),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Added to force server to send JSON
        },
      );

      if (response.statusCode == 200) {
        await setCheckInStatus(action);

        _showSuccessDialog('$action successful!');
      } else {
        print('Error Response: ${response.body}');
        Map<String, dynamic> jsonData = json.decode(response.body);
        _showErrorDialog('${jsonData["message"]}');
      }
    } catch (e) {
      _showErrorDialog('Error during $action: $e');
    }
  }

  void _showSuccessDialog(String successMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(successMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: NetworkImage(
                'https://img.freepik.com/premium-vector/qr-code-scan-pay-concept-illustration_270158-499.jpg'),
          ),
          Text(
            'Scan Now!',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.022),
          ),
          Text(
            'Scan QR code by clicking below button.',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w100,
                fontSize: MediaQuery.of(context).size.height * 0.016),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.20),
          GestureDetector(
            onTap: scanQRCode,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: checkInOutStatus == "check_in"
                    ? Colors.red
                    : const Color(0xff020053),
              ),
              child: Center(
                child: Text(
                  checkInOutStatus == "check_in" ? 'Check-out' : 'Check-in',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.height * 0.018,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
