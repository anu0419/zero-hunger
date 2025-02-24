import 'package:flutter/material.dart';
import '../services/early_warning_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EarlyWarningScreen extends StatefulWidget {
  @override
  _EarlyWarningScreenState createState() => _EarlyWarningScreenState();
}

class _EarlyWarningScreenState extends State<EarlyWarningScreen> {
  final _warningService = EarlyWarningService();
  String _riskMessage = "Enter data to check risk level";
  String _weatherAlert = "No alerts";
  bool _isLoading = false;

  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  void _checkRisk() async {
    if (_tempController.text.isEmpty || _humidityController.text.isEmpty || _latController.text.isEmpty || _lonController.text.isEmpty) {
      setState(() {
        _riskMessage = "Please enter all required data";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _riskMessage = "Checking risk level...";
    });

    try {
      double temperature = double.parse(_tempController.text);
      double humidity = double.parse(_humidityController.text);
      double latitude = double.parse(_latController.text);
      double longitude = double.parse(_lonController.text);

      var result = await _warningService.getRiskLevel(temperature, humidity, latitude, longitude);

      setState(() {
        _riskMessage = "Risk Level: ${result['risk'] ?? 'Unknown'}";
        _weatherAlert = result['weather_alert'] ?? "No weather alerts";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _riskMessage = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Early Warning System")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _tempController,
              decoration: InputDecoration(labelText: "Temperature (°C)", hintText: "Enter temperature"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _humidityController,
              decoration: InputDecoration(labelText: "Humidity (%)", hintText: "Enter humidity"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _latController,
              decoration: InputDecoration(labelText: "Latitude", hintText: "Enter latitude"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lonController,
              decoration: InputDecoration(labelText: "Longitude", hintText: "Enter longitude"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkRisk,
              child: _isLoading 
                ? CircularProgressIndicator()
                : Text("Check Risk Level"),
            ),
            SizedBox(height: 20),
            Text(
              _riskMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _riskMessage.contains("Error") ? Colors.red : Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "🌍 $_weatherAlert",
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
