import 'dart:convert';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/components/network_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/auth/login.dart';
import 'package:blogsquid/pages/show_page.dart';
import 'package:blogsquid/utils/app_actions.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Account extends HookWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final color = useProvider(colorProvider);
    final pages = useProvider(pagesProvider);

    final loading = useState(true);
    final loadingError = useState(true);

    void loadData() async {
      // print(account.state);
      var result = await Network().validateToken();
      print(result);
      if (result == false) {
        await AppAction().logout(account, token);
      }
      try {
        loading.value = true;
        loadingError.value = false;
        var response = await Network().simpleGet("/pages?per_page=20");
        var body = json.decode(response.body);
        loading.value = false;
        if (response.statusCode == 200) {
          pages.state = body;
          var box = await Hive.openBox('appBox');
          box.put('pages', json.encode(body));
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
      loadData();
    }, const []);

    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? primaryDark : primaryBg,
        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Account",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: color.state == 'dark'
                            ? Color(0xFFE9E9E9)
                            : Colors.black)),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    account.state['id'] != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF3F3E8),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: account.state['avatar_urls'] !=
                                                          null &&
                                                      account.state['avatar_urls']
                                                              ["96"] !=
                                                          null
                                                  ? Image.network(account.state[
                                                          'avatar_urls']["96"])
                                                      .image
                                                  : Image.asset(
                                                          'assets/images/placeholder-' +
                                                              color.state +
                                                              '.png')
                                                      .image),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: colorPrimary, width: 3),
                                        )),
                                    SizedBox(height: 10),
                                    Text(
                                      "${account.state['name']}",
                                      style: TextStyle(
                                          color: color.state == 'dark'
                                              ? Color(0xFFE9E9E9)
                                              : Color(0xFF282828),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "${account.state['email']}",
                                      style:
                                          TextStyle(color: Color(0xFF999999)),
                                    ),
                                    SizedBox(height: 20),
                                    InkWell(
                                        onTap: () async {
                                          await AppAction()
                                              .logout(account, token);
                                        },
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: colorPrimary
                                                    .withOpacity(0.05)),
                                            child: Text(
                                              "Logout",
                                              style: TextStyle(
                                                  color: color.state == 'dark'
                                                      ? Colors.redAccent
                                                      : Color(0xFF282828),
                                                  fontWeight: FontWeight.w500),
                                            ))),
                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Container(
                            margin: EdgeInsets.only(bottom: 40, top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Get full access",
                                  style: TextStyle(color: Color(0xFF9A9FAC)),
                                ),
                                SizedBox(width: 10),
                                InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  ),
                                  child: Text(
                                    "Click here to Login",
                                    style: TextStyle(
                                        color: colorPrimary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              ],
                            ),
                          ),
                    Container(
                      child: Row(
                        children: [
                          EachTop(
                              side: "left",
                              icon: "chart-pie.svg",
                              title: "Color Preference",
                              action: () => showMaterialModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Colors.black.withOpacity(
                                      color.state == 'dark' ? 0.8 : 0.5),
                                  context: context,
                                  builder: (context) => ColorModal())),
                          EachTop(
                              side: "right",
                              icon: "cog.svg",
                              title: "Configurations",
                              bordered: false,
                              action: () => showMaterialModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Colors.black.withOpacity(
                                      color.state == 'dark' ? 0.8 : 0.5),
                                  context: context,
                                  builder: (context) => Configurations())),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    loading.value && pages.state.length == 0
                        ? Container(
                            margin: EdgeInsets.only(
                                top: (MediaQuery.of(context).size.height / 3) -
                                    20),
                            child: SpinKitFadingCube(
                              color: colorPrimary,
                              size: 30.0,
                            ),
                          )
                        : loadingError.value && pages.state.length == 0
                            ? NetworkError(
                                loadData: loadData, message: "Network error,")
                            : pages.state.length > 0
                                ? Container(
                                    padding: EdgeInsets.only(
                                        left: 20, top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        color: color.state == 'dark'
                                            ? eachPostBgDark
                                            : Color(0xFFF3F3F3),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Column(
                                        children: pages.state
                                            .asMap()
                                            .entries
                                            .map((page) => EachMenu(
                                                page: page.value,
                                                bordered: pages.state.length <=
                                                        page.key + 1
                                                    ? false
                                                    : true,
                                                action: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ShowPage(
                                                                page: page
                                                                    .value)))))
                                            .toList()),
                                  )
                                : Expanded(
                                    child: Center(
                                      child: EmptyError(
                                          loadData: loadData,
                                          message: "No page found,"),
                                    ),
                                  ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EachTop extends HookWidget {
  final String title, side, icon;
  final bool bordered;
  final Function action;
  const EachTop({
    this.title = "",
    this.bordered = true,
    required this.action,
    required this.side,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return Expanded(
        child: InkWell(
      onTap: () => action(),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          margin: EdgeInsets.only(
              left: side == 'left' ? 0 : 5, right: side == 'left' ? 5 : 0),
          decoration: BoxDecoration(
            color: color.state == 'dark' ? eachPostBgDark : Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Color(0xFFEDEDED).withOpacity(0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconsPath + icon,
                color: color.state == 'dark'
                    ? Color(0xFFA7A9AC)
                    : Color(0xFF282828),
                width: 35,
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    color: color.state == 'dark'
                        ? Color(0xFFA7A9AC)
                        : Color(0xFF282828)),
              ),
            ],
          )),
    ));
  }
}

