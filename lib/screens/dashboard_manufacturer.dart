import 'package:flutter/material.dart';
import 'package:zerohungerr/screens/contract_overview_screen.dart';

class ManufacturerDashboard extends StatelessWidget {
  final String manufacturerId;

  ManufacturerDashboard({required this.manufacturerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manufacturer Dashboard")),
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
          ],
        ),
      ),
    );
  }
}
