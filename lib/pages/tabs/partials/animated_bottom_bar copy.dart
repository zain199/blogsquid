import 'package:blogsquid/config/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedBottomBarBackup extends StatefulWidget {
  final List<BarItem> barItems;
  final Duration animationDuration;
  final Function onBarTap;
  final int tabIndex;
  const AnimatedBottomBarBackup(
      {Key? key,
      required this.barItems,
      this.animationDuration = const Duration(milliseconds: 500),
      required this.onBarTap,
      required this.tabIndex})
      : super(key: key);
  @override
  _AnimatedBottomBarBackupState createState() => _AnimatedBottomBarBackupState();
}

class _AnimatedBottomBarBackupState extends State<AnimatedBottomBarBackup>
    with TickerProviderStateMixin {
  int selectedBarIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.white,
      child: Container(
       // margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        padding: EdgeInsets.only(left: 20, right: 20, top:10, bottom: 15),
        decoration: BoxDecoration(
          color: tabBgColor,
          // boxShadow: [
          //   BoxShadow(
          //     color: colorPrimary,
          //     offset: Offset(0, 0),
          //     blurRadius: 1,
          //   ),
          // ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildBarItems(),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    List<Widget> _barItems = [];
    for (int i = 0; i < widget.barItems.length; i++) {
      BarItem item = widget.barItems[i];
      bool isSelected = widget.tabIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectedBarIndex = i;
          });
          widget.onBarTap(selectedBarIndex);
        },
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          duration: widget.animationDuration,
          
          child: Row(
            children: <Widget>[
              // SvgPicture.asset(
              //   item.iconPath,
              //   width: isSelected ? 25 : 20,
              //   color: isSelected ? item.color : Colors.black,
              // ),
              Container(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  vsync: this,
                  curve: Curves.easeInOut,
                  child: SvgPicture.asset(
                    item.icon,
                    color: isSelected ? colorPrimary : tabIconColor,
                    width: isSelected ? item.focusSize : item.theSize,
                    
                  ),
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
