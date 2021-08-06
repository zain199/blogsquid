import 'dart:convert';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/posts/each_post.dart';
import 'package:blogsquid/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Bookmarks extends HookWidget {
  const Bookmarks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookmarks = useProvider(bookmarksProvider);
    final loading = useState(true);
    final categories = useState([
      {"id": 0, "name": "All Bookmarks"}
    ]);
    final filter = useState({
      "id": 0,
      "name": "All Bookmarks",
    });

    extractCategories() async {
      var box = await Hive.openBox('appBox');
      if (box.get('bookmarks') != null) {
        List getBm = jsonDecode(box.get('bookmarks'));
        List ec = [];
        for (var item in getBm) {
          List inner = [];
          for (var iteminner in item["_embedded"]["wp:term"][0]) {
            inner = [
              {"id": iteminner['id'], "name": iteminner['name']},
              ...inner
            ];
          }
          ec = [...inner, ...ec];
        }
        categories.value = [
          {"id": 0, "name": "All Bookmarks"}
        ];
        for (var ecitem in ec) {
          if (categories.value
                  .where((element) => element['id'] == ecitem['id'])
                  .length ==
              0) {
            categories.value.add({"id": ecitem['id'], "name": ecitem['name']});
          }
        }
      }
    }

    loadData() async {
      var box = await Hive.openBox('appBox');
      if (box.get('bookmarks') != null) {
        if (filter.value['id'].toString() == '0') {
          bookmarks.state = jsonDecode(box.get('bookmarks'));
        } else {
          bookmarks.state = [];
          List getBm = jsonDecode(box.get('bookmarks'));
          List ec = [];
          for (var item in getBm) {
            bool exist = false;
            for (var iteminner in item["categories"]) {
              if (filter.value['id'].toString() == iteminner.toString()) {
                exist = true;
              }
            }
            if (exist) {
              ec = [...ec, item];
            }
          }
          bookmarks.state = ec;
        }
      }
      extractCategories();
    }

    useEffect(() {
      loadData();
    }, const []);
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: Text("Bookmarks",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ),
                InkWell(
                  onTap: () => showMaterialModalBottomSheet(
                    context: context,
                    builder: (context) => SingleChildScrollView(
                      controller: ModalScrollController.of(context),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ...categories.value.map((cat) => ListTile(
                                leading: new Icon(
                                  filter.value['id'].toString() ==
                                          cat['id'].toString()
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: filter.value['id'].toString() ==
                                          cat['id'].toString()
                                      ? colorPrimary
                                      : Colors.black,
                                ),
                                title: new Text(cat['name'].toString(),
                                    style: TextStyle(color: Colors.black)),
                                onTap: () {
                                  filter.value = {
                                    "id": cat['id'].toString(),
                                    "name": cat['name'].toString(),
                                  };
                                  Navigator.pop(context);
                                  loadData();
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          Text("${filter.value['name']}",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          SizedBox(width: 10),
                          SvgPicture.asset(
                            iconsPath + "cheveron-down.svg",
                            color: Colors.black,
                            width: 15,
                          )
                        ],
                      )),
                ),
                SizedBox(width: 20)
              ],
            ),
            SizedBox(height: 20),
            bookmarks.state.length > 0
                ? Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        if (!loading.value) loadData();
                      },
                      child: SingleChildScrollView(
                        child: Column(
                            children: bookmarks.state
                                .asMap()
                                .entries
                                .map((each) => EachPost(
                                    background: each.key % 2 == 0
                                        ? eachPostBg
                                        : eachPostBgLow,
                                    post: each.value))
                                .toList()),
                      ),
                    ),
                  )
                : Expanded(
                    child: Center(
                      child: EmptyError(
                          loadData: loadData, message: "No post found,"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
