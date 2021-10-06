import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TextInputWidget extends HookWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isPassword;
  final int position;
  TextInputWidget({
    Key? key,
    required this.controller,
    required this.placeholder,
    this.isPassword = false,
    this.position = 1,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final _focusNode = useFocusNode();
    final focused = useState(false);
    useEffect(() {
      _focusNode.addListener(() {
        focused.value = _focusNode.hasFocus ? true : false;
      });
    }, const []);
    return Container(
        padding: EdgeInsets.only(left: 15, top: 10),
        margin: EdgeInsets.only(
            bottom: focused.value
                ? position == 0 || position == 1
                    ? 1
                    : 0
                : 0),
        decoration: BoxDecoration(
          color: focused.value
              ? color.state == 'dark'
                  ? eachPostBgDark
                  : Color(0xFFF4F6FB)
              : color.state == 'dark'
                  ? primaryDark
                  : Colors.transparent,
          border: Border(
              bottom: BorderSide(
            color: focused.value
                ? colorPrimary
                : color.state == 'dark'
                    ? Color(0xFF4B464B)
                    : Colors.black,
            width: 1,
          )),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              focused.value || controller.text.length > 0 ? placeholder : "",
              style: TextStyle(color: Color(0xFFA19E9C), fontSize: 12),
            ),
            SizedBox(
              height: 36,
              child: TextField(
                  focusNode: _focusNode,
                  obscureText: isPassword,
                  style: TextStyle(
                      fontSize: 14,
                      color: color.state == 'dark'
                          ? Colors.white
                          : Color(0xFF262626)),
                  decoration: InputDecoration(
                      hintStyle: TextStyle(
                        color: Color(0xFFA19E9C),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      hintText: focused.value ? "" : placeholder),
                  controller: controller),
            ),
          ],
        ));
  }
}
