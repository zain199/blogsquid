import 'package:blogsquid/config/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkError extends StatefulWidget {
  final Function loadData;
  final String message;

  const NetworkError({Key? key, required this.loadData, required this.message})
      : super(key: key);
  @override
  _NetworkErrorState createState() => _NetworkErrorState();
}

class _NetworkErrorState extends State<NetworkError> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconsPath + 'status-offline.svg',
            height: 60,
            color: Colors.black38,
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${widget.message}",
                  style: TextStyle(
                      fontSize: 14,
                      color: primaryText,
                      fontWeight: FontWeight.w400)),
              SizedBox(
                width: 5,
              ),
              InkWell(
                onTap: () => widget.loadData(),
                child: Text("Tap to retry",
                    style:
                        TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
