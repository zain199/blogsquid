import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SpeakLoud extends HookWidget {
  final ValueNotifier ttsState;
  final Function speak, stop;
  const SpeakLoud(
      {Key? key,
      required this.ttsState,
      required this.speak,
      required this.stop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return InkWell(
        onTap: () => ttsState.value == 'playing' ? stop() : speak(),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                    color: ttsState.value == 'playing'
                        ? colorPrimary.withOpacity(0.08)
                        : color.state == 'dark'
                            ? Colors.white.withOpacity(0.1)
                            : Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Text(
                      ttsState.value == 'playing' ? "Speaking" : "Speak Loud",
                      style: TextStyle(
                          color: ttsState.value == 'playing'
                              ? colorPrimary
                              : color.state == 'dark'
                                  ? Colors.white
                                  : primaryDark),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.volume_up_outlined,
                        color: ttsState.value == 'playing'
                            ? colorPrimary
                            : color.state == 'dark'
                                ? Colors.white
                                : primaryDark),
                  ],
                )),
          ],
        ));
  }
}