class Configurations extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dataMode = useProvider(dataSavingModeProvider);
    final offlineMode = useProvider(offlineModeProvider);
    final color = useProvider(colorProvider);
    toggleDataSavingMode() async {
      dataMode.state = !dataMode.state;
      var box = await Hive.openBox('appBox');
      box.put('data_saving', dataMode.state);
    }

    toggleOfflineMode() async {
      offlineMode.state = !offlineMode.state;
      var box = await Hive.openBox('appBox');
      box.put('offline_mode', offlineMode.state);
    }

    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Container(
        decoration: BoxDecoration(
            color: color.state == 'dark' ? eachPostBgDark : Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 30.0, top: 30, bottom: 20),
              child: Text("Configurations",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color.state == 'dark'
                          ? Color(0xFFE9E9E9)
                          : Colors.black)),
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 40,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                  color: color.state == 'dark'
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text("Data saving mode",
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? Color(0xFFA7A9AC)
                                      : Colors.black)),
                        ),
                        CupertinoSwitch(
                          value: dataMode.state ? true : false,
                          onChanged: (value) {
                            toggleDataSavingMode();
                          },
                        )
                      ],
                    ),
                    onTap: () {
                      toggleDataSavingMode();
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text("Offline mode",
                              style: TextStyle(
                                  color: color.state == 'dark'
                                      ? Color(0xFFA7A9AC)
                                      : Colors.black)),
                        ),
                        CupertinoSwitch(
                          value: offlineMode.state ? true : false,
                          onChanged: (value) {
                            toggleOfflineMode();
                          },
                        )
                      ],
                    ),
                    onTap: () {
                      toggleOfflineMode();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorModal extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    changeColor(String cl) async {
      color.state = cl;
      var box = await Hive.openBox('appBox');
      box.put('color', cl);
      Navigator.pop(context);
    }

    return SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Container(
        decoration: BoxDecoration(
            color: color.state == 'dark' ? eachPostBgDark : Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 30.0, top: 30, bottom: 20),
              child: Text("Color Preference",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color.state == 'dark'
                          ? Color(0xFFE9E9E9)
                          : Colors.black)),
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 40,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                  color: color.state == 'dark'
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: new Icon(
                      color.state == 'light'
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: color.state == 'light'
                          ? colorPrimary
                          : color.state == 'dark'
                              ? Color(0xFFA7A9AC)
                              : Colors.black,
                    ),
                    title: new Text("Light Mode",
                        style: TextStyle(
                            color: color.state == 'dark'
                                ? Color(0xFFA7A9AC)
                                : Colors.black)),
                    onTap: () {
                      changeColor('light');
                    },
                  ),
                  ListTile(
                    leading: new Icon(
                      color.state == 'dark'
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: color.state == 'dark'
                          ? colorPrimary
                          : color.state == 'dark'
                              ? Color(0xFFA7A9AC)
                              : Colors.black,
                    ),
                    title: new Text("Dark Mode",
                        style: TextStyle(
                            color: color.state == 'dark'
                                ? Color(0xFFA7A9AC)
                                : Colors.black)),
                    onTap: () {
                      changeColor('dark');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EachMenu extends HookWidget {
  final Map page;
  final bool bordered;
  final Function action;
  const EachMenu({
    Key? key,
    required this.page,
    required this.bordered,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return InkWell(
      onTap: () => action(),
      child: Container(
        padding: EdgeInsets.only(top: 20, bottom: 20, right: 20),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1,
                    color: this.bordered
                        ? color.state == 'dark'
                            ? primaryDark.withOpacity(0.1)
                            : Color(0xFFEDEDED).withOpacity(0.7)
                        : Colors.transparent))),
        child: Row(
          children: [
            Expanded(
                child: Text(
              "${page['title']['rendered'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}",
              style: TextStyle(
                  fontSize: 16,
                  color: color.state == 'dark'
                      ? Color(0xFFA7A9AC)
                      : Color(0xFF282828)),
            )),
            SvgPicture.asset(
              iconsPath + "cheveron-right.svg",
              color:
                  color.state == 'dark' ? Color(0xFFA7A9AC) : Color(0xFF282828),
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
