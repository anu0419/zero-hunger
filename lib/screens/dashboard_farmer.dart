import 'package:flutter/material.dart';

class FarmerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Farmer Dashboard")),
      body: Center(child: Text("Welcome, Farmer! Here you can manage your crops and contracts.")),
    );
  }
}
