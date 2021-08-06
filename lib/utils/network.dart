import 'dart:convert';
import 'package:blogsquid/config/app.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Network {
  var token;
  var param = "/wp-json/wp/v2";

  _getToken() async {
    var box = await Hive.openBox('appBox');
    token = jsonDecode(box.get('token'))['token'];
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

  simpleGet(apiUrl) async {
    var fullUrl = appDomain + param + apiUrl;
    return await http.get(Uri.parse(fullUrl));
  }

  simplePost(apiUrl, formdata) async {
    var fullUrl = appDomain + param + apiUrl;
    return await http.post(
      Uri.parse(fullUrl),
      body: formdata,
    );
  }
}
