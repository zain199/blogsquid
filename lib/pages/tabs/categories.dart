import 'dart:convert';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/components/network_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/categories/category_detail.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:blogsquid/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Categories extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final categories = useProvider(categoryProvider);
    final color = useProvider(colorProvider);
    final loading = useState(true);
    final loadingError = useState(true);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);
    final page = useState(1);

    void getCategories() async {
      try {
        loading.value = true;
        loadingError.value = false;
        isLoadMoreDone.value = false;
        page.value = 1;
        var response = await Network()
            .simpleGet("/categories?per_page=20&page=" + page.value.toString());
        var body = json.decode(response.body);
        loading.value = false;
        if (response.statusCode == 200) {
          categories.state = body;
          var box = await Hive.openBox('appBox');
          box.put('categories', json.encode(body));
        } else {
          loadingError.value = true;
        }
      } catch (e) {
        loading.value = false;
        loadingError.value = true;
        print(e);
      }
    }

    useEffect(() {
      getCategories();
    }, const []);
    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? primaryDark : Colors.white,
        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Categories",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: color.state == 'dark'
                        ? Color(0xFFE9E9E9)
                        : Colors.black)),
            SizedBox(height: 20),
            loading.value && categories.state.length == 0
                ? Container(
                    margin: EdgeInsets.only(
                        top: (MediaQuery.of(context).size.height / 3) - 20),
                    child: SpinKitFadingCube(
                      color: colorPrimary,
                      size: 30.0,
                    ),
                  )
                : loadingError.value && categories.state.length == 0
                    ? NetworkError(
                        loadData: getCategories, message: "Network error,")
                    : categories.state.length > 0
                        ? Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                if (!loading.value) getCategories();
                              },
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 20, top: 10, bottom: 10),
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                      color: color.state == 'dark'
                                          ? eachPostBgDark
                                          : Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Column(
                                      children: categories.state
                                          .asMap()
                                          .entries
                                          .map((category) => EachCategory(
                                              category.value,
                                              categories.state.length <=
                                                      category.key + 1
                                                  ? false
                                                  : true,
                                              color))
                                          .toList()),
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: Center(
                              child: EmptyError(
                                  loadData: getCategories,
                                  message: "No category found,"),
                            ),
                          )
          ],
        ),
      ),
    );
  }
}

class EachCategory extends HookWidget {
  final bool bordered;
  final Map category;
  final StateController<String> color;
  EachCategory(this.category, this.bordered, this.color);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryDetail(category: category))),
      child: Container(
        padding: EdgeInsets.only(top: 20, bottom: 20, right: 20),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1,
                    color: this.bordered
                        ?  color.state == 'dark'
                      ? primaryDark.withOpacity(0.2)
                      : Color(0xFFEDEDED).withOpacity(0.7)
                        : Colors.transparent))),
        child: Row(
          children: [
            Expanded(
                child: Text(
              category['name'],
              style: TextStyle(
                  fontSize: 18,
                  color: color.state == 'dark'
                      ? Color(0xFF8D949F)
                      : Color(0xFF282828)),
            )),
            SvgPicture.asset(
              iconsPath + "cheveron-right.svg",
              color: color.state == 'dark'
                      ? Color(0xFF8D949F)
                      : Color(0xFF282828),
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
