import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/components/network_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/config/modules.dart';
import 'package:blogsquid/utils/db_helper.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'posts/speak_loud.dart';

class PostDetail extends HookWidget {
  final Map post;
  const PostDetail({Key? key, required this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final dataMode = useProvider(dataSavingModeProvider);
    List cats = post["_embedded"]["wp:term"][0];
    Map author = post["_embedded"]["author"][0];
    DBHelper dbHelper = new DBHelper();
    final bookmarks = useProvider(bookmarksProvider);
    final bookmarked = useState(false);
    final pageloading = useState(true);
    CarouselController _controller = CarouselController();
    final _current = useState(0);

    final ttsState = useState('stopped');

    FlutterTts flutterTts = FlutterTts();

    Future _speak() async {
      try {
        var result = await flutterTts.speak(
            "${post['title']['rendered'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}: ${post['content']['rendered'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}");

        if (result == 1) ttsState.value = "playing";
      } catch (e) {
        print(e);
      }
    }

    Future _stop() async {
      var result = await flutterTts.stop();
      if (result == 1) ttsState.value = "stopped";
    }

    List productImages = post["_embedded"]["wp:featuredmedia"];

    final AdRequest request = AdRequest(
      keywords: <String>['foo', 'bar'],
      contentUrl: 'http://foo.com/bar.html',
      nonPersonalizedAds: true,
    );

    final _anchoredBanner = useState(new BannerAd(
        adUnitId: '',
        listener: BannerAdListener(),
        request: request,
        size: AdSize.largeBanner));
    final bannerloading = useState(true);

    toggleBookmark() async {
      dbHelper.addOrDelete(post);
      bookmarked.value = !bookmarked.value;
      var box = await Hive.openBox('appBox');
      if (box.get('bookmarks') != null) {
        bookmarks.state = jsonDecode(box.get('bookmarks'));
      }
    }

    checkBm() async {
      var box = await Hive.openBox('appBox');
      List alldata = jsonDecode(box.get('bookmarks'));
      bool exists =
          alldata.where((element) => element['id'] == post['id']).length > 0
              ? true
              : false;
      if (exists) {
        bookmarked.value = true;
      } else {
        bookmarked.value = false;
      }
    }

    sharePost() {
      Share.share(
          post['excerpt']['rendered']
              .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
          subject: post['title']['rendered']
              .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''));
    }

    loadBanner() async {
      await Future.delayed(Duration(seconds: 1));
      pageloading.value = false;
      _anchoredBanner.value = BannerAd(
        adUnitId:
            Platform.isAndroid ? ADMOB_UNIT_ID_ANDROID : ADMOB_UNIT_ID_IOS,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('$BannerAd loaded.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('$BannerAd failedToLoad: $error');
          },
          onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
          //onApplicationExit: (Ad ad) => print('$BannerAd onApplicationExit.'),
        ),
      );

      _anchoredBanner.value.load();
      bannerloading.value = false;
    }

    void _launchURL(_url) async => await canLaunch(_url)
        ? await launch(_url)
        : throw 'Could not launch $_url';
    useEffect(() {
      checkBm();
      loadBanner();
    }, const []);

