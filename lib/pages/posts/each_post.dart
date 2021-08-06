import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:jiffy/jiffy.dart';

import '../post_detail.dart';

class EachPost extends HookWidget {
  final Color background;
  final Map post;
  const EachPost({
    Key? key,
    this.background = eachPostBg,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return InkWell(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostDetail(post: post)))
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        color: background,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: post['title']['rendered']
                  .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
              child: Container(
                width: 118,
                height: 121,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.network(post["_embedded"]["wp:featuredmedia"]
                              [0]["source_url"])
                          .image,
                    )),
              ),
            ),
            SizedBox(width: 18),
            Container(
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title']['rendered']
                          .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                    ),
                    SizedBox(height: 12),
                    Text(
                      post['excerpt']['rendered']
                          .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: TextStyle(
                          color: color.state == 'dark'
                              ? Color(0xFF8D949F)
                              : primaryText,
                          height: 1.3),
                    ),
                    SizedBox(height: 10),
                    Text(
                      Jiffy(post['date'], "yyyy-MM-dd").fromNow(),
                      style: TextStyle(color:color.state == 'dark'
                              ? Color(0xFF525B69)
                              :  Colors.black, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
