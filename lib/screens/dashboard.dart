import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Supply Chain Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Farmer Dashboard")),
            ElevatedButton(onPressed: () {}, child: Text("Manufacturer Dashboard")),
            ElevatedButton(onPressed: () {}, child: Text("Distributor Dashboard")),
            ElevatedButton(onPressed: () {}, child: Text("Retailer Dashboard")),
          ],
        ),
      ),
    );
  }
}