    final List<Widget> imageSliders = productImages
        .asMap()
        .entries
        .map((pImage) => Container(
              child: InkWell(
                onTap: null,
                child: pImage.key == 0
                    ? Hero(
                        tag: post['title']['rendered']
                            .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 0.0),
                            height: 216,
                            decoration: BoxDecoration(
                              color: Color(0xFFF3F3E8),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image:
                                      Image.network(pImage.value["source_url"])
                                          .image),
                            )),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 25.0),
                        height: 216,
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F3E8),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: Image.network(pImage.value["src"]).image),
                        )),
              ),
            ))
        .toList();

    return WillPopScope(
      onWillPop: () async {
        _stop();
        // You can do some work here.
        // Returning true allows the pop to happen, returning false prevents it.
        return true;
      },
      child: Scaffold(
        body: Container(
          color: color.state == 'dark' ? primaryDark : Colors.white,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        iconsPath + "arrow-left.svg",
                        color: color.state == 'dark'
                            ? Color(0xFFE9E9E9)
                            : Color(0xFF282828),
                        width: 20,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                              post['title']['rendered']
                                  .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                              overflow: TextOverflow.ellipsis,
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
              ),
              Container(
                child: Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width,
                                child: dataMode.state
                                    ? Hero(
                                        tag: post['title']['rendered']
                                            .replaceAll(
                                                RegExp(r'<[^>]*>|&[^;]+;'), ''),
                                        child: Container(
                                          height: 250,
                                          child: Image.asset(
                                              'assets/images/placeholder-' +
                                                  color.state +
                                                  '.png'),
                                        ),
                                      )
                                    : post["_embedded"]["wp:featuredmedia"] !=
                                            null
                                        ? Column(
                                            children: [
                                              CarouselSlider(
                                                items: imageSliders,
                                                carouselController: _controller,
                                                options: CarouselOptions(
                                                    autoPlay: false,
                                                    enlargeCenterPage: false,
                                                    aspectRatio: 1.6,
                                                    viewportFraction: 1,
                                                    onPageChanged:
                                                        (index, reason) {
                                                      _current.value = index;
                                                    }),
                                              ),
                                              SizedBox(height: 10),
                                              post["_embedded"][
                                                              "wp:featuredmedia"] !=
                                                          null &&
                                                      post["_embedded"][
                                                                  "wp:featuredmedia"]
                                                              .length >
                                                          1
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: productImages
                                                          .asMap()
                                                          .entries
                                                          .map((entry) {
                                                        return GestureDetector(
                                                          onTap: () =>
                                                              _controller
                                                                  .animateToPage(
                                                                      entry
                                                                          .key),
                                                          child: Container(
                                                            width: _current
                                                                        .value ==
                                                                    entry.key
                                                                ? 12.0
                                                                : 12.0,
                                                            height: 12.0,
                                                            margin: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        8.0,
                                                                    horizontal:
                                                                        4.0),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                                color: _current
                                                                            .value ==
                                                                        entry
                                                                            .key
                                                                    ? Color(
                                                                        0xFFEB920D)
                                                                    : Color(
                                                                        0xFFF3F3E8)),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          )
                                        : Hero(
                                            tag: post['title']['rendered']
                                                .replaceAll(
                                                    RegExp(r'<[^>]*>|&[^;]+;'),
                                                    ''),
                                            child: Container(
                                              height: 250,
                                              child: Image.asset(
                                                  'assets/images/placeholder-' +
                                                      color.state +
                                                      '.png'),
                                            ),
                                          )),
                            Container(
                                padding: EdgeInsets.only(
                                    left: 20, top: 10, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SpeakLoud(
                                        ttsState: ttsState,
                                        speak: _speak,
                                        stop: _stop),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => toggleBookmark(),
                                          child: bookmarked.value
                                              ? Icon(
                                                  Icons.bookmark,
                                                  color: colorPrimary,
                                                  size: 21,
                                                )
                                              : SvgPicture.asset(
                                                  iconsPath + "bookmark.svg",
                                                  color: color.state == 'dark'
                                                      ? Color(0xFFC8CBCF)
                                                      : Colors.black,
                                                  width: 20,
                                                ),
                                        ),
                                        SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => sharePost(),
                                          child: SvgPicture.asset(
                                            iconsPath + "share.svg",
                                            color: color.state == 'dark'
                                                ? Color(0xFFC8CBCF)
                                                : Colors.black,
                                            width: 20,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                            Container(
                              padding:
                                  EdgeInsets.only(top: 20, left: 20, right: 20),
                              margin: EdgeInsets.only(bottom: 60),
                              color: color.state == 'dark'
                                  ? primaryDark
                                  : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: cats
                                        .asMap()
                                        .entries
                                        .map((cat) => Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: Text(
                                                "${cat.value['name']}" +
                                                    (cats.length <= cat.key + 1
                                                        ? '.'
                                                        : ','),
                                                style: TextStyle(
                                                    color: colorPrimary,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    post['title']['rendered'].replaceAll(
                                        RegExp(r'<[^>]*>|&[^;]+;'), ''),
                                    style: TextStyle(
                                        color: color.state == 'dark'
                                            ? Color(0xFFE9E9E9)
                                            : Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        'By ${author['name']}',
                                        style: TextStyle(
                                            color: color.state == 'dark'
                                                ? Color(0xFFC8CBCF)
                                                : Color(0xFF222121),
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          Jiffy(post['date'])
                                              .format("MMMM do, yyyy"),
                                          style: TextStyle(
                                              color: color.state == 'dark'
                                                  ? Color(0xFFC8CBCF)
                                                  : Color(0xFF242424),
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  pageloading.value
                                      ? Container(
                                          height: 200,
                                          child: Center(
                                            child: SpinKitFadingCube(
                                              color: colorPrimary,
                                              size: 30.0,
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Html(
                                              data: post['content']['rendered'],
                                              style: {
                                                "html": Style(
                                                    lineHeight:
                                                        LineHeight.em(1.6),
                                                    fontSize: FontSize.large,
                                                    color: color.state == 'dark'
                                                        ? Color(0xFFA7A9AC)
                                                        : Color(0xFF464646)),
                                                "body": Style(
                                                    margin: EdgeInsets.zero),
                                                "a": Style(color: colorPrimary),
                                              },
                                              customImageRenders: {
                                                networkSourceMatcher(domains: [
                                                  "flutter.dev"
                                                ]): (context, attributes,
                                                    element) {
                                                  return Image.asset(
                                                      'assets/images/placeholder-' +
                                                          color.state +
                                                          '.png',
                                                      width: 200);
                                                },
                                                networkSourceMatcher(domains: [
                                                  "mydomain.com"
                                                ]): networkImageRender(
                                                  headers: {
                                                    "Custom-Header":
                                                        "some-value"
                                                  },
                                                  altWidget: (alt) =>
                                                      Text(alt ?? ""),
                                                  loadingWidget: () =>
                                                      Text("Loading..."),
                                                ),
                                                // On relative paths starting with /wiki, prefix with a base url
                                                (attr, _) =>
                                                        attr["src"] != null &&
                                                        attr["src"]!.startsWith(
                                                            "/wiki"):
                                                    networkImageRender(
                                                        mapUrl: (url) =>
                                                            "https://upload.wikimedia.org" +
                                                            url!),
                                                // Custom placeholder image for broken links
                                                networkSourceMatcher():
                                                    networkImageRender(
                                                        altWidget: (_) =>
                                                            Image.asset(
                                                              'assets/images/placeholder-' +
                                                                  color.state +
                                                                  '.png',
                                                              width: 200,
                                                            )),
                                              },
                                              onLinkTap: (url, _, __, ___) {
                                                print("Opening $url...");
                                                _launchURL(url);
                                              },
                                              onImageTap: (src, _, __, ___) {
                                                print(src);
                                              },
                                              onImageError:
                                                  (exception, stackTrace) {
                                                print(exception);
                                              },
                                            ),
                                            bannerloading.value
                                                ? Text("loading")
                                                : Container(
                                                    width: _anchoredBanner
                                                        .value.size.width
                                                        .toDouble(),
                                                    height: _anchoredBanner
                                                        .value.size.height
                                                        .toDouble(),
                                                    child: AdWidget(
                                                        ad: _anchoredBanner
                                                            .value),
                                                  )
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: InkWell(
                          onTap: () => showMaterialModalBottomSheet(
                              enableDrag: false,
                              context: context,
                              builder: (context) => CommentsWidget(post['id'])),
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: color.state == 'dark'
                                      ? [
                                          Color(0xFF000205).withOpacity(0.92),
                                          Color(0xFF000205),
                                          Color(0xFF000205)
                                        ]
                                      : [
                                          Colors.white.withOpacity(0.92),
                                          Colors.white,
                                          Colors.white
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "View Comments",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: color.state == 'dark'
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.black),
                                  ),
                                  Icon(Icons.arrow_right,
                                      color: color.state == 'dark'
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.black)
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentsWidget extends HookWidget {
  final int postid;
  const CommentsWidget(this.postid);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final loading = useState(true);
    final loadingError = useState(true);
    final loadingMore = useState(false);
    final isLoadMoreDone = useState(false);
    final page = useState(1);
    final account = useProvider(accountProvider);
    final commenting = useState(false);
    final comments = useState([]);

    void loadData() async {
      try {
        loading.value = true;
        loadingError.value = false;
        isLoadMoreDone.value = false;
        page.value = 1;
        var response = await Network().simpleGet('/comments?per_page=20&page=' +
            page.value.toString() +
            '&post=' +
            postid.toString());
        var body = json.decode(response.body);
        loading.value = false;
        if (response.statusCode == 200) {
          comments.value = body;
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
        var response = await Network().simpleGet('/comments?per_page=20&page=' +
            page.value.toString() +
            '&post=' +
            postid.toString());
        var body = json.decode(response.body);
        loadingMore.value = false;
        if (response.statusCode == 200) {
          if (body.length > 0) {
            comments.value.addAll(body);
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

    storeComment(message, name, email) async {
      var newAccount = {"name": name.text, "email": email.text};
      if (message.text.length == 0 || name.text.length == 0) {
        Fluttertoast.showToast(
            msg: message.text.length == 0
                ? "Message field is required"
                : "Name field is required",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: colorPrimary,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        final bool isValid = EmailValidator.validate(email.text);
        if (email.text.length > 0 && !isValid) {
          Fluttertoast.showToast(
              msg: "Email is invalid",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: colorPrimary,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          var box = await Hive.openBox('appBox');
          box.put('account', json.encode(newAccount));
          account.state = newAccount;
          var formData = {
            "post": postid.toString(),
            "author_name": name.text,
            "author_email": email.text,
            "content": message.text,
          };
          commenting.value = true;
          try {
            var response = await Network().simplePost("/comments", formData);

            commenting.value = false;
            var body = json.decode(response.body);
            commenting.value = false;
            if (response.statusCode == 201) {
              Fluttertoast.showToast(
                  msg: "Comment posted",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
              comments.value = [body, ...comments.value];
              Navigator.pop(context);
            } else {
              print(body);

              Fluttertoast.showToast(
                  msg: body["message"] != null
                      ? body["message"]
                      : "Unable to post comment",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          } catch (e) {
            print(e);
            Fluttertoast.showToast(
                msg: "Unable to post comment, check your network connection.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            commenting.value = false;
          }
        }
      }
    }

    useEffect(() {
      loadData();
    }, const []);

    return Container(
      color: color.state == 'dark' ? primaryDark : primaryBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: 20.0, top: 40, bottom: 15, right: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text("Comments",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: color.state == 'dark'
                              ? Color(0xFFE9E9E9)
                              : Colors.black)),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text("Close",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: color.state == 'dark'
                              ? Color(0xFFE9E9E9).withOpacity(0.5)
                              : Colors.black)),
                )
              ],
            ),
          ),
          loading.value && comments.value.length == 0
              ? Expanded(
                  child: Center(
                    child: SpinKitFadingCube(
                      color: colorPrimary,
                      size: 30.0,
                    ),
                  ),
                )
              : loadingError.value && comments.value.length == 0
                  ? Expanded(
                      child: Center(
                        child: NetworkError(
                            loadData: loadData, message: "Network error,"),
                      ),
                    )
                  : comments.value.length > 0
                      ? Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              if (!loading.value) loadData();
                            },
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
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
                                    ...comments.value
                                        .asMap()
                                        .entries
                                        .map((each) => EachComment(
                                            each.key % 2 == 0
                                                ? eachPostBg
                                                : eachPostBgLow,
                                            each.value))
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
                                message: "No comment found,"),
                          ),
                        ),
          InkWell(
            onTap: () => showMaterialModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                barrierColor:
                    Colors.black.withOpacity(color.state == 'dark' ? 0.8 : 0.5),
                builder: (context) =>
                    WriteCommentWidget(storeComment, commenting)),
            child: Container(
                color: Colors.black.withOpacity(0.97),
                padding: EdgeInsets.only(bottom: 20, top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_rounded, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      "Write Comment",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class WriteCommentWidget extends HookWidget {
  final Function storeComment;
  final ValueNotifier<bool> commenting;
  WriteCommentWidget(this.storeComment, this.commenting);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final account = useProvider(accountProvider);
    final messageInput = useTextEditingController();
    final nameInput = useTextEditingController();
    final emailInput = useTextEditingController();
    final _focusNodeMessage = useFocusNode();
    final focusedMessage = useState(false);
    final _focusNodeName = useFocusNode();
    final focusedName = useState(false);
    final _focusNodeEmail = useFocusNode();
    final focusedEmail = useState(false);
    var maxLine = 5;
    final qt = useState(0);
    final loading = useState(false);
    useEffect(() {
      nameInput.text =
          account.state['name'] != null ? account.state['name'] : '';
      emailInput.text =
          account.state['email'] != null ? account.state['email'] : '';
      qt.value = account.state['name'] != null ? 2 : 0;
      _focusNodeMessage.addListener(() {
        focusedMessage.value = _focusNodeMessage.hasFocus ? true : false;
      });
      _focusNodeName.addListener(() {
        focusedName.value = _focusNodeName.hasFocus ? true : false;
      });
      _focusNodeEmail.addListener(() {
        focusedEmail.value = _focusNodeEmail.hasFocus ? true : false;
      });
    }, const []);
    return SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          //margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: color.state == 'dark' ? Color(0xFF0F1620) : Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5), topRight: Radius.circular(5))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20),
                child: Text("Write Comment",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: color.state == 'dark'
                            ? Color(0xFFE9E9E9)
                            : Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: color.state == 'dark'
                              ? Color(0xFFFBFBFB).withOpacity(0.4)
                              : Color(0xFFFBFBFB),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: focusedMessage.value
                                  ? colorPrimary
                                  : Color(0xFFD3D3D3))),
                      height: maxLine * 20,
                      margin: EdgeInsets.only(bottom: 2),
                      padding: EdgeInsets.only(left: 10),
                      child: TextFormField(
                          focusNode: _focusNodeMessage,
                          keyboardType: TextInputType.multiline,
                          maxLines: maxLine,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w100),
                          decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Color(0xFF9A9FAC),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w100),
                              border: InputBorder.none,
                              hintText: "Message"),
                          onChanged: (text) {
                            //loadData();
                          },
                          controller: messageInput),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => {
                            qt.value = qt.value == 2 ? 0 : 2,
                            focusedName.value = false,
                            focusedEmail.value = false
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFE9E9E9),
                              borderRadius: BorderRadius.circular(16.5),
                            ),
                            child: Row(
                              children: [
                                Text("More",
                                    style: TextStyle(color: Color(0xFF282828))),
                                SizedBox(width: 5),
                                RotatedBox(
                                  quarterTurns: qt.value,
                                  child: SvgPicture.asset(
                                    iconsPath + "cheveron-down.svg",
                                    color: Color(0xFF282828),
                                    width: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    qt.value == 2
                        ? SizedBox()
                        : Column(
                            children: [
                              Opacity(
                                opacity: account.state['logged_in'] != null
                                    ? 0.5
                                    : 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: color.state == 'dark'
                                          ? Color(0xFFFBFBFB).withOpacity(0.4)
                                          : Color(0xFFFBFBFB),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: focusedName.value
                                              ? colorPrimary
                                              : Color(0xFFD3D3D3))),
                                  margin: EdgeInsets.only(bottom: 2),
                                  padding: EdgeInsets.only(left: 10, bottom: 2),
                                  child: TextFormField(
                                      focusNode: _focusNodeName,
                                      readOnly:
                                          account.state['logged_in'] != null
                                              ? true
                                              : false,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w100),
                                      decoration: InputDecoration(
                                          hintStyle: TextStyle(
                                              color: Color(0xFF9A9FAC),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w100),
                                          border: InputBorder.none,
                                          hintText: "Name"),
                                      onChanged: (text) {
                                        //loadData();
                                      },
                                      controller: nameInput),
                                ),
                              ),
                              SizedBox(height: 12),
                              Opacity(
                                opacity: account.state['logged_in'] != null
                                    ? 0.5
                                    : 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: color.state == 'dark'
                                          ? Color(0xFFFBFBFB).withOpacity(0.4)
                                          : Color(0xFFFBFBFB),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: focusedEmail.value
                                              ? colorPrimary
                                              : Color(0xFFD3D3D3))),
                                  margin: EdgeInsets.only(bottom: 2),
                                  padding: EdgeInsets.only(left: 10, bottom: 2),
                                  child: TextFormField(
                                      focusNode: _focusNodeEmail,
                                      readOnly:
                                          account.state['logged_in'] != null
                                              ? true
                                              : false,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w100),
                                      decoration: InputDecoration(
                                          hintStyle: TextStyle(
                                              color: Color(0xFF9A9FAC),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w100),
                                          border: InputBorder.none,
                                          hintText: "Email Address"),
                                      onChanged: (text) {
                                        //loadData();
                                      },
                                      controller: emailInput),
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        if (!commenting.value) {
                          loading.value = true;
                          await storeComment(
                              messageInput, nameInput, emailInput);
                          loading.value = false;
                        } else {
                          print("currently loading");
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: loading.value
                                ? Colors.black.withOpacity(0.8)
                                : Colors.black,
                            borderRadius: BorderRadius.circular(5)),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(commenting.value ? "Submitting" : "Submit",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: commenting.value
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.white,
                                    fontWeight: FontWeight.w100)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: focusedMessage.value ||
                        focusedName.value ||
                        focusedEmail.value
                    ? MediaQuery.of(context).viewInsets.bottom
                    : 0,
              )
            ],
          ),
        ));
  }
}

class EachComment extends HookWidget {
  final Color background;
  final Map comment;
  const EachComment(this.background, this.comment);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
            color: color.state == 'dark' ? eachPostBgDark : Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Text(
                  "${comment['author_name']}",
                  style: TextStyle(
                      color: colorPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                )),
                Text(Jiffy(comment['date'], "yyyy-MM-dd").fromNow(),
                    style: TextStyle(color: Color(0xFFE9E9E9))),
              ],
            ),
            SizedBox(height: 10),
            Text(
              comment['content']['rendered']
                  .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
              style: TextStyle(
                  color: color.state == 'dark'
                      ? Color(0xFFE9E9E9).withOpacity(0.7)
                      : Colors.black,
                  fontSize: 16,
                  height: 1.5),
            ),
          ],
        ));
  }
}
