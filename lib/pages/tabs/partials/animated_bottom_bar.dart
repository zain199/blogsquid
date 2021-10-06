import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnimatedBottomBar extends HookWidget {
  final List<BarItem> barItems;
  final Function onBarTap;
  final int tabIndex;
  const AnimatedBottomBar(this.barItems, this.tabIndex, this.onBarTap);

  @override
  Widget build(BuildContext context) {
    final selectedBarIndex = useState(0);
    final color = useProvider(colorProvider);
    bool largeScreen = MediaQuery.of(context).size.width > 800 ? true : false;
    return Material(
      elevation: 0,
      color: color.state == 'dark' ? primaryDark : primaryBg,
      child: Container(
        // margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),

        decoration: BoxDecoration(
          color: color.state == 'dark' ? Color(0xFF323131) : tabBgColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: largeScreen
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceAround,
          children: _buildBarItems(selectedBarIndex, color, largeScreen),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems(selectedBarIndex, color, largeScreen) {
    List<Widget> _barItems = [];
    for (int i = 0; i < barItems.length; i++) {
      BarItem item = barItems[i];
      bool isSelected = tabIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          selectedBarIndex.value = i;
          onBarTap(selectedBarIndex.value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: <Widget>[
              SizedBox(width: largeScreen ? 30 : 0),
              Container(
                child: SvgPicture.asset(
                  item.icon,
                  color: isSelected
                      ? colorPrimary
                      : color.state == 'dark'
                          ? Color(0xFFA7A9AC)
                          : tabIconColor,
                  width: isSelected ? item.focusSize : item.theSize,
                ),
              ),
              SizedBox(width: largeScreen ? 30 : 0),
            ],
          ),
        ),
      ));
    }
    return _barItems;
  }
}

class BarItem {
  late String text, iconPath, icon;
  late double focusSize, theSize;
  BarItem(
      {required this.focusSize,
      required this.theSize,
      required this.text,
      required this.icon});
}
