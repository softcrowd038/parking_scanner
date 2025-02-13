// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:gaushala_scanner1/Components/custom_button.dart';
import 'package:gaushala_scanner1/Components/custom_text_field.dart';
import 'package:gaushala_scanner1/pages/scanner_page.dart';
import 'package:gaushala_scanner1/utils/Login/session_manager.dart';
import 'package:gaushala_scanner1/utils/Login/validate_authentication.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<void> authenticateUser() async {
    const String apiUrl =
        'https://exilance.com/gaushala_management_system/login_api/login_api_visitor.php?visitor_id=&password=';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'visitor_id': userIdController.text,
          'password': passwordController.text,
        }),
      );

      print('${userIdController.text} ${passwordController.text}');

      if (response.statusCode == 200) {
        print('Authentication successful: ${response.body}');

        final Map<String, dynamic> data = jsonDecode(response.body);

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('visitorId', userIdController.text);
        sharedPreferences.setString('password', passwordController.text);

        Provider.of<SessionManager>(context, listen: false)
            .saveAuthToken(data['status']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerPage(),
          ),
        );
      } else {
        print('Authentication failed: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('${userIdController.text} ${passwordController.text}');
      print('Error: $error');
    }
  }

  void validateAndAuthenticate() async {
    if (_key.currentState?.validate() ?? false) {
      await authenticateUser();

      setState(() {
        userIdController.clear();
        passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.060,
                ),
                Image.network(
                    'https://img.freepik.com/free-vector/cow-eating-concept-illustration_114360-13832.jpg?t=st=1731129608~exp=1731133208~hmac=d1720b2dd877558f06c4c494239674897b7be17a83d18c71cf53bb94abc5bb23&w=740'),
                Text(
                  'SIGN IN',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      fontWeight: FontWeight.bold),
                ),
                CustomTextField(
                  hintText: "Enter your Visitor Email here",
                  fieldController: userIdController,
                  type: TextInputType.emailAddress,
                  customValidator: (value) => validateUserId(context, value),
                  icon: const Icon(Icons.person),
                ),
                CustomTextField(
                  hintText: "Enter your password here",
                  fieldController: passwordController,
                  type: TextInputType.text,
                  customValidator: (value) => validatePassword(context, value),
                  icon: const Icon(Icons.key),
                ),
                GestureDetector(
                  onTap: () {
                    authenticateUser();
                  },
                  child: const CustomButton(
                    color: Colors.blue,
                    buttonText: "SCAN",
                  ),
                ),
              ],
            ),
          )),
        ));
  }
}
