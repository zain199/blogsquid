import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/utils/Providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowPage extends HookWidget {
  final Map page;
  const ShowPage({Key? key, required this.page}) : super(key: key);

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    return Scaffold(
      body: Container(
        color: color.state == 'dark' ? primaryDark : primaryBg,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 50, bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      iconsPath + "arrow-left.svg",
                      color: color.state == 'dark'
                          ? Color(0xFFE9E9E9)
                          : Color(0xFF282828),
                      width: 20,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                            page['title']['rendered']
                                .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: color.state == 'dark'
                                    ? Color(0xFFE9E9E9)
                                    : Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Html(
                      data: page['content']['rendered'],
                      style: {
                        "html": Style(
                            lineHeight: LineHeight.em(1.6),
                            fontSize: FontSize.large,
                            color: color.state == 'dark'
                                ? Color(0xFFA7A9AC)
                                : Color(0xFF464646)),
                        "body": Style(margin: EdgeInsets.zero),
                        "a": Style(color: colorPrimary),
                      },
                      customImageRenders: {
                        networkSourceMatcher(domains: ["flutter.dev"]):
                            (context, attributes, element) {
                          return Image.asset(
                              'assets/images/placeholder-' +
                                  color.state +
                                  '.png',
                              width: 200);
                        },
                        networkSourceMatcher(domains: ["mydomain.com"]):
                            networkImageRender(
                          headers: {"Custom-Header": "some-value"},
                          altWidget: (alt) => Text(alt ?? ""),
                          loadingWidget: () => Text("Loading..."),
                        ),
                        // On relative paths starting with /wiki, prefix with a base url
                        (attr, _) =>
                                attr["src"] != null &&
                                attr["src"]!.startsWith("/wiki"):
                            networkImageRender(
                                mapUrl: (url) =>
                                    "https://upload.wikimedia.org" + url!),
                        // Custom placeholder image for broken links
                        networkSourceMatcher(): networkImageRender(
                            altWidget: (_) => Image.asset(
                                  'assets/images/placeholder-' +
                                      color.state +
                                      '.png',
                                  width: 200,
                                )),
                      },
                      onLinkTap: (url, _, __, ___) {
                        print("Opening $url...");
                        _launchURL(url);
                      },
                      onImageTap: (src, _, __, ___) {
                        print(src);
                      },
                      onImageError: (exception, stackTrace) {
                        print(exception);
                      },
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
