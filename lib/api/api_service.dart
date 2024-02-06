import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> getDistance(String origin, String destination) async {
    String apiKey = "AIzaSyB3xRNPEnGd3-lBQ0V6MnlQJ6_qLW_EM2Y";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey";

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      String distance = data['routes'][0]['legs'][0]['distance']['text'];
      return distance;
    } else {
      throw Exception('Failed to load distance');
    }
  }

  double calculateFuel(double fuelConsumption, double distance) {
    double fuelRequired = fuelConsumption * distance;

    return fuelRequired;
  }
}
