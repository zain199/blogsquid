import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jiffy/jiffy.dart';

import '../post_detail.dart';

class EachPost extends HookWidget {
  final Color background;
  final Map post;
  EachPost({
    Key? key,
    this.background = eachPostBg,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataMode = useProvider(dataSavingModeProvider);
    final color = useProvider(colorProvider);

    print('hello omar'+post.toString());
    return InkWell(
      onTap: () => {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostDetail(post: post)))
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        margin: EdgeInsets.only(bottom: 25, left: 10, right: 10),
        decoration: BoxDecoration(
            color:
                color.state == 'dark' ? Color(0xFF282828) : Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: post['title']['rendered']
                  .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
              child: Container(
                width: 118,
                height: 142,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: dataMode.state
                          ? Image.asset('assets/images/placeholder-' +
                                  color.state +
                                  '.png')
                              .image
                          : post["_embedded"]["wp:featuredmedia"] != null
                              ? Image.network(post["_embedded"]
                                      ["wp:featuredmedia"][0]["source_url"])
                                  .image
                              : Image.asset('assets/images/placeholder-' +
                                      color.state +
                                      '.png')
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
                      maxLines: 2,
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
                              ? Color(0xFFA19E9C)
                              : primaryText,
                          height: 1.3),
                    ),
                    SizedBox(height: 10),
                    Text(
                      Jiffy(post['date'], "yyyy-MM-dd").fromNow(),
                      style: TextStyle(
                          color: colorPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
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
