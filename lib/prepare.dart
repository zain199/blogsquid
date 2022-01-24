import 'dart:convert';

import 'package:blogsquid/onboarding.dart';
import 'package:blogsquid/pages/tabs/home.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'components/logo.dart';
import 'pages/dashboard.dart';

class Prepare extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final categories = useProvider(categoryProvider);
    final posts = useProvider(postsProvider);
    final latestposts = useProvider(latestpostsProvider);
    final bookmarks = useProvider(bookmarksProvider);
    final pages = useProvider(pagesProvider);
    final account = useProvider(accountProvider);
    final color = useProvider(colorProvider);
    final dataMode = useProvider(dataSavingModeProvider);
    final offlineMode = useProvider(offlineModeProvider);
    final boarded = useState('no');

    startSequence() async {
      await Hive.initFlutter();
      var box = await Hive.openBox('appBox');

      if (box.get('color') != null) {
        color.state = box.get('color');
      }
      if (box.get('categories') != null) {
        categories.state = jsonDecode(box.get('categories'));
      }
      if (box.get('posts') != null) {
        posts.state = jsonDecode(box.get('posts'));
        latestposts.state = jsonDecode(box.get('posts'));
      }
      if (box.get('bookmarks') != null) {
        bookmarks.state = jsonDecode(box.get('bookmarks'));
      }
      if (box.get('pages') != null) {
        pages.state = jsonDecode(box.get('pages'));
      }
      if (box.get('account') != null) {
        account.state = jsonDecode(box.get('account'));
      }
      if (box.get('data_saving') != null) {
        dataMode.state = box.get('data_saving');
      }
      if (box.get('offline_mode') != null) {
        offlineMode.state = box.get('offline_mode');
      }

      if (box.get('boarded') != null) {
        boarded.value = await box.get('boarded');
      }
      await Future.delayed(Duration(seconds: 2));
      if (boarded.value == 'no') {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Onboarding()),
            (Route<dynamic> route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Dashboard()),
            (Route<dynamic> route) => false);
      }
    }

    useEffect(() {
      startSequence();
    }, const []);

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LogoWidget(24, "dark"),
            ],
          ),
        ),
      ),
    );
  }
}
