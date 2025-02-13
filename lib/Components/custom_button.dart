import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String buttonText;

  const CustomButton(
      {super.key, required this.color, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      height: orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height * 0.06
          : MediaQuery.of(context).size.height * 0.15,
      width: orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width * 0.3
          : MediaQuery.of(context).size.width * 0.15,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(MediaQuery.of(context).size.height * 0.006),
      ),
      child: Center(
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.018,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
