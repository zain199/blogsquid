import 'dart:convert';

import 'package:blogsquid/config/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class Network {
  var token;
  var param = "/wp-json/wp/v2";

  simpleGetToken(apiUrl, tkn) async {
    var fullUrl = "$appDomain$param/$apiUrl";
    return await http
        .get(Uri.parse(fullUrl), headers: {"Authorization": "Bearer " + tkn});
  }

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

  postAuth(formData) async {
    var fullUrl = appDomain + "/wp-json/jwt-auth/v1/token";
    return await http.post(
      Uri.parse(fullUrl),
      body: formData,
    );
  }

  validateToken() async {
    var fullUrl = appDomain + "/wp-json/jwt-auth/v1/token/validate";
    var box = await Hive.openBox('appBox');
    if (box.get('token') != null) {
      if (box.get('token').length > 0) {
        String token = box.get('token');
        var response = await http.post(Uri.parse(fullUrl),
            body: {}, headers: {"Authorization": "Bearer " + token});
        var body = json.decode(response.body);
        if (body['data']?['status'] == 403) {
          return false;
        } else {
          return true;
        }
      }
      return true;
    }
    return true;
  }
}
