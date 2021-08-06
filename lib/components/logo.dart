import 'package:blogsquid/config/app.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final String color;
  const LogoWidget(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Blog",
          style: TextStyle(fontWeight: FontWeight.bold, color: color == "dark" ? Colors.white: Colors.black, fontSize: size),
        ),
        Text(
          "squid",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: size, color: colorPrimary),
        ),
      ],
    );
  }
}
