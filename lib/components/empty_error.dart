import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmptyError extends HookWidget {
  final Function loadData;
  final String message;

  EmptyError({required this.loadData, required this.message});

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconsPath + 'exclamation-circle.svg',
            height: 60,
            color: color.state == 'dark' ? primaryText : Colors.black38,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$message",
                  style: TextStyle(
                      fontSize: 14,
                      color: primaryText,
                      fontWeight: FontWeight.w400)),
              SizedBox(
                width: 5,
              ),
              InkWell(
                onTap: () => loadData(),
                child: Text("Tap to retry",
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            color.state == 'dark' ? colorPrimary : Colors.black,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
