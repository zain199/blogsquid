import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'components/form/botton_widget.dart';
import 'package:lottie/lottie.dart';
import 'pages/dashboard.dart';

class Onboarding extends HookWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CarouselController _controller = CarouselController();
    final _current = useState(0);
    List images = [
      {
        "title": "Read from anywhere",
        "body":
            "We provide access to premium news to be enjoyed from the comfort of your home.",
        "url": "Blogging"
      },
      {
        "title": "Get Connected",
        "body":
            "We provide access to premium news to be enjoyed from the comfort of your home.",
        "url": "Growth Animation"
      },
      {
        "title": "Stay in touch with the world",
        "body":
            "We provide access to premium news to be enjoyed from the comfort of your home.",
        "url": "Chating using apps Colour"
      }
    ];

    startShopping() async {
      var box = await Hive.openBox('appBox');
      box.put('boarded', 'yes');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Dashboard()),
          (Route<dynamic> route) => false);
    }

    final List<Widget> imageSliders = images
        .map((each) => Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    bottom: 100,
                    child: Lottie.asset('assets/lotties/${each['url']}.json'),
                  ),
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: 200,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${each['title']}",
                            style: TextStyle(
                              color: Color(0xFF282828),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '${each['body']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ))
        .toList();
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  items: imageSliders,
                  carouselController: _controller,
                  options: CarouselOptions(
                      autoPlay: true,
                      height: MediaQuery.of(context).size.height,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        _current.value = index;
                      }),
                ),
                Positioned(
                  bottom: 40,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: images.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: Container(
                                width:
                                    _current.value == entry.key ? 30.0 : 12.0,
                                height: 12.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _current.value == entry.key
                                            ? Color(0xFFEC615B)
                                            : Color(0xFFBDBDBD),
                                        width: 1.5),
                                    //shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(6),
                                    color: _current.value == entry.key
                                        ? Color(0xFFEC615B)
                                        : Colors.transparent),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ButtonWidget(
                              action: () => startShopping(),
                              text: "Continue",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
