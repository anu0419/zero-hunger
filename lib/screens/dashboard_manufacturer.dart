import 'package:flutter/material.dart';

class ManufacturerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manufacturer Dashboard")),
      body: Center(child: Text("Welcome, Manufacturer! Here you can manage production and contracts.")),
    );
  }
}
