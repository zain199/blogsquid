import 'package:blogsquid/config/app.dart';
import 'package:http/http.dart' as http;

class Network {
  var token;
  var param = "/wp-json/wp/v2";

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
