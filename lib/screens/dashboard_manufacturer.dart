import 'package:flutter/material.dart';
import 'package:zerohungerr/screens/contract_overview_screen.dart';
import 'package:zerohungerr/screens/map_screen.dart';

class ManufacturerDashboard extends StatelessWidget {
  final String manufacturerId;

  ManufacturerDashboard({required this.manufacturerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manufacturer Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("View Contracts"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContractsOverviewScreen(userId: manufacturerId, userRole: "Manufacturer")),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
              child: Text("Open Map"),
            ),
          ],
        ),
      ),
    );
  }
}
