import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/tabs/account.dart';
import 'package:blogsquid/pages/tabs/bookmarks.dart';
import 'package:blogsquid/pages/tabs/categories.dart';
import 'package:blogsquid/pages/tabs/search.dart';
import 'package:flutter/material.dart';

import 'tabs/home.dart';
import 'tabs/partials/animated_bottom_bar.dart';

class Dashboard extends StatefulWidget {
  final List<BarItem> barItems = [
    BarItem(
        focusSize: 24, theSize: 24, text: "Home", icon: iconsPath + "home.svg"),
    BarItem(
        focusSize: 24,
        theSize: 24,
        text: "Categories",
        icon: iconsPath + "collection.svg"),
    BarItem(
        focusSize: 24,
        theSize: 24,
        text: "Search",
        icon: iconsPath + "search.svg"),
    BarItem(
        focusSize: 24,
        theSize: 24,
        text: "Bookmarks",
        icon: iconsPath + "bookmark.svg"),
    BarItem(
        focusSize: 24,
        theSize: 24,
        text: "Account",
        icon: iconsPath + "user-circle.svg"),
  ];
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  late TabController _tabController;
  late double timeDilation;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
  }

  void _toggleTab() {
    _tabIndex = _tabController.index + 1;
    _tabController.animateTo(_tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: AnimatedBottomBar(
          barItems: widget.barItems,
          tabIndex: _tabIndex,
          animationDuration: const Duration(milliseconds: 150),
          onBarTap: (index) {
            setState(() {
              _tabIndex = index;
            });
            _tabController.animateTo(_tabIndex);
          }),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Home()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Categories()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Search()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Bookmarks()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Account()),
        ],
      ),
    );
  }
}