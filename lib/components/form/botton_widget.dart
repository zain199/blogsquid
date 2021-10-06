import 'package:blogsquid/config/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonWidget extends StatelessWidget {
  final Function action;
  final String text;
  const ButtonWidget({Key? key, required this.action, this.text = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => action(),
        style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 60)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$text",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(width: 10),
            SvgPicture.asset(iconsPath + 'arrow-right.svg', color: Colors.white)
          ],
        ));
  }
}
