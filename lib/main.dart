import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'prepare.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Squid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Circular",
        primarySwatch: Colors.blue,
      ),
      home: Prepare(),
    );
  }
}