import 'dart:convert';
import 'package:http/http.dart' as http;

class EarlyWarningService {
  // Use your computer's IP address instead of localhost
  final String apiUrl = "http://10.0.2.2:5000/predict_warning";  // Special Android emulator IP for localhost

  Future<String> getRiskLevel(double temperature, double humidity) async {
    try {
      print('Sending request to: $apiUrl');
      print('Data: temperature=$temperature, humidity=$humidity');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "temperature": temperature,
          "humidity": humidity,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['risk']; // Returns "Safe", "Medium Risk", or "High Risk"
      } else {
        throw Exception("Failed to get risk level. Status: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print('Error in getRiskLevel: $e');
      rethrow;
    }
  }
}