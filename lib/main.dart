import 'package:blogsquid/config/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'prepare.dart';
import 'package:blogsquid/utils/globals.dart' as globals;

void main() {
  globals.appNavigator = GlobalKey<NavigatorState>();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent, // transparent status bar
  //     statusBarIconBrightness: Brightness.dark // dark text for status bar
  //     ));
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Colors.black, systemNavigationBarColor: Colors.black,));
    }, const []);
    return MaterialApp(
      title: 'Blog Squid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Circular",
        primarySwatch: Colors.blue,
      ),

      /// navigatorKey: globals.appNavigator,
      home: Prepare(),
    );
  }
}
