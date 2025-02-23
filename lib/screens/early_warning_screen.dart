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
  bool _isLoading = false;

  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();

  void _checkRisk() async {
    if (_tempController.text.isEmpty || _humidityController.text.isEmpty) {
      setState(() {
        _riskMessage = "Please enter both temperature and humidity";
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

      String risk = await _warningService.getRiskLevel(temperature, humidity);

      setState(() {
        _riskMessage = "Risk Level: $risk";
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
              decoration: InputDecoration(
                labelText: "Temperature (°C)",
                hintText: "Enter temperature",
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _humidityController,
              decoration: InputDecoration(
                labelText: "Humidity (%)",
                hintText: "Enter humidity",
              ),
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
          ],
        ),
      ),
    );
  }
}