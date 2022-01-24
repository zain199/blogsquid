import 'dart:convert';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/components/logo.dart';
import 'package:blogsquid/components/network_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/config/modules.dart';
import 'package:blogsquid/pages/categories/category_detail.dart';
import 'package:blogsquid/pages/categories/subCategories.dart';
import 'package:blogsquid/pages/posts/each_post.dart';
import 'package:blogsquid/pages/posts/load_post.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../post_detail.dart';

final List<String> imgList = ['', '', '', '', '', ''];

class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    CarouselController _controller = CarouselController();
    final _current = useState(0);
    final posts = useProvider(postsProvider);
    final latestposts = useProvider(latestpostsProvider);
    final categories = useProvider(categoryProvider);
    final offlineMode = useProvider(offlineModeProvider);
    final dataMode = useProvider(dataSavingModeProvider);
    final color = useProvider(colorProvider);
    final loading = useState(true);
    final loadingCategories = useState(true);
    final loadingError = useState(true);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);
    final page = useState(1);
    bool largeScreen = MediaQuery.of(context).size.width > 800 ? true : false;
    final filter = useState({
      "id": 0,
      "name": "Latest",
    });

    Future<void> setupNotification() async {
      //Remove this method to stop OneSignal Debugging
      //OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

      OneSignal.shared.setAppId(ONESIGNAL_APP_ID);

      // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
      OneSignal.shared
          .promptUserForPushNotificationPermission()
          .then((accepted) {
        print("Accepted permission: $accepted");
      });

      OneSignal.shared.setNotificationWillShowInForegroundHandler(
          (OSNotificationReceivedEvent event) {
        // Will be called whenever a notification is received in foreground
        // Display Notification, pass null param for not displaying the notification
        event.complete(event.notification);
      });

      OneSignal.shared
          .setPermissionObserver((OSPermissionStateChanges changes) {
        // Will be called whenever the permission changes
        // (ie. user taps Allow on the permission prompt in iOS)
      });

      OneSignal.shared
          .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
        // Will be called whenever the subscription changes
        // (ie. user gets registered with OneSignal and gets a user ID)
      });

      OneSignal.shared.setEmailSubscriptionObserver(
          (OSEmailSubscriptionStateChanges emailChanges) {
        // Will be called whenever then user's email subscription changes
        // (ie. OneSignal.setEmail(email) is called and the user gets registered
      });
      OneSignal.shared
          .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
        // Will be called whenever a notification is opened/button pressed.
        var postid = result.notification.additionalData?['post_id'];
        if (postid != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoadPost(postid: postid)),
          );
        } else {
          print(result.notification.additionalData);
        }
      });
    }

    void getCategories() async {
      try {
        var response = await Network().simpleGet("/categories?parent=0");
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
      if (offlineMode.state && posts.state.length > 0) {
        Fluttertoast.showToast(
            msg: "You are currently in offline mode",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: colorPrimary,
            textColor: Colors.white,
            fontSize: 16.0);

        loading.value = false;
        loadingError.value = true;
      } else {
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
    }

    void loadMore() async {
      if (offlineMode.state && posts.state.length > 0) {
        Fluttertoast.showToast(
            msg: "You are currently in offline mode",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: colorPrimary,
            textColor: Colors.white,
            fontSize: 16.0);

        loading.value = false;
        loadingError.value = true;
      } else {
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
    }

    switchOn() async {
      offlineMode.state = false;
      var box = await Hive.openBox('appBox');
      box.put('offline_mode', offlineMode.state);
      getPosts();
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
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: Stack(
                        children: <Widget>[
                          dataMode.state
                              ? Image.asset(
                                  'assets/images/placeholder-' +
                                      color.state +
                                      '.png',
                                  fit: BoxFit.cover,
                                  width: 1000.0)
                              : post["_embedded"]["wp:featuredmedia"] != null
                                  ? Image.network(
                                      post["_embedded"]["wp:featuredmedia"][0]
                                          ["source_url"],
                                      fit: BoxFit.cover,
                                      width: 1000.0)
                                  : Image.asset(
                                      'assets/images/placeholder-' +
                                          color.state +
                                          '.png',
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
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xFFF9F7F7).withOpacity(0.9),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                      Jiffy(post['date'], "yyyy-MM-dd")
                                          .fromNow(),
                                      style: TextStyle(
                                          color: colorPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    post['title']['rendered'].replaceAll(
                                        RegExp(r'<[^>]*>|&[^;]+;'), ''),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
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
      setupNotification();
      getPosts();
    }, const []);

    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? primaryDark : primaryBg,
        padding: EdgeInsets.only(top: 40),
        child: Container(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(left: largeScreen ? 20 : 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                            width: 100,
                            child: LogoWidget(
                                18, color.state == 'dark' ? "dark" : "")),
                      ),
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
                                                    ? Color(0xFFE9E9E9)
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
                                                    ? Color(0xFFE9E9E9)
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
                                                    ? Color(0xFFE9E9E9)
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
                                                    ? Color(0xFFE9E9E9)
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
                                                                SubCategories(
                                                                    category[
                                                                        'id'],
                                                                    category[
                                                                        'name']))),
                                                    child: Text(
                                                      category['name'],
                                                      style: TextStyle(
                                                          color: color.state ==
                                                                  'dark'
                                                              ? Color(
                                                                  0xFFA19E9C)
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
                                          : Color(0xFFF9F7F7).withOpacity(0.6),
                                      color.state == 'dark'
                                          ? primaryDark
                                          : Color(0xFFF9F7F7)
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
                                      margin: EdgeInsets.only(
                                          top: largeScreen ? 20 : 0),
                                      width: largeScreen
                                          ? 700
                                          : MediaQuery.of(context).size.width,
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
                                                    //enlargeCenterPage: true,
                                                    aspectRatio: 1.8,
                                                    viewportFraction: 1,
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
                                                                          0xFFE0E5EE),
                                                              width: 1.5),
                                                          //shape: BoxShape.circle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          color: _current
                                                                      .value ==
                                                                  entry.key
                                                              ? colorPrimary
                                                              : Color(
                                                                  0xFFF3F3F3)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ])),
                                            StickyHeader(
                                              header: Container(
                                                color: color.state == 'dark'
                                                    ? primaryDark
                                                    : primaryBg,
                                                padding: EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 30,
                                                    bottom: 20),
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
                                                                  : Colors
                                                                      .black,
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
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                barrierColor: Colors
                                                                    .black
                                                                    .withOpacity(color.state ==
                                                                            'dark'
                                                                        ? 0.8
                                                                        : 0.5),
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        SingleChildScrollView(
                                                                  controller:
                                                                      ModalScrollController.of(
                                                                          context),
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        color: color.state ==
                                                                                'dark'
                                                                            ? primaryDark
                                                                            : Colors
                                                                                .white,
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(5),
                                                                            topRight: Radius.circular(5))),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: <
                                                                          Widget>[
                                                                        //*************************************************************latest*********\\

                                                                        InkWell(
                                                                          onTap:
                                                                              () {
                                                                            if (filter.value['name'].toString() ==
                                                                                'Latest')
                                                                              filter.value['name'] = 'Oldest';
                                                                            else
                                                                              filter.value['name'] = 'Latest';
                                                                            posts.state =
                                                                                posts.state.reversed.toList();
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child: Container(
                                                                            width:
                                                                                double.infinity,
                                                                            padding:
                                                                                EdgeInsets.symmetric(
                                                                              vertical: 20,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              filter.value['name'].toString() == 'Latest' ? 'Oldest' : 'Latest',
                                                                              style: TextStyle(
                                                                                color: color.state == 'dark' ? darkModeText : primaryDark,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                      child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 5),
                                                          decoration: BoxDecoration(
                                                              color: color
                                                                          .state ==
                                                                      'dark'
                                                                  ? Color(0xFFEEEEEE)
                                                                      .withOpacity(
                                                                          0.08)
                                                                  : Color(
                                                                      0xFFEEEEEE),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
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
                                                                              ? Color(0xFFE9E9E9).withOpacity(0.5)
                                                                              : Colors.black38
                                                                          : color.state == 'dark'
                                                                              ? Color(0xFFE9E9E9)
                                                                              : Colors.black)),
                                                              SizedBox(
                                                                  width: 10),
                                                              SvgPicture.asset(
                                                                iconsPath +
                                                                    "cheveron-down.svg",
                                                                color: loading
                                                                            .value ||
                                                                        loadingMore
                                                                            .value
                                                                    ? color.state ==
                                                                            'dark'
                                                                        ? Color(0xFFE9E9E9).withOpacity(
                                                                            0.5)
                                                                        : Colors
                                                                            .black12
                                                                    : color.state ==
                                                                            'dark'
                                                                        ? Color(
                                                                            0xFFE9E9E9)
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
                                              content: Column(children: [
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
                                                            top: 10,
                                                            bottom: 20),
                                                        child:
                                                            SpinKitRotatingCircle(
                                                          color: colorPrimary,
                                                          size: 30.0,
                                                        ),
                                                      )
                                                    : SizedBox()
                                              ]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : EmptyError(
                                    loadData: getPosts,
                                    message: "No post found,")),
              ),
              offlineMode.state
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "You currently in offline mode",
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: switchOn,
                            child: Text("Turn off.",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ))
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
