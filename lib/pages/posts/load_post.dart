import 'dart:convert';

import 'package:blogsquid/components/empty_error.dart';
import 'package:blogsquid/components/network_error.dart';
import 'package:blogsquid/config/app.dart';
import 'package:blogsquid/pages/post_detail.dart';
import 'package:blogsquid/utils/network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoadPost extends HookWidget {
  final int postid;
  const LoadPost({Key? key, required this.postid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = useState(true);
    final loadingError = useState(true);
    final post = useState({});
    void loadData() async {
      try {
        loading.value = true;
        loadingError.value = false;
        var response = await Network().simpleGet('/posts/$postid?_embed');
        var body = json.decode(response.body);
        loading.value = false;
        if (response.statusCode == 200) {
          post.value = body;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PostDetail(post: body),
            ),
          );
        } else {
          if (response.statusCode == 404) {
            Navigator.of(context).pop(context);
            Fluttertoast.showToast(
                msg: "Post not found",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: colorPrimary,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          loadingError.value = true;
        }
      } catch (e) {
        loading.value = false;
        loadingError.value = true;
        print(e);
      }
    }

    useEffect(() {
      loadData();
    }, const []);

    return Scaffold(
      body: loading.value && post.value['id'] == null
          ? Center(
              child: SpinKitFadingCube(
                color: colorPrimary,
                size: 30.0,
              ),
            )
          : loadingError.value && post.value['id'] == null
              ? Center(
                  child: NetworkError(
                      loadData: loadData, message: "Network error,"),
                )
              : Center(
                  child: EmptyError(
                      loadData: loadData, message: "Post not found,"),
                ),
    );
  }
}
