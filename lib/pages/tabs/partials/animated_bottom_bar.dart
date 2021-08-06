import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/providers.dart';
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
    return Material(
      elevation: 0,
      color:color.state == 'dark' ? primaryDark :  Colors.white,
      child: Container(
        // margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
        decoration: BoxDecoration(
          color: color.state == 'dark' ? Color(0xFF000205) : tabBgColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildBarItems(selectedBarIndex, color),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems(selectedBarIndex, color) {
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
              Container(
                child: SvgPicture.asset(
                  item.icon,
                  color: isSelected ? colorPrimary : color.state == 'dark' ? Color(0xFF8D949F) :  tabIconColor,
                  width: isSelected ? item.focusSize : item.theSize,
                ),
              ),
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
