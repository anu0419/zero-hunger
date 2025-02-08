import 'package:flutter/material.dart';

class DistributorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Distributor Dashboard")),
      body: Center(child: Text("Welcome, Distributor! Here you can track shipments and contracts.")),
    );
  }
}
