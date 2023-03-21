import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:passmate/poi.dart';
import 'dart:convert';

//const String baseUrl = 'https://b2b-passmate-dashboard.bubbleapps.io/version-test/api/1.1/obj/';
const String baseUrl = 'https://passmatetest1.azurewebsites.net/api/Attraction';

class BaseClient {
  var client = http.Client();

  //GET
  Future<dynamic> get(String api) async {
    var url = Uri.parse(baseUrl + api);
    String basicAuth =
    'Basic ' + base64.encode(utf8.encode('passmateapp:passmateapppass'));
    print(basicAuth);

    var response = await http.get(Uri.parse(baseUrl),
    headers: {HttpHeaders.authorizationHeader: basicAuth, HttpHeaders.acceptHeader: 'application/json'});
    // print(r.statusCode);
    // print(r.body);
    // var response = await client.get(url);
    if(response.statusCode == 200) {
      return response.body;
    }
    else {
      print(response.statusCode);
    }
  }
}

// main() async {
//   String username = 'test';
//   String password = '123£';
//   String basicAuth =
//       'Basic ' + base64.encode(utf8.encode('$username:$password'));
//   print(basicAuth);
    
//   Response r = await get(Uri.parse('https://api.somewhere.io'),
//       headers: <String, String>{'authorization': basicAuth});
//   print(r.statusCode);
//   print(r.body);
// }