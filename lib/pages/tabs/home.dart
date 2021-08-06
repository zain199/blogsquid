import 'dart:convert';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/components/logo.dart';
import 'package:blogsquid/components/network_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/categories/category_detail.dart';
import 'package:blogsquid/pages/posts/each_post.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:blogsquid/utils/providers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../post_detail.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    CarouselController _controller = CarouselController();
    final _current = useState(0);
    final posts = useProvider(postsProvider);
    final latestposts = useProvider(latestpostsProvider);
    final categories = useProvider(categoryProvider);
    final color = useProvider(colorProvider);
    final loading = useState(true);
    final loadingCategories = useState(true);
    final loadingError = useState(true);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);
    final page = useState(1);
    final filter = useState({
      "id": 0,
      "name": "Latest",
    });

    void getCategories() async {
      try {
        var response = await Network().simpleGet("/categories?per_page=20");
        var body = json.decode(response.body);
        if (response.statusCode == 200) {
          categories.state = body;
          var box = await Hive.openBox('appBox');
          box.put('categories', json.encode(body));
        } else {}
        loadingCategories.value = false;
      } catch (e) {
        print(e);
      }
    }

    void getPosts() async {
      try {
        loading.value = true;
        loadingError.value = false;
        isLoadMoreDone.value = false;
        page.value = 1;
        var path = filter.value['id'] == 0
            ? "/posts?_embed&per_page=20&page=" + page.value.toString()
            : '/posts?_embed&per_page=20&page=' +
                page.value.toString() +
                '&categories=' +
                filter.value['id'].toString();
        var response = await Network().simpleGet(path);
        var body = json.decode(response.body);
        loading.value = false;
        if (response.statusCode == 200) {
          posts.state = body;
          if (filter.value['id'] == 0) {
            latestposts.state = posts.state;
            var box = await Hive.openBox('appBox');
            box.put('posts', json.encode(posts.state));
          }
        } else {
          loadingError.value = true;
        }
        getCategories();
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
        var path = filter.value['id'] == 0
            ? "/posts?_embed&per_page=20&page=" + page.value.toString()
            : '/posts?_embed&per_page=20&page=' +
                page.value.toString() +
                '&categories=' +
                filter.value['id'].toString();
        var response = await Network().simpleGet(path);
        var body = json.decode(response.body);
        loadingMore.value = false;
        if (response.statusCode == 200) {
          if (body.length > 0) {
            posts.state.addAll(body);

            var box = await Hive.openBox('appBox');
            box.put('posts', json.encode(posts.state));
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

    final List<Widget> imageSliders = latestposts.state
        .take(6)
        .map((post) => Container(
              child: InkWell(
                onTap: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostDetail(post: post)))
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: Stack(
                        children: <Widget>[
                          Image.network(
                              post["_embedded"]["wp:featuredmedia"][0]
                                  ["source_url"],
                              fit: BoxFit.cover,
                              width: 1000.0),
                          Positioned(
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black,
                                    Colors.black.withOpacity(0.6),
                                    Colors.black.withOpacity(0)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Jiffy(post['date'], "yyyy-MM-dd").fromNow(),
                                    style: TextStyle(color: Color(0xFFC7C7C7)),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    post['title']['rendered'].replaceAll(
                                        RegExp(r'<[^>]*>|&[^;]+;'), ''),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ))
        .toList();

    useEffect(() {
      getPosts();
    }, const []);

    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? primaryDark : Colors.white,
        padding: EdgeInsets.only(top: 40),
        child: Container(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      Container(
                          width: 120,
                          child: LogoWidget(
                              18, color.state == 'dark' ? "dark" : "")),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: loadingCategories.value &&
                                        categories.state.length == 0
                                    ? Row(
                                        children: [
                                          Container(
                                            height: 14,
                                            width: 60,
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                                color: color.state == 'dark'
                                                    ? Color(0xFF8D949F)
                                                    : eachPostBg,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 14,
                                            width: 80,
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                                color: color.state == 'dark'
                                                    ? Color(0xFF8D949F)
                                                    : eachPostBg,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 14,
                                            width: 65,
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                                color: color.state == 'dark'
                                                    ? Color(0xFF8D949F)
                                                    : eachPostBg,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 14,
                                            width: 30,
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                                color: color.state == 'dark'
                                                    ? Color(0xFF8D949F)
                                                    : eachPostBg,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          Container(
                                            height: 14,
                                            width: 100,
                                            margin: EdgeInsets.only(right: 10),
                                            decoration: BoxDecoration(
                                                color: eachPostBg,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: categories.state
                                            .map((category) => Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10),
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: InkWell(
                                                    onTap: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CategoryDetail(
                                                                    category:
                                                                        category))),
                                                    child: Text(
                                                      category['name'],
                                                      style: TextStyle(
                                                          color: color.state ==
                                                                  'dark'
                                                              ? Color(
                                                                  0xFF8D949F)
                                                              : primaryText),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.state == 'dark'
                                          ? primaryDark.withOpacity(0.6)
                                          : Colors.white.withOpacity(0.6),
                                      color.state == 'dark'
                                          ? primaryDark
                                          : Colors.white
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
              Expanded(
                child: RefreshIndicator(
                    onRefresh: () async {
                      if (!loading.value) getPosts();
                    },
                    child: loading.value && posts.state.length == 0
                        ? SpinKitFadingCube(
                            color: colorPrimary,
                            size: 30.0,
                          )
                        : loadingError.value && posts.state.length == 0
                            ? NetworkError(
                                loadData: getPosts, message: "Network error,")
                            : posts.state.length > 0
                                ? NotificationListener<ScrollNotification>(
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
                                    child: Container(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Container(
                                                child: Column(children: [
                                              CarouselSlider(
                                                items: imageSliders,
                                                carouselController: _controller,
                                                options: CarouselOptions(
                                                    autoPlay: true,
                                                    enlargeCenterPage: true,
                                                    aspectRatio: 2.0,
                                                    onPageChanged:
                                                        (index, reason) {
                                                      _current.value = index;
                                                    }),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: imgList
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  return GestureDetector(
                                                    onTap: () => _controller
                                                        .animateToPage(
                                                            entry.key),
                                                    child: Container(
                                                      width: _current.value ==
                                                              entry.key
                                                          ? 30.0
                                                          : 12.0,
                                                      height: 12.0,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8.0,
                                                              horizontal: 4.0),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: _current
                                                                          .value ==
                                                                      entry.key
                                                                  ? colorPrimary
                                                                  : color.state ==
                                                                          'dark'
                                                                      ? Color(
                                                                          0xFFFFFFFF)
                                                                      : Color(
                                                                          0xFF585858),
                                                              width: 1.5),
                                                          //shape: BoxShape.circle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          color: _current
                                                                      .value ==
                                                                  entry.key
                                                              ? colorPrimary
                                                              : Colors
                                                                  .transparent),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ])),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: 30, bottom: 20),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                        "${filter.value['name']}",
                                                        style: TextStyle(
                                                            color: color.state ==
                                                                    'dark'
                                                                ? Color(
                                                                    0xFFE9E9E9)
                                                                : Colors.black,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ),
                                                  InkWell(
                                                    onTap: loading.value ||
                                                            loadingMore.value
                                                        ? null
                                                        : () =>
                                                            showMaterialModalBottomSheet(
                                                              context: context,
                                                              builder: (context) =>
                                                                  SingleChildScrollView(
                                                                controller:
                                                                    ModalScrollController.of(
                                                                        context),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: <
                                                                      Widget>[
                                                                    ListTile(
                                                                      leading:
                                                                          new Icon(
                                                                        filter.value['id'] ==
                                                                                0
                                                                            ? Icons.check_circle
                                                                            : Icons.radio_button_unchecked,
                                                                        color: filter.value['id'] ==
                                                                                0
                                                                            ? colorPrimary
                                                                            : Colors.black,
                                                                      ),
                                                                      title: new Text(
                                                                          'Latest',
                                                                          style:
                                                                              TextStyle(color: Colors.black)),
                                                                      onTap:
                                                                          () {
                                                                        filter.value =
                                                                            {
                                                                          "id":
                                                                              0,
                                                                          "name":
                                                                              "Latest",
                                                                        };
                                                                        Navigator.pop(
                                                                            context);
                                                                        getPosts();
                                                                      },
                                                                    ),
                                                                    ...categories
                                                                        .state
                                                                        .map((cat) =>
                                                                            ListTile(
                                                                              leading: new Icon(
                                                                                filter.value['id'] == cat['id'] ? Icons.check_circle : Icons.radio_button_unchecked,
                                                                                color: filter.value['id'] == cat['id'] ? colorPrimary : Colors.black,
                                                                              ),
                                                                              title: new Text(cat['name'], style: TextStyle(color: Colors.black)),
                                                                              onTap: () {
                                                                                filter.value = {
                                                                                  "id": cat['id'],
                                                                                  "name": cat['name'],
                                                                                };
                                                                                Navigator.pop(context);
                                                                                getPosts();
                                                                              },
                                                                            ))
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                    child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 15,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: loading.value || loadingMore.value
                                                                    ? color.state == 'dark'
                                                                        ? Color(0xFF8D949F).withOpacity(0.5)
                                                                        : Colors.black12
                                                                    : color.state == 'dark'
                                                                        ? Color(0xFF8D949F)
                                                                        : Colors.black),
                                                            borderRadius: BorderRadius.circular(15)),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                                loading.value ||
                                                                        loadingMore
                                                                            .value
                                                                    ? "Loading..."
                                                                    : filter
                                                                        .value[
                                                                            'name']
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: loading.value
                                                                        ? color.state == 'dark'
                                                                            ? Color(0xFF8D949F).withOpacity(0.5)
                                                                            : Colors.black38
                                                                        : color.state == 'dark'
                                                                            ? Color(0xFF8D949F)
                                                                            : Colors.black)),
                                                            SizedBox(width: 10),
                                                            SvgPicture.asset(
                                                              iconsPath +
                                                                  "cheveron-down.svg",
                                                              color: loading
                                                                          .value ||
                                                                      loadingMore
                                                                          .value
                                                                  ? color.state ==
                                                                          'dark'
                                                                      ? Color(0xFF8D949F)
                                                                          .withOpacity(
                                                                              0.5)
                                                                      : Colors
                                                                          .black12
                                                                  : color.state ==
                                                                          'dark'
                                                                      ? Color(
                                                                          0xFF8D949F)
                                                                      : Colors
                                                                          .black,
                                                              width: 15,
                                                            )
                                                          ],
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(children: [
                                              ...posts.state
                                                  .asMap()
                                                  .entries
                                                  .map((post) => EachPost(
                                                      background: post.key %
                                                                  2 ==
                                                              0
                                                          ? (color.state ==
                                                                  'dark'
                                                              ? eachPostBgDark
                                                              : eachPostBg)
                                                          : (color.state ==
                                                                  'dark'
                                                              ? eachPostBgLowDark
                                                              : eachPostBgLow),
                                                      post: post.value))
                                                  .toList(),
                                              loadingMore.value
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10, bottom: 20),
                                                      child:
                                                          SpinKitRotatingCircle(
                                                        color: colorPrimary,
                                                        size: 30.0,
                                                      ),
                                                    )
                                                  : SizedBox()
                                            ])
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : EmptyError(
                                    loadData: getPosts,
                                    message: "No post found,")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
