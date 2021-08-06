import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class DBHelper {
  addOrDelete(Map data) async {
    var box = await Hive.openBox('appBox');
    List alldata = [];
    if (box.get('bookmarks') != null) {
      alldata = jsonDecode(box.get('bookmarks'));
      bool exists =
          alldata.where((element) => element['id'] == data['id']).length > 0
              ? true
              : false;
      if (exists) {
        alldata.removeWhere((element) => element['id'] == data['id']);
        box.put('bookmarks', json.encode(alldata));
      } else {
        alldata = [data, ...alldata];
        box.put('bookmarks', json.encode(alldata));
      }
    } else {
      alldata.add(data);
      box.put('bookmarks', json.encode(alldata));
    }
  }
}
