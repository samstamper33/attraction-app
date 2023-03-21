import 'package:passmate/poi.dart';
import 'package:http/http.dart' as http;

class RemoteService 
{
  Future<PointOfInterest?> getPoints () async {
    var client = http.Client();

    var uri = Uri.parse('https://b2b-passmate-dashboard.bubbleapps.io/version-test/api/1.1/obj/pointofinterest?constraints=[{"key": "attraction","constraint_type":"equals","value":"1670473174572x726748375602430000"}]');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return pointOfInterestFromJson(json);
    }
  }
}