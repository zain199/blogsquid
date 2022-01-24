import 'dart:convert';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/components/network_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/posts/each_post.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryDetail extends HookWidget {
  final Map category;
  const CategoryDetail({Key? key, required this.category}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    final color = useProvider(colorProvider);
    final loading = useState(true);
    final loadingError = useState(true);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);
    final page = useState(1);
    final detailposts = useState([]);

    void loadData() async {
      try {
        loading.value = true;
        loadingError.value = false;
        isLoadMoreDone.value = false;
        page.value = 1;
        var response = await Network().simpleGet(
            '/posts?_embed&per_page=20&page=' +
                page.value.toString() +
                '&categories=' +
                category['id'].toString());
        var body = json.decode(response.body);
        loading.value = false;
        if (response.statusCode == 200) {
          detailposts.value = body;
        } else {
          loadingError.value = true;
        }
      } catch (e) {
        loading.value = false;
        loadingError.value = true;
        print(e);
      }
    }

    void loadMore() async {
      try {
        loadingMore.value = true;
        page.value++;
        var response = await Network().simpleGet(
            '/posts?_embed&per_page=20&page=' +
                page.value.toString() +
                '&categories=' +
                category['id'].toString());
        var body = json.decode(response.body);
        loadingMore.value = false;
        if (response.statusCode == 200) {
          if (body.length > 0) {
            detailposts.value.addAll(body);
            isLoadMoreDone.value = false;
          } else {
            isLoadMoreDone.value = true;
          }
        } else {
          isLoadMoreDone.value = false;
        }
      } catch (e) {
        loadingMore.value = false;
        isLoadMoreDone.value = false;
      }
    }

    useEffect(() {
      loadData();
    }, const []);
    print('hello omar'+ category.toString());
    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? primaryDark : primaryBg,
        padding: EdgeInsets.only(top: 50),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    child: SvgPicture.asset(
                      iconsPath + "arrow-left.svg",
                      color: color.state == 'dark'
                          ? Color(0xFFE9E9E9)
                          : Color(0xFF282828),
                      width: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category['name'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: color.state == 'dark'
                                  ? Color(0xFFE9E9E9)
                                  : Colors.black)),
                    ],
                  ),
                ),
                SizedBox(width: 20)
              ],
            ),
            SizedBox(height: 20),
            loading.value && detailposts.value.length == 0
                ? Container(
              margin: EdgeInsets.only(
                  top: (MediaQuery.of(context).size.height / 3) - 20),
              child: SpinKitFadingCube(
                color: colorPrimary,
                size: 30.0,
              ),
            )
                : loadingError.value && detailposts.value.length == 0
                ? Expanded(
              child: Center(
                child: NetworkError(
                    loadData: loadData, message: "Network error,"),
              ),
            )
                : detailposts.value.length > 0
                ? Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (!loading.value) loadData();
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification:
                      (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      if (!isLoadMoreDone.value &&
                          !loadingMore.value) {
                        loadMore();
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...detailposts.value
                            .asMap()
                            .entries
                            .map((post) => EachPost(
                            background: post.key % 2 == 0
                                ? (color.state == 'dark'
                                ? eachPostBgDark
                                : eachPostBg)
                                : (color.state == 'dark'
                                ? eachPostBgLowDark
                                : eachPostBgLow),
                            post: post.value))
                            .toList(),
                        loadingMore.value
                            ? Container(
                          margin: EdgeInsets.only(
                              top: 10, bottom: 20),
                          child: SpinKitRotatingCircle(
                            color: colorPrimary,
                            size: 30.0,
                          ),
                        )
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
              ),
            )
                : Expanded(
              child: Center(
                child: EmptyError(
                    loadData: loadData,
                    message: "No post found,"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
