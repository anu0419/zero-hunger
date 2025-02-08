import 'package:flutter/material.dart';

class RetailerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Retailer Dashboard")),
      body: Center(child: Text("Welcome, Retailer! Here you can manage sales and contracts.")),
    );
  }
}
