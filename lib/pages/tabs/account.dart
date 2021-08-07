import 'dart:convert';

import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/show_page.dart';
import 'package:blogsquid/utils/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Account extends HookWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);

    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? primaryDark : Colors.white,
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
                    Container(
                      child: Row(
                        children: [
                          EachTop(
                              side: "left",
                              icon: "chart-pie.svg",
                              title: "Color Preference",
                              color: color,
                              action: () => showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => ColorModal())),
                          EachTop(
                              side: "right",
                              icon: "cog.svg",
                              title: "Configurations",
                              color: color,
                              bordered: false,
                              action: () => showMaterialModalBottomSheet(
                                  context: context,
                                  builder: (context) => Configurations())),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text("Pages",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: color.state == 'dark'
                                  ? Color(0xFFE9E9E9).withOpacity(0.7)
                                  : Colors.black)),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                          color: color.state == 'dark'
                              ? eachPostBgDark
                              : Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(4)),
                      child: Column(
                        children: [
                          EachMenu(
                            title: "About us",
                            action: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowPage())),
                          ),
                          EachMenu(
                            title: "Contact us",
                            action: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowPage())),
                          ),
                          EachMenu(
                            title: "Terms & Conditions",
                            bordered: false,
                            action: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ShowPage())),
                          )
                        ],
                      ),
                    )
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

class EachTop extends StatelessWidget {
  final String title, side, icon;
  final bool bordered;
  final Function action;
  final StateNotifier color;
  const EachTop({
    this.title = "",
    this.bordered = true,
    required this.action,
    required this.side,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InkWell(
      onTap: () => action(),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          margin: EdgeInsets.only(
              left: side == 'left' ? 0 : 5, right: side == 'left' ? 5 : 0),
          decoration: BoxDecoration(
              color: color.state == 'dark' ? eachPostBgDark : Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Color(0xFFEDEDED).withOpacity(0.7))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconsPath + icon,
                color: color.state == 'dark'
                    ? Color(0xFF8D949F)
                    : Color(0xFF282828),
                width: 35,
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    color: color.state == 'dark'
                        ? Color(0xFF8D949F)
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30.0, top: 30, bottom: 20),
            child: Text("Configurations",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: 40,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text("Data saving mode",
                            style: TextStyle(color: Colors.black)),
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
                            style: TextStyle(color: Colors.black)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30.0, top: 30, bottom: 20),
            child: Text("Color Preference",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: 40,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: new Icon(
                    color.state == 'light'
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: color.state == 'light' ? colorPrimary : Colors.black,
                  ),
                  title: new Text("Light Mode",
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    changeColor('light');
                  },
                ),
                ListTile(
                  leading: new Icon(
                    color.state == 'dark'
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: color.state == 'dark' ? colorPrimary : Colors.black,
                  ),
                  title: new Text("Dark Mode",
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    changeColor('dark');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EachMenu extends HookWidget {
  final String title;
  final bool bordered;
  final Function action;
  const EachMenu({
    Key? key,
    this.title = "",
    this.bordered = true,
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
                            ? primaryDark.withOpacity(0.2)
                            : Color(0xFFEDEDED).withOpacity(0.7)
                        : Colors.transparent))),
        child: Row(
          children: [
            Expanded(
                child: Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: color.state == 'dark'
                      ? Color(0xFF8D949F)
                      : Color(0xFF282828)),
            )),
            SvgPicture.asset(
              iconsPath + "cheveron-right.svg",
              color:
                  color.state == 'dark' ? Color(0xFF8D949F) : Color(0xFF282828),
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
