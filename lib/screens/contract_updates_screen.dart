import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractUpdatesScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contract Updates")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('contracts') // Ensure this is the correct path
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var contracts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              var contract = contracts[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text("Contract ID: ${contract.id}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${contract['status']}"),
                      Text(contract['timestamp'] != null
                          ? "Last Updated: ${contract['timestamp'].toDate()}"
                          : "No Timestamp"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
