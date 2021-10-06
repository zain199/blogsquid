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

class Search extends HookWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final search = useTextEditingController();
    final _focusNode = useFocusNode();
    final focused = useState(false);
    final loading = useState(true);
    final loadingError = useState(true);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);
    final page = useState(1);
    final searchposts = useState([]);

    void loadData() async {
      try {
        if (search.text.length > 0) {
          loading.value = true;
          loadingError.value = false;
          isLoadMoreDone.value = false;
          page.value = 1;
          var response = await Network().simpleGet(
              '/posts?_embed&per_page=20&page=' +
                  page.value.toString() +
                  '&search=' +
                  search.text);
          var body = json.decode(response.body);
          loading.value = false;
          if (response.statusCode == 200) {
            searchposts.value = body;
          } else {
            loadingError.value = true;
          }
        } else {
          loading.value = false;
          loadingError.value = false;
          searchposts.value = [];
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
                '&search=' +
                search.text);
        var body = json.decode(response.body);
        loadingMore.value = false;
        if (response.statusCode == 200) {
          if (body.length > 0) {
            searchposts.value.addAll(body);
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
      _focusNode.addListener(() {
        focused.value = _focusNode.hasFocus ? true : false;
      });
      loadData();
    }, const []);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          color: color.state == 'dark' ? primaryDark : primaryBg,
          padding: EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: focused.value
                            ? eachPostBgDark.withOpacity(0.5)
                            : color.state == 'dark'
                                ? eachPostBgDark
                                : Color(0xFFF3F3F3),
                        border: Border.all(
                          color:
                              focused.value ? colorPrimary : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 6),
                                child: TextFormField(
                                    focusNode: _focusNode,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: color.state == 'dark'
                                            ? Colors.white
                                            : Colors.black,
                                        height: 1,
                                        fontWeight: FontWeight.w100),
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: color.state == 'dark'
                                                ? Color(0xFFA19E9C)
                                                : Color(0xFF858585),
                                            fontSize: 16,
                                            height: 1,
                                            fontWeight: FontWeight.w100),
                                        border: InputBorder.none,
                                        hintText: "Search"),
                                    onChanged: (text) {
                                      loadData();
                                    },
                                    controller: search),
                              ),
                            ),
                            loading.value
                                ? SpinKitFadingCube(
                                    color: colorPrimary,
                                    size: 16.0,
                                  )
                                : SvgPicture.asset(
                                    iconsPath + "search.svg",
                                    color: color.state == 'dark'
                                        ? Colors.white
                                        : Color(0xFF282828),
                                    width: 20,
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20)
                ],
              ),
              SizedBox(height: 20),
              loading.value && searchposts.value.length == 0
                  ? Container(
                      margin: EdgeInsets.only(
                          top: (MediaQuery.of(context).size.height / 3) - 20),
                      child: SpinKitFadingCube(
                        color: colorPrimary,
                        size: 30.0,
                      ),
                    )
                  : loadingError.value && searchposts.value.length == 0
                      ? Expanded(
                          child: Center(
                            child: NetworkError(
                                loadData: loadData, message: "Network error,"),
                          ),
                        )
                      : searchposts.value.length > 0
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
                                        ...searchposts.value
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
      ),
    );
  }
}
